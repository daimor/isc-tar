Class UnitTests.FileBinaryTar Extends %UnitTest.TestCase
{

/// Path to examples files
Parameter PATH = "/opt/tests/data/";

/// Testing extract archive
Method TestExtract()
{
  set fileName = ##class(%File).NormalizeFilename("test.tgz", ..#PATH)
  set extracted = ##class(%zUtils.FileBinaryTar).ExtractFile(fileName)
  do ..CheckExtracted(extracted)
}

Method CheckExtracted(extracted As %zUtils.FileBinaryTar) [ Internal ]
{
  do $$$AssertTrue($isobject(extracted), "Extract successful")
  do $$$AssertStatusOK(extracted.FindPath("folder", .folder), "root folder")
  do $$$AssertStatusOK(extracted.FindPath("folder/subfolder/test.txt", .file), "test.txt in the subfolder")
  do $$$AssertEquals(file.fileData.Read(), "test file in subfolder", "right content")
  do $$$AssertStatusOK(folder.FindPath("test.txt", .file), "test.txt in the folder")
  do $$$AssertEquals(file.fileData.Read(), "test file in folder", "right content")
  set tmpDir = $$$FileTempDir
  do $$$AssertStatusOK(extracted.ExtractTo(tmpDir))
  do $$$AssertTrue(##class(%File).DirectoryExists(##class(%File).NormalizeDirectory("folder", tmpDir)))
  do $$$AssertTrue(##class(%File).DirectoryExists(##class(%File).NormalizeDirectory("folder/subfolder", tmpDir)))
  
  set file = ##class(%File).NormalizeFilename("folder/test.txt", tmpDir)
  do $$$AssertTrue(##class(%File).Exists(file))
  do $$$AssertEquals(##class(%File).GetFileSize(file), 19)
  
  set file = ##class(%File).NormalizeFilename("folder/subfolder/test.txt", tmpDir)
  do $$$AssertTrue(##class(%File).Exists(file))
  do $$$AssertEquals(##class(%File).GetFileSize(file), 22)

  do ##class(%File).RemoveDirectoryTree(tmpDir)
}

/// Testing Compact some data to archive
Method TestCompact()
{
  set path = ##class(%File).NormalizeDirectory("folder", ..#PATH)
  set tmpFile = ##class(%File).TempFilename("tgz")
  set archive = ##class(%zUtils.FileBinaryTar).Compact(path, 0, tmpFile)
  do $$$AssertTrue(##class(%File).Exists(tmpFile), "New archive created")  

  do archive.Rewind()
  set extracted = ##class(%zUtils.FileBinaryTar).ExtractStream(archive)
  do ..CheckExtracted(extracted)
  Do ##class(%File).Delete(tmpFile)
}

}
