
obj/user/evilhello.debug：     文件格式 elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 65 00 00 00       	call   8000aa <sys_cputs>
}
  800045:	83 c4 10             	add    $0x10,%esp
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800055:	e8 ce 00 00 00       	call   800128 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 40 80 00       	mov    %eax,0x804004

    // save the name of the program so that panic() can use it
    if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
        binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800096:	e8 87 04 00 00       	call   800522 <close_all>
	sys_env_destroy(0);
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 42 00 00 00       	call   8000e7 <sys_env_destroy>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bb:	89 c3                	mov    %eax,%ebx
  8000bd:	89 c7                	mov    %eax,%edi
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d8:	89 d1                	mov    %edx,%ecx
  8000da:	89 d3                	mov    %edx,%ebx
  8000dc:	89 d7                	mov    %edx,%edi
  8000de:	89 d6                	mov    %edx,%esi
  8000e0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fd:	89 cb                	mov    %ecx,%ebx
  8000ff:	89 cf                	mov    %ecx,%edi
  800101:	89 ce                	mov    %ecx,%esi
  800103:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800105:	85 c0                	test   %eax,%eax
  800107:	7e 17                	jle    800120 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800109:	83 ec 0c             	sub    $0xc,%esp
  80010c:	50                   	push   %eax
  80010d:	6a 03                	push   $0x3
  80010f:	68 4a 1e 80 00       	push   $0x801e4a
  800114:	6a 23                	push   $0x23
  800116:	68 67 1e 80 00       	push   $0x801e67
  80011b:	e8 21 0f 00 00       	call   801041 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5f                   	pop    %edi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    

00800128 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	57                   	push   %edi
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 02 00 00 00       	mov    $0x2,%eax
  800138:	89 d1                	mov    %edx,%ecx
  80013a:	89 d3                	mov    %edx,%ebx
  80013c:	89 d7                	mov    %edx,%edi
  80013e:	89 d6                	mov    %edx,%esi
  800140:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_yield>:

void
sys_yield(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	57                   	push   %edi
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014d:	ba 00 00 00 00       	mov    $0x0,%edx
  800152:	b8 0b 00 00 00       	mov    $0xb,%eax
  800157:	89 d1                	mov    %edx,%ecx
  800159:	89 d3                	mov    %edx,%ebx
  80015b:	89 d7                	mov    %edx,%edi
  80015d:	89 d6                	mov    %edx,%esi
  80015f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
  80016c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016f:	be 00 00 00 00       	mov    $0x0,%esi
  800174:	b8 04 00 00 00       	mov    $0x4,%eax
  800179:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800182:	89 f7                	mov    %esi,%edi
  800184:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800186:	85 c0                	test   %eax,%eax
  800188:	7e 17                	jle    8001a1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	50                   	push   %eax
  80018e:	6a 04                	push   $0x4
  800190:	68 4a 1e 80 00       	push   $0x801e4a
  800195:	6a 23                	push   $0x23
  800197:	68 67 1e 80 00       	push   $0x801e67
  80019c:	e8 a0 0e 00 00       	call   801041 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a4:	5b                   	pop    %ebx
  8001a5:	5e                   	pop    %esi
  8001a6:	5f                   	pop    %edi
  8001a7:	5d                   	pop    %ebp
  8001a8:	c3                   	ret    

008001a9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	57                   	push   %edi
  8001ad:	56                   	push   %esi
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	7e 17                	jle    8001e3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	50                   	push   %eax
  8001d0:	6a 05                	push   $0x5
  8001d2:	68 4a 1e 80 00       	push   $0x801e4a
  8001d7:	6a 23                	push   $0x23
  8001d9:	68 67 1e 80 00       	push   $0x801e67
  8001de:	e8 5e 0e 00 00       	call   801041 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5e                   	pop    %esi
  8001e8:	5f                   	pop    %edi
  8001e9:	5d                   	pop    %ebp
  8001ea:	c3                   	ret    

008001eb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	57                   	push   %edi
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800201:	8b 55 08             	mov    0x8(%ebp),%edx
  800204:	89 df                	mov    %ebx,%edi
  800206:	89 de                	mov    %ebx,%esi
  800208:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020a:	85 c0                	test   %eax,%eax
  80020c:	7e 17                	jle    800225 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	6a 06                	push   $0x6
  800214:	68 4a 1e 80 00       	push   $0x801e4a
  800219:	6a 23                	push   $0x23
  80021b:	68 67 1e 80 00       	push   $0x801e67
  800220:	e8 1c 0e 00 00       	call   801041 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800225:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800228:	5b                   	pop    %ebx
  800229:	5e                   	pop    %esi
  80022a:	5f                   	pop    %edi
  80022b:	5d                   	pop    %ebp
  80022c:	c3                   	ret    

0080022d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023b:	b8 08 00 00 00       	mov    $0x8,%eax
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	8b 55 08             	mov    0x8(%ebp),%edx
  800246:	89 df                	mov    %ebx,%edi
  800248:	89 de                	mov    %ebx,%esi
  80024a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80024c:	85 c0                	test   %eax,%eax
  80024e:	7e 17                	jle    800267 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	50                   	push   %eax
  800254:	6a 08                	push   $0x8
  800256:	68 4a 1e 80 00       	push   $0x801e4a
  80025b:	6a 23                	push   $0x23
  80025d:	68 67 1e 80 00       	push   $0x801e67
  800262:	e8 da 0d 00 00       	call   801041 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800278:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027d:	b8 09 00 00 00       	mov    $0x9,%eax
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	8b 55 08             	mov    0x8(%ebp),%edx
  800288:	89 df                	mov    %ebx,%edi
  80028a:	89 de                	mov    %ebx,%esi
  80028c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028e:	85 c0                	test   %eax,%eax
  800290:	7e 17                	jle    8002a9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	83 ec 0c             	sub    $0xc,%esp
  800295:	50                   	push   %eax
  800296:	6a 09                	push   $0x9
  800298:	68 4a 1e 80 00       	push   $0x801e4a
  80029d:	6a 23                	push   $0x23
  80029f:	68 67 1e 80 00       	push   $0x801e67
  8002a4:	e8 98 0d 00 00       	call   801041 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ca:	89 df                	mov    %ebx,%edi
  8002cc:	89 de                	mov    %ebx,%esi
  8002ce:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002d0:	85 c0                	test   %eax,%eax
  8002d2:	7e 17                	jle    8002eb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	50                   	push   %eax
  8002d8:	6a 0a                	push   $0xa
  8002da:	68 4a 1e 80 00       	push   $0x801e4a
  8002df:	6a 23                	push   $0x23
  8002e1:	68 67 1e 80 00       	push   $0x801e67
  8002e6:	e8 56 0d 00 00       	call   801041 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f9:	be 00 00 00 00       	mov    $0x0,%esi
  8002fe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800303:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800306:	8b 55 08             	mov    0x8(%ebp),%edx
  800309:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	57                   	push   %edi
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
  80031c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800324:	b8 0d 00 00 00       	mov    $0xd,%eax
  800329:	8b 55 08             	mov    0x8(%ebp),%edx
  80032c:	89 cb                	mov    %ecx,%ebx
  80032e:	89 cf                	mov    %ecx,%edi
  800330:	89 ce                	mov    %ecx,%esi
  800332:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800334:	85 c0                	test   %eax,%eax
  800336:	7e 17                	jle    80034f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800338:	83 ec 0c             	sub    $0xc,%esp
  80033b:	50                   	push   %eax
  80033c:	6a 0d                	push   $0xd
  80033e:	68 4a 1e 80 00       	push   $0x801e4a
  800343:	6a 23                	push   $0x23
  800345:	68 67 1e 80 00       	push   $0x801e67
  80034a:	e8 f2 0c 00 00       	call   801041 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800352:	5b                   	pop    %ebx
  800353:	5e                   	pop    %esi
  800354:	5f                   	pop    %edi
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
  800362:	c1 e8 0c             	shr    $0xc,%eax
}
  800365:	5d                   	pop    %ebp
  800366:	c3                   	ret    

00800367 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80036a:	8b 45 08             	mov    0x8(%ebp),%eax
  80036d:	05 00 00 00 30       	add    $0x30000000,%eax
  800372:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800377:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800384:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800389:	89 c2                	mov    %eax,%edx
  80038b:	c1 ea 16             	shr    $0x16,%edx
  80038e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800395:	f6 c2 01             	test   $0x1,%dl
  800398:	74 11                	je     8003ab <fd_alloc+0x2d>
  80039a:	89 c2                	mov    %eax,%edx
  80039c:	c1 ea 0c             	shr    $0xc,%edx
  80039f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a6:	f6 c2 01             	test   $0x1,%dl
  8003a9:	75 09                	jne    8003b4 <fd_alloc+0x36>
			*fd_store = fd;
  8003ab:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b2:	eb 17                	jmp    8003cb <fd_alloc+0x4d>
  8003b4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003be:	75 c9                	jne    800389 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003c0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003c6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d3:	83 f8 1f             	cmp    $0x1f,%eax
  8003d6:	77 36                	ja     80040e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d8:	c1 e0 0c             	shl    $0xc,%eax
  8003db:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 16             	shr    $0x16,%edx
  8003e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 24                	je     800415 <fd_lookup+0x48>
  8003f1:	89 c2                	mov    %eax,%edx
  8003f3:	c1 ea 0c             	shr    $0xc,%edx
  8003f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fd:	f6 c2 01             	test   $0x1,%dl
  800400:	74 1a                	je     80041c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800402:	8b 55 0c             	mov    0xc(%ebp),%edx
  800405:	89 02                	mov    %eax,(%edx)
	return 0;
  800407:	b8 00 00 00 00       	mov    $0x0,%eax
  80040c:	eb 13                	jmp    800421 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800413:	eb 0c                	jmp    800421 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800415:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041a:	eb 05                	jmp    800421 <fd_lookup+0x54>
  80041c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800421:	5d                   	pop    %ebp
  800422:	c3                   	ret    

00800423 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800423:	55                   	push   %ebp
  800424:	89 e5                	mov    %esp,%ebp
  800426:	83 ec 08             	sub    $0x8,%esp
  800429:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80042c:	ba f4 1e 80 00       	mov    $0x801ef4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800431:	eb 13                	jmp    800446 <dev_lookup+0x23>
  800433:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800436:	39 08                	cmp    %ecx,(%eax)
  800438:	75 0c                	jne    800446 <dev_lookup+0x23>
			*dev = devtab[i];
  80043a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043f:	b8 00 00 00 00       	mov    $0x0,%eax
  800444:	eb 2e                	jmp    800474 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800446:	8b 02                	mov    (%edx),%eax
  800448:	85 c0                	test   %eax,%eax
  80044a:	75 e7                	jne    800433 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80044c:	a1 04 40 80 00       	mov    0x804004,%eax
  800451:	8b 40 48             	mov    0x48(%eax),%eax
  800454:	83 ec 04             	sub    $0x4,%esp
  800457:	51                   	push   %ecx
  800458:	50                   	push   %eax
  800459:	68 78 1e 80 00       	push   $0x801e78
  80045e:	e8 b7 0c 00 00       	call   80111a <cprintf>
	*dev = 0;
  800463:	8b 45 0c             	mov    0xc(%ebp),%eax
  800466:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80046c:	83 c4 10             	add    $0x10,%esp
  80046f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800474:	c9                   	leave  
  800475:	c3                   	ret    

00800476 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800476:	55                   	push   %ebp
  800477:	89 e5                	mov    %esp,%ebp
  800479:	56                   	push   %esi
  80047a:	53                   	push   %ebx
  80047b:	83 ec 10             	sub    $0x10,%esp
  80047e:	8b 75 08             	mov    0x8(%ebp),%esi
  800481:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800484:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800487:	50                   	push   %eax
  800488:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048e:	c1 e8 0c             	shr    $0xc,%eax
  800491:	50                   	push   %eax
  800492:	e8 36 ff ff ff       	call   8003cd <fd_lookup>
  800497:	83 c4 08             	add    $0x8,%esp
  80049a:	85 c0                	test   %eax,%eax
  80049c:	78 05                	js     8004a3 <fd_close+0x2d>
	    || fd != fd2)
  80049e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004a1:	74 0c                	je     8004af <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a3:	84 db                	test   %bl,%bl
  8004a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004aa:	0f 44 c2             	cmove  %edx,%eax
  8004ad:	eb 41                	jmp    8004f0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004af:	83 ec 08             	sub    $0x8,%esp
  8004b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b5:	50                   	push   %eax
  8004b6:	ff 36                	pushl  (%esi)
  8004b8:	e8 66 ff ff ff       	call   800423 <dev_lookup>
  8004bd:	89 c3                	mov    %eax,%ebx
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	85 c0                	test   %eax,%eax
  8004c4:	78 1a                	js     8004e0 <fd_close+0x6a>
		if (dev->dev_close)
  8004c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004cc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	74 0b                	je     8004e0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d5:	83 ec 0c             	sub    $0xc,%esp
  8004d8:	56                   	push   %esi
  8004d9:	ff d0                	call   *%eax
  8004db:	89 c3                	mov    %eax,%ebx
  8004dd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	56                   	push   %esi
  8004e4:	6a 00                	push   $0x0
  8004e6:	e8 00 fd ff ff       	call   8001eb <sys_page_unmap>
	return r;
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	89 d8                	mov    %ebx,%eax
}
  8004f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f3:	5b                   	pop    %ebx
  8004f4:	5e                   	pop    %esi
  8004f5:	5d                   	pop    %ebp
  8004f6:	c3                   	ret    

008004f7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004f7:	55                   	push   %ebp
  8004f8:	89 e5                	mov    %esp,%ebp
  8004fa:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800500:	50                   	push   %eax
  800501:	ff 75 08             	pushl  0x8(%ebp)
  800504:	e8 c4 fe ff ff       	call   8003cd <fd_lookup>
  800509:	83 c4 08             	add    $0x8,%esp
  80050c:	85 c0                	test   %eax,%eax
  80050e:	78 10                	js     800520 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	6a 01                	push   $0x1
  800515:	ff 75 f4             	pushl  -0xc(%ebp)
  800518:	e8 59 ff ff ff       	call   800476 <fd_close>
  80051d:	83 c4 10             	add    $0x10,%esp
}
  800520:	c9                   	leave  
  800521:	c3                   	ret    

00800522 <close_all>:

void
close_all(void)
{
  800522:	55                   	push   %ebp
  800523:	89 e5                	mov    %esp,%ebp
  800525:	53                   	push   %ebx
  800526:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800529:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052e:	83 ec 0c             	sub    $0xc,%esp
  800531:	53                   	push   %ebx
  800532:	e8 c0 ff ff ff       	call   8004f7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800537:	83 c3 01             	add    $0x1,%ebx
  80053a:	83 c4 10             	add    $0x10,%esp
  80053d:	83 fb 20             	cmp    $0x20,%ebx
  800540:	75 ec                	jne    80052e <close_all+0xc>
		close(i);
}
  800542:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800545:	c9                   	leave  
  800546:	c3                   	ret    

00800547 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800547:	55                   	push   %ebp
  800548:	89 e5                	mov    %esp,%ebp
  80054a:	57                   	push   %edi
  80054b:	56                   	push   %esi
  80054c:	53                   	push   %ebx
  80054d:	83 ec 2c             	sub    $0x2c,%esp
  800550:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800553:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800556:	50                   	push   %eax
  800557:	ff 75 08             	pushl  0x8(%ebp)
  80055a:	e8 6e fe ff ff       	call   8003cd <fd_lookup>
  80055f:	83 c4 08             	add    $0x8,%esp
  800562:	85 c0                	test   %eax,%eax
  800564:	0f 88 c1 00 00 00    	js     80062b <dup+0xe4>
		return r;
	close(newfdnum);
  80056a:	83 ec 0c             	sub    $0xc,%esp
  80056d:	56                   	push   %esi
  80056e:	e8 84 ff ff ff       	call   8004f7 <close>

	newfd = INDEX2FD(newfdnum);
  800573:	89 f3                	mov    %esi,%ebx
  800575:	c1 e3 0c             	shl    $0xc,%ebx
  800578:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80057e:	83 c4 04             	add    $0x4,%esp
  800581:	ff 75 e4             	pushl  -0x1c(%ebp)
  800584:	e8 de fd ff ff       	call   800367 <fd2data>
  800589:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80058b:	89 1c 24             	mov    %ebx,(%esp)
  80058e:	e8 d4 fd ff ff       	call   800367 <fd2data>
  800593:	83 c4 10             	add    $0x10,%esp
  800596:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800599:	89 f8                	mov    %edi,%eax
  80059b:	c1 e8 16             	shr    $0x16,%eax
  80059e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a5:	a8 01                	test   $0x1,%al
  8005a7:	74 37                	je     8005e0 <dup+0x99>
  8005a9:	89 f8                	mov    %edi,%eax
  8005ab:	c1 e8 0c             	shr    $0xc,%eax
  8005ae:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b5:	f6 c2 01             	test   $0x1,%dl
  8005b8:	74 26                	je     8005e0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c1:	83 ec 0c             	sub    $0xc,%esp
  8005c4:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c9:	50                   	push   %eax
  8005ca:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005cd:	6a 00                	push   $0x0
  8005cf:	57                   	push   %edi
  8005d0:	6a 00                	push   $0x0
  8005d2:	e8 d2 fb ff ff       	call   8001a9 <sys_page_map>
  8005d7:	89 c7                	mov    %eax,%edi
  8005d9:	83 c4 20             	add    $0x20,%esp
  8005dc:	85 c0                	test   %eax,%eax
  8005de:	78 2e                	js     80060e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e3:	89 d0                	mov    %edx,%eax
  8005e5:	c1 e8 0c             	shr    $0xc,%eax
  8005e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ef:	83 ec 0c             	sub    $0xc,%esp
  8005f2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f7:	50                   	push   %eax
  8005f8:	53                   	push   %ebx
  8005f9:	6a 00                	push   $0x0
  8005fb:	52                   	push   %edx
  8005fc:	6a 00                	push   $0x0
  8005fe:	e8 a6 fb ff ff       	call   8001a9 <sys_page_map>
  800603:	89 c7                	mov    %eax,%edi
  800605:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800608:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060a:	85 ff                	test   %edi,%edi
  80060c:	79 1d                	jns    80062b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	53                   	push   %ebx
  800612:	6a 00                	push   $0x0
  800614:	e8 d2 fb ff ff       	call   8001eb <sys_page_unmap>
	sys_page_unmap(0, nva);
  800619:	83 c4 08             	add    $0x8,%esp
  80061c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061f:	6a 00                	push   $0x0
  800621:	e8 c5 fb ff ff       	call   8001eb <sys_page_unmap>
	return r;
  800626:	83 c4 10             	add    $0x10,%esp
  800629:	89 f8                	mov    %edi,%eax
}
  80062b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062e:	5b                   	pop    %ebx
  80062f:	5e                   	pop    %esi
  800630:	5f                   	pop    %edi
  800631:	5d                   	pop    %ebp
  800632:	c3                   	ret    

00800633 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800633:	55                   	push   %ebp
  800634:	89 e5                	mov    %esp,%ebp
  800636:	53                   	push   %ebx
  800637:	83 ec 14             	sub    $0x14,%esp
  80063a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800640:	50                   	push   %eax
  800641:	53                   	push   %ebx
  800642:	e8 86 fd ff ff       	call   8003cd <fd_lookup>
  800647:	83 c4 08             	add    $0x8,%esp
  80064a:	89 c2                	mov    %eax,%edx
  80064c:	85 c0                	test   %eax,%eax
  80064e:	78 6d                	js     8006bd <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800650:	83 ec 08             	sub    $0x8,%esp
  800653:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800656:	50                   	push   %eax
  800657:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065a:	ff 30                	pushl  (%eax)
  80065c:	e8 c2 fd ff ff       	call   800423 <dev_lookup>
  800661:	83 c4 10             	add    $0x10,%esp
  800664:	85 c0                	test   %eax,%eax
  800666:	78 4c                	js     8006b4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800668:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80066b:	8b 42 08             	mov    0x8(%edx),%eax
  80066e:	83 e0 03             	and    $0x3,%eax
  800671:	83 f8 01             	cmp    $0x1,%eax
  800674:	75 21                	jne    800697 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800676:	a1 04 40 80 00       	mov    0x804004,%eax
  80067b:	8b 40 48             	mov    0x48(%eax),%eax
  80067e:	83 ec 04             	sub    $0x4,%esp
  800681:	53                   	push   %ebx
  800682:	50                   	push   %eax
  800683:	68 b9 1e 80 00       	push   $0x801eb9
  800688:	e8 8d 0a 00 00       	call   80111a <cprintf>
		return -E_INVAL;
  80068d:	83 c4 10             	add    $0x10,%esp
  800690:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800695:	eb 26                	jmp    8006bd <read+0x8a>
	}
	if (!dev->dev_read)
  800697:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069a:	8b 40 08             	mov    0x8(%eax),%eax
  80069d:	85 c0                	test   %eax,%eax
  80069f:	74 17                	je     8006b8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a1:	83 ec 04             	sub    $0x4,%esp
  8006a4:	ff 75 10             	pushl  0x10(%ebp)
  8006a7:	ff 75 0c             	pushl  0xc(%ebp)
  8006aa:	52                   	push   %edx
  8006ab:	ff d0                	call   *%eax
  8006ad:	89 c2                	mov    %eax,%edx
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	eb 09                	jmp    8006bd <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b4:	89 c2                	mov    %eax,%edx
  8006b6:	eb 05                	jmp    8006bd <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006bd:	89 d0                	mov    %edx,%eax
  8006bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c2:	c9                   	leave  
  8006c3:	c3                   	ret    

008006c4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c4:	55                   	push   %ebp
  8006c5:	89 e5                	mov    %esp,%ebp
  8006c7:	57                   	push   %edi
  8006c8:	56                   	push   %esi
  8006c9:	53                   	push   %ebx
  8006ca:	83 ec 0c             	sub    $0xc,%esp
  8006cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d8:	eb 21                	jmp    8006fb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006da:	83 ec 04             	sub    $0x4,%esp
  8006dd:	89 f0                	mov    %esi,%eax
  8006df:	29 d8                	sub    %ebx,%eax
  8006e1:	50                   	push   %eax
  8006e2:	89 d8                	mov    %ebx,%eax
  8006e4:	03 45 0c             	add    0xc(%ebp),%eax
  8006e7:	50                   	push   %eax
  8006e8:	57                   	push   %edi
  8006e9:	e8 45 ff ff ff       	call   800633 <read>
		if (m < 0)
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	78 10                	js     800705 <readn+0x41>
			return m;
		if (m == 0)
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	74 0a                	je     800703 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f9:	01 c3                	add    %eax,%ebx
  8006fb:	39 f3                	cmp    %esi,%ebx
  8006fd:	72 db                	jb     8006da <readn+0x16>
  8006ff:	89 d8                	mov    %ebx,%eax
  800701:	eb 02                	jmp    800705 <readn+0x41>
  800703:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800705:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800708:	5b                   	pop    %ebx
  800709:	5e                   	pop    %esi
  80070a:	5f                   	pop    %edi
  80070b:	5d                   	pop    %ebp
  80070c:	c3                   	ret    

0080070d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	53                   	push   %ebx
  800711:	83 ec 14             	sub    $0x14,%esp
  800714:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800717:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071a:	50                   	push   %eax
  80071b:	53                   	push   %ebx
  80071c:	e8 ac fc ff ff       	call   8003cd <fd_lookup>
  800721:	83 c4 08             	add    $0x8,%esp
  800724:	89 c2                	mov    %eax,%edx
  800726:	85 c0                	test   %eax,%eax
  800728:	78 68                	js     800792 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072a:	83 ec 08             	sub    $0x8,%esp
  80072d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800730:	50                   	push   %eax
  800731:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800734:	ff 30                	pushl  (%eax)
  800736:	e8 e8 fc ff ff       	call   800423 <dev_lookup>
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	85 c0                	test   %eax,%eax
  800740:	78 47                	js     800789 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800742:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800745:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800749:	75 21                	jne    80076c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074b:	a1 04 40 80 00       	mov    0x804004,%eax
  800750:	8b 40 48             	mov    0x48(%eax),%eax
  800753:	83 ec 04             	sub    $0x4,%esp
  800756:	53                   	push   %ebx
  800757:	50                   	push   %eax
  800758:	68 d5 1e 80 00       	push   $0x801ed5
  80075d:	e8 b8 09 00 00       	call   80111a <cprintf>
		return -E_INVAL;
  800762:	83 c4 10             	add    $0x10,%esp
  800765:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80076a:	eb 26                	jmp    800792 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80076c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076f:	8b 52 0c             	mov    0xc(%edx),%edx
  800772:	85 d2                	test   %edx,%edx
  800774:	74 17                	je     80078d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800776:	83 ec 04             	sub    $0x4,%esp
  800779:	ff 75 10             	pushl  0x10(%ebp)
  80077c:	ff 75 0c             	pushl  0xc(%ebp)
  80077f:	50                   	push   %eax
  800780:	ff d2                	call   *%edx
  800782:	89 c2                	mov    %eax,%edx
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	eb 09                	jmp    800792 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800789:	89 c2                	mov    %eax,%edx
  80078b:	eb 05                	jmp    800792 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80078d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800792:	89 d0                	mov    %edx,%eax
  800794:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <seek>:

int
seek(int fdnum, off_t offset)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80079f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007a2:	50                   	push   %eax
  8007a3:	ff 75 08             	pushl  0x8(%ebp)
  8007a6:	e8 22 fc ff ff       	call   8003cd <fd_lookup>
  8007ab:	83 c4 08             	add    $0x8,%esp
  8007ae:	85 c0                	test   %eax,%eax
  8007b0:	78 0e                	js     8007c0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c0:	c9                   	leave  
  8007c1:	c3                   	ret    

008007c2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	53                   	push   %ebx
  8007c6:	83 ec 14             	sub    $0x14,%esp
  8007c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cf:	50                   	push   %eax
  8007d0:	53                   	push   %ebx
  8007d1:	e8 f7 fb ff ff       	call   8003cd <fd_lookup>
  8007d6:	83 c4 08             	add    $0x8,%esp
  8007d9:	89 c2                	mov    %eax,%edx
  8007db:	85 c0                	test   %eax,%eax
  8007dd:	78 65                	js     800844 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007df:	83 ec 08             	sub    $0x8,%esp
  8007e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e5:	50                   	push   %eax
  8007e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e9:	ff 30                	pushl  (%eax)
  8007eb:	e8 33 fc ff ff       	call   800423 <dev_lookup>
  8007f0:	83 c4 10             	add    $0x10,%esp
  8007f3:	85 c0                	test   %eax,%eax
  8007f5:	78 44                	js     80083b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007fe:	75 21                	jne    800821 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800800:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800805:	8b 40 48             	mov    0x48(%eax),%eax
  800808:	83 ec 04             	sub    $0x4,%esp
  80080b:	53                   	push   %ebx
  80080c:	50                   	push   %eax
  80080d:	68 98 1e 80 00       	push   $0x801e98
  800812:	e8 03 09 00 00       	call   80111a <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800817:	83 c4 10             	add    $0x10,%esp
  80081a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80081f:	eb 23                	jmp    800844 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800821:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800824:	8b 52 18             	mov    0x18(%edx),%edx
  800827:	85 d2                	test   %edx,%edx
  800829:	74 14                	je     80083f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80082b:	83 ec 08             	sub    $0x8,%esp
  80082e:	ff 75 0c             	pushl  0xc(%ebp)
  800831:	50                   	push   %eax
  800832:	ff d2                	call   *%edx
  800834:	89 c2                	mov    %eax,%edx
  800836:	83 c4 10             	add    $0x10,%esp
  800839:	eb 09                	jmp    800844 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083b:	89 c2                	mov    %eax,%edx
  80083d:	eb 05                	jmp    800844 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80083f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800844:	89 d0                	mov    %edx,%eax
  800846:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800849:	c9                   	leave  
  80084a:	c3                   	ret    

0080084b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	83 ec 14             	sub    $0x14,%esp
  800852:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800855:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800858:	50                   	push   %eax
  800859:	ff 75 08             	pushl  0x8(%ebp)
  80085c:	e8 6c fb ff ff       	call   8003cd <fd_lookup>
  800861:	83 c4 08             	add    $0x8,%esp
  800864:	89 c2                	mov    %eax,%edx
  800866:	85 c0                	test   %eax,%eax
  800868:	78 58                	js     8008c2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086a:	83 ec 08             	sub    $0x8,%esp
  80086d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800870:	50                   	push   %eax
  800871:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800874:	ff 30                	pushl  (%eax)
  800876:	e8 a8 fb ff ff       	call   800423 <dev_lookup>
  80087b:	83 c4 10             	add    $0x10,%esp
  80087e:	85 c0                	test   %eax,%eax
  800880:	78 37                	js     8008b9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800882:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800885:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800889:	74 32                	je     8008bd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80088b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80088e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800895:	00 00 00 
	stat->st_isdir = 0;
  800898:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80089f:	00 00 00 
	stat->st_dev = dev;
  8008a2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a8:	83 ec 08             	sub    $0x8,%esp
  8008ab:	53                   	push   %ebx
  8008ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8008af:	ff 50 14             	call   *0x14(%eax)
  8008b2:	89 c2                	mov    %eax,%edx
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	eb 09                	jmp    8008c2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b9:	89 c2                	mov    %eax,%edx
  8008bb:	eb 05                	jmp    8008c2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008bd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008c2:	89 d0                	mov    %edx,%eax
  8008c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c7:	c9                   	leave  
  8008c8:	c3                   	ret    

008008c9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	56                   	push   %esi
  8008cd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ce:	83 ec 08             	sub    $0x8,%esp
  8008d1:	6a 00                	push   $0x0
  8008d3:	ff 75 08             	pushl  0x8(%ebp)
  8008d6:	e8 e3 01 00 00       	call   800abe <open>
  8008db:	89 c3                	mov    %eax,%ebx
  8008dd:	83 c4 10             	add    $0x10,%esp
  8008e0:	85 c0                	test   %eax,%eax
  8008e2:	78 1b                	js     8008ff <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e4:	83 ec 08             	sub    $0x8,%esp
  8008e7:	ff 75 0c             	pushl  0xc(%ebp)
  8008ea:	50                   	push   %eax
  8008eb:	e8 5b ff ff ff       	call   80084b <fstat>
  8008f0:	89 c6                	mov    %eax,%esi
	close(fd);
  8008f2:	89 1c 24             	mov    %ebx,(%esp)
  8008f5:	e8 fd fb ff ff       	call   8004f7 <close>
	return r;
  8008fa:	83 c4 10             	add    $0x10,%esp
  8008fd:	89 f0                	mov    %esi,%eax
}
  8008ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800902:	5b                   	pop    %ebx
  800903:	5e                   	pop    %esi
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	56                   	push   %esi
  80090a:	53                   	push   %ebx
  80090b:	89 c6                	mov    %eax,%esi
  80090d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80090f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800916:	75 12                	jne    80092a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800918:	83 ec 0c             	sub    $0xc,%esp
  80091b:	6a 01                	push   $0x1
  80091d:	e8 00 12 00 00       	call   801b22 <ipc_find_env>
  800922:	a3 00 40 80 00       	mov    %eax,0x804000
  800927:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80092a:	6a 07                	push   $0x7
  80092c:	68 00 50 80 00       	push   $0x805000
  800931:	56                   	push   %esi
  800932:	ff 35 00 40 80 00    	pushl  0x804000
  800938:	e8 91 11 00 00       	call   801ace <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80093d:	83 c4 0c             	add    $0xc,%esp
  800940:	6a 00                	push   $0x0
  800942:	53                   	push   %ebx
  800943:	6a 00                	push   $0x0
  800945:	e8 1b 11 00 00       	call   801a65 <ipc_recv>
}
  80094a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094d:	5b                   	pop    %ebx
  80094e:	5e                   	pop    %esi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 40 0c             	mov    0xc(%eax),%eax
  80095d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800962:	8b 45 0c             	mov    0xc(%ebp),%eax
  800965:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80096a:	ba 00 00 00 00       	mov    $0x0,%edx
  80096f:	b8 02 00 00 00       	mov    $0x2,%eax
  800974:	e8 8d ff ff ff       	call   800906 <fsipc>
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 40 0c             	mov    0xc(%eax),%eax
  800987:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80098c:	ba 00 00 00 00       	mov    $0x0,%edx
  800991:	b8 06 00 00 00       	mov    $0x6,%eax
  800996:	e8 6b ff ff ff       	call   800906 <fsipc>
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	53                   	push   %ebx
  8009a1:	83 ec 04             	sub    $0x4,%esp
  8009a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ad:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009bc:	e8 45 ff ff ff       	call   800906 <fsipc>
  8009c1:	85 c0                	test   %eax,%eax
  8009c3:	78 2c                	js     8009f1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c5:	83 ec 08             	sub    $0x8,%esp
  8009c8:	68 00 50 80 00       	push   $0x805000
  8009cd:	53                   	push   %ebx
  8009ce:	e8 4b 0d 00 00       	call   80171e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d3:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009de:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e9:	83 c4 10             	add    $0x10,%esp
  8009ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f4:	c9                   	leave  
  8009f5:	c3                   	ret    

008009f6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	83 ec 0c             	sub    $0xc,%esp
  8009fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ff:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a04:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a09:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a0f:	8b 52 0c             	mov    0xc(%edx),%edx
  800a12:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a18:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a1d:	50                   	push   %eax
  800a1e:	ff 75 0c             	pushl  0xc(%ebp)
  800a21:	68 08 50 80 00       	push   $0x805008
  800a26:	e8 85 0e 00 00       	call   8018b0 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a30:	b8 04 00 00 00       	mov    $0x4,%eax
  800a35:	e8 cc fe ff ff       	call   800906 <fsipc>
	//panic("devfile_write not implemented");
}
  800a3a:	c9                   	leave  
  800a3b:	c3                   	ret    

00800a3c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	56                   	push   %esi
  800a40:	53                   	push   %ebx
  800a41:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	8b 40 0c             	mov    0xc(%eax),%eax
  800a4a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a4f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a55:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a5f:	e8 a2 fe ff ff       	call   800906 <fsipc>
  800a64:	89 c3                	mov    %eax,%ebx
  800a66:	85 c0                	test   %eax,%eax
  800a68:	78 4b                	js     800ab5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a6a:	39 c6                	cmp    %eax,%esi
  800a6c:	73 16                	jae    800a84 <devfile_read+0x48>
  800a6e:	68 04 1f 80 00       	push   $0x801f04
  800a73:	68 0b 1f 80 00       	push   $0x801f0b
  800a78:	6a 7c                	push   $0x7c
  800a7a:	68 20 1f 80 00       	push   $0x801f20
  800a7f:	e8 bd 05 00 00       	call   801041 <_panic>
	assert(r <= PGSIZE);
  800a84:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a89:	7e 16                	jle    800aa1 <devfile_read+0x65>
  800a8b:	68 2b 1f 80 00       	push   $0x801f2b
  800a90:	68 0b 1f 80 00       	push   $0x801f0b
  800a95:	6a 7d                	push   $0x7d
  800a97:	68 20 1f 80 00       	push   $0x801f20
  800a9c:	e8 a0 05 00 00       	call   801041 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aa1:	83 ec 04             	sub    $0x4,%esp
  800aa4:	50                   	push   %eax
  800aa5:	68 00 50 80 00       	push   $0x805000
  800aaa:	ff 75 0c             	pushl  0xc(%ebp)
  800aad:	e8 fe 0d 00 00       	call   8018b0 <memmove>
	return r;
  800ab2:	83 c4 10             	add    $0x10,%esp
}
  800ab5:	89 d8                	mov    %ebx,%eax
  800ab7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aba:	5b                   	pop    %ebx
  800abb:	5e                   	pop    %esi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	53                   	push   %ebx
  800ac2:	83 ec 20             	sub    $0x20,%esp
  800ac5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ac8:	53                   	push   %ebx
  800ac9:	e8 17 0c 00 00       	call   8016e5 <strlen>
  800ace:	83 c4 10             	add    $0x10,%esp
  800ad1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ad6:	7f 67                	jg     800b3f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ad8:	83 ec 0c             	sub    $0xc,%esp
  800adb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ade:	50                   	push   %eax
  800adf:	e8 9a f8 ff ff       	call   80037e <fd_alloc>
  800ae4:	83 c4 10             	add    $0x10,%esp
		return r;
  800ae7:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ae9:	85 c0                	test   %eax,%eax
  800aeb:	78 57                	js     800b44 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800aed:	83 ec 08             	sub    $0x8,%esp
  800af0:	53                   	push   %ebx
  800af1:	68 00 50 80 00       	push   $0x805000
  800af6:	e8 23 0c 00 00       	call   80171e <strcpy>
	fsipcbuf.open.req_omode = mode;
  800afb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afe:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b03:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b06:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0b:	e8 f6 fd ff ff       	call   800906 <fsipc>
  800b10:	89 c3                	mov    %eax,%ebx
  800b12:	83 c4 10             	add    $0x10,%esp
  800b15:	85 c0                	test   %eax,%eax
  800b17:	79 14                	jns    800b2d <open+0x6f>
		fd_close(fd, 0);
  800b19:	83 ec 08             	sub    $0x8,%esp
  800b1c:	6a 00                	push   $0x0
  800b1e:	ff 75 f4             	pushl  -0xc(%ebp)
  800b21:	e8 50 f9 ff ff       	call   800476 <fd_close>
		return r;
  800b26:	83 c4 10             	add    $0x10,%esp
  800b29:	89 da                	mov    %ebx,%edx
  800b2b:	eb 17                	jmp    800b44 <open+0x86>
	}

	return fd2num(fd);
  800b2d:	83 ec 0c             	sub    $0xc,%esp
  800b30:	ff 75 f4             	pushl  -0xc(%ebp)
  800b33:	e8 1f f8 ff ff       	call   800357 <fd2num>
  800b38:	89 c2                	mov    %eax,%edx
  800b3a:	83 c4 10             	add    $0x10,%esp
  800b3d:	eb 05                	jmp    800b44 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b3f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b44:	89 d0                	mov    %edx,%eax
  800b46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b49:	c9                   	leave  
  800b4a:	c3                   	ret    

00800b4b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b51:	ba 00 00 00 00       	mov    $0x0,%edx
  800b56:	b8 08 00 00 00       	mov    $0x8,%eax
  800b5b:	e8 a6 fd ff ff       	call   800906 <fsipc>
}
  800b60:	c9                   	leave  
  800b61:	c3                   	ret    

00800b62 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	56                   	push   %esi
  800b66:	53                   	push   %ebx
  800b67:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b6a:	83 ec 0c             	sub    $0xc,%esp
  800b6d:	ff 75 08             	pushl  0x8(%ebp)
  800b70:	e8 f2 f7 ff ff       	call   800367 <fd2data>
  800b75:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b77:	83 c4 08             	add    $0x8,%esp
  800b7a:	68 37 1f 80 00       	push   $0x801f37
  800b7f:	53                   	push   %ebx
  800b80:	e8 99 0b 00 00       	call   80171e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b85:	8b 46 04             	mov    0x4(%esi),%eax
  800b88:	2b 06                	sub    (%esi),%eax
  800b8a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b90:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b97:	00 00 00 
	stat->st_dev = &devpipe;
  800b9a:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800ba1:	30 80 00 
	return 0;
}
  800ba4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 0c             	sub    $0xc,%esp
  800bb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bba:	53                   	push   %ebx
  800bbb:	6a 00                	push   $0x0
  800bbd:	e8 29 f6 ff ff       	call   8001eb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bc2:	89 1c 24             	mov    %ebx,(%esp)
  800bc5:	e8 9d f7 ff ff       	call   800367 <fd2data>
  800bca:	83 c4 08             	add    $0x8,%esp
  800bcd:	50                   	push   %eax
  800bce:	6a 00                	push   $0x0
  800bd0:	e8 16 f6 ff ff       	call   8001eb <sys_page_unmap>
}
  800bd5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bd8:	c9                   	leave  
  800bd9:	c3                   	ret    

00800bda <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	57                   	push   %edi
  800bde:	56                   	push   %esi
  800bdf:	53                   	push   %ebx
  800be0:	83 ec 1c             	sub    $0x1c,%esp
  800be3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800be6:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800be8:	a1 04 40 80 00       	mov    0x804004,%eax
  800bed:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bf0:	83 ec 0c             	sub    $0xc,%esp
  800bf3:	ff 75 e0             	pushl  -0x20(%ebp)
  800bf6:	e8 60 0f 00 00       	call   801b5b <pageref>
  800bfb:	89 c3                	mov    %eax,%ebx
  800bfd:	89 3c 24             	mov    %edi,(%esp)
  800c00:	e8 56 0f 00 00       	call   801b5b <pageref>
  800c05:	83 c4 10             	add    $0x10,%esp
  800c08:	39 c3                	cmp    %eax,%ebx
  800c0a:	0f 94 c1             	sete   %cl
  800c0d:	0f b6 c9             	movzbl %cl,%ecx
  800c10:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c13:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c19:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c1c:	39 ce                	cmp    %ecx,%esi
  800c1e:	74 1b                	je     800c3b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c20:	39 c3                	cmp    %eax,%ebx
  800c22:	75 c4                	jne    800be8 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c24:	8b 42 58             	mov    0x58(%edx),%eax
  800c27:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c2a:	50                   	push   %eax
  800c2b:	56                   	push   %esi
  800c2c:	68 3e 1f 80 00       	push   $0x801f3e
  800c31:	e8 e4 04 00 00       	call   80111a <cprintf>
  800c36:	83 c4 10             	add    $0x10,%esp
  800c39:	eb ad                	jmp    800be8 <_pipeisclosed+0xe>
	}
}
  800c3b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c41:	5b                   	pop    %ebx
  800c42:	5e                   	pop    %esi
  800c43:	5f                   	pop    %edi
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 28             	sub    $0x28,%esp
  800c4f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c52:	56                   	push   %esi
  800c53:	e8 0f f7 ff ff       	call   800367 <fd2data>
  800c58:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c5a:	83 c4 10             	add    $0x10,%esp
  800c5d:	bf 00 00 00 00       	mov    $0x0,%edi
  800c62:	eb 4b                	jmp    800caf <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c64:	89 da                	mov    %ebx,%edx
  800c66:	89 f0                	mov    %esi,%eax
  800c68:	e8 6d ff ff ff       	call   800bda <_pipeisclosed>
  800c6d:	85 c0                	test   %eax,%eax
  800c6f:	75 48                	jne    800cb9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c71:	e8 d1 f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c76:	8b 43 04             	mov    0x4(%ebx),%eax
  800c79:	8b 0b                	mov    (%ebx),%ecx
  800c7b:	8d 51 20             	lea    0x20(%ecx),%edx
  800c7e:	39 d0                	cmp    %edx,%eax
  800c80:	73 e2                	jae    800c64 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c85:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c89:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c8c:	89 c2                	mov    %eax,%edx
  800c8e:	c1 fa 1f             	sar    $0x1f,%edx
  800c91:	89 d1                	mov    %edx,%ecx
  800c93:	c1 e9 1b             	shr    $0x1b,%ecx
  800c96:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c99:	83 e2 1f             	and    $0x1f,%edx
  800c9c:	29 ca                	sub    %ecx,%edx
  800c9e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ca2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ca6:	83 c0 01             	add    $0x1,%eax
  800ca9:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cac:	83 c7 01             	add    $0x1,%edi
  800caf:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cb2:	75 c2                	jne    800c76 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cb4:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb7:	eb 05                	jmp    800cbe <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cb9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
  800ccc:	83 ec 18             	sub    $0x18,%esp
  800ccf:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cd2:	57                   	push   %edi
  800cd3:	e8 8f f6 ff ff       	call   800367 <fd2data>
  800cd8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cda:	83 c4 10             	add    $0x10,%esp
  800cdd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce2:	eb 3d                	jmp    800d21 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ce4:	85 db                	test   %ebx,%ebx
  800ce6:	74 04                	je     800cec <devpipe_read+0x26>
				return i;
  800ce8:	89 d8                	mov    %ebx,%eax
  800cea:	eb 44                	jmp    800d30 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cec:	89 f2                	mov    %esi,%edx
  800cee:	89 f8                	mov    %edi,%eax
  800cf0:	e8 e5 fe ff ff       	call   800bda <_pipeisclosed>
  800cf5:	85 c0                	test   %eax,%eax
  800cf7:	75 32                	jne    800d2b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cf9:	e8 49 f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cfe:	8b 06                	mov    (%esi),%eax
  800d00:	3b 46 04             	cmp    0x4(%esi),%eax
  800d03:	74 df                	je     800ce4 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d05:	99                   	cltd   
  800d06:	c1 ea 1b             	shr    $0x1b,%edx
  800d09:	01 d0                	add    %edx,%eax
  800d0b:	83 e0 1f             	and    $0x1f,%eax
  800d0e:	29 d0                	sub    %edx,%eax
  800d10:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d18:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d1b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d1e:	83 c3 01             	add    $0x1,%ebx
  800d21:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d24:	75 d8                	jne    800cfe <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d26:	8b 45 10             	mov    0x10(%ebp),%eax
  800d29:	eb 05                	jmp    800d30 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d2b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    

00800d38 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	56                   	push   %esi
  800d3c:	53                   	push   %ebx
  800d3d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d40:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d43:	50                   	push   %eax
  800d44:	e8 35 f6 ff ff       	call   80037e <fd_alloc>
  800d49:	83 c4 10             	add    $0x10,%esp
  800d4c:	89 c2                	mov    %eax,%edx
  800d4e:	85 c0                	test   %eax,%eax
  800d50:	0f 88 2c 01 00 00    	js     800e82 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d56:	83 ec 04             	sub    $0x4,%esp
  800d59:	68 07 04 00 00       	push   $0x407
  800d5e:	ff 75 f4             	pushl  -0xc(%ebp)
  800d61:	6a 00                	push   $0x0
  800d63:	e8 fe f3 ff ff       	call   800166 <sys_page_alloc>
  800d68:	83 c4 10             	add    $0x10,%esp
  800d6b:	89 c2                	mov    %eax,%edx
  800d6d:	85 c0                	test   %eax,%eax
  800d6f:	0f 88 0d 01 00 00    	js     800e82 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d75:	83 ec 0c             	sub    $0xc,%esp
  800d78:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d7b:	50                   	push   %eax
  800d7c:	e8 fd f5 ff ff       	call   80037e <fd_alloc>
  800d81:	89 c3                	mov    %eax,%ebx
  800d83:	83 c4 10             	add    $0x10,%esp
  800d86:	85 c0                	test   %eax,%eax
  800d88:	0f 88 e2 00 00 00    	js     800e70 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d8e:	83 ec 04             	sub    $0x4,%esp
  800d91:	68 07 04 00 00       	push   $0x407
  800d96:	ff 75 f0             	pushl  -0x10(%ebp)
  800d99:	6a 00                	push   $0x0
  800d9b:	e8 c6 f3 ff ff       	call   800166 <sys_page_alloc>
  800da0:	89 c3                	mov    %eax,%ebx
  800da2:	83 c4 10             	add    $0x10,%esp
  800da5:	85 c0                	test   %eax,%eax
  800da7:	0f 88 c3 00 00 00    	js     800e70 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dad:	83 ec 0c             	sub    $0xc,%esp
  800db0:	ff 75 f4             	pushl  -0xc(%ebp)
  800db3:	e8 af f5 ff ff       	call   800367 <fd2data>
  800db8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dba:	83 c4 0c             	add    $0xc,%esp
  800dbd:	68 07 04 00 00       	push   $0x407
  800dc2:	50                   	push   %eax
  800dc3:	6a 00                	push   $0x0
  800dc5:	e8 9c f3 ff ff       	call   800166 <sys_page_alloc>
  800dca:	89 c3                	mov    %eax,%ebx
  800dcc:	83 c4 10             	add    $0x10,%esp
  800dcf:	85 c0                	test   %eax,%eax
  800dd1:	0f 88 89 00 00 00    	js     800e60 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd7:	83 ec 0c             	sub    $0xc,%esp
  800dda:	ff 75 f0             	pushl  -0x10(%ebp)
  800ddd:	e8 85 f5 ff ff       	call   800367 <fd2data>
  800de2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800de9:	50                   	push   %eax
  800dea:	6a 00                	push   $0x0
  800dec:	56                   	push   %esi
  800ded:	6a 00                	push   $0x0
  800def:	e8 b5 f3 ff ff       	call   8001a9 <sys_page_map>
  800df4:	89 c3                	mov    %eax,%ebx
  800df6:	83 c4 20             	add    $0x20,%esp
  800df9:	85 c0                	test   %eax,%eax
  800dfb:	78 55                	js     800e52 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dfd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e06:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e0b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e12:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e18:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e1b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e20:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e27:	83 ec 0c             	sub    $0xc,%esp
  800e2a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e2d:	e8 25 f5 ff ff       	call   800357 <fd2num>
  800e32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e35:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e37:	83 c4 04             	add    $0x4,%esp
  800e3a:	ff 75 f0             	pushl  -0x10(%ebp)
  800e3d:	e8 15 f5 ff ff       	call   800357 <fd2num>
  800e42:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e45:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e48:	83 c4 10             	add    $0x10,%esp
  800e4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e50:	eb 30                	jmp    800e82 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e52:	83 ec 08             	sub    $0x8,%esp
  800e55:	56                   	push   %esi
  800e56:	6a 00                	push   $0x0
  800e58:	e8 8e f3 ff ff       	call   8001eb <sys_page_unmap>
  800e5d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e60:	83 ec 08             	sub    $0x8,%esp
  800e63:	ff 75 f0             	pushl  -0x10(%ebp)
  800e66:	6a 00                	push   $0x0
  800e68:	e8 7e f3 ff ff       	call   8001eb <sys_page_unmap>
  800e6d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e70:	83 ec 08             	sub    $0x8,%esp
  800e73:	ff 75 f4             	pushl  -0xc(%ebp)
  800e76:	6a 00                	push   $0x0
  800e78:	e8 6e f3 ff ff       	call   8001eb <sys_page_unmap>
  800e7d:	83 c4 10             	add    $0x10,%esp
  800e80:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e82:	89 d0                	mov    %edx,%eax
  800e84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e87:	5b                   	pop    %ebx
  800e88:	5e                   	pop    %esi
  800e89:	5d                   	pop    %ebp
  800e8a:	c3                   	ret    

00800e8b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e94:	50                   	push   %eax
  800e95:	ff 75 08             	pushl  0x8(%ebp)
  800e98:	e8 30 f5 ff ff       	call   8003cd <fd_lookup>
  800e9d:	83 c4 10             	add    $0x10,%esp
  800ea0:	85 c0                	test   %eax,%eax
  800ea2:	78 18                	js     800ebc <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ea4:	83 ec 0c             	sub    $0xc,%esp
  800ea7:	ff 75 f4             	pushl  -0xc(%ebp)
  800eaa:	e8 b8 f4 ff ff       	call   800367 <fd2data>
	return _pipeisclosed(fd, p);
  800eaf:	89 c2                	mov    %eax,%edx
  800eb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb4:	e8 21 fd ff ff       	call   800bda <_pipeisclosed>
  800eb9:	83 c4 10             	add    $0x10,%esp
}
  800ebc:	c9                   	leave  
  800ebd:	c3                   	ret    

00800ebe <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ec1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec6:	5d                   	pop    %ebp
  800ec7:	c3                   	ret    

00800ec8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ece:	68 56 1f 80 00       	push   $0x801f56
  800ed3:	ff 75 0c             	pushl  0xc(%ebp)
  800ed6:	e8 43 08 00 00       	call   80171e <strcpy>
	return 0;
}
  800edb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee0:	c9                   	leave  
  800ee1:	c3                   	ret    

00800ee2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	57                   	push   %edi
  800ee6:	56                   	push   %esi
  800ee7:	53                   	push   %ebx
  800ee8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eee:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ef3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef9:	eb 2d                	jmp    800f28 <devcons_write+0x46>
		m = n - tot;
  800efb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800efe:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f00:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f03:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f08:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f0b:	83 ec 04             	sub    $0x4,%esp
  800f0e:	53                   	push   %ebx
  800f0f:	03 45 0c             	add    0xc(%ebp),%eax
  800f12:	50                   	push   %eax
  800f13:	57                   	push   %edi
  800f14:	e8 97 09 00 00       	call   8018b0 <memmove>
		sys_cputs(buf, m);
  800f19:	83 c4 08             	add    $0x8,%esp
  800f1c:	53                   	push   %ebx
  800f1d:	57                   	push   %edi
  800f1e:	e8 87 f1 ff ff       	call   8000aa <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f23:	01 de                	add    %ebx,%esi
  800f25:	83 c4 10             	add    $0x10,%esp
  800f28:	89 f0                	mov    %esi,%eax
  800f2a:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f2d:	72 cc                	jb     800efb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f32:	5b                   	pop    %ebx
  800f33:	5e                   	pop    %esi
  800f34:	5f                   	pop    %edi
  800f35:	5d                   	pop    %ebp
  800f36:	c3                   	ret    

00800f37 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	83 ec 08             	sub    $0x8,%esp
  800f3d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f42:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f46:	74 2a                	je     800f72 <devcons_read+0x3b>
  800f48:	eb 05                	jmp    800f4f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f4a:	e8 f8 f1 ff ff       	call   800147 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f4f:	e8 74 f1 ff ff       	call   8000c8 <sys_cgetc>
  800f54:	85 c0                	test   %eax,%eax
  800f56:	74 f2                	je     800f4a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	78 16                	js     800f72 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f5c:	83 f8 04             	cmp    $0x4,%eax
  800f5f:	74 0c                	je     800f6d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f61:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f64:	88 02                	mov    %al,(%edx)
	return 1;
  800f66:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6b:	eb 05                	jmp    800f72 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f6d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f72:	c9                   	leave  
  800f73:	c3                   	ret    

00800f74 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f80:	6a 01                	push   $0x1
  800f82:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f85:	50                   	push   %eax
  800f86:	e8 1f f1 ff ff       	call   8000aa <sys_cputs>
}
  800f8b:	83 c4 10             	add    $0x10,%esp
  800f8e:	c9                   	leave  
  800f8f:	c3                   	ret    

00800f90 <getchar>:

int
getchar(void)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
  800f93:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f96:	6a 01                	push   $0x1
  800f98:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f9b:	50                   	push   %eax
  800f9c:	6a 00                	push   $0x0
  800f9e:	e8 90 f6 ff ff       	call   800633 <read>
	if (r < 0)
  800fa3:	83 c4 10             	add    $0x10,%esp
  800fa6:	85 c0                	test   %eax,%eax
  800fa8:	78 0f                	js     800fb9 <getchar+0x29>
		return r;
	if (r < 1)
  800faa:	85 c0                	test   %eax,%eax
  800fac:	7e 06                	jle    800fb4 <getchar+0x24>
		return -E_EOF;
	return c;
  800fae:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fb2:	eb 05                	jmp    800fb9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fb4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fb9:	c9                   	leave  
  800fba:	c3                   	ret    

00800fbb <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fbb:	55                   	push   %ebp
  800fbc:	89 e5                	mov    %esp,%ebp
  800fbe:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc4:	50                   	push   %eax
  800fc5:	ff 75 08             	pushl  0x8(%ebp)
  800fc8:	e8 00 f4 ff ff       	call   8003cd <fd_lookup>
  800fcd:	83 c4 10             	add    $0x10,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	78 11                	js     800fe5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fdd:	39 10                	cmp    %edx,(%eax)
  800fdf:	0f 94 c0             	sete   %al
  800fe2:	0f b6 c0             	movzbl %al,%eax
}
  800fe5:	c9                   	leave  
  800fe6:	c3                   	ret    

00800fe7 <opencons>:

int
opencons(void)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff0:	50                   	push   %eax
  800ff1:	e8 88 f3 ff ff       	call   80037e <fd_alloc>
  800ff6:	83 c4 10             	add    $0x10,%esp
		return r;
  800ff9:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800ffb:	85 c0                	test   %eax,%eax
  800ffd:	78 3e                	js     80103d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fff:	83 ec 04             	sub    $0x4,%esp
  801002:	68 07 04 00 00       	push   $0x407
  801007:	ff 75 f4             	pushl  -0xc(%ebp)
  80100a:	6a 00                	push   $0x0
  80100c:	e8 55 f1 ff ff       	call   800166 <sys_page_alloc>
  801011:	83 c4 10             	add    $0x10,%esp
		return r;
  801014:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801016:	85 c0                	test   %eax,%eax
  801018:	78 23                	js     80103d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80101a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801020:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801023:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801025:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801028:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80102f:	83 ec 0c             	sub    $0xc,%esp
  801032:	50                   	push   %eax
  801033:	e8 1f f3 ff ff       	call   800357 <fd2num>
  801038:	89 c2                	mov    %eax,%edx
  80103a:	83 c4 10             	add    $0x10,%esp
}
  80103d:	89 d0                	mov    %edx,%eax
  80103f:	c9                   	leave  
  801040:	c3                   	ret    

00801041 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	56                   	push   %esi
  801045:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801046:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801049:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80104f:	e8 d4 f0 ff ff       	call   800128 <sys_getenvid>
  801054:	83 ec 0c             	sub    $0xc,%esp
  801057:	ff 75 0c             	pushl  0xc(%ebp)
  80105a:	ff 75 08             	pushl  0x8(%ebp)
  80105d:	56                   	push   %esi
  80105e:	50                   	push   %eax
  80105f:	68 64 1f 80 00       	push   $0x801f64
  801064:	e8 b1 00 00 00       	call   80111a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801069:	83 c4 18             	add    $0x18,%esp
  80106c:	53                   	push   %ebx
  80106d:	ff 75 10             	pushl  0x10(%ebp)
  801070:	e8 54 00 00 00       	call   8010c9 <vcprintf>
	cprintf("\n");
  801075:	c7 04 24 4f 1f 80 00 	movl   $0x801f4f,(%esp)
  80107c:	e8 99 00 00 00       	call   80111a <cprintf>
  801081:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801084:	cc                   	int3   
  801085:	eb fd                	jmp    801084 <_panic+0x43>

00801087 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	53                   	push   %ebx
  80108b:	83 ec 04             	sub    $0x4,%esp
  80108e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801091:	8b 13                	mov    (%ebx),%edx
  801093:	8d 42 01             	lea    0x1(%edx),%eax
  801096:	89 03                	mov    %eax,(%ebx)
  801098:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80109b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80109f:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010a4:	75 1a                	jne    8010c0 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010a6:	83 ec 08             	sub    $0x8,%esp
  8010a9:	68 ff 00 00 00       	push   $0xff
  8010ae:	8d 43 08             	lea    0x8(%ebx),%eax
  8010b1:	50                   	push   %eax
  8010b2:	e8 f3 ef ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  8010b7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010bd:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010c0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c7:	c9                   	leave  
  8010c8:	c3                   	ret    

008010c9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010c9:	55                   	push   %ebp
  8010ca:	89 e5                	mov    %esp,%ebp
  8010cc:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010d2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010d9:	00 00 00 
	b.cnt = 0;
  8010dc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010e3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010e6:	ff 75 0c             	pushl  0xc(%ebp)
  8010e9:	ff 75 08             	pushl  0x8(%ebp)
  8010ec:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010f2:	50                   	push   %eax
  8010f3:	68 87 10 80 00       	push   $0x801087
  8010f8:	e8 1a 01 00 00       	call   801217 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010fd:	83 c4 08             	add    $0x8,%esp
  801100:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801106:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80110c:	50                   	push   %eax
  80110d:	e8 98 ef ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  801112:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801118:	c9                   	leave  
  801119:	c3                   	ret    

0080111a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801120:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801123:	50                   	push   %eax
  801124:	ff 75 08             	pushl  0x8(%ebp)
  801127:	e8 9d ff ff ff       	call   8010c9 <vcprintf>
	va_end(ap);

	return cnt;
}
  80112c:	c9                   	leave  
  80112d:	c3                   	ret    

0080112e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	57                   	push   %edi
  801132:	56                   	push   %esi
  801133:	53                   	push   %ebx
  801134:	83 ec 1c             	sub    $0x1c,%esp
  801137:	89 c7                	mov    %eax,%edi
  801139:	89 d6                	mov    %edx,%esi
  80113b:	8b 45 08             	mov    0x8(%ebp),%eax
  80113e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801141:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801144:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801147:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80114a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801152:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801155:	39 d3                	cmp    %edx,%ebx
  801157:	72 05                	jb     80115e <printnum+0x30>
  801159:	39 45 10             	cmp    %eax,0x10(%ebp)
  80115c:	77 45                	ja     8011a3 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80115e:	83 ec 0c             	sub    $0xc,%esp
  801161:	ff 75 18             	pushl  0x18(%ebp)
  801164:	8b 45 14             	mov    0x14(%ebp),%eax
  801167:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80116a:	53                   	push   %ebx
  80116b:	ff 75 10             	pushl  0x10(%ebp)
  80116e:	83 ec 08             	sub    $0x8,%esp
  801171:	ff 75 e4             	pushl  -0x1c(%ebp)
  801174:	ff 75 e0             	pushl  -0x20(%ebp)
  801177:	ff 75 dc             	pushl  -0x24(%ebp)
  80117a:	ff 75 d8             	pushl  -0x28(%ebp)
  80117d:	e8 1e 0a 00 00       	call   801ba0 <__udivdi3>
  801182:	83 c4 18             	add    $0x18,%esp
  801185:	52                   	push   %edx
  801186:	50                   	push   %eax
  801187:	89 f2                	mov    %esi,%edx
  801189:	89 f8                	mov    %edi,%eax
  80118b:	e8 9e ff ff ff       	call   80112e <printnum>
  801190:	83 c4 20             	add    $0x20,%esp
  801193:	eb 18                	jmp    8011ad <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801195:	83 ec 08             	sub    $0x8,%esp
  801198:	56                   	push   %esi
  801199:	ff 75 18             	pushl  0x18(%ebp)
  80119c:	ff d7                	call   *%edi
  80119e:	83 c4 10             	add    $0x10,%esp
  8011a1:	eb 03                	jmp    8011a6 <printnum+0x78>
  8011a3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011a6:	83 eb 01             	sub    $0x1,%ebx
  8011a9:	85 db                	test   %ebx,%ebx
  8011ab:	7f e8                	jg     801195 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011ad:	83 ec 08             	sub    $0x8,%esp
  8011b0:	56                   	push   %esi
  8011b1:	83 ec 04             	sub    $0x4,%esp
  8011b4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ba:	ff 75 dc             	pushl  -0x24(%ebp)
  8011bd:	ff 75 d8             	pushl  -0x28(%ebp)
  8011c0:	e8 0b 0b 00 00       	call   801cd0 <__umoddi3>
  8011c5:	83 c4 14             	add    $0x14,%esp
  8011c8:	0f be 80 87 1f 80 00 	movsbl 0x801f87(%eax),%eax
  8011cf:	50                   	push   %eax
  8011d0:	ff d7                	call   *%edi
}
  8011d2:	83 c4 10             	add    $0x10,%esp
  8011d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d8:	5b                   	pop    %ebx
  8011d9:	5e                   	pop    %esi
  8011da:	5f                   	pop    %edi
  8011db:	5d                   	pop    %ebp
  8011dc:	c3                   	ret    

008011dd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011e3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011e7:	8b 10                	mov    (%eax),%edx
  8011e9:	3b 50 04             	cmp    0x4(%eax),%edx
  8011ec:	73 0a                	jae    8011f8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011ee:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011f1:	89 08                	mov    %ecx,(%eax)
  8011f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f6:	88 02                	mov    %al,(%edx)
}
  8011f8:	5d                   	pop    %ebp
  8011f9:	c3                   	ret    

008011fa <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801200:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801203:	50                   	push   %eax
  801204:	ff 75 10             	pushl  0x10(%ebp)
  801207:	ff 75 0c             	pushl  0xc(%ebp)
  80120a:	ff 75 08             	pushl  0x8(%ebp)
  80120d:	e8 05 00 00 00       	call   801217 <vprintfmt>
	va_end(ap);
}
  801212:	83 c4 10             	add    $0x10,%esp
  801215:	c9                   	leave  
  801216:	c3                   	ret    

00801217 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801217:	55                   	push   %ebp
  801218:	89 e5                	mov    %esp,%ebp
  80121a:	57                   	push   %edi
  80121b:	56                   	push   %esi
  80121c:	53                   	push   %ebx
  80121d:	83 ec 2c             	sub    $0x2c,%esp
  801220:	8b 75 08             	mov    0x8(%ebp),%esi
  801223:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801226:	8b 7d 10             	mov    0x10(%ebp),%edi
  801229:	eb 12                	jmp    80123d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80122b:	85 c0                	test   %eax,%eax
  80122d:	0f 84 42 04 00 00    	je     801675 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  801233:	83 ec 08             	sub    $0x8,%esp
  801236:	53                   	push   %ebx
  801237:	50                   	push   %eax
  801238:	ff d6                	call   *%esi
  80123a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80123d:	83 c7 01             	add    $0x1,%edi
  801240:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801244:	83 f8 25             	cmp    $0x25,%eax
  801247:	75 e2                	jne    80122b <vprintfmt+0x14>
  801249:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80124d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801254:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80125b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801262:	b9 00 00 00 00       	mov    $0x0,%ecx
  801267:	eb 07                	jmp    801270 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801269:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80126c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801270:	8d 47 01             	lea    0x1(%edi),%eax
  801273:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801276:	0f b6 07             	movzbl (%edi),%eax
  801279:	0f b6 d0             	movzbl %al,%edx
  80127c:	83 e8 23             	sub    $0x23,%eax
  80127f:	3c 55                	cmp    $0x55,%al
  801281:	0f 87 d3 03 00 00    	ja     80165a <vprintfmt+0x443>
  801287:	0f b6 c0             	movzbl %al,%eax
  80128a:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  801291:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801294:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801298:	eb d6                	jmp    801270 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80129a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80129d:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012a5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012a8:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8012ac:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8012af:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8012b2:	83 f9 09             	cmp    $0x9,%ecx
  8012b5:	77 3f                	ja     8012f6 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012b7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012ba:	eb e9                	jmp    8012a5 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8012bf:	8b 00                	mov    (%eax),%eax
  8012c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c7:	8d 40 04             	lea    0x4(%eax),%eax
  8012ca:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012d0:	eb 2a                	jmp    8012fc <vprintfmt+0xe5>
  8012d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8012dc:	0f 49 d0             	cmovns %eax,%edx
  8012df:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012e5:	eb 89                	jmp    801270 <vprintfmt+0x59>
  8012e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012ea:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012f1:	e9 7a ff ff ff       	jmp    801270 <vprintfmt+0x59>
  8012f6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012f9:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8012fc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801300:	0f 89 6a ff ff ff    	jns    801270 <vprintfmt+0x59>
				width = precision, precision = -1;
  801306:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801309:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80130c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801313:	e9 58 ff ff ff       	jmp    801270 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801318:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80131e:	e9 4d ff ff ff       	jmp    801270 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801323:	8b 45 14             	mov    0x14(%ebp),%eax
  801326:	8d 78 04             	lea    0x4(%eax),%edi
  801329:	83 ec 08             	sub    $0x8,%esp
  80132c:	53                   	push   %ebx
  80132d:	ff 30                	pushl  (%eax)
  80132f:	ff d6                	call   *%esi
			break;
  801331:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801334:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801337:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80133a:	e9 fe fe ff ff       	jmp    80123d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80133f:	8b 45 14             	mov    0x14(%ebp),%eax
  801342:	8d 78 04             	lea    0x4(%eax),%edi
  801345:	8b 00                	mov    (%eax),%eax
  801347:	99                   	cltd   
  801348:	31 d0                	xor    %edx,%eax
  80134a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80134c:	83 f8 0f             	cmp    $0xf,%eax
  80134f:	7f 0b                	jg     80135c <vprintfmt+0x145>
  801351:	8b 14 85 20 22 80 00 	mov    0x802220(,%eax,4),%edx
  801358:	85 d2                	test   %edx,%edx
  80135a:	75 1b                	jne    801377 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80135c:	50                   	push   %eax
  80135d:	68 9f 1f 80 00       	push   $0x801f9f
  801362:	53                   	push   %ebx
  801363:	56                   	push   %esi
  801364:	e8 91 fe ff ff       	call   8011fa <printfmt>
  801369:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80136c:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80136f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801372:	e9 c6 fe ff ff       	jmp    80123d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801377:	52                   	push   %edx
  801378:	68 1d 1f 80 00       	push   $0x801f1d
  80137d:	53                   	push   %ebx
  80137e:	56                   	push   %esi
  80137f:	e8 76 fe ff ff       	call   8011fa <printfmt>
  801384:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801387:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80138a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80138d:	e9 ab fe ff ff       	jmp    80123d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801392:	8b 45 14             	mov    0x14(%ebp),%eax
  801395:	83 c0 04             	add    $0x4,%eax
  801398:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80139b:	8b 45 14             	mov    0x14(%ebp),%eax
  80139e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013a0:	85 ff                	test   %edi,%edi
  8013a2:	b8 98 1f 80 00       	mov    $0x801f98,%eax
  8013a7:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013aa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013ae:	0f 8e 94 00 00 00    	jle    801448 <vprintfmt+0x231>
  8013b4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013b8:	0f 84 98 00 00 00    	je     801456 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013be:	83 ec 08             	sub    $0x8,%esp
  8013c1:	ff 75 d0             	pushl  -0x30(%ebp)
  8013c4:	57                   	push   %edi
  8013c5:	e8 33 03 00 00       	call   8016fd <strnlen>
  8013ca:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013cd:	29 c1                	sub    %eax,%ecx
  8013cf:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013d2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013d5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013dc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013df:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e1:	eb 0f                	jmp    8013f2 <vprintfmt+0x1db>
					putch(padc, putdat);
  8013e3:	83 ec 08             	sub    $0x8,%esp
  8013e6:	53                   	push   %ebx
  8013e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8013ea:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013ec:	83 ef 01             	sub    $0x1,%edi
  8013ef:	83 c4 10             	add    $0x10,%esp
  8013f2:	85 ff                	test   %edi,%edi
  8013f4:	7f ed                	jg     8013e3 <vprintfmt+0x1cc>
  8013f6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013f9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013fc:	85 c9                	test   %ecx,%ecx
  8013fe:	b8 00 00 00 00       	mov    $0x0,%eax
  801403:	0f 49 c1             	cmovns %ecx,%eax
  801406:	29 c1                	sub    %eax,%ecx
  801408:	89 75 08             	mov    %esi,0x8(%ebp)
  80140b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80140e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801411:	89 cb                	mov    %ecx,%ebx
  801413:	eb 4d                	jmp    801462 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801415:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801419:	74 1b                	je     801436 <vprintfmt+0x21f>
  80141b:	0f be c0             	movsbl %al,%eax
  80141e:	83 e8 20             	sub    $0x20,%eax
  801421:	83 f8 5e             	cmp    $0x5e,%eax
  801424:	76 10                	jbe    801436 <vprintfmt+0x21f>
					putch('?', putdat);
  801426:	83 ec 08             	sub    $0x8,%esp
  801429:	ff 75 0c             	pushl  0xc(%ebp)
  80142c:	6a 3f                	push   $0x3f
  80142e:	ff 55 08             	call   *0x8(%ebp)
  801431:	83 c4 10             	add    $0x10,%esp
  801434:	eb 0d                	jmp    801443 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  801436:	83 ec 08             	sub    $0x8,%esp
  801439:	ff 75 0c             	pushl  0xc(%ebp)
  80143c:	52                   	push   %edx
  80143d:	ff 55 08             	call   *0x8(%ebp)
  801440:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801443:	83 eb 01             	sub    $0x1,%ebx
  801446:	eb 1a                	jmp    801462 <vprintfmt+0x24b>
  801448:	89 75 08             	mov    %esi,0x8(%ebp)
  80144b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80144e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801451:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801454:	eb 0c                	jmp    801462 <vprintfmt+0x24b>
  801456:	89 75 08             	mov    %esi,0x8(%ebp)
  801459:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80145c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80145f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801462:	83 c7 01             	add    $0x1,%edi
  801465:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801469:	0f be d0             	movsbl %al,%edx
  80146c:	85 d2                	test   %edx,%edx
  80146e:	74 23                	je     801493 <vprintfmt+0x27c>
  801470:	85 f6                	test   %esi,%esi
  801472:	78 a1                	js     801415 <vprintfmt+0x1fe>
  801474:	83 ee 01             	sub    $0x1,%esi
  801477:	79 9c                	jns    801415 <vprintfmt+0x1fe>
  801479:	89 df                	mov    %ebx,%edi
  80147b:	8b 75 08             	mov    0x8(%ebp),%esi
  80147e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801481:	eb 18                	jmp    80149b <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801483:	83 ec 08             	sub    $0x8,%esp
  801486:	53                   	push   %ebx
  801487:	6a 20                	push   $0x20
  801489:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80148b:	83 ef 01             	sub    $0x1,%edi
  80148e:	83 c4 10             	add    $0x10,%esp
  801491:	eb 08                	jmp    80149b <vprintfmt+0x284>
  801493:	89 df                	mov    %ebx,%edi
  801495:	8b 75 08             	mov    0x8(%ebp),%esi
  801498:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80149b:	85 ff                	test   %edi,%edi
  80149d:	7f e4                	jg     801483 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80149f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8014a2:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014a8:	e9 90 fd ff ff       	jmp    80123d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014ad:	83 f9 01             	cmp    $0x1,%ecx
  8014b0:	7e 19                	jle    8014cb <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8014b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b5:	8b 50 04             	mov    0x4(%eax),%edx
  8014b8:	8b 00                	mov    (%eax),%eax
  8014ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014bd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c3:	8d 40 08             	lea    0x8(%eax),%eax
  8014c6:	89 45 14             	mov    %eax,0x14(%ebp)
  8014c9:	eb 38                	jmp    801503 <vprintfmt+0x2ec>
	else if (lflag)
  8014cb:	85 c9                	test   %ecx,%ecx
  8014cd:	74 1b                	je     8014ea <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8014cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d2:	8b 00                	mov    (%eax),%eax
  8014d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014d7:	89 c1                	mov    %eax,%ecx
  8014d9:	c1 f9 1f             	sar    $0x1f,%ecx
  8014dc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014df:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e2:	8d 40 04             	lea    0x4(%eax),%eax
  8014e5:	89 45 14             	mov    %eax,0x14(%ebp)
  8014e8:	eb 19                	jmp    801503 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8014ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ed:	8b 00                	mov    (%eax),%eax
  8014ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f2:	89 c1                	mov    %eax,%ecx
  8014f4:	c1 f9 1f             	sar    $0x1f,%ecx
  8014f7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8014fd:	8d 40 04             	lea    0x4(%eax),%eax
  801500:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801503:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801506:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801509:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80150e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801512:	0f 89 0e 01 00 00    	jns    801626 <vprintfmt+0x40f>
				putch('-', putdat);
  801518:	83 ec 08             	sub    $0x8,%esp
  80151b:	53                   	push   %ebx
  80151c:	6a 2d                	push   $0x2d
  80151e:	ff d6                	call   *%esi
				num = -(long long) num;
  801520:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801523:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801526:	f7 da                	neg    %edx
  801528:	83 d1 00             	adc    $0x0,%ecx
  80152b:	f7 d9                	neg    %ecx
  80152d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801530:	b8 0a 00 00 00       	mov    $0xa,%eax
  801535:	e9 ec 00 00 00       	jmp    801626 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80153a:	83 f9 01             	cmp    $0x1,%ecx
  80153d:	7e 18                	jle    801557 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  80153f:	8b 45 14             	mov    0x14(%ebp),%eax
  801542:	8b 10                	mov    (%eax),%edx
  801544:	8b 48 04             	mov    0x4(%eax),%ecx
  801547:	8d 40 08             	lea    0x8(%eax),%eax
  80154a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80154d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801552:	e9 cf 00 00 00       	jmp    801626 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801557:	85 c9                	test   %ecx,%ecx
  801559:	74 1a                	je     801575 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80155b:	8b 45 14             	mov    0x14(%ebp),%eax
  80155e:	8b 10                	mov    (%eax),%edx
  801560:	b9 00 00 00 00       	mov    $0x0,%ecx
  801565:	8d 40 04             	lea    0x4(%eax),%eax
  801568:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80156b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801570:	e9 b1 00 00 00       	jmp    801626 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801575:	8b 45 14             	mov    0x14(%ebp),%eax
  801578:	8b 10                	mov    (%eax),%edx
  80157a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80157f:	8d 40 04             	lea    0x4(%eax),%eax
  801582:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801585:	b8 0a 00 00 00       	mov    $0xa,%eax
  80158a:	e9 97 00 00 00       	jmp    801626 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80158f:	83 ec 08             	sub    $0x8,%esp
  801592:	53                   	push   %ebx
  801593:	6a 58                	push   $0x58
  801595:	ff d6                	call   *%esi
			putch('X', putdat);
  801597:	83 c4 08             	add    $0x8,%esp
  80159a:	53                   	push   %ebx
  80159b:	6a 58                	push   $0x58
  80159d:	ff d6                	call   *%esi
			putch('X', putdat);
  80159f:	83 c4 08             	add    $0x8,%esp
  8015a2:	53                   	push   %ebx
  8015a3:	6a 58                	push   $0x58
  8015a5:	ff d6                	call   *%esi
			break;
  8015a7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8015ad:	e9 8b fc ff ff       	jmp    80123d <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8015b2:	83 ec 08             	sub    $0x8,%esp
  8015b5:	53                   	push   %ebx
  8015b6:	6a 30                	push   $0x30
  8015b8:	ff d6                	call   *%esi
			putch('x', putdat);
  8015ba:	83 c4 08             	add    $0x8,%esp
  8015bd:	53                   	push   %ebx
  8015be:	6a 78                	push   $0x78
  8015c0:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c5:	8b 10                	mov    (%eax),%edx
  8015c7:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015cc:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015cf:	8d 40 04             	lea    0x4(%eax),%eax
  8015d2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015d5:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015da:	eb 4a                	jmp    801626 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015dc:	83 f9 01             	cmp    $0x1,%ecx
  8015df:	7e 15                	jle    8015f6 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8015e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e4:	8b 10                	mov    (%eax),%edx
  8015e6:	8b 48 04             	mov    0x4(%eax),%ecx
  8015e9:	8d 40 08             	lea    0x8(%eax),%eax
  8015ec:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8015ef:	b8 10 00 00 00       	mov    $0x10,%eax
  8015f4:	eb 30                	jmp    801626 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8015f6:	85 c9                	test   %ecx,%ecx
  8015f8:	74 17                	je     801611 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8015fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8015fd:	8b 10                	mov    (%eax),%edx
  8015ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  801604:	8d 40 04             	lea    0x4(%eax),%eax
  801607:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80160a:	b8 10 00 00 00       	mov    $0x10,%eax
  80160f:	eb 15                	jmp    801626 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801611:	8b 45 14             	mov    0x14(%ebp),%eax
  801614:	8b 10                	mov    (%eax),%edx
  801616:	b9 00 00 00 00       	mov    $0x0,%ecx
  80161b:	8d 40 04             	lea    0x4(%eax),%eax
  80161e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801621:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801626:	83 ec 0c             	sub    $0xc,%esp
  801629:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80162d:	57                   	push   %edi
  80162e:	ff 75 e0             	pushl  -0x20(%ebp)
  801631:	50                   	push   %eax
  801632:	51                   	push   %ecx
  801633:	52                   	push   %edx
  801634:	89 da                	mov    %ebx,%edx
  801636:	89 f0                	mov    %esi,%eax
  801638:	e8 f1 fa ff ff       	call   80112e <printnum>
			break;
  80163d:	83 c4 20             	add    $0x20,%esp
  801640:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801643:	e9 f5 fb ff ff       	jmp    80123d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801648:	83 ec 08             	sub    $0x8,%esp
  80164b:	53                   	push   %ebx
  80164c:	52                   	push   %edx
  80164d:	ff d6                	call   *%esi
			break;
  80164f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801652:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801655:	e9 e3 fb ff ff       	jmp    80123d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80165a:	83 ec 08             	sub    $0x8,%esp
  80165d:	53                   	push   %ebx
  80165e:	6a 25                	push   $0x25
  801660:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801662:	83 c4 10             	add    $0x10,%esp
  801665:	eb 03                	jmp    80166a <vprintfmt+0x453>
  801667:	83 ef 01             	sub    $0x1,%edi
  80166a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80166e:	75 f7                	jne    801667 <vprintfmt+0x450>
  801670:	e9 c8 fb ff ff       	jmp    80123d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801675:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801678:	5b                   	pop    %ebx
  801679:	5e                   	pop    %esi
  80167a:	5f                   	pop    %edi
  80167b:	5d                   	pop    %ebp
  80167c:	c3                   	ret    

0080167d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
  801680:	83 ec 18             	sub    $0x18,%esp
  801683:	8b 45 08             	mov    0x8(%ebp),%eax
  801686:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801689:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80168c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801690:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801693:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80169a:	85 c0                	test   %eax,%eax
  80169c:	74 26                	je     8016c4 <vsnprintf+0x47>
  80169e:	85 d2                	test   %edx,%edx
  8016a0:	7e 22                	jle    8016c4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8016a2:	ff 75 14             	pushl  0x14(%ebp)
  8016a5:	ff 75 10             	pushl  0x10(%ebp)
  8016a8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016ab:	50                   	push   %eax
  8016ac:	68 dd 11 80 00       	push   $0x8011dd
  8016b1:	e8 61 fb ff ff       	call   801217 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016b6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016b9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	eb 05                	jmp    8016c9 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016c9:	c9                   	leave  
  8016ca:	c3                   	ret    

008016cb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016cb:	55                   	push   %ebp
  8016cc:	89 e5                	mov    %esp,%ebp
  8016ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016d1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016d4:	50                   	push   %eax
  8016d5:	ff 75 10             	pushl  0x10(%ebp)
  8016d8:	ff 75 0c             	pushl  0xc(%ebp)
  8016db:	ff 75 08             	pushl  0x8(%ebp)
  8016de:	e8 9a ff ff ff       	call   80167d <vsnprintf>
	va_end(ap);

	return rc;
}
  8016e3:	c9                   	leave  
  8016e4:	c3                   	ret    

008016e5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016e5:	55                   	push   %ebp
  8016e6:	89 e5                	mov    %esp,%ebp
  8016e8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f0:	eb 03                	jmp    8016f5 <strlen+0x10>
		n++;
  8016f2:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016f5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016f9:	75 f7                	jne    8016f2 <strlen+0xd>
		n++;
	return n;
}
  8016fb:	5d                   	pop    %ebp
  8016fc:	c3                   	ret    

008016fd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016fd:	55                   	push   %ebp
  8016fe:	89 e5                	mov    %esp,%ebp
  801700:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801703:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801706:	ba 00 00 00 00       	mov    $0x0,%edx
  80170b:	eb 03                	jmp    801710 <strnlen+0x13>
		n++;
  80170d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801710:	39 c2                	cmp    %eax,%edx
  801712:	74 08                	je     80171c <strnlen+0x1f>
  801714:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801718:	75 f3                	jne    80170d <strnlen+0x10>
  80171a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80171c:	5d                   	pop    %ebp
  80171d:	c3                   	ret    

0080171e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	53                   	push   %ebx
  801722:	8b 45 08             	mov    0x8(%ebp),%eax
  801725:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801728:	89 c2                	mov    %eax,%edx
  80172a:	83 c2 01             	add    $0x1,%edx
  80172d:	83 c1 01             	add    $0x1,%ecx
  801730:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801734:	88 5a ff             	mov    %bl,-0x1(%edx)
  801737:	84 db                	test   %bl,%bl
  801739:	75 ef                	jne    80172a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80173b:	5b                   	pop    %ebx
  80173c:	5d                   	pop    %ebp
  80173d:	c3                   	ret    

0080173e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	53                   	push   %ebx
  801742:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801745:	53                   	push   %ebx
  801746:	e8 9a ff ff ff       	call   8016e5 <strlen>
  80174b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80174e:	ff 75 0c             	pushl  0xc(%ebp)
  801751:	01 d8                	add    %ebx,%eax
  801753:	50                   	push   %eax
  801754:	e8 c5 ff ff ff       	call   80171e <strcpy>
	return dst;
}
  801759:	89 d8                	mov    %ebx,%eax
  80175b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175e:	c9                   	leave  
  80175f:	c3                   	ret    

00801760 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801760:	55                   	push   %ebp
  801761:	89 e5                	mov    %esp,%ebp
  801763:	56                   	push   %esi
  801764:	53                   	push   %ebx
  801765:	8b 75 08             	mov    0x8(%ebp),%esi
  801768:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80176b:	89 f3                	mov    %esi,%ebx
  80176d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801770:	89 f2                	mov    %esi,%edx
  801772:	eb 0f                	jmp    801783 <strncpy+0x23>
		*dst++ = *src;
  801774:	83 c2 01             	add    $0x1,%edx
  801777:	0f b6 01             	movzbl (%ecx),%eax
  80177a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80177d:	80 39 01             	cmpb   $0x1,(%ecx)
  801780:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801783:	39 da                	cmp    %ebx,%edx
  801785:	75 ed                	jne    801774 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801787:	89 f0                	mov    %esi,%eax
  801789:	5b                   	pop    %ebx
  80178a:	5e                   	pop    %esi
  80178b:	5d                   	pop    %ebp
  80178c:	c3                   	ret    

0080178d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80178d:	55                   	push   %ebp
  80178e:	89 e5                	mov    %esp,%ebp
  801790:	56                   	push   %esi
  801791:	53                   	push   %ebx
  801792:	8b 75 08             	mov    0x8(%ebp),%esi
  801795:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801798:	8b 55 10             	mov    0x10(%ebp),%edx
  80179b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80179d:	85 d2                	test   %edx,%edx
  80179f:	74 21                	je     8017c2 <strlcpy+0x35>
  8017a1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8017a5:	89 f2                	mov    %esi,%edx
  8017a7:	eb 09                	jmp    8017b2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017a9:	83 c2 01             	add    $0x1,%edx
  8017ac:	83 c1 01             	add    $0x1,%ecx
  8017af:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017b2:	39 c2                	cmp    %eax,%edx
  8017b4:	74 09                	je     8017bf <strlcpy+0x32>
  8017b6:	0f b6 19             	movzbl (%ecx),%ebx
  8017b9:	84 db                	test   %bl,%bl
  8017bb:	75 ec                	jne    8017a9 <strlcpy+0x1c>
  8017bd:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017bf:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017c2:	29 f0                	sub    %esi,%eax
}
  8017c4:	5b                   	pop    %ebx
  8017c5:	5e                   	pop    %esi
  8017c6:	5d                   	pop    %ebp
  8017c7:	c3                   	ret    

008017c8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017c8:	55                   	push   %ebp
  8017c9:	89 e5                	mov    %esp,%ebp
  8017cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017d1:	eb 06                	jmp    8017d9 <strcmp+0x11>
		p++, q++;
  8017d3:	83 c1 01             	add    $0x1,%ecx
  8017d6:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017d9:	0f b6 01             	movzbl (%ecx),%eax
  8017dc:	84 c0                	test   %al,%al
  8017de:	74 04                	je     8017e4 <strcmp+0x1c>
  8017e0:	3a 02                	cmp    (%edx),%al
  8017e2:	74 ef                	je     8017d3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017e4:	0f b6 c0             	movzbl %al,%eax
  8017e7:	0f b6 12             	movzbl (%edx),%edx
  8017ea:	29 d0                	sub    %edx,%eax
}
  8017ec:	5d                   	pop    %ebp
  8017ed:	c3                   	ret    

008017ee <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	53                   	push   %ebx
  8017f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f8:	89 c3                	mov    %eax,%ebx
  8017fa:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017fd:	eb 06                	jmp    801805 <strncmp+0x17>
		n--, p++, q++;
  8017ff:	83 c0 01             	add    $0x1,%eax
  801802:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801805:	39 d8                	cmp    %ebx,%eax
  801807:	74 15                	je     80181e <strncmp+0x30>
  801809:	0f b6 08             	movzbl (%eax),%ecx
  80180c:	84 c9                	test   %cl,%cl
  80180e:	74 04                	je     801814 <strncmp+0x26>
  801810:	3a 0a                	cmp    (%edx),%cl
  801812:	74 eb                	je     8017ff <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801814:	0f b6 00             	movzbl (%eax),%eax
  801817:	0f b6 12             	movzbl (%edx),%edx
  80181a:	29 d0                	sub    %edx,%eax
  80181c:	eb 05                	jmp    801823 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80181e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801823:	5b                   	pop    %ebx
  801824:	5d                   	pop    %ebp
  801825:	c3                   	ret    

00801826 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801826:	55                   	push   %ebp
  801827:	89 e5                	mov    %esp,%ebp
  801829:	8b 45 08             	mov    0x8(%ebp),%eax
  80182c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801830:	eb 07                	jmp    801839 <strchr+0x13>
		if (*s == c)
  801832:	38 ca                	cmp    %cl,%dl
  801834:	74 0f                	je     801845 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801836:	83 c0 01             	add    $0x1,%eax
  801839:	0f b6 10             	movzbl (%eax),%edx
  80183c:	84 d2                	test   %dl,%dl
  80183e:	75 f2                	jne    801832 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801840:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801845:	5d                   	pop    %ebp
  801846:	c3                   	ret    

00801847 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	8b 45 08             	mov    0x8(%ebp),%eax
  80184d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801851:	eb 03                	jmp    801856 <strfind+0xf>
  801853:	83 c0 01             	add    $0x1,%eax
  801856:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801859:	38 ca                	cmp    %cl,%dl
  80185b:	74 04                	je     801861 <strfind+0x1a>
  80185d:	84 d2                	test   %dl,%dl
  80185f:	75 f2                	jne    801853 <strfind+0xc>
			break;
	return (char *) s;
}
  801861:	5d                   	pop    %ebp
  801862:	c3                   	ret    

00801863 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	57                   	push   %edi
  801867:	56                   	push   %esi
  801868:	53                   	push   %ebx
  801869:	8b 7d 08             	mov    0x8(%ebp),%edi
  80186c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80186f:	85 c9                	test   %ecx,%ecx
  801871:	74 36                	je     8018a9 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801873:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801879:	75 28                	jne    8018a3 <memset+0x40>
  80187b:	f6 c1 03             	test   $0x3,%cl
  80187e:	75 23                	jne    8018a3 <memset+0x40>
		c &= 0xFF;
  801880:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801884:	89 d3                	mov    %edx,%ebx
  801886:	c1 e3 08             	shl    $0x8,%ebx
  801889:	89 d6                	mov    %edx,%esi
  80188b:	c1 e6 18             	shl    $0x18,%esi
  80188e:	89 d0                	mov    %edx,%eax
  801890:	c1 e0 10             	shl    $0x10,%eax
  801893:	09 f0                	or     %esi,%eax
  801895:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801897:	89 d8                	mov    %ebx,%eax
  801899:	09 d0                	or     %edx,%eax
  80189b:	c1 e9 02             	shr    $0x2,%ecx
  80189e:	fc                   	cld    
  80189f:	f3 ab                	rep stos %eax,%es:(%edi)
  8018a1:	eb 06                	jmp    8018a9 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8018a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a6:	fc                   	cld    
  8018a7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8018a9:	89 f8                	mov    %edi,%eax
  8018ab:	5b                   	pop    %ebx
  8018ac:	5e                   	pop    %esi
  8018ad:	5f                   	pop    %edi
  8018ae:	5d                   	pop    %ebp
  8018af:	c3                   	ret    

008018b0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	57                   	push   %edi
  8018b4:	56                   	push   %esi
  8018b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018bb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018be:	39 c6                	cmp    %eax,%esi
  8018c0:	73 35                	jae    8018f7 <memmove+0x47>
  8018c2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018c5:	39 d0                	cmp    %edx,%eax
  8018c7:	73 2e                	jae    8018f7 <memmove+0x47>
		s += n;
		d += n;
  8018c9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018cc:	89 d6                	mov    %edx,%esi
  8018ce:	09 fe                	or     %edi,%esi
  8018d0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018d6:	75 13                	jne    8018eb <memmove+0x3b>
  8018d8:	f6 c1 03             	test   $0x3,%cl
  8018db:	75 0e                	jne    8018eb <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018dd:	83 ef 04             	sub    $0x4,%edi
  8018e0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018e3:	c1 e9 02             	shr    $0x2,%ecx
  8018e6:	fd                   	std    
  8018e7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018e9:	eb 09                	jmp    8018f4 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018eb:	83 ef 01             	sub    $0x1,%edi
  8018ee:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018f1:	fd                   	std    
  8018f2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018f4:	fc                   	cld    
  8018f5:	eb 1d                	jmp    801914 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018f7:	89 f2                	mov    %esi,%edx
  8018f9:	09 c2                	or     %eax,%edx
  8018fb:	f6 c2 03             	test   $0x3,%dl
  8018fe:	75 0f                	jne    80190f <memmove+0x5f>
  801900:	f6 c1 03             	test   $0x3,%cl
  801903:	75 0a                	jne    80190f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801905:	c1 e9 02             	shr    $0x2,%ecx
  801908:	89 c7                	mov    %eax,%edi
  80190a:	fc                   	cld    
  80190b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80190d:	eb 05                	jmp    801914 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80190f:	89 c7                	mov    %eax,%edi
  801911:	fc                   	cld    
  801912:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801914:	5e                   	pop    %esi
  801915:	5f                   	pop    %edi
  801916:	5d                   	pop    %ebp
  801917:	c3                   	ret    

00801918 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80191b:	ff 75 10             	pushl  0x10(%ebp)
  80191e:	ff 75 0c             	pushl  0xc(%ebp)
  801921:	ff 75 08             	pushl  0x8(%ebp)
  801924:	e8 87 ff ff ff       	call   8018b0 <memmove>
}
  801929:	c9                   	leave  
  80192a:	c3                   	ret    

0080192b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80192b:	55                   	push   %ebp
  80192c:	89 e5                	mov    %esp,%ebp
  80192e:	56                   	push   %esi
  80192f:	53                   	push   %ebx
  801930:	8b 45 08             	mov    0x8(%ebp),%eax
  801933:	8b 55 0c             	mov    0xc(%ebp),%edx
  801936:	89 c6                	mov    %eax,%esi
  801938:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80193b:	eb 1a                	jmp    801957 <memcmp+0x2c>
		if (*s1 != *s2)
  80193d:	0f b6 08             	movzbl (%eax),%ecx
  801940:	0f b6 1a             	movzbl (%edx),%ebx
  801943:	38 d9                	cmp    %bl,%cl
  801945:	74 0a                	je     801951 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801947:	0f b6 c1             	movzbl %cl,%eax
  80194a:	0f b6 db             	movzbl %bl,%ebx
  80194d:	29 d8                	sub    %ebx,%eax
  80194f:	eb 0f                	jmp    801960 <memcmp+0x35>
		s1++, s2++;
  801951:	83 c0 01             	add    $0x1,%eax
  801954:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801957:	39 f0                	cmp    %esi,%eax
  801959:	75 e2                	jne    80193d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80195b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801960:	5b                   	pop    %ebx
  801961:	5e                   	pop    %esi
  801962:	5d                   	pop    %ebp
  801963:	c3                   	ret    

00801964 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	53                   	push   %ebx
  801968:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80196b:	89 c1                	mov    %eax,%ecx
  80196d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801970:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801974:	eb 0a                	jmp    801980 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801976:	0f b6 10             	movzbl (%eax),%edx
  801979:	39 da                	cmp    %ebx,%edx
  80197b:	74 07                	je     801984 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80197d:	83 c0 01             	add    $0x1,%eax
  801980:	39 c8                	cmp    %ecx,%eax
  801982:	72 f2                	jb     801976 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801984:	5b                   	pop    %ebx
  801985:	5d                   	pop    %ebp
  801986:	c3                   	ret    

00801987 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801987:	55                   	push   %ebp
  801988:	89 e5                	mov    %esp,%ebp
  80198a:	57                   	push   %edi
  80198b:	56                   	push   %esi
  80198c:	53                   	push   %ebx
  80198d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801990:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801993:	eb 03                	jmp    801998 <strtol+0x11>
		s++;
  801995:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801998:	0f b6 01             	movzbl (%ecx),%eax
  80199b:	3c 20                	cmp    $0x20,%al
  80199d:	74 f6                	je     801995 <strtol+0xe>
  80199f:	3c 09                	cmp    $0x9,%al
  8019a1:	74 f2                	je     801995 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8019a3:	3c 2b                	cmp    $0x2b,%al
  8019a5:	75 0a                	jne    8019b1 <strtol+0x2a>
		s++;
  8019a7:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019aa:	bf 00 00 00 00       	mov    $0x0,%edi
  8019af:	eb 11                	jmp    8019c2 <strtol+0x3b>
  8019b1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019b6:	3c 2d                	cmp    $0x2d,%al
  8019b8:	75 08                	jne    8019c2 <strtol+0x3b>
		s++, neg = 1;
  8019ba:	83 c1 01             	add    $0x1,%ecx
  8019bd:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019c2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019c8:	75 15                	jne    8019df <strtol+0x58>
  8019ca:	80 39 30             	cmpb   $0x30,(%ecx)
  8019cd:	75 10                	jne    8019df <strtol+0x58>
  8019cf:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019d3:	75 7c                	jne    801a51 <strtol+0xca>
		s += 2, base = 16;
  8019d5:	83 c1 02             	add    $0x2,%ecx
  8019d8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019dd:	eb 16                	jmp    8019f5 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019df:	85 db                	test   %ebx,%ebx
  8019e1:	75 12                	jne    8019f5 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019e3:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019e8:	80 39 30             	cmpb   $0x30,(%ecx)
  8019eb:	75 08                	jne    8019f5 <strtol+0x6e>
		s++, base = 8;
  8019ed:	83 c1 01             	add    $0x1,%ecx
  8019f0:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019fa:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019fd:	0f b6 11             	movzbl (%ecx),%edx
  801a00:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a03:	89 f3                	mov    %esi,%ebx
  801a05:	80 fb 09             	cmp    $0x9,%bl
  801a08:	77 08                	ja     801a12 <strtol+0x8b>
			dig = *s - '0';
  801a0a:	0f be d2             	movsbl %dl,%edx
  801a0d:	83 ea 30             	sub    $0x30,%edx
  801a10:	eb 22                	jmp    801a34 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a12:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a15:	89 f3                	mov    %esi,%ebx
  801a17:	80 fb 19             	cmp    $0x19,%bl
  801a1a:	77 08                	ja     801a24 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a1c:	0f be d2             	movsbl %dl,%edx
  801a1f:	83 ea 57             	sub    $0x57,%edx
  801a22:	eb 10                	jmp    801a34 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a24:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a27:	89 f3                	mov    %esi,%ebx
  801a29:	80 fb 19             	cmp    $0x19,%bl
  801a2c:	77 16                	ja     801a44 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a2e:	0f be d2             	movsbl %dl,%edx
  801a31:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a34:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a37:	7d 0b                	jge    801a44 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a39:	83 c1 01             	add    $0x1,%ecx
  801a3c:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a40:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a42:	eb b9                	jmp    8019fd <strtol+0x76>

	if (endptr)
  801a44:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a48:	74 0d                	je     801a57 <strtol+0xd0>
		*endptr = (char *) s;
  801a4a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a4d:	89 0e                	mov    %ecx,(%esi)
  801a4f:	eb 06                	jmp    801a57 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a51:	85 db                	test   %ebx,%ebx
  801a53:	74 98                	je     8019ed <strtol+0x66>
  801a55:	eb 9e                	jmp    8019f5 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a57:	89 c2                	mov    %eax,%edx
  801a59:	f7 da                	neg    %edx
  801a5b:	85 ff                	test   %edi,%edi
  801a5d:	0f 45 c2             	cmovne %edx,%eax
}
  801a60:	5b                   	pop    %ebx
  801a61:	5e                   	pop    %esi
  801a62:	5f                   	pop    %edi
  801a63:	5d                   	pop    %ebp
  801a64:	c3                   	ret    

00801a65 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a65:	55                   	push   %ebp
  801a66:	89 e5                	mov    %esp,%ebp
  801a68:	56                   	push   %esi
  801a69:	53                   	push   %ebx
  801a6a:	8b 75 08             	mov    0x8(%ebp),%esi
  801a6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a70:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801a73:	85 c0                	test   %eax,%eax
  801a75:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a7a:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801a7d:	83 ec 0c             	sub    $0xc,%esp
  801a80:	50                   	push   %eax
  801a81:	e8 90 e8 ff ff       	call   800316 <sys_ipc_recv>
  801a86:	83 c4 10             	add    $0x10,%esp
  801a89:	85 c0                	test   %eax,%eax
  801a8b:	79 16                	jns    801aa3 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801a8d:	85 f6                	test   %esi,%esi
  801a8f:	74 06                	je     801a97 <ipc_recv+0x32>
            *from_env_store = 0;
  801a91:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801a97:	85 db                	test   %ebx,%ebx
  801a99:	74 2c                	je     801ac7 <ipc_recv+0x62>
            *perm_store = 0;
  801a9b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801aa1:	eb 24                	jmp    801ac7 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801aa3:	85 f6                	test   %esi,%esi
  801aa5:	74 0a                	je     801ab1 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801aa7:	a1 04 40 80 00       	mov    0x804004,%eax
  801aac:	8b 40 74             	mov    0x74(%eax),%eax
  801aaf:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801ab1:	85 db                	test   %ebx,%ebx
  801ab3:	74 0a                	je     801abf <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801ab5:	a1 04 40 80 00       	mov    0x804004,%eax
  801aba:	8b 40 78             	mov    0x78(%eax),%eax
  801abd:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801abf:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac4:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801ac7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aca:	5b                   	pop    %ebx
  801acb:	5e                   	pop    %esi
  801acc:	5d                   	pop    %ebp
  801acd:	c3                   	ret    

00801ace <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	57                   	push   %edi
  801ad2:	56                   	push   %esi
  801ad3:	53                   	push   %ebx
  801ad4:	83 ec 0c             	sub    $0xc,%esp
  801ad7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ada:	8b 75 0c             	mov    0xc(%ebp),%esi
  801add:	8b 45 10             	mov    0x10(%ebp),%eax
  801ae0:	85 c0                	test   %eax,%eax
  801ae2:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ae7:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801aea:	eb 1c                	jmp    801b08 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801aec:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aef:	74 12                	je     801b03 <ipc_send+0x35>
  801af1:	50                   	push   %eax
  801af2:	68 80 22 80 00       	push   $0x802280
  801af7:	6a 3a                	push   $0x3a
  801af9:	68 96 22 80 00       	push   $0x802296
  801afe:	e8 3e f5 ff ff       	call   801041 <_panic>
		sys_yield();
  801b03:	e8 3f e6 ff ff       	call   800147 <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801b08:	ff 75 14             	pushl  0x14(%ebp)
  801b0b:	53                   	push   %ebx
  801b0c:	56                   	push   %esi
  801b0d:	57                   	push   %edi
  801b0e:	e8 e0 e7 ff ff       	call   8002f3 <sys_ipc_try_send>
  801b13:	83 c4 10             	add    $0x10,%esp
  801b16:	85 c0                	test   %eax,%eax
  801b18:	78 d2                	js     801aec <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801b1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1d:	5b                   	pop    %ebx
  801b1e:	5e                   	pop    %esi
  801b1f:	5f                   	pop    %edi
  801b20:	5d                   	pop    %ebp
  801b21:	c3                   	ret    

00801b22 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b28:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b2d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b30:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b36:	8b 52 50             	mov    0x50(%edx),%edx
  801b39:	39 ca                	cmp    %ecx,%edx
  801b3b:	75 0d                	jne    801b4a <ipc_find_env+0x28>
			return envs[i].env_id;
  801b3d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b40:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b45:	8b 40 48             	mov    0x48(%eax),%eax
  801b48:	eb 0f                	jmp    801b59 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b4a:	83 c0 01             	add    $0x1,%eax
  801b4d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b52:	75 d9                	jne    801b2d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b54:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b59:	5d                   	pop    %ebp
  801b5a:	c3                   	ret    

00801b5b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b61:	89 d0                	mov    %edx,%eax
  801b63:	c1 e8 16             	shr    $0x16,%eax
  801b66:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b6d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b72:	f6 c1 01             	test   $0x1,%cl
  801b75:	74 1d                	je     801b94 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b77:	c1 ea 0c             	shr    $0xc,%edx
  801b7a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b81:	f6 c2 01             	test   $0x1,%dl
  801b84:	74 0e                	je     801b94 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b86:	c1 ea 0c             	shr    $0xc,%edx
  801b89:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b90:	ef 
  801b91:	0f b7 c0             	movzwl %ax,%eax
}
  801b94:	5d                   	pop    %ebp
  801b95:	c3                   	ret    
  801b96:	66 90                	xchg   %ax,%ax
  801b98:	66 90                	xchg   %ax,%ax
  801b9a:	66 90                	xchg   %ax,%ax
  801b9c:	66 90                	xchg   %ax,%ax
  801b9e:	66 90                	xchg   %ax,%ax

00801ba0 <__udivdi3>:
  801ba0:	55                   	push   %ebp
  801ba1:	57                   	push   %edi
  801ba2:	56                   	push   %esi
  801ba3:	53                   	push   %ebx
  801ba4:	83 ec 1c             	sub    $0x1c,%esp
  801ba7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bab:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801baf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bb7:	85 f6                	test   %esi,%esi
  801bb9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bbd:	89 ca                	mov    %ecx,%edx
  801bbf:	89 f8                	mov    %edi,%eax
  801bc1:	75 3d                	jne    801c00 <__udivdi3+0x60>
  801bc3:	39 cf                	cmp    %ecx,%edi
  801bc5:	0f 87 c5 00 00 00    	ja     801c90 <__udivdi3+0xf0>
  801bcb:	85 ff                	test   %edi,%edi
  801bcd:	89 fd                	mov    %edi,%ebp
  801bcf:	75 0b                	jne    801bdc <__udivdi3+0x3c>
  801bd1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd6:	31 d2                	xor    %edx,%edx
  801bd8:	f7 f7                	div    %edi
  801bda:	89 c5                	mov    %eax,%ebp
  801bdc:	89 c8                	mov    %ecx,%eax
  801bde:	31 d2                	xor    %edx,%edx
  801be0:	f7 f5                	div    %ebp
  801be2:	89 c1                	mov    %eax,%ecx
  801be4:	89 d8                	mov    %ebx,%eax
  801be6:	89 cf                	mov    %ecx,%edi
  801be8:	f7 f5                	div    %ebp
  801bea:	89 c3                	mov    %eax,%ebx
  801bec:	89 d8                	mov    %ebx,%eax
  801bee:	89 fa                	mov    %edi,%edx
  801bf0:	83 c4 1c             	add    $0x1c,%esp
  801bf3:	5b                   	pop    %ebx
  801bf4:	5e                   	pop    %esi
  801bf5:	5f                   	pop    %edi
  801bf6:	5d                   	pop    %ebp
  801bf7:	c3                   	ret    
  801bf8:	90                   	nop
  801bf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c00:	39 ce                	cmp    %ecx,%esi
  801c02:	77 74                	ja     801c78 <__udivdi3+0xd8>
  801c04:	0f bd fe             	bsr    %esi,%edi
  801c07:	83 f7 1f             	xor    $0x1f,%edi
  801c0a:	0f 84 98 00 00 00    	je     801ca8 <__udivdi3+0x108>
  801c10:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c15:	89 f9                	mov    %edi,%ecx
  801c17:	89 c5                	mov    %eax,%ebp
  801c19:	29 fb                	sub    %edi,%ebx
  801c1b:	d3 e6                	shl    %cl,%esi
  801c1d:	89 d9                	mov    %ebx,%ecx
  801c1f:	d3 ed                	shr    %cl,%ebp
  801c21:	89 f9                	mov    %edi,%ecx
  801c23:	d3 e0                	shl    %cl,%eax
  801c25:	09 ee                	or     %ebp,%esi
  801c27:	89 d9                	mov    %ebx,%ecx
  801c29:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c2d:	89 d5                	mov    %edx,%ebp
  801c2f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c33:	d3 ed                	shr    %cl,%ebp
  801c35:	89 f9                	mov    %edi,%ecx
  801c37:	d3 e2                	shl    %cl,%edx
  801c39:	89 d9                	mov    %ebx,%ecx
  801c3b:	d3 e8                	shr    %cl,%eax
  801c3d:	09 c2                	or     %eax,%edx
  801c3f:	89 d0                	mov    %edx,%eax
  801c41:	89 ea                	mov    %ebp,%edx
  801c43:	f7 f6                	div    %esi
  801c45:	89 d5                	mov    %edx,%ebp
  801c47:	89 c3                	mov    %eax,%ebx
  801c49:	f7 64 24 0c          	mull   0xc(%esp)
  801c4d:	39 d5                	cmp    %edx,%ebp
  801c4f:	72 10                	jb     801c61 <__udivdi3+0xc1>
  801c51:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c55:	89 f9                	mov    %edi,%ecx
  801c57:	d3 e6                	shl    %cl,%esi
  801c59:	39 c6                	cmp    %eax,%esi
  801c5b:	73 07                	jae    801c64 <__udivdi3+0xc4>
  801c5d:	39 d5                	cmp    %edx,%ebp
  801c5f:	75 03                	jne    801c64 <__udivdi3+0xc4>
  801c61:	83 eb 01             	sub    $0x1,%ebx
  801c64:	31 ff                	xor    %edi,%edi
  801c66:	89 d8                	mov    %ebx,%eax
  801c68:	89 fa                	mov    %edi,%edx
  801c6a:	83 c4 1c             	add    $0x1c,%esp
  801c6d:	5b                   	pop    %ebx
  801c6e:	5e                   	pop    %esi
  801c6f:	5f                   	pop    %edi
  801c70:	5d                   	pop    %ebp
  801c71:	c3                   	ret    
  801c72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c78:	31 ff                	xor    %edi,%edi
  801c7a:	31 db                	xor    %ebx,%ebx
  801c7c:	89 d8                	mov    %ebx,%eax
  801c7e:	89 fa                	mov    %edi,%edx
  801c80:	83 c4 1c             	add    $0x1c,%esp
  801c83:	5b                   	pop    %ebx
  801c84:	5e                   	pop    %esi
  801c85:	5f                   	pop    %edi
  801c86:	5d                   	pop    %ebp
  801c87:	c3                   	ret    
  801c88:	90                   	nop
  801c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c90:	89 d8                	mov    %ebx,%eax
  801c92:	f7 f7                	div    %edi
  801c94:	31 ff                	xor    %edi,%edi
  801c96:	89 c3                	mov    %eax,%ebx
  801c98:	89 d8                	mov    %ebx,%eax
  801c9a:	89 fa                	mov    %edi,%edx
  801c9c:	83 c4 1c             	add    $0x1c,%esp
  801c9f:	5b                   	pop    %ebx
  801ca0:	5e                   	pop    %esi
  801ca1:	5f                   	pop    %edi
  801ca2:	5d                   	pop    %ebp
  801ca3:	c3                   	ret    
  801ca4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ca8:	39 ce                	cmp    %ecx,%esi
  801caa:	72 0c                	jb     801cb8 <__udivdi3+0x118>
  801cac:	31 db                	xor    %ebx,%ebx
  801cae:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cb2:	0f 87 34 ff ff ff    	ja     801bec <__udivdi3+0x4c>
  801cb8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cbd:	e9 2a ff ff ff       	jmp    801bec <__udivdi3+0x4c>
  801cc2:	66 90                	xchg   %ax,%ax
  801cc4:	66 90                	xchg   %ax,%ax
  801cc6:	66 90                	xchg   %ax,%ax
  801cc8:	66 90                	xchg   %ax,%ax
  801cca:	66 90                	xchg   %ax,%ax
  801ccc:	66 90                	xchg   %ax,%ax
  801cce:	66 90                	xchg   %ax,%ax

00801cd0 <__umoddi3>:
  801cd0:	55                   	push   %ebp
  801cd1:	57                   	push   %edi
  801cd2:	56                   	push   %esi
  801cd3:	53                   	push   %ebx
  801cd4:	83 ec 1c             	sub    $0x1c,%esp
  801cd7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cdb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cdf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ce3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ce7:	85 d2                	test   %edx,%edx
  801ce9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ced:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cf1:	89 f3                	mov    %esi,%ebx
  801cf3:	89 3c 24             	mov    %edi,(%esp)
  801cf6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cfa:	75 1c                	jne    801d18 <__umoddi3+0x48>
  801cfc:	39 f7                	cmp    %esi,%edi
  801cfe:	76 50                	jbe    801d50 <__umoddi3+0x80>
  801d00:	89 c8                	mov    %ecx,%eax
  801d02:	89 f2                	mov    %esi,%edx
  801d04:	f7 f7                	div    %edi
  801d06:	89 d0                	mov    %edx,%eax
  801d08:	31 d2                	xor    %edx,%edx
  801d0a:	83 c4 1c             	add    $0x1c,%esp
  801d0d:	5b                   	pop    %ebx
  801d0e:	5e                   	pop    %esi
  801d0f:	5f                   	pop    %edi
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    
  801d12:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d18:	39 f2                	cmp    %esi,%edx
  801d1a:	89 d0                	mov    %edx,%eax
  801d1c:	77 52                	ja     801d70 <__umoddi3+0xa0>
  801d1e:	0f bd ea             	bsr    %edx,%ebp
  801d21:	83 f5 1f             	xor    $0x1f,%ebp
  801d24:	75 5a                	jne    801d80 <__umoddi3+0xb0>
  801d26:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d2a:	0f 82 e0 00 00 00    	jb     801e10 <__umoddi3+0x140>
  801d30:	39 0c 24             	cmp    %ecx,(%esp)
  801d33:	0f 86 d7 00 00 00    	jbe    801e10 <__umoddi3+0x140>
  801d39:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d3d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d41:	83 c4 1c             	add    $0x1c,%esp
  801d44:	5b                   	pop    %ebx
  801d45:	5e                   	pop    %esi
  801d46:	5f                   	pop    %edi
  801d47:	5d                   	pop    %ebp
  801d48:	c3                   	ret    
  801d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d50:	85 ff                	test   %edi,%edi
  801d52:	89 fd                	mov    %edi,%ebp
  801d54:	75 0b                	jne    801d61 <__umoddi3+0x91>
  801d56:	b8 01 00 00 00       	mov    $0x1,%eax
  801d5b:	31 d2                	xor    %edx,%edx
  801d5d:	f7 f7                	div    %edi
  801d5f:	89 c5                	mov    %eax,%ebp
  801d61:	89 f0                	mov    %esi,%eax
  801d63:	31 d2                	xor    %edx,%edx
  801d65:	f7 f5                	div    %ebp
  801d67:	89 c8                	mov    %ecx,%eax
  801d69:	f7 f5                	div    %ebp
  801d6b:	89 d0                	mov    %edx,%eax
  801d6d:	eb 99                	jmp    801d08 <__umoddi3+0x38>
  801d6f:	90                   	nop
  801d70:	89 c8                	mov    %ecx,%eax
  801d72:	89 f2                	mov    %esi,%edx
  801d74:	83 c4 1c             	add    $0x1c,%esp
  801d77:	5b                   	pop    %ebx
  801d78:	5e                   	pop    %esi
  801d79:	5f                   	pop    %edi
  801d7a:	5d                   	pop    %ebp
  801d7b:	c3                   	ret    
  801d7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d80:	8b 34 24             	mov    (%esp),%esi
  801d83:	bf 20 00 00 00       	mov    $0x20,%edi
  801d88:	89 e9                	mov    %ebp,%ecx
  801d8a:	29 ef                	sub    %ebp,%edi
  801d8c:	d3 e0                	shl    %cl,%eax
  801d8e:	89 f9                	mov    %edi,%ecx
  801d90:	89 f2                	mov    %esi,%edx
  801d92:	d3 ea                	shr    %cl,%edx
  801d94:	89 e9                	mov    %ebp,%ecx
  801d96:	09 c2                	or     %eax,%edx
  801d98:	89 d8                	mov    %ebx,%eax
  801d9a:	89 14 24             	mov    %edx,(%esp)
  801d9d:	89 f2                	mov    %esi,%edx
  801d9f:	d3 e2                	shl    %cl,%edx
  801da1:	89 f9                	mov    %edi,%ecx
  801da3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801da7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dab:	d3 e8                	shr    %cl,%eax
  801dad:	89 e9                	mov    %ebp,%ecx
  801daf:	89 c6                	mov    %eax,%esi
  801db1:	d3 e3                	shl    %cl,%ebx
  801db3:	89 f9                	mov    %edi,%ecx
  801db5:	89 d0                	mov    %edx,%eax
  801db7:	d3 e8                	shr    %cl,%eax
  801db9:	89 e9                	mov    %ebp,%ecx
  801dbb:	09 d8                	or     %ebx,%eax
  801dbd:	89 d3                	mov    %edx,%ebx
  801dbf:	89 f2                	mov    %esi,%edx
  801dc1:	f7 34 24             	divl   (%esp)
  801dc4:	89 d6                	mov    %edx,%esi
  801dc6:	d3 e3                	shl    %cl,%ebx
  801dc8:	f7 64 24 04          	mull   0x4(%esp)
  801dcc:	39 d6                	cmp    %edx,%esi
  801dce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dd2:	89 d1                	mov    %edx,%ecx
  801dd4:	89 c3                	mov    %eax,%ebx
  801dd6:	72 08                	jb     801de0 <__umoddi3+0x110>
  801dd8:	75 11                	jne    801deb <__umoddi3+0x11b>
  801dda:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dde:	73 0b                	jae    801deb <__umoddi3+0x11b>
  801de0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801de4:	1b 14 24             	sbb    (%esp),%edx
  801de7:	89 d1                	mov    %edx,%ecx
  801de9:	89 c3                	mov    %eax,%ebx
  801deb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801def:	29 da                	sub    %ebx,%edx
  801df1:	19 ce                	sbb    %ecx,%esi
  801df3:	89 f9                	mov    %edi,%ecx
  801df5:	89 f0                	mov    %esi,%eax
  801df7:	d3 e0                	shl    %cl,%eax
  801df9:	89 e9                	mov    %ebp,%ecx
  801dfb:	d3 ea                	shr    %cl,%edx
  801dfd:	89 e9                	mov    %ebp,%ecx
  801dff:	d3 ee                	shr    %cl,%esi
  801e01:	09 d0                	or     %edx,%eax
  801e03:	89 f2                	mov    %esi,%edx
  801e05:	83 c4 1c             	add    $0x1c,%esp
  801e08:	5b                   	pop    %ebx
  801e09:	5e                   	pop    %esi
  801e0a:	5f                   	pop    %edi
  801e0b:	5d                   	pop    %ebp
  801e0c:	c3                   	ret    
  801e0d:	8d 76 00             	lea    0x0(%esi),%esi
  801e10:	29 f9                	sub    %edi,%ecx
  801e12:	19 d6                	sbb    %edx,%esi
  801e14:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e18:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e1c:	e9 18 ff ff ff       	jmp    801d39 <__umoddi3+0x69>
