# Objective C Adapter Windows build POC

## Purpose

The goal is to have a basic Objective C adapter test application running in a Windows environment as described in IPS-6 (https://pep.foundation/jira/browse/IPS-6)

## Development

It starts from a basic hello world ObjC application to test the basic ObjC compilation (found in gnustep-test1 folder).

Then, the complete libpEpObjCAdapter and pEpObjCAdapterTest (which is the test application) compilation. The last version of the engine is also built.

A lot of different configurations and tools were tested in this POC, but only the successful ones are explained in this doc.

### libpEpObjCAdapter 

To build ObjC in Windows GNUstep is used as framework that implements almost any ObjC need. There is a toolchain for msvc that fits for the purpose (https://github.com/gnustep/tools-windows-msvc). It has to be installed following its readme.

The ObjC applications and libraries must be compiled and linked using clang, so LLVM tools have to be installed (https://releases.llvm.org/). In this POC the version 11.0 was used. Also, clang compiler tools component must be installed in Visual Studio (https://docs.microsoft.com/en-us/cpp/build/clang-support-msbuild?view=msvc-170)

The adapter builds a static library that will be used later by test application. Project files can be found in libpEpObjCAdapter folder. One solution for each project and subproject is found. Project must be configured to use LLVM (clang) as platform toolset and every ObjC file included in the project that has to be compiled (presumably .m files) must be configured as C/C++ compiler in the item type (then apply) and, in the advanced properties "Compile As" must be blank (not Default).

### libpEpObjCAdapterTest

Implements a basic message encryption and is written in ObjC. 

The project can be configured as a Console application. The project, as in libpEpObjCAdapter, must be configured to use clang and all the individual files must be configured to compile C/C++, just the same. 
It must be linked with GNUstep but also with all the libpEpIbjCAdapter projects. 
To make the libpEpObjCAdapter ObjC extensions to work all the static libraries with extensions must be included using the 'wholearchive' option. The project contains all the necessary options and configurations to build it properly. 

### Engine

To start, the document https://dev.pep.security/Windows/How%20to%20build%20pEp%20for%20Windows was followed. It explains how to build Outlook plugin, but it includes the procedure to build the engine. Unfortunately, for the last engine version, which would be required for the project, not all the steps worked as expected and some modifications have been applied. 
This modifications are:
 - libnettle, libhogweed and libgmp from mingw64 did not work as expected as they were crashing, so the ones found as vcpkg packages are the ones used. vcpkg is a package manager from Microsoft integrated with Visual Studio that has a big librariy and framework catalog. This link (https://vcpkg.io/en/getting-started.html) explains how to install. From there, to import those dependencies the command "vcpkg.exe install nettle:x64-windows" installs them for a x64 architecture. 

- In GeneralizedTime.c setenv and unsetenv had to be implemented 

- setenv, unsetenv in GeneralizedTime.c as follows
```C++
int setenv(const char* name, const char* value, int overwrite)
{
	int errcode = 0;
	if (!overwrite) {
		size_t envsize = 0;
		errcode = getenv_s(&envsize, NULL, 0, name);
		if (errcode || envsize) return errcode;
	}
	return _putenv_s(name, value);
}
int unsetenv(const char* name)
{
	int errcode = 0;
	return _putenv_s(name, "");
}
```

- Some modifications to the projects and generate_code.cmd were applied in order to avoid error that were no related to the purpose of this POC

## Conclusions

The goal is accomplished, but there is still work to do like ensure the dependencies work correctly in all cases, fix lots of warnings when compiling and linking in ObjC but also C/C++ and create a proper build system based on more standardized tools.



