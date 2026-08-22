const mongoose = require('mongoose');
const { S3Client, PutObjectCommand } = require('@aws-sdk/client-s3');
const { getSignedUrl } = require('@aws-sdk/s3-request-presigner');
const path = require('path');

const useGridFs = () => process.env.MEDIA_STORAGE !== 's3';

const validateUpload = (req, fileName, fileType, folder) => {
  if (!fileName || !fileType) return 'fileName and fileType are required';

  const allowedTypes = [
    'image/jpeg',
    'image/png',
    'image/webp',
    'audio/aac',
    'audio/m4a',
    'audio/mp4'
  ];
  if (!allowedTypes.includes(fileType)) return 'Unsupported file type';

  const allowedFolders = req.user.role === 'SHOPKEEPER' || req.user.role === 'ADMIN'
    ? ['chat', 'profiles', 'products', 'shops', 'specials']
    : ['chat', 'profiles'];
  if (!allowedFolders.includes(folder)) return 'You are not authorized to upload to this folder';

  return null;
};

const safeName = (fileName) => {
  const name = path.basename(fileName).replace(/[^a-zA-Z0-9._-]/g, '_');
  return name && name !== '.' && name !== '..' ? name : null;
};

const getBucket = () => {
  if (!mongoose.connection.db) throw new Error('Database is not connected');
  return new mongoose.mongo.GridFSBucket(mongoose.connection.db, { bucketName: 'media' });
};

exports.getPresignedUrl = async (req, res) => {
  try {
    const { fileName, fileType, folder = 'chat' } = req.body;
    const validationError = validateUpload(req, fileName, fileType, folder);
    if (validationError) return res.status(400).json({ message: validationError });

    const safeFileName = safeName(fileName);
    if (!safeFileName) return res.status(400).json({ message: 'Invalid file name' });

    if (useGridFs()) {
      return res.status(200).json({
        storage: 'gridfs',
        uploadUrl: '/api/uploads/files',
        fileType,
        folder,
        fileName: safeFileName
      });
    }

    const s3Client = new S3Client({
      region: process.env.AWS_REGION,
      credentials: {
        accessKeyId: process.env.AWS_ACCESS_KEY,
        secretAccessKey: process.env.AWS_SECRET_KEY,
      },
    });

    const key = `${folder}/${req.user.id}/${Date.now()}_${safeFileName}`;
    const command = new PutObjectCommand({
      Bucket: process.env.S3_BUCKET_NAME,
      Key: key,
      ContentType: fileType,
    });

    const url = await getSignedUrl(s3Client, command, { expiresIn: 3600 });

    res.status(200).json({
      uploadUrl: url,
      fileUrl: `https://${process.env.S3_BUCKET_NAME}.s3.${process.env.AWS_REGION}.amazonaws.com/${key}`,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.uploadToGridFs = async (req, res) => {
  try {
    const { fileName, fileType, folder = 'chat', data } = req.body;
    const validationError = validateUpload(req, fileName, fileType, folder);
    if (validationError) return res.status(400).json({ message: validationError });
    if (!data || typeof data !== 'string') {
      return res.status(400).json({ message: 'Base64 file data is required' });
    }

    const buffer = Buffer.from(data, 'base64');
    if (!buffer.length || buffer.length > 8 * 1024 * 1024) {
      return res.status(400).json({ message: 'File must be between 1 byte and 8 MB' });
    }

    const name = `${folder}/${req.user.id}/${Date.now()}_${safeName(fileName)}`;
    const bucket = getBucket();
    const uploadStream = bucket.openUploadStream(name, {
      contentType: fileType,
      metadata: { ownerId: req.user.id, folder }
    });

    uploadStream.end(buffer);
    uploadStream.on('finish', () => {
      res.status(201).json({
        storage: 'gridfs',
        fileId: uploadStream.id.toString(),
        fileUrl: `/api/uploads/files/${uploadStream.id}`
      });
    });
    uploadStream.on('error', (error) => {
      if (!res.headersSent) res.status(500).json({ message: error.message });
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getGridFsFile = async (req, res) => {
  try {
    const fileId = new mongoose.Types.ObjectId(req.params.id);
    const bucket = getBucket();
    const files = await bucket.find({ _id: fileId }).toArray();
    if (!files.length) return res.status(404).json({ message: 'File not found' });

    const file = files[0];
    const privateFolder = ['profiles', 'chat'].includes(file.metadata?.folder);
    if (privateFolder && (!req.user || file.metadata?.ownerId !== req.user.id)) {
      return res.status(403).json({ message: 'You are not authorized to access this file' });
    }

    res.set('Content-Type', file.contentType || 'application/octet-stream');
    bucket.openDownloadStream(fileId).pipe(res);
  } catch (error) {
    res.status(400).json({ message: 'Invalid file id' });
  }
};
