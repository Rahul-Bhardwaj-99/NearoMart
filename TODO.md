You are working on an existing full-stack application with:

* Frontend: Flutter/Dart
* Backend: Node.js/Express
* Database: MongoDB/Mongoose
* Authentication: existing authentication system
* The application has at least two important roles:

    * Buyer
    * Shopkeeper/Seller

I need you to inspect the EXISTING project completely before making changes.

The main issue we need to solve is:

A user is logged in as a BUYER, but some API responses are currently loading data belonging to other users/shopkeepers. The response may contain private profile information, personal details, bank/payment information, account-related fields, IDs, or other sensitive seller information.

This is a DATA ACCESS / API DESIGN problem, not merely a Flutter UI problem.

DO NOT solve this by simply hiding fields in Flutter.

The backend must never send unauthorized/private data to the buyer unless that data is explicitly required and intended to be publicly visible.

==================================================

1. FIRST: AUDIT THE EXISTING PROJECT
   ==================================================

Before modifying code:

1. Inspect the Flutter project structure.
2. Inspect all API service/repository classes.
3. Inspect all ViewModels/controllers/providers/blocs used for Buyer screens.
4. Inspect Node.js/Express routes.
5. Inspect authentication middleware.
6. Inspect authorization/role middleware.
7. Inspect MongoDB/Mongoose schemas/models.
8. Inspect all queries that fetch:

    * users
    * buyers
    * shopkeepers
    * shops
    * profiles
    * bank details
    * payment details
    * KYC/verification data
    * addresses
    * orders
    * products
    * transactions
    * seller information
9. Identify which API request is returning unnecessary data.
10. Identify exactly why the Buyer is receiving another user's/shopkeeper's data.
11. Check whether the problem is caused by:

* missing role validation
* missing ownership validation
* querying all users instead of the current user
* populate()
* aggregation
* returning complete MongoDB documents
* missing field projection
* incorrect API endpoint
* incorrect frontend API call
* incorrect cached state
* incorrect response mapping
* another issue

DO NOT guess.

Trace the complete flow:

Flutter screen
→ Flutter API call
→ HTTP request
→ authentication middleware
→ authorization middleware
→ controller
→ service
→ MongoDB query
→ populate/aggregation
→ response
→ Flutter model
→ UI

Document the actual problematic flow before fixing it.

==================================================
2. CORE SECURITY REQUIREMENT
   ============================

The backend must follow this rule:

AUTHENTICATED DOES NOT MEAN AUTHORIZED.

A Buyer being logged in does NOT give the Buyer permission to receive every user's data.

For every API:

1. Identify the authenticated user from the token/session.
2. Identify their role.
3. Determine what resource they are requesting.
4. Check whether they are authorized to access that resource.
5. Query only the required records.
6. Return only fields that are allowed for that role and use case.

Never return complete MongoDB documents directly to the client.

BAD:

const user = await User.findById(req.user.id);
res.json(user);

or:

const users = await User.find({});
res.json(users);

or:

const shop = await Shop.findById(id).populate('owner');

if this causes private owner information to be serialized automatically.

Instead, use explicit projections / DTOs / serializers.

==================================================
3. BUYER DATA ISOLATION
   =======================

When the logged-in user is a Buyer:

The Buyer should only receive:

A. Their own private information where required.

B. Public information of shops/shopkeepers that is genuinely required for marketplace functionality.

C. Product information required to browse products.

D. Order information belonging to the authenticated Buyer.

E. Other information that the Buyer is legitimately authorized to access.

The Buyer must NOT receive private data belonging to another Buyer or Shopkeeper.

Examples of information that must NOT be exposed to a Buyer unless there is a very specific authorized business requirement:

* bank account number
* bank account details
* IFSC
* UPI/private payment identifiers
* payout information
* KYC documents
* Aadhaar/PAN or similar identity information
* private personal profile fields
* private phone number
* private email where not intended to be public
* authentication information
* password/password hash
* OTP information
* refresh tokens/access tokens
* internal MongoDB fields
* security fields
* private addresses
* internal notes
* admin-only fields
* seller financial information
* seller verification/internal information
* private user metadata
* other users' private information

IMPORTANT:

Do not assume that because a field exists in MongoDB it should be returned through the API.

Database schema ≠ API response schema.

==================================================
4. PUBLIC SHOPKEEPER INFORMATION
   ================================

A Buyer may legitimately need some Shopkeeper/Shop information for marketplace functionality.

Create a clear distinction between:

PRIVATE SELLER DATA

and

PUBLIC SHOP/SELLER DATA.

For example, public marketplace data may include only what the business actually needs, such as:

* shop name
* shop logo/image
* shop description
* public shop location/address if intentionally public
* business category
* public rating
* public product information
* public shop timing
* other explicitly public fields

Do NOT expose the Shopkeeper's complete User document.

If Shopkeeper information is populated using Mongoose populate(), explicitly select only the safe public fields.

Example concept:

populate({
path: 'owner',
select: 'shopName shopLogo category publicLocation'
})

Do NOT populate sensitive seller fields unnecessarily.

==================================================
5. ROLE-BASED API RESPONSE DESIGN
   =================================

Implement proper role-based response handling.

At minimum:

BUYER

* Can access own buyer information.
* Can browse public shops.
* Can browse public products.
* Can access own orders.
* Cannot access another user's private information.
* Cannot access seller bank/payment/KYC/private data.

SHOPKEEPER

* Can access their own shop/business information.
* Can access their own seller/private information where required.
* Can manage their own products/shop/orders.
* Cannot access another seller's private data unless explicitly authorized.

ADMIN

* Can have broader access according to the existing business rules.
* Do not weaken existing admin functionality.

Do not break existing role functionality.

==================================================
6. API RESPONSE DTO / SERIALIZATION
   ===================================

Introduce a clean response layer if the existing project does not already have one.

Do not return raw Mongoose documents.

Use explicit DTOs/serializers such as:

BuyerResponse
PublicShopResponse
PublicSellerResponse
ProductResponse
OrderResponse
PrivateSellerResponse
AdminUserResponse

Each response object should explicitly define which fields can leave the backend.

Example concept:

{
"id": "...",
"shopName": "...",
"shopImage": "...",
"category": "...",
"publicAddress": "..."
}

instead of:

{
"...every MongoDB field..."
}

The principle should be:

ALLOWLIST fields.

Do NOT use a blacklist such as:

remove bankAccount
remove password
remove kyc

because new sensitive fields could accidentally become exposed later.

==================================================
7. MONGODB QUERY DESIGN
   =======================

Inspect all MongoDB queries involved in the affected screens.

Avoid:

User.find({})
User.findById(...)
without projection
Shop.find(...)
with full populated user documents

Use explicit field selection.

For example:

User.findById(userId).select(
'_id name profileImage'
)

or an equivalent projection/DTO approach.

For public shop data:

Shop.find(...)
.select(
'_id name logo description category publicLocation'
)

If owner information is required, populate only explicitly approved public fields.

Also inspect aggregation pipelines.

If an aggregation returns:

{
user: "$user",
owner: "$owner"
}

or similar full nested documents, replace it with explicit field selection.

==================================================
8. AUTHORIZATION MUST BE DONE ON THE BACKEND
   ============================================

Do not trust:

* userId from Flutter request body
* role from Flutter request body
* hidden frontend fields
* query parameters alone

The backend must derive the authenticated identity from the authenticated token/session.

For example:

req.user.id
req.user.role

Then perform authorization.

If an endpoint is:

GET /users/:id

the backend must verify whether the authenticated user is allowed to access that :id.

A Buyer must not be able to change:

/users/shopkeeperId

and retrieve that shopkeeper's private data.

Likewise, if an endpoint is:

GET /shops/:shopId

the backend should return the public shop representation, not the complete owner account.

==================================================
9. FRONTEND ARCHITECTURE
   ========================

After securing the backend, update Flutter according to the actual API contracts.

Do NOT make Flutter depend on private fields that should no longer exist.

Create/use separate models where appropriate.

For example:

BuyerModel
PublicShopModel
PublicSellerModel
ProductModel
OrderModel

Do not use one giant UserModel for every screen if it causes private fields to be mapped everywhere.

The UI should consume only the data required by that screen.

Example:

Shop Details screen should use:

PublicShopModel

not:

CompleteUserModel

This makes the frontend safer and easier to maintain.

==================================================
10. FRONTEND UX
    ===============

Design the Buyer frontend according to the actual business role.

Buyer-facing screens should display:

* Buyer profile
* Buyer-specific information
* Public shop information
* Products
* Orders
* Cart
* Relevant marketplace information

Do not display:

* seller bank details
* seller private profile information
* seller KYC
* seller financial information
* internal account information
* unrelated users

If some API response currently contains these fields, do not render them and, more importantly, fix the backend so those fields are no longer transmitted.

==================================================
11. API ENDPOINT REVIEW
    =======================

Audit every endpoint used by Buyer screens.

For every endpoint, create a table/documentation internally containing:

Endpoint
HTTP method
Authenticated?
Allowed roles
Resource owner
MongoDB query
Returned fields
Sensitive fields
Potential authorization issue

For example:

GET /api/shops

Allowed:
Buyer, Shopkeeper, Admin

Buyer response:
Only public shop information.

GET /api/profile

Allowed:
Authenticated user

Response:
Only the authenticated user's allowed profile information.

GET /api/orders

Buyer:
Only orders belonging to req.user.id.

Shopkeeper:
Only orders belonging to their own shop where business rules allow.

Admin:
According to admin authorization rules.

Do not allow a Buyer to retrieve arbitrary users' records.

==================================================
12. CURRENT PROBLEM MUST BE TRACED TO THE ROOT
    ==============================================

The current issue appears to be that the Buyer is logged in but the API/network logs are showing other users/shopkeepers' information.

Do NOT simply say:

"Frontend filtering is working."

That is not enough.

The final secure state should be:

Buyer request
→ Authenticated Buyer identified
→ Role checked
→ Ownership/access checked
→ MongoDB returns only necessary records
→ Sensitive fields excluded
→ API returns sanitized DTO
→ Flutter maps only required public/user data
→ UI displays only authorized information

==================================================
13. SECURITY TESTING
    ====================

After implementation, test the following cases.

TEST 1:
Login as Buyer A.

Request Buyer A profile.

Expected:
Only Buyer A's authorized data.

TEST 2:
While logged in as Buyer A, attempt to request Buyer B's private profile.

Expected:
403 Forbidden or appropriate authorization response.

TEST 3:
While logged in as Buyer A, attempt to request Shopkeeper B's private profile.

Expected:
403 Forbidden or only the explicitly public representation if the endpoint is specifically designed for public shop data.

TEST 4:
Buyer requests shop details.

Expected:
Only public shop information.

Must NOT contain:
bank information
KYC
private owner information
internal fields
authentication/security fields.

TEST 5:
Buyer requests products.

Expected:
Only product/shop information necessary for browsing.

TEST 6:
Buyer requests orders.

Expected:
Only orders belonging to authenticated Buyer A.

TEST 7:
Change IDs manually in Postman.

Expected:
Authorization must still prevent unauthorized access.

TEST 8:
Inspect the raw network response.

Expected:
Sensitive seller/user fields must not be present at all.

This is extremely important.

Do not consider the issue fixed merely because Flutter does not display the fields.

==================================================
14. POSTMAN/API TESTING
    =======================

After implementation, provide example Postman requests for:

1. Buyer login
2. Buyer profile
3. Public shop list
4. Public shop details
5. Products
6. Buyer orders
7. Unauthorized user access attempt
8. Unauthorized shopkeeper data access attempt

For each request show:

Method
URL
Authorization
Expected status
Expected response structure

For unauthorized requests, demonstrate the expected 401/403 behavior according to the existing authentication architecture.

==================================================
15. DO NOT BREAK EXISTING FUNCTIONALITY
    =======================================

Before changing anything:

Understand the current architecture.

Do not rewrite the entire application.

Do not replace existing authentication unless necessary.

Do not replace MongoDB models unnecessarily.

Do not remove fields from the database simply because they should not be exposed through an API.

The database may legitimately need private fields.

The important separation is:

DATABASE
↓
SERVICE / QUERY
↓
AUTHORIZATION
↓
DTO / SERIALIZER
↓
API RESPONSE
↓
FLUTTER MODEL
↓
UI

Private database fields can remain in MongoDB while being excluded from API responses.

==================================================
16. IMPORTANT FRONTEND + BACKEND RULE
    =====================================

Remember this rule throughout the implementation:

FRONTEND SECURITY IS NOT REAL SECURITY.

This is NOT sufficient:

Backend sends:

{
name,
email,
bankAccount,
ifsc,
kyc,
phone
}

Flutter then hides:

bankAccount
ifsc
kyc

That is still a security/data exposure problem.

Correct implementation:

Backend never sends:

bankAccount
ifsc
kyc

to a Buyer in the first place.

==================================================
17. LOGGING
    ===========

Inspect the existing API/network logs.

Do not log sensitive information unnecessarily.

Do not print:

* passwords
* OTPs
* access tokens
* refresh tokens
* bank details
* KYC data
* complete user documents
* private financial information

If debug logging currently prints complete API responses, sanitize those logs as well.

==================================================
18. IMPLEMENTATION PROCESS
    ==========================

Follow this exact order:

PHASE 1 — AUDIT

Inspect the existing frontend/backend/database.

Find the exact API causing the data exposure.

Explain the root cause.

PHASE 2 — API CONTRACT

Define what the Buyer should receive.

Define what the Shopkeeper should receive.

Define what is public and what is private.

PHASE 3 — BACKEND SECURITY

Implement:

* authentication verification
* role-based authorization
* ownership checks
* MongoDB projections
* explicit DTOs/serializers
* safe populate()
* sanitized API responses

PHASE 4 — FLUTTER

Update:

* API models
* repositories/services
* ViewModels/providers/controllers
* screens
* state management

so the frontend uses the new safe API contracts.

PHASE 5 — TESTING

Test:

* Buyer → own data
* Buyer → another Buyer
* Buyer → Shopkeeper private data
* Buyer → public Shop
* Buyer → products
* Buyer → own orders
* Shopkeeper → own data
* Shopkeeper → another seller
* Admin → permitted data

PHASE 6 — FINAL REVIEW

Search the entire project for:

* User.find
* findById
* findOne
* populate
* aggregate
* res.json
* res.send
* UserModel
* userId
* owner
* seller
* shopkeeper
* bank
* account
* ifsc
* kyc
* payment
* profile

Check whether any endpoint can still accidentally expose private information.

==================================================
19. IMPORTANT: DO NOT BLINDLY MODIFY
    ====================================

Do not start changing files immediately.

First inspect and understand the existing code.

Then provide me with:

1. Exact root cause.
2. Exact affected API endpoint(s).
3. Exact backend file(s) that need modification.
4. Exact Flutter file(s) that need modification.
5. Current response vs required response.
6. Security risk.
7. Proposed architecture.
8. Implementation plan.

After the analysis, implement the required changes carefully.

If there are multiple possible solutions, prefer the smallest secure change that fits the existing architecture rather than rewriting working modules.

==================================================
20. FINAL ACCEPTANCE CRITERIA
    =============================

The task is considered COMPLETE only when:

[ ] Buyer cannot receive another user's private data.
[ ] Buyer cannot receive Shopkeeper bank/payment/KYC/private data.
[ ] Backend performs role-based authorization.
[ ] Backend performs ownership checks where required.
[ ] MongoDB queries use appropriate projections.
[ ] Raw MongoDB documents are not blindly returned.
[ ] Public shop data is separated from private seller data.
[ ] Flutter models match the safe API contracts.
[ ] Flutter does not depend on sensitive fields.
[ ] Raw API/network response contains no unauthorized sensitive data.
[ ] Postman tests confirm unauthorized access is blocked.
[ ] Existing Buyer functionality still works.
[ ] Existing Shopkeeper functionality still works.
[ ] Existing Admin functionality is not unnecessarily broken.
[ ] Sensitive information is not printed in logs.
[ ] No unnecessary database fields are deleted.
[ ] No unrelated functionality is changed.

MOST IMPORTANT:

Do not treat this as a UI filtering problem.

Treat it as a complete RBAC + authorization + data minimization + API response design problem.

The backend is the security boundary.

The final architecture must ensure that a Buyer receives only the minimum data required for the Buyer's actual functionality.
