#!/bin/bash

# Copy all them files
function copy_files {
  FILES_PATH=$1
  RENAME_TO=$2

  if [ -d "$FILES_PATH" ]; then
    echo "Copying dir"
    cp -rf $FILES_PATH $NEW_REPOSITORY
    FILES_COPIED+=("$FILES_PATH")
  elif [ ! -z "$RENAME_TO" ]; then
    echo "Copying file and renaming"
    cp $FILES_PATH $NEW_REPOSITORY/$RENAME_TO
    FILES_COPIED+=("$RENAME_TO")
  else
    echo "Copying file"
    cp $FILES_PATH $NEW_REPOSITORY
    FILES_COPIED+=("$FILES_PATH")
  fi
}

#############
# Variables #
#############

NEW_REPOSITORY=$1
USES_ARTIFACTORY=""
FILES_COPIED=()

######################
# Validate Variables #
######################

if [ -z "$NEW_REPOSITORY" ]; then
  echo "Usage: ./copy_template.sh PUT_PATH_TO_NEW_REPOSITORY"
fi

if [ ! -d "$NEW_REPOSITORY" ]; then
  echo "The \"${NEW_REPOSITORY}\" directory does not exist."
fi

###################
# Gradle or Maven #
###################

echo "Enter \"gradle\" or \"maven\":"
read BUILD_TOOL
# echo "BUILD_TOOL = \"${BUILD_TOOL}\""

if [ "gradle" != "$BUILD_TOOL" ] && [ "maven" != "$BUILD_TOOL" ]; then
  echo "\"$BUILD_TOOL\" is an invalid build tool... Exiting"
  exit 1
fi

if [ "maven" == "$BUILD_TOOL" ]; then
  printf "Does this project pulls JAR file dependencies from Artifactory [y/n]? "
  read ARTIFACTORY

  if [ "yes" == $ARTIFACTORY ] || [ "y" == "$ARTIFACTORY" ]; then
    USES_ARTIFACTORY="true"
  fi
fi

##############
# Copy Files #
##############

mkdir -p "$NEW_REPOSITORY/.jenkins"
copy_files ".jenkins/jenkins-pod.yaml" ".jenkins/jenkins-pod.yaml"
copy_files "config"
copy_files ".gitignore"


if [ "gradle" == "$BUILD_TOOL" ]; then
  echo "Copying Gradle related files..."
  copy_files "gradle"
  copy_files "gradlew"
  copy_files "gradlew.bat"
  copy_files "Dockerfile.gradle" "Dockerfile"
  copy_files ".jenkins/Jenkinsfile-oss.groovy" ".jenkins/Jenkinsfile-oss.groovy"
  copy_files ".jenkins/Jenkinsfile-gradle.groovy" ".jenkins/Jenkinsfile.groovy"

elif [ "maven" == "$BUILD_TOOL" ]; then
  echo "Copying Maven related files..."
  copy_files ".mvn"
  copy_files "mvnw"
  copy_files "mvnw.cmd"
  copy_files "pom.xml"

  if [ "true" == "$USES_ARTIFACTORY" ]; then
    copy_files ".jenkins/Jenkinsfile-oss-artifactory.groovy" ".jenkins/Jenkinsfile-oss.groovy"
    copy_files ".jenkins/Jenkinsfile-maven-artifactory.groovy" ".jenkins/Jenkinsfile.groovy"
    copy_files "Dockerfile.maven-artifactory" "Dockerfile"
  else
    copy_files ".jenkins/Jenkinsfile-oss.groovy" ".jenkins/Jenkinsfile-oss.groovy"
    copy_files ".jenkins/Jenkinsfile-maven.groovy" ".jenkins/Jenkinsfile.groovy"
    copy_files "Dockerfile.maven" "Dockerfile"
  fi
fi

########
# Done #
########

echo
echo
echo "Copied the following files into the \"${NEW_REPOSITORY}\" folder:"

SORTED_FILES=($(printf '%s\n' "${FILES_COPIED[@]}"|sort))

for value in "${SORTED_FILES[@]}"
do
  echo $value
done