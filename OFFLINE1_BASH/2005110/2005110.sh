useArchieve="true"
allowedArchieveFormats=()
allowedLanguage=()
totalMarks=0
penalty=0 #for unmatched or non existent output
workingDirectory=""
sidRange=()
outputFileLocation=""
penaltyForViolation=0
plagiarismFile=""
plagiarismPenalty=0



fileSubmitted=()
archieveSubmitted=()
folderSubmitted=()
declare -A issueArr;
declare -A marksArr;
declare -A diffArr;
executedProperly=()
executedWithIssues=()
notExecuted=()


#first go to working directory
goto_working_directory()
{
    ###fix
path=$workingDirectory
if [ ! -d "$path" ]; then
    mkdir -p "$path"
    echo "directory created"
    cd "$path"
    mkdir evaluation
    mkdir issues
    mkdir checked
else 
    echo "Directory already exits"
    cd /
    cd "$path"

    if [ -d "evaluation" ];then
        rm -r evaluation/*
    else 
        mkdir evaluation
    fi

    if [ -d "issues" ];then
        rm -r issues/*
    else 
         mkdir issues
    fi

    if [ -d "checked" ];then
        rm -r checked/*
    else 
        mkdir checked
    fi

fi

}



##check file is in allowed format
check_file_type()
{
    fileType=$(echo "$1" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')

    for type in "${allowedArchieveFormats[@]}"
    do
        if [[ $fileType == $type ]]; then
            return 0
        fi
    done
    return 1
}




# ##check allowed language
# check_allowed_language()
# {
#     local temp=$(echo "$1" | tr -d '[:space:]')

#     for type in "${allowedLanguage[@]}"
#     do
#         type=$(echo "$type" | tr -d '[:space:]')
#         if [[ $temp == $type ]];then
#             echo "allowed language $type"
#             return 0;
#         fi
#     done

#     return 1;
# }

###need to give manual input
check_allowed_language() {
    local ext=$1
    case $ext in
        c|cpp|py)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}



##check fileName is in range
check_in_range()
{
    fileName=$(echo "$1" | tr -d '[:space:]')
    start=$(echo "${sidRange[0]}" | tr -d '[:space:]')  # Remove spaces from start
    end=$(echo "${sidRange[1]}" | tr -d '[:space:]')

    if [[ $fileName -ge $start  &&  $fileName -le $end ]]; then
        echo "in range"
        return 0
    fi 

    return 1 
}



##match type , range 
#travarsing all the files
make_evaluable()
{
    for file in *
do
    echo $file
    fileName=${file%%.*} ##extracts the file name
    fileType=${file##*.} ##extracts the file type 

    check_allowed_language $fileType

    if [ $? -eq 0 ];then
    
        check_in_range $fileName

        if [ $? -eq 0 ]; then ##file is in allowed format and language
            mkdir -p "evaluation/$fileName"
            mv "$file" "evaluation/$fileName/"
            fileSubmitted+=("$fileName")
        else 
            ##case 3 --not allowed range
            issueArr["$fileName"]="#case 3"
            notExecuted+=($fileName) ##range er bahire ###fix
        fi 
           

    else 
        ##handle zip submission
        ##check allowed format 
        check_file_type $fileType

        if [ $? -eq 0 ]; then #is in allowed format
            echo $fileType
            ##check allowed range
            check_in_range $fileName
            if [ $? -eq 0 ]; then ##is in allowed format and allowed range
                #unzip the folder
                unzip $fileName -d evaluation/
                archieveSubmitted+=("$fileName")
            else 
                ##case 2--invalid archeved format
                issueArr["$fileName"]="#case 2"
                notExecuted+=($fileName) ##range er bahire ###fix
            fi
        else 
         ##handle folder submission 
            if [ -d "$file" ]; then
                check_in_range $fileName ##remarks case 1 --submitted folder & if valid proceed to eval
                if [ $? -eq 0 ]; then 
                    folderSubmitted+=("$fileName")
                    issueArr["$fileName"]="#case 1"
                    cp -r $file evaluation/
                else 
                    notExecuted+=("$fileName") ##folder but range er bahire
                    issueArr[$fileName]="#case 4"
                fi
            fi
        fi

    fi
       
done

}


##to count the difference ,,1st arg--given outputfile path ,,second arg--sid_ouput.txt path
file_difference()
{
    outputFile=$(echo "$outputFileLocation" | tr -d '[:space:]')
    testFile=$1
    diff=0

    outName="$outputFile" ##chnaged
    testName="$testFile"

    while IFS= read -r line; do
        matched=0
        while IFS= read -r line2; do
            if [[ "$(echo "$line" | tr -d '[:space:]')" == "$(echo "$line2" | tr -d '[:space:]')" ]]; then
                matched=1
                break
            else
                matched=0
            fi
        done < "$testName"

        if [ $matched -eq 0 ]; then
             diff=$((diff+1))
        fi
    done < "$outName"

    echo "$diff"
}



##execute the allowed type file
execute_file()
{
    fileType=$1
    fileName=$2
    file=$3

    if [[ "$fileType" = "c" ]]; then
        #execute c file
        output="${fileName}_output.txt"
        gcc $file -o $fileName
        ./"$fileName" > "$output"

        file_difference "$output"
        diffArr["$fileName"]=$diff

    elif [[ "$fileType" = "cpp" ]]; then
        #execute cpp file
        output="${fileName}_output.txt"
        g++ $file -o $fileName
        ./"$fileName" > "$output"
      
        file_difference "$output"
        diffArr["$fileName"]=$diff

    elif [[ "$fileType" = "java" ]]; then
        #execute java file
        output="${fileName}_output.txt"
        javac "$file"
        java "$fileName" >> "$output"

        ##calculate output dofference
        file_difference "$output"
        diffArr["$fileName"]=$diff
      
    elif [[ "$fileType" = "py" ]]; then
        #execute python file
        output="${fileName}_output.txt"
        python3 "$file" > "$output"
    
        file_difference "$output"
        diffArr["$fileName"]=$diff
        
    else
        echo "file type not allowed"
    fi

}


##run each program
##supposed one file in the directory
run_the_program()
{
    local dir=$1

    for file in *
    do 
        fileName=${file%%.*} ##extracts the file name
        fileType=${file##*.} ##extracts the file type 
        echo "$fileName"
        echo "$fileType"
        check_allowed_language $fileType
        if [ $? -eq 0 ]; then
            ##execute the file 
            ##write its output to "sid_output.txt file"
            execute_file $fileType $fileName $file

            ##added later--chdeck the extracted folder or file name is valid--case 4--will moved to issues folder
            check_in_range "$dir"

            if [ $? -eq 1 ]; then
                issueArr["$dir"]="#case 4"
                executedWithIssues+=("$fileName")
                return 1;
            fi

            check_in_range "$fileName"

            if [ $? -eq 1 ];then 
                ##fixx
                issueArr["$dir"]="#case 4"
                executedWithIssues+=($fileName)
                return 1
            fi
            return 0
            
        else 
            ##the file format is not allowed 
            ##write issue > issue.txt
            ##move the folder to issues folder
            issueArr["$fileName"]="#case 3"
            notExecuted+=("$fileName")
            return 1
            
        fi

    done

    return 1

}



##from the evaluation folder run each folder
do_evaluation()
{
    cd evaluation

    for dir in *
    do 
        echo "$dir"
        
        cd "$dir"
        run_the_program $dir
        return_val=$?
        cd ..

        ###fix need to make here the directory to /workingDirectory/checked/
        ##checked executed properly or not and move them checked or issues folder
        # echo "Returnnnnnnnnnnn val: $dir --> $return_val"
        ##fix path
        if [ $return_val -eq 0 ]; then
            cp -r "$dir" "${workingDirectory}/checked/"
            executedProperly+=("$dir")
        else 
            cp -r "$dir" "${workingDirectory}/issues/"
            #issueArr["$dir"]="#case 3"
        fi
    done

    ##cd - to come out working directory
    cd -
}


##report generation initially , then will insert the corresponding rows
report_generate()
{
    echo "--------------------------------------------------------"
    echo "ExecutedProperly:     ${executedProperly[@]}"
    echo "ExecutedWithIssues:   ${executedWithIssues[@]}"
    echo "Not executed :     ${notExecuted[@]}"
    echo "--------------------------------------------------------"
    
    ###calculate marks
    ###if in notExecuted--mark=0
    ###if executedWithIssues mark = total - diff*penalty - penalty for submission violation
    ##if executed properly && (in folderSubmit || inFileSubmit) mark = total mark - penalty for submission violation
    ## else mark = total mark

    echo "id, marks , marks_deducted, total_marks , remarks" > "${workingDirectory}/2005110_report.csv"
    chmod u+w "${workingDirectory}/2005110_report.csv"

    echo "in report generation------------"

    start=${sidRange[0]}
    end=${sidRange[1]}

    start=$(echo "$start" | tr -d '[:space:]')
    end=$(echo "$end" | tr -d '[:space:]')
   
    for (( i=start; i<=end; i++ ));
    do
        found=0
        mark=0
        deducted=0
        remark=""


        ##for not executed
        if [[ $found -eq 0 ]]; then
            ##for not executed
            for element in ${notExecuted[@]}; do
                if [[ $element ==  $i ]]; then
                    mark=0
                    deducted=$((0 - 100))
                    found=1
                    remark="${issueArr[$i]}"
                    break
                fi
            done
        fi
        
        #for executed with issues
        if [[ $found -eq 0 ]]; then
            for element in ${executedWithIssues[@]}; do
                if [[ $element ==  $i ]]; then
                    diff=${diffArr[$i]}

                    penalty=$(echo "$penalty" | tr -d '[:space:]')
                    totalMarks=$(echo "$totalMarks" | tr -d '[:space:]')
                    diff=$(echo "$diff" | tr -d '[:space:]')
        
                    deductedTemp=$(( diff * penalty ))
                    temp=$((totalMarks - deductedTemp))
                    mark=$((temp - penaltyForViolation))
                    deducted=$((0 - deductedTemp))
                    found=1
                    remark="${issueArr[$i]}"
                    break
                fi
            done
        fi

        #executed properly
        if [[ $found -eq 0 ]]; then
            for element in ${executedProperly[@]}; do
                if [[ $element ==  $i ]]; then

                    diff=${diffArr[$i]}
                    
                    penalty=$(echo "$penalty" | tr -d '[:space:]')
                    totalMarks=$(echo "$totalMarks" | tr -d '[:space:]')
                    diff=$(echo "$diff" | tr -d '[:space:]')

                    # Ensure variables are numeric before performing arithmetic
                    if [[ -z "$diff" || -z "$penalty" || -z "$totalMarks" ]]; then
                        echo "One of the variables is not initialized correctly."
                    else
                    # Perform arithmetic only if values are valid
                        temp=$((diff * penalty))   # Calculate deducted marks
                        
                        ##extra----fix
                        #file submit
                        for ch in "${fileSubmitted[@]}";do
                            if [[ $ch == $i ]];then
                                issueArr[$i]="#case 2"
                                temp=$((temp + penaltyForViolation))
                            fi
                        done
                        ##folder submit
                        for ch in "${folderSubmitted[@]}";do
                            if [[ $ch == $i ]];then
                                issueArr[$i]="#case 2"
                                temp=$((temp + penaltyForViolation))
                            fi
                        done

                       
                        mark=$((totalMarks - temp)) # Calculate final marks
                        deducted=$((0 - temp))


                    fi
                    found=1
                    break
                fi
            done
        fi

        ##for not submission
        if [[ $found -eq 0 ]]; then
            mark=0
            deducted=$((0 - 100))
            remark="not submitted"
            found=1
        fi
        #

        ##check plagiarism
        plagName="$plagiarismFile"
        while IFS= read -r line; do
            cid=$(echo "$line" | tr -d '[:space:]')
            if [[ "$cid" == "$i" ]]; then
                issueArr[$i]="copy"
                echo "copy------$cid"
                remark="copy"
                deducted=$((0 - plagiarismPenalty))
                break
            fi
        done < "$plagName"


        remark=$(echo "${issueArr[$i]}" | tr -d '[:space:]')
        echo "$i,$mark,$deducted,$totalMarks,$remark" >> "${workingDirectory}/2005110_report.csv"

        found=0
        mark=0
        remark=""
        deducted=0
    done
}



###initialize code

# Function to initialize variables from a file
initialize_all() {
    filePath=$1
    echo "Initializing from file: $filePath"
    filename=$filePath

    i=1
    while IFS= read -r line; do
        # Split the line into an array
        read -r -a fields <<< "$line"

        case $i in
            1) useArchieve="${fields[0]}"
                echo "useArchieve: $useArchieve"
                ;;
            2)
                allowedArchieveFormats=("${fields[@]}")
                echo "allowedArchieveFormats: ${allowedArchieveFormats[@]}"
                ;;
            3)allowedLanguage=("${fields[@]}")
                echo "allowedLanguage: ${allowedLanguage[@]}"
                ;;
            4) totalMarks="${fields[0]}"
                echo "totalMarks: $totalMarks"
                ;;
            5) penalty="${fields[0]}"
                echo "penalty: $penalty"
                ;;

            6) workingDirectory="${fields[0]}" ##fixxx
                workingDirectory=$(echo "$workingDirectory" | tr -d '[:space:]')
                echo "workingDirectory: $workingDirectory"
                ;;

            7)
                sidRange=("${fields[@]}")
                echo "sidRange: ${sidRange[@]}"
                ;;

            8) outputFileLocation="${fields[0]}"
                echo "outputFileLocation: $outputFileLocation"
                ;;

            9) penaltyForViolation="${fields[0]}"
                penaltyForViolation=$(echo "$penaltyForViolation" | tr -d '[:space:]')
                echo "penaltyForViolation: $penaltyForViolation"
                ;;

            10) plagiarismFile="${fields[0]}"
                plagiarismFile=$(echo "$plagiarismFile" | tr -d '[:space:]')
                echo "plagiarismFile: $plagiarismFile"
                ;;

            11) plagiarismPenalty="${fields[0]}"
                plagiarismPenalty=$(echo "$plagiarismPenalty" | tr -d '[:space:]')
                echo "plagiarism penalty: $plagiarismPenalty"
                ;;
        esac

        i=$((i + 1))

    done < "$filename"
}

# Main function
main() {
    while getopts ":i:" opt; do
        case $opt in
            i)
                inputPath="$OPTARG"
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                exit 1
                ;;
            :)
                echo "Option -$OPTARG requires a path argument." >&2
                exit 1
                ;;
        esac
    done

    if [ -n "$inputPath" ]; then
        initialize_all "$inputPath"
        # Rest of the function calls
        goto_working_directory
        make_evaluable
        do_evaluation
        report_generate
        echo "file submitted: ${fileSubmitted[@]}"
    else
        echo "Usage: $0 -i path_to_file" >&2
        exit 1
    fi
}

main "$@"






