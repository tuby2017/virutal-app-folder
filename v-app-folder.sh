#!/bin/bash
##usage ./scriptName.sh 
##output files and folder in /tmp. scriptName.date.randomString/ and if success Apps_MonthDate/
## on debain require libgtk-3-bin. Set desktop file to open with command gtk-launch 
## greploop [0|1|2] for sorting desktop file with multiple caterogeries, has order.

tempprefix=$(basename "$0")

#: << '@xbvcxcn'
temp_dir=`mktemp -d -t "${tempprefix}.$(date +%Y-%m-%d.%Hh%Mm%Ss).XXXXXXXXXX"`
echo "output to $temp_dir"

 #grep -s to surpress error
cd /usr/share/applications;
allapp=$temp_dir/allapp.txt
allapp_nodisplay=$temp_dir/allapp-nodisplay.txt
list_1=$temp_dir/list-1
grep -s --exclude-dir=screensavers --include=\*.desktop -rl -e '^Exec=' > $allapp
grep -s -e '^OnlyShowIn=' * |grep -v 'XFCE'|cut -d':' -f1 > $allapp_nodisplay
grep -s --exclude-dir=screensavers --include=\*.desktop -ril -e '^NoDisplay=true' * >> $allapp_nodisplay
 #grep -xvf fired.txt workers.txt
cd $temp_dir #/tmp
grep -xvf $allapp_nodisplay $allapp > $list_1

homeApp=`echo $HOME/.local/share/applications`
cd $homeApp
usrapp=$temp_dir/usrapp.txt
usrapp_nodisplay='$temp_dir/usrapp-nodisplay.txt'
list_2=$temp_dir/list-2
ls -p | egrep -v /$ > $usrapp
 #grep --include=\*.desktop -iln -e 'NoDisplay' * #$(ls -p | egrep -v /$)
grep -s --include=\*.desktop -il -e '^NoDisplay=true' * > $usrapp-nodisplay
cd $temp_dir #/tmp
grep -xvf $usrapp-nodisplay $usrapp > $list_2

list_3=$temp_dir/list-3
list_display=$temp_dir/list-display.txt
grep -xvf $usrapp-nodisplay $list_1 > $list_3
grep -xvf $list_2 $list_3 |sed "s;^;/usr/share/applications/;g" > $list_1
cat $list_2|sed "s;^;$homeApp/;g" > $list_3
cat $list_1 $list_3|sort > $list_display

#@xbvcxcn
#temp_dir=/tmp/x.sh.2020-11-26.11h11m33s.6KwuaCJVGJ/ ##debug test
#list_display=$temp_dir/list-display.txt ##

ld2=$temp_dir/ld2
ld2_1=$temp_dir/ld2-1
## todo try reduce repeat grep usage
grep -e '^Categories=' $(cat $list_display) > $ld2

firstList=true
whichList='ld2'; ListOut='ld2-1'
whichList=$ld2; ListOut=$ld2_1
# change ListOut to sourceList ?
toggleFile(){
	if [[ "$firstList" == 'false' ]]; then 
		whichList=$ld2_1; ListOut=$ld2; firstList=true;
		else whichList=$ld2; ListOut=$ld2_1; firstList=false; fi
}

##iftest
function iftest(){
	#grep -xvf "$folderList" "$whichList" > "$ListOut";;
	# if $folderList is empty then remove list 
	[[ ! -s "$1" ]] && return;
	grep -xvf "$1" "$2" > "$3";
	#echo "$1" "$2, " "$3";
	local appFolder="$temp_dir/App/$1" #/tmp/App/"$1"
	mkdir -p "$appFolder";
	
	local cpyFile="$1"-2
	cut -d':' -f1 "$1" > "$cpyFile"
	grep -e '^Name=' $(cat "$cpyFile") > "$1"
	local t1=`cat "$cpyFile"|wc -l`
	local t2=`cat "$1"|wc -l`
	local fromFile="$1"
	[[ ! "$t1" -eq "$t2" ]] && fromFile="$cpyFile"

	local progNm='Output_desktop_file_name'
	if [[ "$fromFile" -eq "$cpyFile" ]]; then
	while read line; do 
	 progNm=`echo "$appFolder"/"${line##*/}"`
	 ln -s "$line" "$progNm"; done < "$fromFile"; 
	else
	while read line; do 
	 progNm=`cut -d':' -f2 "$line"|cut -c 6-`
	 ln --backup=t -s "$line" "$appFolder"/"$porgNm" ; 
	 done < "$cpyFile";
	fi
}

greploop(){
	toggleFile;
	local frstValue="$1"
	local folderList="$2"
	[[ -z $frstValue ]] && return
	shift 2
	case $frstValue in
		0) grep "$folderList" "$whichList" > "$folderList";
			#echo "$folderList" "$whichList" "$ListOut" 0000;;
			iftest "$folderList" "$whichList" "$ListOut";;
		1) grep "$1" "$whichList" > "$folderList";
			grep -xvf "$folderList" "$whichList" > "$ListOut";
			#echo $folderList 1;;
			iftest "$folderList" "$whichList" "$ListOut";;
		2) grep ${@/#/-e } "$whichList" > "$folderList"; 
			grep -xvf "$folderList" "$whichList" > "$ListOut";
			#echo $folderList 2
			iftest "$folderList" "$whichList" "$ListOut";;
		*) echo 'no action, exit script';;
	esac
	#return
}

cd $temp_dir
#greploop 2 123 32 3
#greploop [1|2] 'folderList_Name.txt' 'match_exact_string_1' '2nd' 'etc'
greploop 1 'MX-Tools' 'MX-' 
greploop 2 'Multimedia' Audio Video AudioVideo
greploop 0 'X-XFCE'
greploop 0 Office
greploop 1 'Internet' Network
greploop 2 'System' System Emulator
greploop 0 Graphics
 greploop 0 'Development'
greploop 1 'Games' Game
greploop 2 'Accessories' Utility Accessibility Core Legacy Utilities
 greploop 0 Education 

mv $temp_dir/App /tmp/Apps_$(date +%b%d)
echo "finish! check" /tmp/Apps_$(date +%b%d)
exit
