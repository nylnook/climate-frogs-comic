#!/bin/sh

# v4
# Usage: ./export-comic.sh X.svg
# Usage: ./export-comic.sh --all

# Require Bash 4, Exiftools, Inkscape, ImageMagick, Gostscript, Sed, Calibre, Zip and and Unzip

# Variables must be stored in metadata.sh
# =======================================




# Check that a file name has been passed
# ======================================
function checkFileExists {
	if [ ! -f $1 ]
	then
		echo "The specified file ($1) could not be found"
		exit 1
	fi
}

# Report how we got on
# ====================
function checkExitStatus {
	if [ `echo $?` = 1 ]
	then
		echo "Error during processing."
	else
		if [ "$1" != "-silent" ]
		then
			echo "All done!"
		fi
	fi
}

# Function to check and create directories
# ========================================
function checkWebDirs {
	dir=$dirwebjpg
	if [ ! -d "${dir}" ]; then
	  mkdir ${dir}
	fi
	dir=$dirverticalstrip
	if [ ! -d "${dir}" ]; then
	  mkdir ${dir}
	fi
	dir=$direbooks
	if [ ! -d "${dir}" ]; then
	  mkdir ${dir}
	fi
}

function checkHDDirs {
	dir=$dirHDjpg
	if [ ! -d "${dir}" ]; then
	  mkdir ${dir}
	fi
	dir=$direbooks
	if [ ! -d "${dir}" ]; then
	  mkdir ${dir}
	fi
}

function checkPrintDirs {
	dir=$dirprintrgb
	if [ ! -d "${dir}" ]; then
	  mkdir ${dir}
	fi
	dir=$dirprintcmyk
	if [ ! -d "${dir}" ]; then
	  mkdir ${dir}
	fi
}


# Functions to actually export image form a svg file
# ==================================================
function exportWebFile {
	# check
	checkFileExists $file

	filename=$(basename "$file")
	filename="${filename%.*}"
	#extension="${filename##*.}"

	# export for web
	inkscape -z $file -e=temp.png -d=175  --export-background-opacity=255 --export-background=white
	convert temp.png -unsharp 0.48x0.48+0.50+0.012 -colorspace sRGB -quality 92% page-$filename.jpg
	rm temp.png
	# Metadata : First remove everything for privacy
	exiftool -all= -overwrite_original -q page-$filename.jpg
	# Metadata : Then put credits
	exiftool \
		-EXIF:XPTitle="page-$filename" \
		-IPTC:ObjectName="page-$filename" \
		-XMP-dc:Title="page-$filename" \
		-XMP-xmpDM:ShotName="page-$filename" \
		-EXIF:XPAuthor="$creator" \
		-IPTC:By-line="$creator" \
		-XMP-dc:Creator="$creator" \
		-XMP-pdf:Author="$creator" \
		-EXIF:Artist="$creator" \
		-EXIF:Copyright="$copyright" \
		-EXIF:OwnerName="$creator" \
		-EXIF:Usercomment="$licence" \
		-EXIF:XPAuthor="$creator" \
		-EXIF:XPComment="$copyright"\
		-IPTC:By-line="$creator" \
		-IPTC:Contact="$creator" \
		-IPTC:CopyrightNotice="$licence" \
		-IPTC:Credit="$creator" \
		-Photoshop:CopyrightFlag="True" \
		-Photoshop:URL="$url" \
		-XMP-aux:OwnerName="$creator" \
		-XMP-dc:Source="$creator" \
		-XMP-dc:Creator="$creator" \
		-XMP-dc:Rights="$licence" \
		-XMP-pdf:Author="$creator" \
		-XMP-photoshop:Credit="$creator" \
		-XMP-photoshop:Source="$creator" \
		-XMP-xmpDM:Copyright="$copyright" \
		-XMP-xmpRights:Marked="True" \
		-XMP-xmpRights:Owner="$creator" \
		-XMP-xmpRights:UsageTerms="$licence" \
		-XMP-xmpRights:WebStatement="$url" \
	 	-overwrite_original -q page-$filename.jpg
	#move
	mv page-$filename.jpg $dirwebjpg
	
	# check
	checkExitStatus -silent
}

function exportHDFile {
	# check
	checkFileExists $file

	filename=$(basename "$file")
	filename="${filename%.*}"
	#extension="${filename##*.}"

	# export for web
	inkscape -z $file -e=temp.png -d=342  --export-background-opacity=255 --export-background=white
	convert temp.png -unsharp 0.48x0.48+0.50+0.012 -colorspace sRGB -quality 92% page-HD-$filename.jpg
	rm temp.png
	# Metadata : First remove everything for privacy
	exiftool -all= -overwrite_original -q page-HD-$filename.jpg
	# Metadata : Then put credits
	exiftool \
		-EXIF:XPTitle="page-$filename" \
		-IPTC:ObjectName="page-$filename" \
		-XMP-dc:Title="page-$filename" \
		-XMP-xmpDM:ShotName="page-$filename" \
		-EXIF:XPAuthor="$creator" \
		-IPTC:By-line="$creator" \
		-XMP-dc:Creator="$creator" \
		-XMP-pdf:Author="$creator" \
		-EXIF:Artist="$creator" \
		-EXIF:Copyright="$copyright" \
		-EXIF:OwnerName="$creator" \
		-EXIF:Usercomment="$licence" \
		-EXIF:XPAuthor="$creator" \
		-EXIF:XPComment="$copyright"\
		-IPTC:By-line="$creator" \
		-IPTC:Contact="$creator" \
		-IPTC:CopyrightNotice="$licence" \
		-IPTC:Credit="$creator" \
		-Photoshop:CopyrightFlag="True" \
		-Photoshop:URL="$url" \
		-XMP-aux:OwnerName="$creator" \
		-XMP-dc:Source="$creator" \
		-XMP-dc:Creator="$creator" \
		-XMP-dc:Rights="$licence" \
		-XMP-pdf:Author="$creator" \
		-XMP-photoshop:Credit="$creator" \
		-XMP-photoshop:Source="$creator" \
		-XMP-xmpDM:Copyright="$copyright" \
		-XMP-xmpRights:Marked="True" \
		-XMP-xmpRights:Owner="$creator" \
		-XMP-xmpRights:UsageTerms="$licence" \
		-XMP-xmpRights:WebStatement="$url" \
	 	-overwrite_original -q page-HD-$filename.jpg
	#move
	mv page-HD-$filename.jpg $dirHDjpg
	
	# check
	checkExitStatus -silent
}



function exportPrintFile {
	# check
	checkFileExists $file

	filename=$(basename "$file")
	filename="${filename%.*}"
	#extension="${filename##*.}"
	

	#export for A5 print best quality (A5 600 dpi = A3 300 dpi)
	inkscape -z $file -e=tempHD.png -d=600 -T --export-background-opacity=255 --export-background=white --export-margin=0
	convert tempHD.png -unsharp 0.48x0.48+0.50+0.012 -colorspace sRGB -quality 92% print-page-$filename.jpg
	rm tempHD.png
	# Metadata : First remove everything for privacy
	exiftool -all= -overwrite_original -q print-page-$filename.jpg
	# Metadata : Then put credits
	exiftool \
		-EXIF:XPTitle="page-$filename" \
		-IPTC:ObjectName="page-$filename" \
		-XMP-dc:Title="page-$filename" \
		-XMP-xmpDM:ShotName="page-$filename" \
		-EXIF:XPAuthor="$creator" \
		-IPTC:By-line="$creator" \
		-XMP-dc:Creator="$creator" \
		-XMP-pdf:Author="$creator" \
		-EXIF:Artist="$creator" \
		-EXIF:Copyright="$copyright" \
		-EXIF:OwnerName="$creator" \
		-EXIF:Usercomment="$licence" \
		-EXIF:XPAuthor="$creator" \
		-EXIF:XPComment="$copyright"\
		-IPTC:By-line="$creator" \
		-IPTC:Contact="$creator" \
		-IPTC:CopyrightNotice="$licence" \
		-IPTC:Credit="$creator" \
		-Photoshop:CopyrightFlag="True" \
		-Photoshop:URL="$url" \
		-XMP-aux:OwnerName="$creator" \
		-XMP-dc:Source="$creator" \
		-XMP-dc:Creator="$creator" \
		-XMP-dc:Rights="$licence" \
		-XMP-pdf:Author="$creator" \
		-XMP-photoshop:Credit="$creator" \
		-XMP-photoshop:Source="$creator" \
		-XMP-xmpDM:Copyright="$copyright" \
		-XMP-xmpRights:Marked="True" \
		-XMP-xmpRights:Owner="$creator" \
		-XMP-xmpRights:UsageTerms="$licence" \
		-XMP-xmpRights:WebStatement="$url" \
	 	-overwrite_original -q print-page-$filename.jpg
	#move
	mv print-page-$filename.jpg $dirprintrgb

	#export for A5 print best quality with cutting marks (A5 600 dpi = A3 300 dpi)
	inkscape -z $file -e=tempHDmarks.png -d=600 -T --export-background-opacity=255 --export-background=white --export-area=-70:-70:594:814
	convert tempHDmarks.png -unsharp 0.48x0.48+0.50+0.012 -colorspace sRGB -quality 92% print-page-marks-$filename.jpg
	rm tempHDmarks.png
	# Metadata : First remove everything for privacy
	exiftool -all= -overwrite_original -q print-page-marks-$filename.jpg
	# Metadata : Then put credits
	exiftool \
		-EXIF:XPTitle="page-$filename" \
		-IPTC:ObjectName="page-$filename" \
		-XMP-dc:Title="page-$filename" \
		-XMP-xmpDM:ShotName="page-$filename" \
		-EXIF:XPAuthor="$creator" \
		-IPTC:By-line="$creator" \
		-XMP-dc:Creator="$creator" \
		-XMP-pdf:Author="$creator" \
		-EXIF:Artist="$creator" \
		-EXIF:Copyright="$copyright" \
		-EXIF:OwnerName="$creator" \
		-EXIF:Usercomment="$licence" \
		-EXIF:XPAuthor="$creator" \
		-EXIF:XPComment="$copyright"\
		-IPTC:By-line="$creator" \
		-IPTC:Contact="$creator" \
		-IPTC:CopyrightNotice="$licence" \
		-IPTC:Credit="$creator" \
		-Photoshop:CopyrightFlag="True" \
		-Photoshop:URL="$url" \
		-XMP-aux:OwnerName="$creator" \
		-XMP-dc:Source="$creator" \
		-XMP-dc:Creator="$creator" \
		-XMP-dc:Rights="$licence" \
		-XMP-pdf:Author="$creator" \
		-XMP-photoshop:Credit="$creator" \
		-XMP-photoshop:Source="$creator" \
		-XMP-xmpDM:Copyright="$copyright" \
		-XMP-xmpRights:Marked="True" \
		-XMP-xmpRights:Owner="$creator" \
		-XMP-xmpRights:UsageTerms="$licence" \
		-XMP-xmpRights:WebStatement="$url" \
	 	-overwrite_original -q print-page-marks-$filename.jpg
	#move
	mv print-page-marks-$filename.jpg $dirprintcmyk
	
	# check
	checkExitStatus -silent
}

function checkWebImg {
	if find "$dirwebjpg" -mindepth 1 -print -quit | grep -q .
	then
	  echo "---> Web images are ready"
	else
	  echo "---> Generating missing web images"
	  for file in $files
	  do
                echo "------- $count/$filecount -------"
		exportWebFile
		count=$((count+1))
	  done
	fi
}

function checkHDImg {
	if find "$dirHDjpg" -mindepth 1 -print -quit | grep -q .
	then
	  echo "---> HD images are ready"
	else
	  echo "---> Generating missing HD images"
	  for file in $files
	  do
                echo "------- $count/$filecount -------"
		exportHDFile
		count=$((count+1))
	  done
	fi
}

function checkPrintImg {
	if find "$dirprintcmyk" -mindepth 1 -print -quit | grep -q .
	then
	  echo "---> Print images are ready"
	else
	  echo "---> Generating missing print images"
	  for file in $files
	  do
                echo "------- $count/$filecount -------"
		exportPrintFile
		count=$((count+1))
	  done
	fi
}

function joinToPdfWeb {
	#for i in *.jpg; do num=`expr match "$i" '\([0-9]\+\).*'`;
	#> padded=`printf "%03d" $num`; mv -v "$i" "${i/$num/$padded}"; done
	convert *.jpg -units PixelsPerInch -density 175x175 $joinedfilename.pdf
	# Metadata : Then put credits
	exiftool \
		-Title="$title" \
		-Author="$creator" \
	 	-overwrite_original -q $joinedfilename.pdf
}

function joinToPdfHD {
	#for i in *.jpg; do num=`expr match "$i" '\([0-9]\+\).*'`;
	#> padded=`printf "%03d" $num`; mv -v "$i" "${i/$num/$padded}"; done
	convert *.jpg -units PixelsPerInch -density 342x342 $joinedfilename.pdf
	# Metadata : Then put credits
	exiftool \
		-Title="$title" \
		-Author="$creator" \
	 	-overwrite_original -q $joinedfilename.pdf
}

function joinToPdfPrint {
	#for i in *.jpg; do num=`expr match "$i" '\([0-9]\+\).*'`;
	#> padded=`printf "%03d" $num`; mv -v "$i" "${i/$num/$padded}"; done
	convert *.jpg -units PixelsPerInch -density 600x600 $joinedfilename.pdf
	# Metadata : Then put credits
	exiftool \
		-Title="$title" \
		-Author="$creator" \
	 	-overwrite_original -q $joinedfilename.pdf
}


function generatePdf {
	echo "------- generate PDFs -------"
	#join Print PDF rgb
	echo "---> print rgb PDF"
	cd $dirprintrgb
	joinedfilename=all-print-pages-rgb
	joinToPdfPrint
	cd ..
	#join Print PDF cmyk with makrs
	echo "---> print rgb PDF with marks"
	cd $dirprintcmyk
	joinedfilename=all-print-pages-marks
	joinToPdfPrint
	echo "---> print cmyk PDF with marks"
	gs -q -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite \
	-sColorConversionStrategy=CMYK -dProcessColorModel=/DeviceCMYK \
	-sOutputFile="all-print-pages-cmyk.pdf" "all-print-pages-marks.pdf"
	rm all-print-pages-marks.pdf
	cd ..
}

function convertToeBooks {
	#coverid=$(($filecount + 1))

	echo "------- generate web eBooks -------"
	cd $dirwebjpg
	joinedfilename=all-pages
	echo "---> web PDF"
	joinToPdfWeb
	echo "---> web Cbz"
	zip $joinedfilename.cbz *.jpg
	echo "---> web ePub"
	ebook-convert $joinedfilename.cbz $joinedfilename.epub --authors "$creator" --publisher "$creator" --title "$title" --isbn "$ebookIsbn" --pubdate "$pubDate" --language "$language" --no-default-epub-cover --dont-grayscale --dont-normalize --keep-aspect-ratio --output-profile tablet --no-process --disable-trim --dont-add-comic-pages-to-toc --wide --extra-css "img{width:100%}" --cover "page-1.jpg" --remove-first-image

	#add metadatas to be Amazon compliant, thanks to eschwartz in MobileRead Calibre Forums
	epub="$(realpath "$joinedfilename.epub")"
	tmp_epub=$(mktemp -d)
	unzip "$epub" -d $tmp_epub
	pushd $tmp_epub
	metacontent='\t\t<meta content="comic" name="book-type"/>\n\t\t<meta content="true" name="zero-gutter"/>\n\t\t<meta content="true" name="zero-margin"/>\n\t\t<meta content="true" name="fixed-layout"/>\n\t\t<meta content="none" name="orientation-lock"/>\n\t\t<meta content="horizontal-lr" name="primary-writing-mode"/>\n\t\t<meta content="false" name="region-mag"/>\n\t\t<meta content="1993x2828" name="original-resolution"/>'
	sed -i '/<\/metadata>/i\'"$metacontent" content.opf
	sed -e 1~2s'|<itemref |<itemref linear="yes" properties="facing-page-right" |' -i content.opf
	sed -e 2~2s'|<itemref |<itemref linear="yes" properties="facing-page-left" |' -i content.opf
	zip -r "$epub" * -x mimetype
	pushd
	rm -rf $tmp_epub

	mv $joinedfilename.pdf ../$direbooks
	mv $joinedfilename.cbz ../$direbooks
	mv $joinedfilename.epub ../$direbooks

	echo "------- generate HD eBooks -------"
	cd ../$dirHDjpg
	joinedfilename=all-pages-HD
	echo "---> HD PDF"
	joinToPdfHD
	echo "---> HD Cbz"
	zip $joinedfilename.cbz *.jpg
	echo "---> HD ePub"
	ebook-convert $joinedfilename.cbz $joinedfilename.epub --authors "$creator" --book-producer "$creator" --publisher "$creator" --title "$title" --isbn "$ebookIsbn" --pubdate "$pubDate" --language "$language" --no-default-epub-cover --dont-grayscale --dont-normalize --keep-aspect-ratio --output-profile tablet --no-process --disable-trim --dont-add-comic-pages-to-toc --wide --extra-css "img{width:100%}" --cover "page-HD-1.jpg" --remove-first-image

	#add metadatas to be Amazon compliant, thanks to eschwartz in MobileRead Calibre Forums
	epub="$(realpath "$joinedfilename.epub")"
	tmp_epub=$(mktemp -d)
	unzip "$epub" -d $tmp_epub
	pushd $tmp_epub
	metacontent='\t\t<meta content="comic" name="book-type"/>\n\t\t<meta content="true" name="zero-gutter"/>\n\t\t<meta content="true" name="zero-margin"/>\n\t\t<meta content="true" name="fixed-layout"/>\n\t\t<meta content="none" name="orientation-lock"/>\n\t\t<meta content="horizontal-lr" name="primary-writing-mode"/>\n\t\t<meta content="false" name="region-mag"/>\n\t\t<meta content="902x1280" name="original-resolution"/>'
	sed -i '/<\/metadata>/i\'"$metacontent" content.opf
	sed -e 1~2s'|<itemref |<itemref linear="yes" properties="facing-page-right" |' -i content.opf
	sed -e 2~2s'|<itemref |<itemref linear="yes" properties="facing-page-left" |' -i content.opf
	zip -r "$epub" * -x mimetype
	pushd
	rm -rf $tmp_epub


	mv $joinedfilename.pdf ../$direbooks
	mv $joinedfilename.cbz ../$direbooks
	mv $joinedfilename.epub ../$direbooks

	cd ..
}

function generateVerticalStrip {
	echo "------- generate vertical image -------"
	cd $dirwebjpg
	joinedfilename=all-pages
	convert -append page-*.jpg $joinedfilename.jpg
	mv all-pages.jpg ../$dirverticalstrip
	cd ..
}

function renameeBooksToTitle {
	echo "------- renaming eBooks to title -------"
	cd $direbooks
	mv all-pages.pdf "$title - ebook".pdf
	mv all-pages.cbz "$title - ebook".cbz
	mv all-pages.epub "$title - ebook".epub
	mv all-pages-HD.pdf "$title - HD ebook".pdf
	mv all-pages-HD.cbz "$title - HD ebook".cbz
	mv all-pages-HD.epub "$title - HD ebook".epub
	cd ..
}

function renamePdfToTitle {
	echo "------- renaming Print PDFs to title -------"
	cd $dirprintrgb
	mv all-print-pages-rgb.pdf "$title - print".pdf
	cd ..
	cd $dirprintcmyk
	mv all-print-pages-cmyk.pdf "$title - print cmyk".pdf
	cd ..
}

function renameVerticalToTitle {
	echo "------- renaming vertical strip to title -------"
	cd $dirverticalstrip
	mv all-pages.jpg "$title".jpg
	cd ..
}

function checkMetadatas {
	if [ -f "metadata.sh" ]
	then
		source ./metadata.sh
		echo "Ok, found metadatas"
	else
		echo "WARNING --- Metadata.sh file is missing !"
		echo "WARNING --- Using test Metadatas !"
		creator='creator'
		url="http://example.com"
		year=`date +'%Y'`
		copyright="Copyright (c) $creator $year"
		licence="A License."
		pubDate=`date +%Y-%m`
		title="A Testing Title"
		ebookIsbn="000-000-00000-00-0"
		language=en
		dirwebjpg=web-jpg
		dirHDjpg=hd-jpg
		dirverticalstrip=vertical
		direbooks=ebooks
		dirprintrgb=print-rgb
		dirprintcmyk=print-cmyk
	fi
}

# Function to print examples of how the script should be used
# ===========================================================
function printExamples {
	echo "./export-comic.sh ebook-en/source-file.svg" 
        echo "./export-comic.sh --all ebook-en/"
}


# =====================================
# =        START SCRIPT PROPER        =
# =====================================

# Check that arguments have been passed
# =====================================

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]
then
	echo "Please pass a --all, --images, --web-images, --hd-images, --print-images, --print, --ebook flag and a directory or a path to a filename.svg to this script.
Shortcodes -a, -i, -wi, -hi, -pi, -p, -e
Examples : "
	printExamples
	exit
fi


# Make the changes
# ==============================
startdate=$(date +"%s")
count=1

if [ "$#" == 2 ]
then
	cd $2

	checkMetadatas
	files=`ls *.svg *.SVG 2> /dev/null`
	filecount=`echo $files | wc | awk '{print $2}'`

	if [ "$1" = "--all" ] || [ "$1" = "-a" ]
	then
		checkWebDirs
		checkHDDirs
		checkPrintDirs
		for file in $files
		do
		        echo "------- $count/$filecount -------"
			exportWebFile
			exportHDFile
			exportPrintFile
			count=$((count+1))
		done
		convertToeBooks
		generateVerticalStrip
		generatePdf
		renameeBooksToTitle
		renameVerticalToTitle
		renamePdfToTitle
	elif [ "$1" = "--images" ] || [ "$1" = "-i" ]
	then
		checkWebDirs
		checkPrintDirscd ..
		for file in $files
		do
		        echo "-------- $count/$filecount -------"
			exportWebFile
			exportHDFile
			exportPrintFile
			count=$((count+1))
		done
		generateVerticalStrip
	elif [ "$1" = "--web-images" ] || [ "$1" = "-wi" ]
	then
		checkWebDirs
		for file in $files
		do
		        echo "------- $count/$filecount -------"
			exportWebFile
			count=$((count+1))
		done
		generateVerticalStrip
	elif [ "$1" = "--hd-images" ] || [ "$1" = "-hi" ]
	then
		checkHDDirs
		for file in $files
		do
		        echo "------- $count/$filecount -------"
			exportHDFile
			count=$((count+1))
		done
	elif [ "$1" = "--print-images" ] || [ "$1" = "-pi" ]
	then
		checkPrintDirs
		for file in $files
		do
		        echo "------- $count/$filecount -------"
			exportPrintFile
			count=$((count+1))
		done
	elif [ "$1" = "--print" ] || [ "$1" = "-p" ]
	then
		checkPrintDirs
		checkPrintImg
		generatePdf
		renamePdfToTitle
	elif [ "$1" = "--ebook" ] || [ "$1" = "-e" ]
	then
		checkWebDirs
		checkHDDirs
		checkWebImg
		convertToeBooks
		generateVerticalStrip
		renameeBooksToTitle
		renameVerticalToTitle
	fi

	cd ..

elif [ "$#" == 1 ]
then
	cd $(dirname $1)

	checkMetadatas

	checkWebDirs
	checkHDDirs
	checkPrintDirs
	file=$(basename $1)
	exportWebFile
	exportPrintFile

	cd ..
fi



#======== Finish ========
enddate=$(date +"%s")
diff=$(($enddate-$startdate))
echo "------------------"
echo "Finished processing in $(($diff / 60)) minute(s) and $(($diff % 60)) seconds."
exit


