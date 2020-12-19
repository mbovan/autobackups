#!/bin/bash 

# Initalize variables from .env file
CLIENT_ID=$(grep CLIENT_ID .env | cut -d '=' -f2)
CLIENT_SECRET=$(grep CLIENT_SECRET .env | cut -d '=' -f2)
SUBJECT_ID=$(grep SUBJECT_ID .env | cut -d '=' -f2)
FOLDER_ID=$(grep FOLDER_ID .env | cut -d '=' -f2)
PROJECTS_ROOT=$(grep PROJECTS_ROOT .env | cut -d '=' -f2)
DOCROOT=$(grep DOCROOT .env | cut -d '=' -f2)
EXPORT_DIR=$(grep EXPORT_DIR .env | cut -d '=' -f2)

echo "-----------------------------------------------"
echo " Get a Box.com token "
echo "-----------------------------------------------"

# Get Box.com access token.
ACCESS_TOKEN=$( curl --location --request POST 'https://api.box.com/oauth2/token' --header 'Content-Type: application/x-www-form-urlencoded' --data-urlencode "client_id=$CLIENT_ID" --data-urlencode "client_secret=$CLIENT_SECRET" --data-urlencode 'grant_type=client_credentials' --data-urlencode 'box_subject_type=enterprise' --data-urlencode "box_subject_id=$SUBJECT_ID" | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["access_token"]' )

# Navigate to the projects directory.
cd $PROJECTS_ROOT

# Iterate over all projects in the main directory.
for dir in */ ; do
# Set the project name without a leading slash.
PROJECT_NAME=${dir%*/}
# Build a project root path.
PROJECT_ROOT="$PROJECTS_ROOT/$PROJECT_NAME/$DOCROOT"

# Check whether the project directory exists.
if [ -d $PROJECT_ROOT ]
then

echo "-----------------------------------------------"
echo " Generate $PROJECT_NAME backup "
echo "-----------------------------------------------"
    # Navigate to the project docroot.
    cd $PROJECT_ROOT
    # Generate a backup file name.
    FILE_NAME="${PROJECT_NAME}_db_$(date +"%Y-%m-%d").sql"
    # Trigger drush sql dump into target directory.
    drush sql:dump --gzip --result-file=$EXPORT_DIR/$FILE_NAME
    # Append the gzip to the file name.
    FILE_NAME+=".gz"
echo "-----------------------------------------------"
echo " Uploading $FILE_NAME to Box.com "
echo "-----------------------------------------------"
    # Upload the backup file to Box.com.
    curl -i -X POST 'https://upload.box.com/api/2.0/files/content' -H "Authorization: Bearer $ACCESS_TOKEN" -H "Content-Type: multipart/form-data" -F attributes="{\"name\":\"$FILE_NAME\", \"parent\":{\"id\":\"$FOLDER_ID\"}}" -F file=@"$EXPORT_DIR/$FILE_NAME"
    # Remove the backup file.
    rm $EXPORT_DIR/$FILE_NAME
fi
done
