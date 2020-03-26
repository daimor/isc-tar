[![Gitter](https://img.shields.io/badge/Available%20on-Intersystems%20Open%20Exchange-00b2a9.svg)](https://openexchange.intersystems.com/package/isc-tar)

Tar compress tool for InterSystems products
===
This tool helps to extract data right from `tar.gz` or just `tar` archives with ObjectScript. Or compact any files/folders with tar format and make `tar.gz`.

Standalone installation
---
Import and compile file [`zUtils.FileBinaryTar.xml`](https://github.com/daimor/isc-tar/releases/latest) to `%SYS` namespace.

Development mode 
---
```
docker-compose up -d --build
```
Avialable in any namespace, code stored in %SYS.

Examples
---
Extract `tar.gz` file
```ObjectScript
  Set gzip = 1
  Set extracted = ##class(%zUtils.FileBinaryTar).ExtractFile("/tmp/some.tgz", gzip)
  Set tSC = extracted.FindPath("folder/subfolder/test.txt", .file)
  Set fileContent = file.fileData
  While 'fileContent.AtEnd {
    /// read file from archive
  }
  Set tSC = extracted.ExtractTo("/tmp/some/place")
```

Compact folder/file to `tar.gz` file
```ObjectScript
  Set gzip = 1
  Set archive = ##class(%zUtils.FileBinaryTar).Compact("/tmp/some/place", gzip, "/tmp/some.tgz")
```
