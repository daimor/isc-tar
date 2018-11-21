Class %zUtils.FileBinaryTar Extends (%RegisteredObject, %ArrayOfDataTypes)
{

/// name of file
Property name As %String(CAPTION = "Header", MAXLEN = 100, TRUNCATE = 0);

/// file mode
Property mode As %String(CAPTION = "Header", MAXLEN = 8);

/// owner user ID
Property uid As %String(CAPTION = "Header", MAXLEN = 8);

/// owner group ID
Property gid As %String(CAPTION = "Header", MAXLEN = 8);

/// length of file in bytes
Property size As %String(CAPTION = "Header", MAXLEN = 12);

/// modify time of file
Property mtime As %String(CAPTION = "Header", MAXLEN = 12);

/// checksum for header
Property chksum As %String(CAPTION = "Header", MAXLEN = 8);

/// type of file
Property typeflag As %String(CAPTION = "Header", DISPLAYLIST = ",REGULAR,LINK,RESERVED,CHARACTER SPECIAL,BLOCK SPECIAL,DIRECTORY,FIFO SPECIAL,RESERVED", MAXLEN = 1, VALUELIST = ",0,1,2,3,4,5,6,7,x,g,L,K");

/// name of linked file
Property linkname As %String(CAPTION = "Header", MAXLEN = 100);

/// USTAR indicator
Property magic As %String(CAPTION = "Header", MAXLEN = 6);

/// USTAR version
Property version As %String(CAPTION = "Header", MAXLEN = 2);

/// owner user name
Property uname As %String(CAPTION = "Header", MAXLEN = 32);

/// owner group name
Property gname As %String(CAPTION = "Header", MAXLEN = 32);

/// device major number
Property devmajor As %String(CAPTION = "Header", MAXLEN = 8);

/// device minor number
Property devminor As %String(CAPTION = "Header", MAXLEN = 8);

/// prefix for file name
Property prefix As %String(CAPTION = "Header", MAXLEN = 155);

/// file data
Property fileData As %Stream.Object;

Method nameGet() As %String
{
	quit i%prefix_i%name
}

Method sizeGet() As %Integer
{
	quit $$oct2dec^%Wmdc(i%size)
}

Method sizeSet(pSize As %Integer) As %Status
{
	set i%size=$translate($justify($$dec2oct^%Wmdc(pSize),11)," ",0)
	quit:$length(i%size)>11 $$$ERROR(5001, "Size too big")
	quit $$$OK
}

Method FindPath(pPath As %String = "", Output found As FileBinaryTar) As %Status
{
	set found = $$$NULLOREF
	set pPath = $tr(pPath, "\", "/")
	set tmp = ..GetAt($p(pPath, "/"))
	if '$isobject(tmp) {
		return $$$ERROR($$$GeneralError, "not found")
	}
	if $l(pPath, "/")>1 {
		return tmp.FindPath($p(pPath, "/", 2, *), .found)
	}
	set found = tmp
	quit $$$OK
}

ClassMethod ExtractFile(aFileName As %String = "", Gzip As %Boolean = 1) As FileBinaryTar
{
	if aFileName = "" quit $$$ERROR($$$GeneralError, "Filename not specified")
	if Gzip {
		set fileStream=##class(%Stream.FileBinaryGzip).%New()
	} else {
		set fileStream=##class(%Stream.FileBinary).%New()
	}
	set fileStream.Filename=aFileName
	quit ..ExtractStream(fileStream)
}

ClassMethod ExtractStream(aFileStream As %Stream.Object) As FileBinaryTar
{
	#dim blockSize As %Integer = 512
	set result=..%New()
	while 'aFileStream.AtEnd {
		set tFile=..%New()
		set longLink4Name=""
		set longLink4Link=""
		do {
			set tHeader=aFileStream.Read(blockSize)
			do tFile.ParseHeader(tHeader)
			set magic=tFile.magic
			quit:tFile.name=""
			set fileSize=tFile.size
			set typeFlag=tFile.typeflag
			if (typeFlag="L") || (typeFlag="K") {
				set readBlocks=fileSize \ blockSize
				set:fileSize#blockSize>0 readBlocks=readBlocks + 1
				set longLink=aFileStream.Read(readBlocks * blockSize)
				set longLink=$zstrip(longLink,"<>",$char(0,32))
				set:(typeFlag="L") longLink4Name=longLink
				set:(typeFlag="K") longLink4Link=longLink
				set repeat=1
				continue
			}
			set repeat=0
			set:longLink4Name'="" tFile.name=longLink4Name
			set:longLink4Link'="" tFile.linkname=longLink4Link
		} while repeat
		set fileName=tFile.name
		quit:fileName=""
		if tFile.typeflag'="g" {
			do ..AddToArray(tFile, result)
		}
		continue:fileSize=0
		set readBlocks=fileSize \ blockSize
		set:fileSize#blockSize>0 readBlocks=readBlocks + 1
		set tFile.fileData=##class(%Stream.FileBinary).%New()
		for tPos=1:1:readBlocks {
			set tData=aFileStream.Read(512)
			set:tPos=readBlocks tData=$extract(tData, 1, fileSize#blockSize)
			do tFile.fileData.Write(tData)
		}
	}
	quit result
}

ClassMethod AddToArray(pFile As FileBinaryTar, pArray As FileBinaryTar) [ Internal, Private ]
{
	quit:'$isobject(pFile)
	quit:'$isobject(pArray)
	
	set tFileName= $zstrip(pFile.name,"<>", "/")
	set tItem=pArray
	for i=1:1:$length(tFileName, "/")-1 {
		set tPathItem=$piece(tFileName, "/", i)
		if 'tItem.IsDefined(tPathItem) {
			do tItem.SetAt(..%New(), tPathItem)
		}
		set tItem=tItem.GetAt(tPathItem)
	}
	do tItem.SetAt(pFile, $piece(tFileName, "/", $length(tFileName, "/")))
}

Method ParseHeader(aHeaderData As %String) [ CodeMode = objectgenerator ]
{
	set tProps=%class.Properties
	Set tPropKey = ""
	For {
		Set tProp = %class.Properties.GetNext(.tPropKey)
		Quit:(tPropKey = "")
		CONTINUE:"Header"'=tProp.Parameters.GetAt("CAPTION")
		set tProps(tProp.SequenceNumber)=tProp
	}	
	Set tPropKey = "", tPos = 0
	For {
		Set tPropKey = $Order(tProps(tPropKey),1,tProp)
		Quit:tPropKey=""
		Set tLen = tProp.Parameters.GetAt("MAXLEN")
		Do %code.WriteLine($char(9)_"Set i%"_tProp.Name_" = $zstrip($extract(aHeaderData, "_$increment(tPos)_", "_$increment(tPos, tLen - 1)_"), ""<>"", $c(0,32))")
		Do:tProp.Name="typeflag" %code.WriteLine($char(9)_"Set:i%"_tProp.Name_"=$c(0) i%"_tProp.Name_" = 0")
	}
	quit $$$OK
}

}
