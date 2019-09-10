#!/bin/awk -v app=Apache.JMeter -v param=test.jmx -v maxN=100 -f sjk.hh.2.influx.awk

function escapeField(stringValue) {
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", stringValue)
       	gsub(/,/, "\\,", stringValue)
        gsub(/=/, "\\=", stringValue)
        gsub(/[[:space:]]+/, "\\ ", stringValue)
	return stringValue
}

function printTotal2influx() {
	influxMessage = "sjk.hh"
	if (appEsc != "") {
		influxMessage = influxMessage ",app=" appEsc
	}

	if (paramEsc != "") {
		influxMessage = influxMessage ",param=" paramEsc
	}

    influxMessage = influxMessage " TotalInstances=" total_Instances "i" ",TotalBytes=" total_Bytes "i"

	print influxMessage
}

function print2influx() {
	influxMessage = "sjk.hh"
	if (appEsc != "") {
		influxMessage = influxMessage ",app=" appEsc
	}

	if (paramEsc != "") {
		influxMessage = influxMessage ",param=" paramEsc
	}

	if (Type != "") {
		TypeEsc = escapeField( Type )
		influxMessage = influxMessage ",Type=" TypeEsc
	}

	if (typeNameG1 != "") {
		G1 = escapeField( typeNameG1 )
		influxMessage = influxMessage ",Group1=" G1
	}

	if (typeNameG2 != "") {
		G2 = escapeField( typeNameG2 )
		influxMessage = influxMessage ",Group2=" G2
	}

	if (typeNameG3 != "") {
		G3 = escapeField( typeNameG3 )
		influxMessage = influxMessage ",Group3=" G3
	}

    influxMessage = influxMessage " Instances=" count "i" ",Bytes=" bytes "i"

    if(countProcent != "") {
        influxMessage = influxMessage ",InstancesProcent=" sprintf("%.16f", countProcent)
    }

    if (bytesProcent != "") {
        influxMessage = influxMessage ",BytesProcent=" sprintf("%.16f", bytesProcent)
    }

	print influxMessage
}

function parseTypeName(typeName) {
    firstChar = substr(typeName, 1, 1)

    if (firstChar == "[" ) {
        return parseTypeName(substr(typeName, 2)) "[]"
    } else if (firstChar == "L"){
        if (substr(typeName, length(typeName)) == ";") {
            # return "(class)" parseTypeName(substr(typeName, 2, length(typeName) - 2 ))
            return parseTypeName(substr(typeName, 2, length(typeName) - 2 ))
        } else
            return typeName
    } else if (typeName == "Z") {
        typeNameG1 = "-"
        typeNameG2 = "-"
        typeNameG3 = "-"
        return "boolean"
    } else if (typeName == "B") {
        typeNameG1 = "-"
        typeNameG2 = "-"
        typeNameG3 = "-"
        return "byte"
    } else if (typeName == "C") {
        typeNameG1 = "-"
        typeNameG2 = "-"
        typeNameG3 = "-"
        return "char"
    } else if (typeName == "D") {
        typeNameG1 = "-"
        typeNameG2 = "-"
        typeNameG3 = "-"
        return "double"
    } else if (typeName == "F") {
        typeNameG1 = "-"
        typeNameG2 = "-"
        typeNameG3 = "-"
        return "float"
    } else if (typeName == "I") {
        typeNameG1 = "-"
        typeNameG2 = "-"
        typeNameG3 = "-"
        return "int"
    } else if (typeName == "J") {
        typeNameG1 = "-"
        typeNameG2 = "-"
        typeNameG3 = "-"
        return "long"
    } else if (typeName == "S") {
        typeNameG1 = "-"
        typeNameG2 = "-"
        typeNameG3 = "-"
        return "short"
    } else {
        split(typeName, typeNameGroup, "\\.")
        if(typeNameGroup[1] != "")
            typeNameG1 = typeNameGroup[1]
        if(typeNameGroup[2] != "") {
            typeNameG2 = typeNameGroup[1] "." typeNameGroup[2]
        } else {
            typeNameG2 = typeNameG1
        }
        if(typeNameGroup[3] != "")
            typeNameG3 = typeNameGroup[1] "." typeNameGroup[2] "." typeNameGroup[3]
        else {
            typeNameG3 = typeNameG2
        }
        return typeName
    }
}

BEGIN {
	if (app != "") {
		appEsc = escapeField( app )
	}

	if (param != "") {
		paramEsc = escapeField( param )
	}

    n = 0
}

{
    #   1:      30000     3330000  [C
    #   2:      40000      220000  java.lang.String
    if ($0 ~ "^[ ]*[0-9]+:[ ]+[0-9]+" ) {
        if (maxN == "" || (maxN != "" && n < maxN)) {
            Type = parseTypeName($4)

            STAT[n]["Type"]=Type
            STAT[n]["g1"]=typeNameG1
            STAT[n]["g2"]=typeNameG2
            STAT[n]["g3"]=typeNameG3
            STAT[n]["count"]=$2
            STAT[n]["bytes"]=$3

            n = n + 1
        }
    } else
    #Total      92000     3711111
    if ($0 ~ "^Total[ ]+[0-9]+[ ]+[0-9]+") {
        split($0, total, "[[:space:]]+")
        total_Instances=total[2]
        total_Bytes=total[3]
    }
}

END {
    printTotal2influx()
    for (n in STAT) {
        Type = STAT[n]["Type"]
        typeNameG1 = STAT[n]["g1"]
        typeNameG2 = STAT[n]["g2"]
        typeNameG3 = STAT[n]["g3"]
        count = STAT[n]["count"]
        bytes = STAT[n]["bytes"]
        if (total_Instances != "")
            countProcent = 100.0 * count / total_Instances
        else
            countProcent = ""
        if (total_Bytes != "")
            bytesProcent = 100.0 * bytes / total_Bytes
        else
            bytesProcent = ""

        print2influx()
    }
}