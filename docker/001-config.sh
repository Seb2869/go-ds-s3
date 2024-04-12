#!/bin/sh
set -ex

echo "IPFS Path: ${IPFS_PATH}"

# backup old config file
cp ${IPFS_PATH}/config ${IPFS_PATH}/config_bak

# inject the S3 plugin datastore
cat ${IPFS_PATH}/config_bak | \
jq ".Datastore.Spec = { 
    mounts: [
        {
          child: {
            type: \"s3ds\",
            region: \"${BUCKET_REGION}\",
            bucket: \"${BUCKET}\",
            rootDirectory: \"${CLUSTER_PEERNAME}\",
            accessKey: \"${BUCKET_ACCESS_KEY}\",
            secretKey: \"${BUCKET_SECRET_KEY}\",
            regionEndpoint: \"${BUCKET_ENDPOINT}\",
            keyTransform: \"${KEY_TRANSFORM}\"
          },
          mountpoint: \"/blocks\",
          prefix: \"s3.datastore\",
          type: \"measure\"
        },
        {
          child: {
            compression: \"none\",
            path: \"datastore\",
            type: \"levelds\"
          },
          mountpoint: \"/\",
          prefix: \"leveldb.datastore\",
          type: \"measure\"
        }
    ], 
    type: \"mount\"
}" > ${IPFS_PATH}/config

# override the ${IPFS_PATH}/datastore_spec file
echo "{\"mounts\":[{\"bucket\":\"${BUCKET}\",\"mountpoint\":\"/blocks\",\"region\":\"${BUCKET_REGION}\",\"rootDirectory\":\"${CLUSTER_PEERNAME}\"},{\"mountpoint\":\"/\",\"path\":\"datastore\",\"type\":\"levelds\"}],\"type\":\"mount\"}" > ${IPFS_PATH}/datastore_spec
