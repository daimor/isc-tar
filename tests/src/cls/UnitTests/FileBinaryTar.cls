Class UnitTests.FileBinaryTar Extends %UnitTest.TestCase
{

/// Path to examples files
Property Path As %String;

Method OnBeforeAllTests() As %Status
{
  set ..Path = ##class(%File).NormalizeDirectory("data", ##class(%File).ParentDirectoryName(^UnitTestRoot))
  Quit $$$OK
}

/// Testing extract archive
Method TestExtract()
{
  set fileName = ##class(%File).NormalizeFilename("test.tgz", ##class(%File).ParentDirectoryName(..Path))
  set extracted = ##class(%zUtils.FileBinaryTar).ExtractFile(fileName)
  do ..CheckExtracted(extracted)
}

Method CompareFolders(pOriginal As %String, pNew As %String)
{
  Set tRS = ##class(%File).FileSetFunc(pOriginal)
  While tRS.%Next() {
    If tRS.Type="D" {
      Do ..CompareFolders(tRS.Name, ##class(%File).NormalizeDirectory(tRS.ItemName, pNew))
    }
    ElseIf tRS.Type="F" {
      set tName = tRS.ItemName
      If ($LISTFIND($LISTBUILD("tar", "tgz"), $$$lcase($PIECE(tName, ".", *)))) {
        CONTINUE 
      }
      set tNewName = ##class(%File).NormalizeDirectory(pNew) _ tName
      if $$$AssertTrue(##class(%File).Exists(tNewName), tNewName) {
        do $$$AssertEquals(##class(%File).GetFileSize(tNewName), ##class(%File).GetFileSize(tRS.Name))
      }
    }
  }
}

Method CheckExtracted(extracted As %zUtils.FileBinaryTar) [ Internal ]
{
  do $$$AssertTrue($isobject(extracted), "Extract successful")
  do $$$AssertStatusOK(extracted.FindPath("folder", .folder), "root folder")
  do $$$AssertStatusOK(extracted.FindPath("folder/subfolder/test.txt", .file), "test.txt in the subfolder")
  if $$$AssertEquals(file.fileData.Read(), "test file in subfolder", "right content") {
  do $$$AssertStatusOK(folder.FindPath("test.txt", .file), "test.txt in the folder") }
  do $$$AssertEquals(file.fileData.Read(), "test file in folder", "right content")
  do $$$AssertStatusOK(folder.FindPath("file with spaces.txt", .file), "file with spaces.txt in the folder")
  do $$$AssertEquals(file.fileData.Read(), "test content for file with spaces", "right content")
  if $$$AssertStatusOK(extracted.FindPath("folder with spaces/test.txt", .file), "test.txt in the folder with spaces") {
  do $$$AssertEquals(file.fileData.Read(), "test file in folder with spaces", "right content") }
  if $$$AssertStatusOK(extracted.FindPath("folder with spaces/file with spaces.txt", .file), "file with spaces.txt in the folder with spaces") {
  do $$$AssertEquals(file.fileData.Read(), "test content for file with spaces", "right content") }
 
  set tmpDir = $$$FileTempDir
  do $$$AssertStatusOK(extracted.ExtractTo(tmpDir))

  Do ..CompareFolders(..Path, tmpDir)

  do ##class(%File).RemoveDirectoryTree(tmpDir)
}

/// Testing Compact some data to archive
Method TestCompact()
{
  set path = ##class(%File).NormalizeDirectory(..Path)
  set tmpFile = ##class(%File).TempFilename("tgz")
  set archive = ##class(%zUtils.FileBinaryTar).Compact(path, 0, tmpFile, path)
  do $$$AssertTrue(##class(%File).Exists(tmpFile), "New archive created")  

  do archive.Rewind()
  set extracted = ##class(%zUtils.FileBinaryTar).ExtractStream(archive)
  do ..CheckExtracted(extracted)
  #; Do ##class(%File).Delete(tmpFile)
  zw tmpFile
}

}
