Class UnitTests.FileBinaryTar Extends %UnitTest.TestCase
{

/// Path to examples files
Parameter PATH = "/opt/data/";

Method TestExtract()
{
    set fileName = ##class(%File).NormalizeFilename("test.tgz", ..#PATH)
    set extracted = ##class(%zUtils.FileBinaryTar).ExtractFile(fileName)
    do $$$AssertTrue($isobject(extracted), "Extract successful")
    do $$$AssertStatusOK(extracted.FindPath("folder", .folder), "root folder")
    do $$$AssertStatusOK(extracted.FindPath("folder/subfolder/test.txt", .file), "test.txt in the subfolder")
    do $$$AssertEquals(file.fileData.Read(), "test file in subfolder", "right content")
    do $$$AssertStatusOK(folder.FindPath("test.txt", .file), "test.txt in the folder")
    do $$$AssertEquals(file.fileData.Read(), "test file in folder", "right content")
}

}
