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
}

/// Testing Compact some data to archive
Method TestCompact()
{
  set path = ##class(%File).NormalizeDirectory("folder", ..#PATH)
  set archive = ##class(%zUtils.FileBinaryTar).Compact(path, 0)

  do archive.Rewind()
  set extracted = ##class(%zUtils.FileBinaryTar).ExtractStream(archive)
  do ..CheckExtracted(extracted)
}

}
