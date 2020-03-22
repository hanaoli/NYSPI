#!/usr/bin/env bash
# Dr. Xiaofu He's lab 
# This script is used to convert dicom to nifty with a file list as input parameter to the dcm2niix

scriptPath=~/Desktop/data # /dcm2niixFolder/#the location of dcm2niix

dicomPath=~/Desktop/data # #/home/DICOM the raw dicom folder
savedPath=~/Desktop/data/output # # /home/saved where you will save the nifty file after running dcm2niix

#subfolderName=$1 #subfoldername
volNum=$1 #3 #how many vols in total
sliceNumPerVol=$2 #48 #how many slices per vol
sessionNum=$3 #1, means session#1
#options="-b n" #no bid
options="-b y" #with bid 

sessionNum=$(printf "%03d" ${sessionNum})

count=1

#dicomPath=$dicomPath/$subfolderName
#savedPath=$savedPath/$subfolderName

processedPath=$savedPath/processed #move all processed slices to this folder
mkdir -p $processedPath #make dir if not exist
cd $dicomPath # go to dicom files path

for i in $(seq 1 $volNum) # For each volumn
do
  
  echo $count
  start=$(date +"%s%3N") # start time calculation
 
  firstDicom=$(ls -1v i* | head -n1) # get first slice name start with i* 
  sliceIndexStart=$(echo $firstDicom | awk -F. '{print $1}' | cut -c2-) # extract dicom name
  sliceIndexEnd=$(($sliceIndexStart+$sliceNumPerVol-1)) # End Index
  
  # If file does not exist, sleep 2 and continue
  if [ ! -f i${sliceIndexEnd}.MRDC.* ];
  then
    sleep 2
  fi
      
  txtName=$(printf "%06d" $i).txt  # name of the file
  > ${savedPath}/${txtName} # create new txt file to store file locations
  
  # write slices into txt file, if does not exist, then will not write
  for files in $(seq $sliceIndexStart $sliceIndexEnd | awk '{print "i"$1".MRDC*"}')
  do
	if [ -f $files ];
	then
	  echo C:/Users/36576/Desktop/data/$files >> ${savedPath}/$txtName
	  #echo ${dicomPath}/$files >> ${savedPath}/$txtName 
	  ((k++))
	else
	  break
   fi
  done

  ${scriptPath}/dcm2niix ${options} -f ${sessionNum}_%6s_$(printf "%06d" $count) -o $savedPath -s y ${savedPath}/$txtName   #convert dicom to a nifty file
  #nii_file=$(ls -1v ${savedPath}/${outputBasename}* | head -n1) 
  #nii_file=$(ls -1v ${savedPath}/ ${outputBasename}* | head -n1) 
  #nii_file=$(ls -1v ${savedPath}/${outputBasename}* | head -n1|cut -d'/' -f 9) 
  #nii_file=$(ls -1v ${savedPath}/${sessionNum}_* | tail -n1) #get the last field 
  nii_file=$(ls -1v ${savedPath}/${sessionNum}_* | tail -n1 | xargs -n 1 basename)
  echo $nii_file 
  
  # Get series Num
  seriesNum=$(echo $nii_file | cut -d'_' -f 2)
  echo $seriesNum
  
  # If first volume, then store seriesNum
  if [ $count -eq 1 ];
  then
    temp=$seriesNum
  fi
  
  # If seriesNum is different, start from 1
  if [ $temp -ne $seriesNum ];
  then
    temp=$seriesNum
	mv $savedPath/${sessionNum}_${seriesNum}_$(printf "%06d" $count).nii $savedPath/${sessionNum}_${seriesNum}_$(printf "%06d" 1).nii 
    mv $savedPath/${sessionNum}_${seriesNum}_$(printf "%06d" $count).json $savedPath/${sessionNum}_${seriesNum}_$(printf "%06d" 1).json
	count=1
  fi
  
  ((count++))
 # final_name=${sessionNum}_$(printf "%06d" ${seriesNum})_$(printf "%06d" $i)  
 
 # cp $firstDicom ${savedPath}/${final_name}.dcm # copy fist slice and rename
 
  
  # rename the output nifty file as xxxxvol{1}.nii #note: the nifty file name should be a 6-digit, e.g., 000001.nii means the first volume, 000010.nii means the 10th volume, i.e., padding with 0 if the vol# is smaller than 6 digit
#  mv $savedPath/${outputBasename}*.nii $savedPath/${final_name}.nii  
#  mv $savedPath/${outputBasename}*.json $savedPath/${final_name}.json
  
  # move the vol's slices to $processedPath
  cat ${savedPath}/$txtName | xargs mv -t $processedPath
#  mv ${savedPath}/$txtName ${savedPath}/${final_name}.txt #rename the text file 
 
  end=$(date +"%s%3N") # end time 
  dif=$(($end - $start)) # time difference
  echo "Time elapsed: $dif milliseconds" # print out time elapsed
  
done #end for i
