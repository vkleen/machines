#!@shell@
backend=${0}
jobid=${1}
cupsuser=${2}
jobtitle=${3}
jobcopies=${4}
joboptions=${5}
jobfile=${6}

rmapi=@RMAPI@
export RMAPI_HOST=@cloudUrl@
export RMAPI_CONFIG=@RMAPI_CONFIG@

printtime=$(@date@ +%Y-%b-%d-%H-%M)
sanitized_jobtitle="$(echo ${jobtitle} | @tr@ [[:blank:]:/%\&=+?\\\\#\'\`\´\*] _ | @sed@ 's/ü/u/g;s/ä/a/g;s/ö/o/g;s/Ü/U/g;s/Ä/A/g;s/Ö/O/g;s/{\\ß}/ss/g' | @cut@ -f 1 -d '.' ).pdf"
outname=/tmp/${printtime}_${sanitized_jobtitle}

case ${#} in
    0)
        # this case is for "backend discovery mode"
        echo "Remarkable Printer \"Mark Meyer\" \"Backend to print directly to Remarkable cloud\""
        exit 0
        ;;

    5)
        # backend needs to read from stdin if number of arguments is 5
        @cat@ > ${outname}
        if [ ! -e ${DEVICE_URI#remarkable:} ]; then
            ${rmapi} put ${outname} ${DEVICE_URI#remarkable:}
        else
            ${rmapi} put ${outname}
        fi
        ;;

    6)
        @cat@ ${6} > ${outname}
        if [ ! -e ${DEVICE_URI#remarkable:} ]; then
            ${rmapi} put ${outname} ${DEVICE_URI#remarkable:}
        else
            ${rmapi} put ${outname}
        fi
        ;;
esac
@rm@ ${outname}

echo 1>&2

exit 0
