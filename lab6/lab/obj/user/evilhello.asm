
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
  800067:	a3 08 40 80 00       	mov    %eax,0x804008

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
  800096:	e8 c6 04 00 00       	call   800561 <close_all>
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
  80010f:	68 ea 22 80 00       	push   $0x8022ea
  800114:	6a 23                	push   $0x23
  800116:	68 07 23 80 00       	push   $0x802307
  80011b:	e8 c7 13 00 00       	call   8014e7 <_panic>

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
  800190:	68 ea 22 80 00       	push   $0x8022ea
  800195:	6a 23                	push   $0x23
  800197:	68 07 23 80 00       	push   $0x802307
  80019c:	e8 46 13 00 00       	call   8014e7 <_panic>

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
  8001d2:	68 ea 22 80 00       	push   $0x8022ea
  8001d7:	6a 23                	push   $0x23
  8001d9:	68 07 23 80 00       	push   $0x802307
  8001de:	e8 04 13 00 00       	call   8014e7 <_panic>

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
  800214:	68 ea 22 80 00       	push   $0x8022ea
  800219:	6a 23                	push   $0x23
  80021b:	68 07 23 80 00       	push   $0x802307
  800220:	e8 c2 12 00 00       	call   8014e7 <_panic>

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
  800256:	68 ea 22 80 00       	push   $0x8022ea
  80025b:	6a 23                	push   $0x23
  80025d:	68 07 23 80 00       	push   $0x802307
  800262:	e8 80 12 00 00       	call   8014e7 <_panic>

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
  800298:	68 ea 22 80 00       	push   $0x8022ea
  80029d:	6a 23                	push   $0x23
  80029f:	68 07 23 80 00       	push   $0x802307
  8002a4:	e8 3e 12 00 00       	call   8014e7 <_panic>

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
  8002da:	68 ea 22 80 00       	push   $0x8022ea
  8002df:	6a 23                	push   $0x23
  8002e1:	68 07 23 80 00       	push   $0x802307
  8002e6:	e8 fc 11 00 00       	call   8014e7 <_panic>

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
  80033e:	68 ea 22 80 00       	push   $0x8022ea
  800343:	6a 23                	push   $0x23
  800345:	68 07 23 80 00       	push   $0x802307
  80034a:	e8 98 11 00 00       	call   8014e7 <_panic>

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

00800357 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	57                   	push   %edi
  80035b:	56                   	push   %esi
  80035c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035d:	ba 00 00 00 00       	mov    $0x0,%edx
  800362:	b8 0e 00 00 00       	mov    $0xe,%eax
  800367:	89 d1                	mov    %edx,%ecx
  800369:	89 d3                	mov    %edx,%ebx
  80036b:	89 d7                	mov    %edx,%edi
  80036d:	89 d6                	mov    %edx,%esi
  80036f:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800371:	5b                   	pop    %ebx
  800372:	5e                   	pop    %esi
  800373:	5f                   	pop    %edi
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	57                   	push   %edi
  80037a:	56                   	push   %esi
  80037b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80037c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800381:	b8 10 00 00 00       	mov    $0x10,%eax
  800386:	8b 55 08             	mov    0x8(%ebp),%edx
  800389:	89 cb                	mov    %ecx,%ebx
  80038b:	89 cf                	mov    %ecx,%edi
  80038d:	89 ce                	mov    %ecx,%esi
  80038f:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800391:	5b                   	pop    %ebx
  800392:	5e                   	pop    %esi
  800393:	5f                   	pop    %edi
  800394:	5d                   	pop    %ebp
  800395:	c3                   	ret    

00800396 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800399:	8b 45 08             	mov    0x8(%ebp),%eax
  80039c:	05 00 00 00 30       	add    $0x30000000,%eax
  8003a1:	c1 e8 0c             	shr    $0xc,%eax
}
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    

008003a6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ac:	05 00 00 00 30       	add    $0x30000000,%eax
  8003b1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003b6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003c8:	89 c2                	mov    %eax,%edx
  8003ca:	c1 ea 16             	shr    $0x16,%edx
  8003cd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003d4:	f6 c2 01             	test   $0x1,%dl
  8003d7:	74 11                	je     8003ea <fd_alloc+0x2d>
  8003d9:	89 c2                	mov    %eax,%edx
  8003db:	c1 ea 0c             	shr    $0xc,%edx
  8003de:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003e5:	f6 c2 01             	test   $0x1,%dl
  8003e8:	75 09                	jne    8003f3 <fd_alloc+0x36>
			*fd_store = fd;
  8003ea:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f1:	eb 17                	jmp    80040a <fd_alloc+0x4d>
  8003f3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003f8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003fd:	75 c9                	jne    8003c8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003ff:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800405:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800412:	83 f8 1f             	cmp    $0x1f,%eax
  800415:	77 36                	ja     80044d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800417:	c1 e0 0c             	shl    $0xc,%eax
  80041a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80041f:	89 c2                	mov    %eax,%edx
  800421:	c1 ea 16             	shr    $0x16,%edx
  800424:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80042b:	f6 c2 01             	test   $0x1,%dl
  80042e:	74 24                	je     800454 <fd_lookup+0x48>
  800430:	89 c2                	mov    %eax,%edx
  800432:	c1 ea 0c             	shr    $0xc,%edx
  800435:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80043c:	f6 c2 01             	test   $0x1,%dl
  80043f:	74 1a                	je     80045b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800441:	8b 55 0c             	mov    0xc(%ebp),%edx
  800444:	89 02                	mov    %eax,(%edx)
	return 0;
  800446:	b8 00 00 00 00       	mov    $0x0,%eax
  80044b:	eb 13                	jmp    800460 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80044d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800452:	eb 0c                	jmp    800460 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800454:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800459:	eb 05                	jmp    800460 <fd_lookup+0x54>
  80045b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800460:	5d                   	pop    %ebp
  800461:	c3                   	ret    

00800462 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
  800465:	83 ec 08             	sub    $0x8,%esp
  800468:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80046b:	ba 94 23 80 00       	mov    $0x802394,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800470:	eb 13                	jmp    800485 <dev_lookup+0x23>
  800472:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800475:	39 08                	cmp    %ecx,(%eax)
  800477:	75 0c                	jne    800485 <dev_lookup+0x23>
			*dev = devtab[i];
  800479:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80047c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80047e:	b8 00 00 00 00       	mov    $0x0,%eax
  800483:	eb 2e                	jmp    8004b3 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800485:	8b 02                	mov    (%edx),%eax
  800487:	85 c0                	test   %eax,%eax
  800489:	75 e7                	jne    800472 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80048b:	a1 08 40 80 00       	mov    0x804008,%eax
  800490:	8b 40 48             	mov    0x48(%eax),%eax
  800493:	83 ec 04             	sub    $0x4,%esp
  800496:	51                   	push   %ecx
  800497:	50                   	push   %eax
  800498:	68 18 23 80 00       	push   $0x802318
  80049d:	e8 1e 11 00 00       	call   8015c0 <cprintf>
	*dev = 0;
  8004a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004ab:	83 c4 10             	add    $0x10,%esp
  8004ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004b3:	c9                   	leave  
  8004b4:	c3                   	ret    

008004b5 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004b5:	55                   	push   %ebp
  8004b6:	89 e5                	mov    %esp,%ebp
  8004b8:	56                   	push   %esi
  8004b9:	53                   	push   %ebx
  8004ba:	83 ec 10             	sub    $0x10,%esp
  8004bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004c6:	50                   	push   %eax
  8004c7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004cd:	c1 e8 0c             	shr    $0xc,%eax
  8004d0:	50                   	push   %eax
  8004d1:	e8 36 ff ff ff       	call   80040c <fd_lookup>
  8004d6:	83 c4 08             	add    $0x8,%esp
  8004d9:	85 c0                	test   %eax,%eax
  8004db:	78 05                	js     8004e2 <fd_close+0x2d>
	    || fd != fd2)
  8004dd:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004e0:	74 0c                	je     8004ee <fd_close+0x39>
		return (must_exist ? r : 0);
  8004e2:	84 db                	test   %bl,%bl
  8004e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e9:	0f 44 c2             	cmove  %edx,%eax
  8004ec:	eb 41                	jmp    80052f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004f4:	50                   	push   %eax
  8004f5:	ff 36                	pushl  (%esi)
  8004f7:	e8 66 ff ff ff       	call   800462 <dev_lookup>
  8004fc:	89 c3                	mov    %eax,%ebx
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	85 c0                	test   %eax,%eax
  800503:	78 1a                	js     80051f <fd_close+0x6a>
		if (dev->dev_close)
  800505:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800508:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80050b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800510:	85 c0                	test   %eax,%eax
  800512:	74 0b                	je     80051f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800514:	83 ec 0c             	sub    $0xc,%esp
  800517:	56                   	push   %esi
  800518:	ff d0                	call   *%eax
  80051a:	89 c3                	mov    %eax,%ebx
  80051c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	56                   	push   %esi
  800523:	6a 00                	push   $0x0
  800525:	e8 c1 fc ff ff       	call   8001eb <sys_page_unmap>
	return r;
  80052a:	83 c4 10             	add    $0x10,%esp
  80052d:	89 d8                	mov    %ebx,%eax
}
  80052f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800532:	5b                   	pop    %ebx
  800533:	5e                   	pop    %esi
  800534:	5d                   	pop    %ebp
  800535:	c3                   	ret    

00800536 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800536:	55                   	push   %ebp
  800537:	89 e5                	mov    %esp,%ebp
  800539:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80053c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80053f:	50                   	push   %eax
  800540:	ff 75 08             	pushl  0x8(%ebp)
  800543:	e8 c4 fe ff ff       	call   80040c <fd_lookup>
  800548:	83 c4 08             	add    $0x8,%esp
  80054b:	85 c0                	test   %eax,%eax
  80054d:	78 10                	js     80055f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	6a 01                	push   $0x1
  800554:	ff 75 f4             	pushl  -0xc(%ebp)
  800557:	e8 59 ff ff ff       	call   8004b5 <fd_close>
  80055c:	83 c4 10             	add    $0x10,%esp
}
  80055f:	c9                   	leave  
  800560:	c3                   	ret    

00800561 <close_all>:

void
close_all(void)
{
  800561:	55                   	push   %ebp
  800562:	89 e5                	mov    %esp,%ebp
  800564:	53                   	push   %ebx
  800565:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800568:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80056d:	83 ec 0c             	sub    $0xc,%esp
  800570:	53                   	push   %ebx
  800571:	e8 c0 ff ff ff       	call   800536 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800576:	83 c3 01             	add    $0x1,%ebx
  800579:	83 c4 10             	add    $0x10,%esp
  80057c:	83 fb 20             	cmp    $0x20,%ebx
  80057f:	75 ec                	jne    80056d <close_all+0xc>
		close(i);
}
  800581:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800584:	c9                   	leave  
  800585:	c3                   	ret    

00800586 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800586:	55                   	push   %ebp
  800587:	89 e5                	mov    %esp,%ebp
  800589:	57                   	push   %edi
  80058a:	56                   	push   %esi
  80058b:	53                   	push   %ebx
  80058c:	83 ec 2c             	sub    $0x2c,%esp
  80058f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800592:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800595:	50                   	push   %eax
  800596:	ff 75 08             	pushl  0x8(%ebp)
  800599:	e8 6e fe ff ff       	call   80040c <fd_lookup>
  80059e:	83 c4 08             	add    $0x8,%esp
  8005a1:	85 c0                	test   %eax,%eax
  8005a3:	0f 88 c1 00 00 00    	js     80066a <dup+0xe4>
		return r;
	close(newfdnum);
  8005a9:	83 ec 0c             	sub    $0xc,%esp
  8005ac:	56                   	push   %esi
  8005ad:	e8 84 ff ff ff       	call   800536 <close>

	newfd = INDEX2FD(newfdnum);
  8005b2:	89 f3                	mov    %esi,%ebx
  8005b4:	c1 e3 0c             	shl    $0xc,%ebx
  8005b7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005bd:	83 c4 04             	add    $0x4,%esp
  8005c0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005c3:	e8 de fd ff ff       	call   8003a6 <fd2data>
  8005c8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005ca:	89 1c 24             	mov    %ebx,(%esp)
  8005cd:	e8 d4 fd ff ff       	call   8003a6 <fd2data>
  8005d2:	83 c4 10             	add    $0x10,%esp
  8005d5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005d8:	89 f8                	mov    %edi,%eax
  8005da:	c1 e8 16             	shr    $0x16,%eax
  8005dd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005e4:	a8 01                	test   $0x1,%al
  8005e6:	74 37                	je     80061f <dup+0x99>
  8005e8:	89 f8                	mov    %edi,%eax
  8005ea:	c1 e8 0c             	shr    $0xc,%eax
  8005ed:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005f4:	f6 c2 01             	test   $0x1,%dl
  8005f7:	74 26                	je     80061f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800600:	83 ec 0c             	sub    $0xc,%esp
  800603:	25 07 0e 00 00       	and    $0xe07,%eax
  800608:	50                   	push   %eax
  800609:	ff 75 d4             	pushl  -0x2c(%ebp)
  80060c:	6a 00                	push   $0x0
  80060e:	57                   	push   %edi
  80060f:	6a 00                	push   $0x0
  800611:	e8 93 fb ff ff       	call   8001a9 <sys_page_map>
  800616:	89 c7                	mov    %eax,%edi
  800618:	83 c4 20             	add    $0x20,%esp
  80061b:	85 c0                	test   %eax,%eax
  80061d:	78 2e                	js     80064d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80061f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800622:	89 d0                	mov    %edx,%eax
  800624:	c1 e8 0c             	shr    $0xc,%eax
  800627:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80062e:	83 ec 0c             	sub    $0xc,%esp
  800631:	25 07 0e 00 00       	and    $0xe07,%eax
  800636:	50                   	push   %eax
  800637:	53                   	push   %ebx
  800638:	6a 00                	push   $0x0
  80063a:	52                   	push   %edx
  80063b:	6a 00                	push   $0x0
  80063d:	e8 67 fb ff ff       	call   8001a9 <sys_page_map>
  800642:	89 c7                	mov    %eax,%edi
  800644:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800647:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800649:	85 ff                	test   %edi,%edi
  80064b:	79 1d                	jns    80066a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	53                   	push   %ebx
  800651:	6a 00                	push   $0x0
  800653:	e8 93 fb ff ff       	call   8001eb <sys_page_unmap>
	sys_page_unmap(0, nva);
  800658:	83 c4 08             	add    $0x8,%esp
  80065b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80065e:	6a 00                	push   $0x0
  800660:	e8 86 fb ff ff       	call   8001eb <sys_page_unmap>
	return r;
  800665:	83 c4 10             	add    $0x10,%esp
  800668:	89 f8                	mov    %edi,%eax
}
  80066a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066d:	5b                   	pop    %ebx
  80066e:	5e                   	pop    %esi
  80066f:	5f                   	pop    %edi
  800670:	5d                   	pop    %ebp
  800671:	c3                   	ret    

00800672 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800672:	55                   	push   %ebp
  800673:	89 e5                	mov    %esp,%ebp
  800675:	53                   	push   %ebx
  800676:	83 ec 14             	sub    $0x14,%esp
  800679:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80067c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80067f:	50                   	push   %eax
  800680:	53                   	push   %ebx
  800681:	e8 86 fd ff ff       	call   80040c <fd_lookup>
  800686:	83 c4 08             	add    $0x8,%esp
  800689:	89 c2                	mov    %eax,%edx
  80068b:	85 c0                	test   %eax,%eax
  80068d:	78 6d                	js     8006fc <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800695:	50                   	push   %eax
  800696:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800699:	ff 30                	pushl  (%eax)
  80069b:	e8 c2 fd ff ff       	call   800462 <dev_lookup>
  8006a0:	83 c4 10             	add    $0x10,%esp
  8006a3:	85 c0                	test   %eax,%eax
  8006a5:	78 4c                	js     8006f3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006a7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006aa:	8b 42 08             	mov    0x8(%edx),%eax
  8006ad:	83 e0 03             	and    $0x3,%eax
  8006b0:	83 f8 01             	cmp    $0x1,%eax
  8006b3:	75 21                	jne    8006d6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006b5:	a1 08 40 80 00       	mov    0x804008,%eax
  8006ba:	8b 40 48             	mov    0x48(%eax),%eax
  8006bd:	83 ec 04             	sub    $0x4,%esp
  8006c0:	53                   	push   %ebx
  8006c1:	50                   	push   %eax
  8006c2:	68 59 23 80 00       	push   $0x802359
  8006c7:	e8 f4 0e 00 00       	call   8015c0 <cprintf>
		return -E_INVAL;
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006d4:	eb 26                	jmp    8006fc <read+0x8a>
	}
	if (!dev->dev_read)
  8006d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d9:	8b 40 08             	mov    0x8(%eax),%eax
  8006dc:	85 c0                	test   %eax,%eax
  8006de:	74 17                	je     8006f7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006e0:	83 ec 04             	sub    $0x4,%esp
  8006e3:	ff 75 10             	pushl  0x10(%ebp)
  8006e6:	ff 75 0c             	pushl  0xc(%ebp)
  8006e9:	52                   	push   %edx
  8006ea:	ff d0                	call   *%eax
  8006ec:	89 c2                	mov    %eax,%edx
  8006ee:	83 c4 10             	add    $0x10,%esp
  8006f1:	eb 09                	jmp    8006fc <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006f3:	89 c2                	mov    %eax,%edx
  8006f5:	eb 05                	jmp    8006fc <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006f7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006fc:	89 d0                	mov    %edx,%eax
  8006fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800701:	c9                   	leave  
  800702:	c3                   	ret    

00800703 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800703:	55                   	push   %ebp
  800704:	89 e5                	mov    %esp,%ebp
  800706:	57                   	push   %edi
  800707:	56                   	push   %esi
  800708:	53                   	push   %ebx
  800709:	83 ec 0c             	sub    $0xc,%esp
  80070c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80070f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800712:	bb 00 00 00 00       	mov    $0x0,%ebx
  800717:	eb 21                	jmp    80073a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800719:	83 ec 04             	sub    $0x4,%esp
  80071c:	89 f0                	mov    %esi,%eax
  80071e:	29 d8                	sub    %ebx,%eax
  800720:	50                   	push   %eax
  800721:	89 d8                	mov    %ebx,%eax
  800723:	03 45 0c             	add    0xc(%ebp),%eax
  800726:	50                   	push   %eax
  800727:	57                   	push   %edi
  800728:	e8 45 ff ff ff       	call   800672 <read>
		if (m < 0)
  80072d:	83 c4 10             	add    $0x10,%esp
  800730:	85 c0                	test   %eax,%eax
  800732:	78 10                	js     800744 <readn+0x41>
			return m;
		if (m == 0)
  800734:	85 c0                	test   %eax,%eax
  800736:	74 0a                	je     800742 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800738:	01 c3                	add    %eax,%ebx
  80073a:	39 f3                	cmp    %esi,%ebx
  80073c:	72 db                	jb     800719 <readn+0x16>
  80073e:	89 d8                	mov    %ebx,%eax
  800740:	eb 02                	jmp    800744 <readn+0x41>
  800742:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800744:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800747:	5b                   	pop    %ebx
  800748:	5e                   	pop    %esi
  800749:	5f                   	pop    %edi
  80074a:	5d                   	pop    %ebp
  80074b:	c3                   	ret    

0080074c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80074c:	55                   	push   %ebp
  80074d:	89 e5                	mov    %esp,%ebp
  80074f:	53                   	push   %ebx
  800750:	83 ec 14             	sub    $0x14,%esp
  800753:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800756:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800759:	50                   	push   %eax
  80075a:	53                   	push   %ebx
  80075b:	e8 ac fc ff ff       	call   80040c <fd_lookup>
  800760:	83 c4 08             	add    $0x8,%esp
  800763:	89 c2                	mov    %eax,%edx
  800765:	85 c0                	test   %eax,%eax
  800767:	78 68                	js     8007d1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800769:	83 ec 08             	sub    $0x8,%esp
  80076c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80076f:	50                   	push   %eax
  800770:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800773:	ff 30                	pushl  (%eax)
  800775:	e8 e8 fc ff ff       	call   800462 <dev_lookup>
  80077a:	83 c4 10             	add    $0x10,%esp
  80077d:	85 c0                	test   %eax,%eax
  80077f:	78 47                	js     8007c8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800781:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800784:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800788:	75 21                	jne    8007ab <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80078a:	a1 08 40 80 00       	mov    0x804008,%eax
  80078f:	8b 40 48             	mov    0x48(%eax),%eax
  800792:	83 ec 04             	sub    $0x4,%esp
  800795:	53                   	push   %ebx
  800796:	50                   	push   %eax
  800797:	68 75 23 80 00       	push   $0x802375
  80079c:	e8 1f 0e 00 00       	call   8015c0 <cprintf>
		return -E_INVAL;
  8007a1:	83 c4 10             	add    $0x10,%esp
  8007a4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007a9:	eb 26                	jmp    8007d1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007ae:	8b 52 0c             	mov    0xc(%edx),%edx
  8007b1:	85 d2                	test   %edx,%edx
  8007b3:	74 17                	je     8007cc <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007b5:	83 ec 04             	sub    $0x4,%esp
  8007b8:	ff 75 10             	pushl  0x10(%ebp)
  8007bb:	ff 75 0c             	pushl  0xc(%ebp)
  8007be:	50                   	push   %eax
  8007bf:	ff d2                	call   *%edx
  8007c1:	89 c2                	mov    %eax,%edx
  8007c3:	83 c4 10             	add    $0x10,%esp
  8007c6:	eb 09                	jmp    8007d1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c8:	89 c2                	mov    %eax,%edx
  8007ca:	eb 05                	jmp    8007d1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007cc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007d1:	89 d0                	mov    %edx,%eax
  8007d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007de:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007e1:	50                   	push   %eax
  8007e2:	ff 75 08             	pushl  0x8(%ebp)
  8007e5:	e8 22 fc ff ff       	call   80040c <fd_lookup>
  8007ea:	83 c4 08             	add    $0x8,%esp
  8007ed:	85 c0                	test   %eax,%eax
  8007ef:	78 0e                	js     8007ff <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ff:	c9                   	leave  
  800800:	c3                   	ret    

00800801 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	53                   	push   %ebx
  800805:	83 ec 14             	sub    $0x14,%esp
  800808:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80080b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80080e:	50                   	push   %eax
  80080f:	53                   	push   %ebx
  800810:	e8 f7 fb ff ff       	call   80040c <fd_lookup>
  800815:	83 c4 08             	add    $0x8,%esp
  800818:	89 c2                	mov    %eax,%edx
  80081a:	85 c0                	test   %eax,%eax
  80081c:	78 65                	js     800883 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80081e:	83 ec 08             	sub    $0x8,%esp
  800821:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800824:	50                   	push   %eax
  800825:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800828:	ff 30                	pushl  (%eax)
  80082a:	e8 33 fc ff ff       	call   800462 <dev_lookup>
  80082f:	83 c4 10             	add    $0x10,%esp
  800832:	85 c0                	test   %eax,%eax
  800834:	78 44                	js     80087a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800836:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800839:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80083d:	75 21                	jne    800860 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80083f:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800844:	8b 40 48             	mov    0x48(%eax),%eax
  800847:	83 ec 04             	sub    $0x4,%esp
  80084a:	53                   	push   %ebx
  80084b:	50                   	push   %eax
  80084c:	68 38 23 80 00       	push   $0x802338
  800851:	e8 6a 0d 00 00       	call   8015c0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800856:	83 c4 10             	add    $0x10,%esp
  800859:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80085e:	eb 23                	jmp    800883 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800860:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800863:	8b 52 18             	mov    0x18(%edx),%edx
  800866:	85 d2                	test   %edx,%edx
  800868:	74 14                	je     80087e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80086a:	83 ec 08             	sub    $0x8,%esp
  80086d:	ff 75 0c             	pushl  0xc(%ebp)
  800870:	50                   	push   %eax
  800871:	ff d2                	call   *%edx
  800873:	89 c2                	mov    %eax,%edx
  800875:	83 c4 10             	add    $0x10,%esp
  800878:	eb 09                	jmp    800883 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80087a:	89 c2                	mov    %eax,%edx
  80087c:	eb 05                	jmp    800883 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80087e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800883:	89 d0                	mov    %edx,%eax
  800885:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800888:	c9                   	leave  
  800889:	c3                   	ret    

0080088a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	53                   	push   %ebx
  80088e:	83 ec 14             	sub    $0x14,%esp
  800891:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800894:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800897:	50                   	push   %eax
  800898:	ff 75 08             	pushl  0x8(%ebp)
  80089b:	e8 6c fb ff ff       	call   80040c <fd_lookup>
  8008a0:	83 c4 08             	add    $0x8,%esp
  8008a3:	89 c2                	mov    %eax,%edx
  8008a5:	85 c0                	test   %eax,%eax
  8008a7:	78 58                	js     800901 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a9:	83 ec 08             	sub    $0x8,%esp
  8008ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008af:	50                   	push   %eax
  8008b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008b3:	ff 30                	pushl  (%eax)
  8008b5:	e8 a8 fb ff ff       	call   800462 <dev_lookup>
  8008ba:	83 c4 10             	add    $0x10,%esp
  8008bd:	85 c0                	test   %eax,%eax
  8008bf:	78 37                	js     8008f8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008c8:	74 32                	je     8008fc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008ca:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008cd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008d4:	00 00 00 
	stat->st_isdir = 0;
  8008d7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008de:	00 00 00 
	stat->st_dev = dev;
  8008e1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008e7:	83 ec 08             	sub    $0x8,%esp
  8008ea:	53                   	push   %ebx
  8008eb:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ee:	ff 50 14             	call   *0x14(%eax)
  8008f1:	89 c2                	mov    %eax,%edx
  8008f3:	83 c4 10             	add    $0x10,%esp
  8008f6:	eb 09                	jmp    800901 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008f8:	89 c2                	mov    %eax,%edx
  8008fa:	eb 05                	jmp    800901 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008fc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800901:	89 d0                	mov    %edx,%eax
  800903:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800906:	c9                   	leave  
  800907:	c3                   	ret    

00800908 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	56                   	push   %esi
  80090c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80090d:	83 ec 08             	sub    $0x8,%esp
  800910:	6a 00                	push   $0x0
  800912:	ff 75 08             	pushl  0x8(%ebp)
  800915:	e8 e3 01 00 00       	call   800afd <open>
  80091a:	89 c3                	mov    %eax,%ebx
  80091c:	83 c4 10             	add    $0x10,%esp
  80091f:	85 c0                	test   %eax,%eax
  800921:	78 1b                	js     80093e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800923:	83 ec 08             	sub    $0x8,%esp
  800926:	ff 75 0c             	pushl  0xc(%ebp)
  800929:	50                   	push   %eax
  80092a:	e8 5b ff ff ff       	call   80088a <fstat>
  80092f:	89 c6                	mov    %eax,%esi
	close(fd);
  800931:	89 1c 24             	mov    %ebx,(%esp)
  800934:	e8 fd fb ff ff       	call   800536 <close>
	return r;
  800939:	83 c4 10             	add    $0x10,%esp
  80093c:	89 f0                	mov    %esi,%eax
}
  80093e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800941:	5b                   	pop    %ebx
  800942:	5e                   	pop    %esi
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	56                   	push   %esi
  800949:	53                   	push   %ebx
  80094a:	89 c6                	mov    %eax,%esi
  80094c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80094e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800955:	75 12                	jne    800969 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800957:	83 ec 0c             	sub    $0xc,%esp
  80095a:	6a 01                	push   $0x1
  80095c:	e8 67 16 00 00       	call   801fc8 <ipc_find_env>
  800961:	a3 00 40 80 00       	mov    %eax,0x804000
  800966:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800969:	6a 07                	push   $0x7
  80096b:	68 00 50 80 00       	push   $0x805000
  800970:	56                   	push   %esi
  800971:	ff 35 00 40 80 00    	pushl  0x804000
  800977:	e8 f8 15 00 00       	call   801f74 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80097c:	83 c4 0c             	add    $0xc,%esp
  80097f:	6a 00                	push   $0x0
  800981:	53                   	push   %ebx
  800982:	6a 00                	push   $0x0
  800984:	e8 82 15 00 00       	call   801f0b <ipc_recv>
}
  800989:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80098c:	5b                   	pop    %ebx
  80098d:	5e                   	pop    %esi
  80098e:	5d                   	pop    %ebp
  80098f:	c3                   	ret    

00800990 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800990:	55                   	push   %ebp
  800991:	89 e5                	mov    %esp,%ebp
  800993:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800996:	8b 45 08             	mov    0x8(%ebp),%eax
  800999:	8b 40 0c             	mov    0xc(%eax),%eax
  80099c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a4:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ae:	b8 02 00 00 00       	mov    $0x2,%eax
  8009b3:	e8 8d ff ff ff       	call   800945 <fsipc>
}
  8009b8:	c9                   	leave  
  8009b9:	c3                   	ret    

008009ba <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d0:	b8 06 00 00 00       	mov    $0x6,%eax
  8009d5:	e8 6b ff ff ff       	call   800945 <fsipc>
}
  8009da:	c9                   	leave  
  8009db:	c3                   	ret    

008009dc <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009dc:	55                   	push   %ebp
  8009dd:	89 e5                	mov    %esp,%ebp
  8009df:	53                   	push   %ebx
  8009e0:	83 ec 04             	sub    $0x4,%esp
  8009e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ec:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f6:	b8 05 00 00 00       	mov    $0x5,%eax
  8009fb:	e8 45 ff ff ff       	call   800945 <fsipc>
  800a00:	85 c0                	test   %eax,%eax
  800a02:	78 2c                	js     800a30 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a04:	83 ec 08             	sub    $0x8,%esp
  800a07:	68 00 50 80 00       	push   $0x805000
  800a0c:	53                   	push   %ebx
  800a0d:	e8 b2 11 00 00       	call   801bc4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a12:	a1 80 50 80 00       	mov    0x805080,%eax
  800a17:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a1d:	a1 84 50 80 00       	mov    0x805084,%eax
  800a22:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a28:	83 c4 10             	add    $0x10,%esp
  800a2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a33:	c9                   	leave  
  800a34:	c3                   	ret    

00800a35 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	83 ec 0c             	sub    $0xc,%esp
  800a3b:	8b 45 10             	mov    0x10(%ebp),%eax
  800a3e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a43:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a48:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a4b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4e:	8b 52 0c             	mov    0xc(%edx),%edx
  800a51:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a57:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a5c:	50                   	push   %eax
  800a5d:	ff 75 0c             	pushl  0xc(%ebp)
  800a60:	68 08 50 80 00       	push   $0x805008
  800a65:	e8 ec 12 00 00       	call   801d56 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6f:	b8 04 00 00 00       	mov    $0x4,%eax
  800a74:	e8 cc fe ff ff       	call   800945 <fsipc>
	//panic("devfile_write not implemented");
}
  800a79:	c9                   	leave  
  800a7a:	c3                   	ret    

00800a7b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	56                   	push   %esi
  800a7f:	53                   	push   %ebx
  800a80:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
  800a86:	8b 40 0c             	mov    0xc(%eax),%eax
  800a89:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a8e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a94:	ba 00 00 00 00       	mov    $0x0,%edx
  800a99:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9e:	e8 a2 fe ff ff       	call   800945 <fsipc>
  800aa3:	89 c3                	mov    %eax,%ebx
  800aa5:	85 c0                	test   %eax,%eax
  800aa7:	78 4b                	js     800af4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aa9:	39 c6                	cmp    %eax,%esi
  800aab:	73 16                	jae    800ac3 <devfile_read+0x48>
  800aad:	68 a8 23 80 00       	push   $0x8023a8
  800ab2:	68 af 23 80 00       	push   $0x8023af
  800ab7:	6a 7c                	push   $0x7c
  800ab9:	68 c4 23 80 00       	push   $0x8023c4
  800abe:	e8 24 0a 00 00       	call   8014e7 <_panic>
	assert(r <= PGSIZE);
  800ac3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ac8:	7e 16                	jle    800ae0 <devfile_read+0x65>
  800aca:	68 cf 23 80 00       	push   $0x8023cf
  800acf:	68 af 23 80 00       	push   $0x8023af
  800ad4:	6a 7d                	push   $0x7d
  800ad6:	68 c4 23 80 00       	push   $0x8023c4
  800adb:	e8 07 0a 00 00       	call   8014e7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae0:	83 ec 04             	sub    $0x4,%esp
  800ae3:	50                   	push   %eax
  800ae4:	68 00 50 80 00       	push   $0x805000
  800ae9:	ff 75 0c             	pushl  0xc(%ebp)
  800aec:	e8 65 12 00 00       	call   801d56 <memmove>
	return r;
  800af1:	83 c4 10             	add    $0x10,%esp
}
  800af4:	89 d8                	mov    %ebx,%eax
  800af6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	53                   	push   %ebx
  800b01:	83 ec 20             	sub    $0x20,%esp
  800b04:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b07:	53                   	push   %ebx
  800b08:	e8 7e 10 00 00       	call   801b8b <strlen>
  800b0d:	83 c4 10             	add    $0x10,%esp
  800b10:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b15:	7f 67                	jg     800b7e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b17:	83 ec 0c             	sub    $0xc,%esp
  800b1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b1d:	50                   	push   %eax
  800b1e:	e8 9a f8 ff ff       	call   8003bd <fd_alloc>
  800b23:	83 c4 10             	add    $0x10,%esp
		return r;
  800b26:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b28:	85 c0                	test   %eax,%eax
  800b2a:	78 57                	js     800b83 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b2c:	83 ec 08             	sub    $0x8,%esp
  800b2f:	53                   	push   %ebx
  800b30:	68 00 50 80 00       	push   $0x805000
  800b35:	e8 8a 10 00 00       	call   801bc4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b42:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b45:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4a:	e8 f6 fd ff ff       	call   800945 <fsipc>
  800b4f:	89 c3                	mov    %eax,%ebx
  800b51:	83 c4 10             	add    $0x10,%esp
  800b54:	85 c0                	test   %eax,%eax
  800b56:	79 14                	jns    800b6c <open+0x6f>
		fd_close(fd, 0);
  800b58:	83 ec 08             	sub    $0x8,%esp
  800b5b:	6a 00                	push   $0x0
  800b5d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b60:	e8 50 f9 ff ff       	call   8004b5 <fd_close>
		return r;
  800b65:	83 c4 10             	add    $0x10,%esp
  800b68:	89 da                	mov    %ebx,%edx
  800b6a:	eb 17                	jmp    800b83 <open+0x86>
	}

	return fd2num(fd);
  800b6c:	83 ec 0c             	sub    $0xc,%esp
  800b6f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b72:	e8 1f f8 ff ff       	call   800396 <fd2num>
  800b77:	89 c2                	mov    %eax,%edx
  800b79:	83 c4 10             	add    $0x10,%esp
  800b7c:	eb 05                	jmp    800b83 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b7e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b83:	89 d0                	mov    %edx,%eax
  800b85:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b88:	c9                   	leave  
  800b89:	c3                   	ret    

00800b8a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b8a:	55                   	push   %ebp
  800b8b:	89 e5                	mov    %esp,%ebp
  800b8d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b90:	ba 00 00 00 00       	mov    $0x0,%edx
  800b95:	b8 08 00 00 00       	mov    $0x8,%eax
  800b9a:	e8 a6 fd ff ff       	call   800945 <fsipc>
}
  800b9f:	c9                   	leave  
  800ba0:	c3                   	ret    

00800ba1 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800ba7:	68 db 23 80 00       	push   $0x8023db
  800bac:	ff 75 0c             	pushl  0xc(%ebp)
  800baf:	e8 10 10 00 00       	call   801bc4 <strcpy>
	return 0;
}
  800bb4:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb9:	c9                   	leave  
  800bba:	c3                   	ret    

00800bbb <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	53                   	push   %ebx
  800bbf:	83 ec 10             	sub    $0x10,%esp
  800bc2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bc5:	53                   	push   %ebx
  800bc6:	e8 36 14 00 00       	call   802001 <pageref>
  800bcb:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bce:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800bd3:	83 f8 01             	cmp    $0x1,%eax
  800bd6:	75 10                	jne    800be8 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800bd8:	83 ec 0c             	sub    $0xc,%esp
  800bdb:	ff 73 0c             	pushl  0xc(%ebx)
  800bde:	e8 c0 02 00 00       	call   800ea3 <nsipc_close>
  800be3:	89 c2                	mov    %eax,%edx
  800be5:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800be8:	89 d0                	mov    %edx,%eax
  800bea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bed:	c9                   	leave  
  800bee:	c3                   	ret    

00800bef <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bf5:	6a 00                	push   $0x0
  800bf7:	ff 75 10             	pushl  0x10(%ebp)
  800bfa:	ff 75 0c             	pushl  0xc(%ebp)
  800bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800c00:	ff 70 0c             	pushl  0xc(%eax)
  800c03:	e8 78 03 00 00       	call   800f80 <nsipc_send>
}
  800c08:	c9                   	leave  
  800c09:	c3                   	ret    

00800c0a <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c10:	6a 00                	push   $0x0
  800c12:	ff 75 10             	pushl  0x10(%ebp)
  800c15:	ff 75 0c             	pushl  0xc(%ebp)
  800c18:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1b:	ff 70 0c             	pushl  0xc(%eax)
  800c1e:	e8 f1 02 00 00       	call   800f14 <nsipc_recv>
}
  800c23:	c9                   	leave  
  800c24:	c3                   	ret    

00800c25 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c2b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c2e:	52                   	push   %edx
  800c2f:	50                   	push   %eax
  800c30:	e8 d7 f7 ff ff       	call   80040c <fd_lookup>
  800c35:	83 c4 10             	add    $0x10,%esp
  800c38:	85 c0                	test   %eax,%eax
  800c3a:	78 17                	js     800c53 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c3f:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c45:	39 08                	cmp    %ecx,(%eax)
  800c47:	75 05                	jne    800c4e <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c49:	8b 40 0c             	mov    0xc(%eax),%eax
  800c4c:	eb 05                	jmp    800c53 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c4e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c53:	c9                   	leave  
  800c54:	c3                   	ret    

00800c55 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	56                   	push   %esi
  800c59:	53                   	push   %ebx
  800c5a:	83 ec 1c             	sub    $0x1c,%esp
  800c5d:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c62:	50                   	push   %eax
  800c63:	e8 55 f7 ff ff       	call   8003bd <fd_alloc>
  800c68:	89 c3                	mov    %eax,%ebx
  800c6a:	83 c4 10             	add    $0x10,%esp
  800c6d:	85 c0                	test   %eax,%eax
  800c6f:	78 1b                	js     800c8c <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c71:	83 ec 04             	sub    $0x4,%esp
  800c74:	68 07 04 00 00       	push   $0x407
  800c79:	ff 75 f4             	pushl  -0xc(%ebp)
  800c7c:	6a 00                	push   $0x0
  800c7e:	e8 e3 f4 ff ff       	call   800166 <sys_page_alloc>
  800c83:	89 c3                	mov    %eax,%ebx
  800c85:	83 c4 10             	add    $0x10,%esp
  800c88:	85 c0                	test   %eax,%eax
  800c8a:	79 10                	jns    800c9c <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c8c:	83 ec 0c             	sub    $0xc,%esp
  800c8f:	56                   	push   %esi
  800c90:	e8 0e 02 00 00       	call   800ea3 <nsipc_close>
		return r;
  800c95:	83 c4 10             	add    $0x10,%esp
  800c98:	89 d8                	mov    %ebx,%eax
  800c9a:	eb 24                	jmp    800cc0 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800c9c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca5:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800ca7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800caa:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cb1:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cb4:	83 ec 0c             	sub    $0xc,%esp
  800cb7:	50                   	push   %eax
  800cb8:	e8 d9 f6 ff ff       	call   800396 <fd2num>
  800cbd:	83 c4 10             	add    $0x10,%esp
}
  800cc0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5d                   	pop    %ebp
  800cc6:	c3                   	ret    

00800cc7 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cc7:	55                   	push   %ebp
  800cc8:	89 e5                	mov    %esp,%ebp
  800cca:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ccd:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd0:	e8 50 ff ff ff       	call   800c25 <fd2sockid>
		return r;
  800cd5:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cd7:	85 c0                	test   %eax,%eax
  800cd9:	78 1f                	js     800cfa <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cdb:	83 ec 04             	sub    $0x4,%esp
  800cde:	ff 75 10             	pushl  0x10(%ebp)
  800ce1:	ff 75 0c             	pushl  0xc(%ebp)
  800ce4:	50                   	push   %eax
  800ce5:	e8 12 01 00 00       	call   800dfc <nsipc_accept>
  800cea:	83 c4 10             	add    $0x10,%esp
		return r;
  800ced:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cef:	85 c0                	test   %eax,%eax
  800cf1:	78 07                	js     800cfa <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800cf3:	e8 5d ff ff ff       	call   800c55 <alloc_sockfd>
  800cf8:	89 c1                	mov    %eax,%ecx
}
  800cfa:	89 c8                	mov    %ecx,%eax
  800cfc:	c9                   	leave  
  800cfd:	c3                   	ret    

00800cfe <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d04:	8b 45 08             	mov    0x8(%ebp),%eax
  800d07:	e8 19 ff ff ff       	call   800c25 <fd2sockid>
  800d0c:	85 c0                	test   %eax,%eax
  800d0e:	78 12                	js     800d22 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d10:	83 ec 04             	sub    $0x4,%esp
  800d13:	ff 75 10             	pushl  0x10(%ebp)
  800d16:	ff 75 0c             	pushl  0xc(%ebp)
  800d19:	50                   	push   %eax
  800d1a:	e8 2d 01 00 00       	call   800e4c <nsipc_bind>
  800d1f:	83 c4 10             	add    $0x10,%esp
}
  800d22:	c9                   	leave  
  800d23:	c3                   	ret    

00800d24 <shutdown>:

int
shutdown(int s, int how)
{
  800d24:	55                   	push   %ebp
  800d25:	89 e5                	mov    %esp,%ebp
  800d27:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2d:	e8 f3 fe ff ff       	call   800c25 <fd2sockid>
  800d32:	85 c0                	test   %eax,%eax
  800d34:	78 0f                	js     800d45 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d36:	83 ec 08             	sub    $0x8,%esp
  800d39:	ff 75 0c             	pushl  0xc(%ebp)
  800d3c:	50                   	push   %eax
  800d3d:	e8 3f 01 00 00       	call   800e81 <nsipc_shutdown>
  800d42:	83 c4 10             	add    $0x10,%esp
}
  800d45:	c9                   	leave  
  800d46:	c3                   	ret    

00800d47 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d50:	e8 d0 fe ff ff       	call   800c25 <fd2sockid>
  800d55:	85 c0                	test   %eax,%eax
  800d57:	78 12                	js     800d6b <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d59:	83 ec 04             	sub    $0x4,%esp
  800d5c:	ff 75 10             	pushl  0x10(%ebp)
  800d5f:	ff 75 0c             	pushl  0xc(%ebp)
  800d62:	50                   	push   %eax
  800d63:	e8 55 01 00 00       	call   800ebd <nsipc_connect>
  800d68:	83 c4 10             	add    $0x10,%esp
}
  800d6b:	c9                   	leave  
  800d6c:	c3                   	ret    

00800d6d <listen>:

int
listen(int s, int backlog)
{
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d73:	8b 45 08             	mov    0x8(%ebp),%eax
  800d76:	e8 aa fe ff ff       	call   800c25 <fd2sockid>
  800d7b:	85 c0                	test   %eax,%eax
  800d7d:	78 0f                	js     800d8e <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d7f:	83 ec 08             	sub    $0x8,%esp
  800d82:	ff 75 0c             	pushl  0xc(%ebp)
  800d85:	50                   	push   %eax
  800d86:	e8 67 01 00 00       	call   800ef2 <nsipc_listen>
  800d8b:	83 c4 10             	add    $0x10,%esp
}
  800d8e:	c9                   	leave  
  800d8f:	c3                   	ret    

00800d90 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d90:	55                   	push   %ebp
  800d91:	89 e5                	mov    %esp,%ebp
  800d93:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d96:	ff 75 10             	pushl  0x10(%ebp)
  800d99:	ff 75 0c             	pushl  0xc(%ebp)
  800d9c:	ff 75 08             	pushl  0x8(%ebp)
  800d9f:	e8 3a 02 00 00       	call   800fde <nsipc_socket>
  800da4:	83 c4 10             	add    $0x10,%esp
  800da7:	85 c0                	test   %eax,%eax
  800da9:	78 05                	js     800db0 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800dab:	e8 a5 fe ff ff       	call   800c55 <alloc_sockfd>
}
  800db0:	c9                   	leave  
  800db1:	c3                   	ret    

00800db2 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	53                   	push   %ebx
  800db6:	83 ec 04             	sub    $0x4,%esp
  800db9:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dbb:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dc2:	75 12                	jne    800dd6 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dc4:	83 ec 0c             	sub    $0xc,%esp
  800dc7:	6a 02                	push   $0x2
  800dc9:	e8 fa 11 00 00       	call   801fc8 <ipc_find_env>
  800dce:	a3 04 40 80 00       	mov    %eax,0x804004
  800dd3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dd6:	6a 07                	push   $0x7
  800dd8:	68 00 60 80 00       	push   $0x806000
  800ddd:	53                   	push   %ebx
  800dde:	ff 35 04 40 80 00    	pushl  0x804004
  800de4:	e8 8b 11 00 00       	call   801f74 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800de9:	83 c4 0c             	add    $0xc,%esp
  800dec:	6a 00                	push   $0x0
  800dee:	6a 00                	push   $0x0
  800df0:	6a 00                	push   $0x0
  800df2:	e8 14 11 00 00       	call   801f0b <ipc_recv>
}
  800df7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dfa:	c9                   	leave  
  800dfb:	c3                   	ret    

00800dfc <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	56                   	push   %esi
  800e00:	53                   	push   %ebx
  800e01:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e04:	8b 45 08             	mov    0x8(%ebp),%eax
  800e07:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e0c:	8b 06                	mov    (%esi),%eax
  800e0e:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e13:	b8 01 00 00 00       	mov    $0x1,%eax
  800e18:	e8 95 ff ff ff       	call   800db2 <nsipc>
  800e1d:	89 c3                	mov    %eax,%ebx
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	78 20                	js     800e43 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e23:	83 ec 04             	sub    $0x4,%esp
  800e26:	ff 35 10 60 80 00    	pushl  0x806010
  800e2c:	68 00 60 80 00       	push   $0x806000
  800e31:	ff 75 0c             	pushl  0xc(%ebp)
  800e34:	e8 1d 0f 00 00       	call   801d56 <memmove>
		*addrlen = ret->ret_addrlen;
  800e39:	a1 10 60 80 00       	mov    0x806010,%eax
  800e3e:	89 06                	mov    %eax,(%esi)
  800e40:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e43:	89 d8                	mov    %ebx,%eax
  800e45:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e48:	5b                   	pop    %ebx
  800e49:	5e                   	pop    %esi
  800e4a:	5d                   	pop    %ebp
  800e4b:	c3                   	ret    

00800e4c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	53                   	push   %ebx
  800e50:	83 ec 08             	sub    $0x8,%esp
  800e53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e56:	8b 45 08             	mov    0x8(%ebp),%eax
  800e59:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e5e:	53                   	push   %ebx
  800e5f:	ff 75 0c             	pushl  0xc(%ebp)
  800e62:	68 04 60 80 00       	push   $0x806004
  800e67:	e8 ea 0e 00 00       	call   801d56 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e6c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e72:	b8 02 00 00 00       	mov    $0x2,%eax
  800e77:	e8 36 ff ff ff       	call   800db2 <nsipc>
}
  800e7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e7f:	c9                   	leave  
  800e80:	c3                   	ret    

00800e81 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e87:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e92:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e97:	b8 03 00 00 00       	mov    $0x3,%eax
  800e9c:	e8 11 ff ff ff       	call   800db2 <nsipc>
}
  800ea1:	c9                   	leave  
  800ea2:	c3                   	ret    

00800ea3 <nsipc_close>:

int
nsipc_close(int s)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ea9:	8b 45 08             	mov    0x8(%ebp),%eax
  800eac:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800eb1:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb6:	e8 f7 fe ff ff       	call   800db2 <nsipc>
}
  800ebb:	c9                   	leave  
  800ebc:	c3                   	ret    

00800ebd <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	53                   	push   %ebx
  800ec1:	83 ec 08             	sub    $0x8,%esp
  800ec4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ec7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eca:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ecf:	53                   	push   %ebx
  800ed0:	ff 75 0c             	pushl  0xc(%ebp)
  800ed3:	68 04 60 80 00       	push   $0x806004
  800ed8:	e8 79 0e 00 00       	call   801d56 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800edd:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ee3:	b8 05 00 00 00       	mov    $0x5,%eax
  800ee8:	e8 c5 fe ff ff       	call   800db2 <nsipc>
}
  800eed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef0:	c9                   	leave  
  800ef1:	c3                   	ret    

00800ef2 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ef8:	8b 45 08             	mov    0x8(%ebp),%eax
  800efb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f00:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f03:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f08:	b8 06 00 00 00       	mov    $0x6,%eax
  800f0d:	e8 a0 fe ff ff       	call   800db2 <nsipc>
}
  800f12:	c9                   	leave  
  800f13:	c3                   	ret    

00800f14 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	56                   	push   %esi
  800f18:	53                   	push   %ebx
  800f19:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f24:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f2a:	8b 45 14             	mov    0x14(%ebp),%eax
  800f2d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f32:	b8 07 00 00 00       	mov    $0x7,%eax
  800f37:	e8 76 fe ff ff       	call   800db2 <nsipc>
  800f3c:	89 c3                	mov    %eax,%ebx
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	78 35                	js     800f77 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f42:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f47:	7f 04                	jg     800f4d <nsipc_recv+0x39>
  800f49:	39 c6                	cmp    %eax,%esi
  800f4b:	7d 16                	jge    800f63 <nsipc_recv+0x4f>
  800f4d:	68 e7 23 80 00       	push   $0x8023e7
  800f52:	68 af 23 80 00       	push   $0x8023af
  800f57:	6a 62                	push   $0x62
  800f59:	68 fc 23 80 00       	push   $0x8023fc
  800f5e:	e8 84 05 00 00       	call   8014e7 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f63:	83 ec 04             	sub    $0x4,%esp
  800f66:	50                   	push   %eax
  800f67:	68 00 60 80 00       	push   $0x806000
  800f6c:	ff 75 0c             	pushl  0xc(%ebp)
  800f6f:	e8 e2 0d 00 00       	call   801d56 <memmove>
  800f74:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f77:	89 d8                	mov    %ebx,%eax
  800f79:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f7c:	5b                   	pop    %ebx
  800f7d:	5e                   	pop    %esi
  800f7e:	5d                   	pop    %ebp
  800f7f:	c3                   	ret    

00800f80 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	53                   	push   %ebx
  800f84:	83 ec 04             	sub    $0x4,%esp
  800f87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8d:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f92:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f98:	7e 16                	jle    800fb0 <nsipc_send+0x30>
  800f9a:	68 08 24 80 00       	push   $0x802408
  800f9f:	68 af 23 80 00       	push   $0x8023af
  800fa4:	6a 6d                	push   $0x6d
  800fa6:	68 fc 23 80 00       	push   $0x8023fc
  800fab:	e8 37 05 00 00       	call   8014e7 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fb0:	83 ec 04             	sub    $0x4,%esp
  800fb3:	53                   	push   %ebx
  800fb4:	ff 75 0c             	pushl  0xc(%ebp)
  800fb7:	68 0c 60 80 00       	push   $0x80600c
  800fbc:	e8 95 0d 00 00       	call   801d56 <memmove>
	nsipcbuf.send.req_size = size;
  800fc1:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fc7:	8b 45 14             	mov    0x14(%ebp),%eax
  800fca:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fcf:	b8 08 00 00 00       	mov    $0x8,%eax
  800fd4:	e8 d9 fd ff ff       	call   800db2 <nsipc>
}
  800fd9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fdc:	c9                   	leave  
  800fdd:	c3                   	ret    

00800fde <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fde:	55                   	push   %ebp
  800fdf:	89 e5                	mov    %esp,%ebp
  800fe1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fe4:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800fec:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fef:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800ff4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff7:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  800ffc:	b8 09 00 00 00       	mov    $0x9,%eax
  801001:	e8 ac fd ff ff       	call   800db2 <nsipc>
}
  801006:	c9                   	leave  
  801007:	c3                   	ret    

00801008 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801008:	55                   	push   %ebp
  801009:	89 e5                	mov    %esp,%ebp
  80100b:	56                   	push   %esi
  80100c:	53                   	push   %ebx
  80100d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801010:	83 ec 0c             	sub    $0xc,%esp
  801013:	ff 75 08             	pushl  0x8(%ebp)
  801016:	e8 8b f3 ff ff       	call   8003a6 <fd2data>
  80101b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80101d:	83 c4 08             	add    $0x8,%esp
  801020:	68 14 24 80 00       	push   $0x802414
  801025:	53                   	push   %ebx
  801026:	e8 99 0b 00 00       	call   801bc4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80102b:	8b 46 04             	mov    0x4(%esi),%eax
  80102e:	2b 06                	sub    (%esi),%eax
  801030:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801036:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80103d:	00 00 00 
	stat->st_dev = &devpipe;
  801040:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801047:	30 80 00 
	return 0;
}
  80104a:	b8 00 00 00 00       	mov    $0x0,%eax
  80104f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801052:	5b                   	pop    %ebx
  801053:	5e                   	pop    %esi
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    

00801056 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	53                   	push   %ebx
  80105a:	83 ec 0c             	sub    $0xc,%esp
  80105d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801060:	53                   	push   %ebx
  801061:	6a 00                	push   $0x0
  801063:	e8 83 f1 ff ff       	call   8001eb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801068:	89 1c 24             	mov    %ebx,(%esp)
  80106b:	e8 36 f3 ff ff       	call   8003a6 <fd2data>
  801070:	83 c4 08             	add    $0x8,%esp
  801073:	50                   	push   %eax
  801074:	6a 00                	push   $0x0
  801076:	e8 70 f1 ff ff       	call   8001eb <sys_page_unmap>
}
  80107b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107e:	c9                   	leave  
  80107f:	c3                   	ret    

00801080 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	57                   	push   %edi
  801084:	56                   	push   %esi
  801085:	53                   	push   %ebx
  801086:	83 ec 1c             	sub    $0x1c,%esp
  801089:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80108c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80108e:	a1 08 40 80 00       	mov    0x804008,%eax
  801093:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801096:	83 ec 0c             	sub    $0xc,%esp
  801099:	ff 75 e0             	pushl  -0x20(%ebp)
  80109c:	e8 60 0f 00 00       	call   802001 <pageref>
  8010a1:	89 c3                	mov    %eax,%ebx
  8010a3:	89 3c 24             	mov    %edi,(%esp)
  8010a6:	e8 56 0f 00 00       	call   802001 <pageref>
  8010ab:	83 c4 10             	add    $0x10,%esp
  8010ae:	39 c3                	cmp    %eax,%ebx
  8010b0:	0f 94 c1             	sete   %cl
  8010b3:	0f b6 c9             	movzbl %cl,%ecx
  8010b6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010b9:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010bf:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010c2:	39 ce                	cmp    %ecx,%esi
  8010c4:	74 1b                	je     8010e1 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010c6:	39 c3                	cmp    %eax,%ebx
  8010c8:	75 c4                	jne    80108e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010ca:	8b 42 58             	mov    0x58(%edx),%eax
  8010cd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d0:	50                   	push   %eax
  8010d1:	56                   	push   %esi
  8010d2:	68 1b 24 80 00       	push   $0x80241b
  8010d7:	e8 e4 04 00 00       	call   8015c0 <cprintf>
  8010dc:	83 c4 10             	add    $0x10,%esp
  8010df:	eb ad                	jmp    80108e <_pipeisclosed+0xe>
	}
}
  8010e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e7:	5b                   	pop    %ebx
  8010e8:	5e                   	pop    %esi
  8010e9:	5f                   	pop    %edi
  8010ea:	5d                   	pop    %ebp
  8010eb:	c3                   	ret    

008010ec <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	57                   	push   %edi
  8010f0:	56                   	push   %esi
  8010f1:	53                   	push   %ebx
  8010f2:	83 ec 28             	sub    $0x28,%esp
  8010f5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8010f8:	56                   	push   %esi
  8010f9:	e8 a8 f2 ff ff       	call   8003a6 <fd2data>
  8010fe:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801100:	83 c4 10             	add    $0x10,%esp
  801103:	bf 00 00 00 00       	mov    $0x0,%edi
  801108:	eb 4b                	jmp    801155 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80110a:	89 da                	mov    %ebx,%edx
  80110c:	89 f0                	mov    %esi,%eax
  80110e:	e8 6d ff ff ff       	call   801080 <_pipeisclosed>
  801113:	85 c0                	test   %eax,%eax
  801115:	75 48                	jne    80115f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801117:	e8 2b f0 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80111c:	8b 43 04             	mov    0x4(%ebx),%eax
  80111f:	8b 0b                	mov    (%ebx),%ecx
  801121:	8d 51 20             	lea    0x20(%ecx),%edx
  801124:	39 d0                	cmp    %edx,%eax
  801126:	73 e2                	jae    80110a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801128:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80112f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801132:	89 c2                	mov    %eax,%edx
  801134:	c1 fa 1f             	sar    $0x1f,%edx
  801137:	89 d1                	mov    %edx,%ecx
  801139:	c1 e9 1b             	shr    $0x1b,%ecx
  80113c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80113f:	83 e2 1f             	and    $0x1f,%edx
  801142:	29 ca                	sub    %ecx,%edx
  801144:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801148:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80114c:	83 c0 01             	add    $0x1,%eax
  80114f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801152:	83 c7 01             	add    $0x1,%edi
  801155:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801158:	75 c2                	jne    80111c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80115a:	8b 45 10             	mov    0x10(%ebp),%eax
  80115d:	eb 05                	jmp    801164 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80115f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801164:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801167:	5b                   	pop    %ebx
  801168:	5e                   	pop    %esi
  801169:	5f                   	pop    %edi
  80116a:	5d                   	pop    %ebp
  80116b:	c3                   	ret    

0080116c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80116c:	55                   	push   %ebp
  80116d:	89 e5                	mov    %esp,%ebp
  80116f:	57                   	push   %edi
  801170:	56                   	push   %esi
  801171:	53                   	push   %ebx
  801172:	83 ec 18             	sub    $0x18,%esp
  801175:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801178:	57                   	push   %edi
  801179:	e8 28 f2 ff ff       	call   8003a6 <fd2data>
  80117e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801180:	83 c4 10             	add    $0x10,%esp
  801183:	bb 00 00 00 00       	mov    $0x0,%ebx
  801188:	eb 3d                	jmp    8011c7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80118a:	85 db                	test   %ebx,%ebx
  80118c:	74 04                	je     801192 <devpipe_read+0x26>
				return i;
  80118e:	89 d8                	mov    %ebx,%eax
  801190:	eb 44                	jmp    8011d6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801192:	89 f2                	mov    %esi,%edx
  801194:	89 f8                	mov    %edi,%eax
  801196:	e8 e5 fe ff ff       	call   801080 <_pipeisclosed>
  80119b:	85 c0                	test   %eax,%eax
  80119d:	75 32                	jne    8011d1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80119f:	e8 a3 ef ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011a4:	8b 06                	mov    (%esi),%eax
  8011a6:	3b 46 04             	cmp    0x4(%esi),%eax
  8011a9:	74 df                	je     80118a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011ab:	99                   	cltd   
  8011ac:	c1 ea 1b             	shr    $0x1b,%edx
  8011af:	01 d0                	add    %edx,%eax
  8011b1:	83 e0 1f             	and    $0x1f,%eax
  8011b4:	29 d0                	sub    %edx,%eax
  8011b6:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011be:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011c1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011c4:	83 c3 01             	add    $0x1,%ebx
  8011c7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011ca:	75 d8                	jne    8011a4 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8011cf:	eb 05                	jmp    8011d6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011d1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d9:	5b                   	pop    %ebx
  8011da:	5e                   	pop    %esi
  8011db:	5f                   	pop    %edi
  8011dc:	5d                   	pop    %ebp
  8011dd:	c3                   	ret    

008011de <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011de:	55                   	push   %ebp
  8011df:	89 e5                	mov    %esp,%ebp
  8011e1:	56                   	push   %esi
  8011e2:	53                   	push   %ebx
  8011e3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e9:	50                   	push   %eax
  8011ea:	e8 ce f1 ff ff       	call   8003bd <fd_alloc>
  8011ef:	83 c4 10             	add    $0x10,%esp
  8011f2:	89 c2                	mov    %eax,%edx
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	0f 88 2c 01 00 00    	js     801328 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011fc:	83 ec 04             	sub    $0x4,%esp
  8011ff:	68 07 04 00 00       	push   $0x407
  801204:	ff 75 f4             	pushl  -0xc(%ebp)
  801207:	6a 00                	push   $0x0
  801209:	e8 58 ef ff ff       	call   800166 <sys_page_alloc>
  80120e:	83 c4 10             	add    $0x10,%esp
  801211:	89 c2                	mov    %eax,%edx
  801213:	85 c0                	test   %eax,%eax
  801215:	0f 88 0d 01 00 00    	js     801328 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80121b:	83 ec 0c             	sub    $0xc,%esp
  80121e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801221:	50                   	push   %eax
  801222:	e8 96 f1 ff ff       	call   8003bd <fd_alloc>
  801227:	89 c3                	mov    %eax,%ebx
  801229:	83 c4 10             	add    $0x10,%esp
  80122c:	85 c0                	test   %eax,%eax
  80122e:	0f 88 e2 00 00 00    	js     801316 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801234:	83 ec 04             	sub    $0x4,%esp
  801237:	68 07 04 00 00       	push   $0x407
  80123c:	ff 75 f0             	pushl  -0x10(%ebp)
  80123f:	6a 00                	push   $0x0
  801241:	e8 20 ef ff ff       	call   800166 <sys_page_alloc>
  801246:	89 c3                	mov    %eax,%ebx
  801248:	83 c4 10             	add    $0x10,%esp
  80124b:	85 c0                	test   %eax,%eax
  80124d:	0f 88 c3 00 00 00    	js     801316 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801253:	83 ec 0c             	sub    $0xc,%esp
  801256:	ff 75 f4             	pushl  -0xc(%ebp)
  801259:	e8 48 f1 ff ff       	call   8003a6 <fd2data>
  80125e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801260:	83 c4 0c             	add    $0xc,%esp
  801263:	68 07 04 00 00       	push   $0x407
  801268:	50                   	push   %eax
  801269:	6a 00                	push   $0x0
  80126b:	e8 f6 ee ff ff       	call   800166 <sys_page_alloc>
  801270:	89 c3                	mov    %eax,%ebx
  801272:	83 c4 10             	add    $0x10,%esp
  801275:	85 c0                	test   %eax,%eax
  801277:	0f 88 89 00 00 00    	js     801306 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80127d:	83 ec 0c             	sub    $0xc,%esp
  801280:	ff 75 f0             	pushl  -0x10(%ebp)
  801283:	e8 1e f1 ff ff       	call   8003a6 <fd2data>
  801288:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80128f:	50                   	push   %eax
  801290:	6a 00                	push   $0x0
  801292:	56                   	push   %esi
  801293:	6a 00                	push   $0x0
  801295:	e8 0f ef ff ff       	call   8001a9 <sys_page_map>
  80129a:	89 c3                	mov    %eax,%ebx
  80129c:	83 c4 20             	add    $0x20,%esp
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	78 55                	js     8012f8 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012a3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ac:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012b8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012cd:	83 ec 0c             	sub    $0xc,%esp
  8012d0:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d3:	e8 be f0 ff ff       	call   800396 <fd2num>
  8012d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012db:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012dd:	83 c4 04             	add    $0x4,%esp
  8012e0:	ff 75 f0             	pushl  -0x10(%ebp)
  8012e3:	e8 ae f0 ff ff       	call   800396 <fd2num>
  8012e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012eb:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f6:	eb 30                	jmp    801328 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8012f8:	83 ec 08             	sub    $0x8,%esp
  8012fb:	56                   	push   %esi
  8012fc:	6a 00                	push   $0x0
  8012fe:	e8 e8 ee ff ff       	call   8001eb <sys_page_unmap>
  801303:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801306:	83 ec 08             	sub    $0x8,%esp
  801309:	ff 75 f0             	pushl  -0x10(%ebp)
  80130c:	6a 00                	push   $0x0
  80130e:	e8 d8 ee ff ff       	call   8001eb <sys_page_unmap>
  801313:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801316:	83 ec 08             	sub    $0x8,%esp
  801319:	ff 75 f4             	pushl  -0xc(%ebp)
  80131c:	6a 00                	push   $0x0
  80131e:	e8 c8 ee ff ff       	call   8001eb <sys_page_unmap>
  801323:	83 c4 10             	add    $0x10,%esp
  801326:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801328:	89 d0                	mov    %edx,%eax
  80132a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132d:	5b                   	pop    %ebx
  80132e:	5e                   	pop    %esi
  80132f:	5d                   	pop    %ebp
  801330:	c3                   	ret    

00801331 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801331:	55                   	push   %ebp
  801332:	89 e5                	mov    %esp,%ebp
  801334:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801337:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133a:	50                   	push   %eax
  80133b:	ff 75 08             	pushl  0x8(%ebp)
  80133e:	e8 c9 f0 ff ff       	call   80040c <fd_lookup>
  801343:	83 c4 10             	add    $0x10,%esp
  801346:	85 c0                	test   %eax,%eax
  801348:	78 18                	js     801362 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80134a:	83 ec 0c             	sub    $0xc,%esp
  80134d:	ff 75 f4             	pushl  -0xc(%ebp)
  801350:	e8 51 f0 ff ff       	call   8003a6 <fd2data>
	return _pipeisclosed(fd, p);
  801355:	89 c2                	mov    %eax,%edx
  801357:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135a:	e8 21 fd ff ff       	call   801080 <_pipeisclosed>
  80135f:	83 c4 10             	add    $0x10,%esp
}
  801362:	c9                   	leave  
  801363:	c3                   	ret    

00801364 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801364:	55                   	push   %ebp
  801365:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801367:	b8 00 00 00 00       	mov    $0x0,%eax
  80136c:	5d                   	pop    %ebp
  80136d:	c3                   	ret    

0080136e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80136e:	55                   	push   %ebp
  80136f:	89 e5                	mov    %esp,%ebp
  801371:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801374:	68 33 24 80 00       	push   $0x802433
  801379:	ff 75 0c             	pushl  0xc(%ebp)
  80137c:	e8 43 08 00 00       	call   801bc4 <strcpy>
	return 0;
}
  801381:	b8 00 00 00 00       	mov    $0x0,%eax
  801386:	c9                   	leave  
  801387:	c3                   	ret    

00801388 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	57                   	push   %edi
  80138c:	56                   	push   %esi
  80138d:	53                   	push   %ebx
  80138e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801394:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801399:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80139f:	eb 2d                	jmp    8013ce <devcons_write+0x46>
		m = n - tot;
  8013a1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013a4:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013a6:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013a9:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013ae:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013b1:	83 ec 04             	sub    $0x4,%esp
  8013b4:	53                   	push   %ebx
  8013b5:	03 45 0c             	add    0xc(%ebp),%eax
  8013b8:	50                   	push   %eax
  8013b9:	57                   	push   %edi
  8013ba:	e8 97 09 00 00       	call   801d56 <memmove>
		sys_cputs(buf, m);
  8013bf:	83 c4 08             	add    $0x8,%esp
  8013c2:	53                   	push   %ebx
  8013c3:	57                   	push   %edi
  8013c4:	e8 e1 ec ff ff       	call   8000aa <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013c9:	01 de                	add    %ebx,%esi
  8013cb:	83 c4 10             	add    $0x10,%esp
  8013ce:	89 f0                	mov    %esi,%eax
  8013d0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013d3:	72 cc                	jb     8013a1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d8:	5b                   	pop    %ebx
  8013d9:	5e                   	pop    %esi
  8013da:	5f                   	pop    %edi
  8013db:	5d                   	pop    %ebp
  8013dc:	c3                   	ret    

008013dd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013dd:	55                   	push   %ebp
  8013de:	89 e5                	mov    %esp,%ebp
  8013e0:	83 ec 08             	sub    $0x8,%esp
  8013e3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013e8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013ec:	74 2a                	je     801418 <devcons_read+0x3b>
  8013ee:	eb 05                	jmp    8013f5 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013f0:	e8 52 ed ff ff       	call   800147 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013f5:	e8 ce ec ff ff       	call   8000c8 <sys_cgetc>
  8013fa:	85 c0                	test   %eax,%eax
  8013fc:	74 f2                	je     8013f0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013fe:	85 c0                	test   %eax,%eax
  801400:	78 16                	js     801418 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801402:	83 f8 04             	cmp    $0x4,%eax
  801405:	74 0c                	je     801413 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801407:	8b 55 0c             	mov    0xc(%ebp),%edx
  80140a:	88 02                	mov    %al,(%edx)
	return 1;
  80140c:	b8 01 00 00 00       	mov    $0x1,%eax
  801411:	eb 05                	jmp    801418 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801413:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801418:	c9                   	leave  
  801419:	c3                   	ret    

0080141a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  80141a:	55                   	push   %ebp
  80141b:	89 e5                	mov    %esp,%ebp
  80141d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801420:	8b 45 08             	mov    0x8(%ebp),%eax
  801423:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801426:	6a 01                	push   $0x1
  801428:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80142b:	50                   	push   %eax
  80142c:	e8 79 ec ff ff       	call   8000aa <sys_cputs>
}
  801431:	83 c4 10             	add    $0x10,%esp
  801434:	c9                   	leave  
  801435:	c3                   	ret    

00801436 <getchar>:

int
getchar(void)
{
  801436:	55                   	push   %ebp
  801437:	89 e5                	mov    %esp,%ebp
  801439:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80143c:	6a 01                	push   $0x1
  80143e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801441:	50                   	push   %eax
  801442:	6a 00                	push   $0x0
  801444:	e8 29 f2 ff ff       	call   800672 <read>
	if (r < 0)
  801449:	83 c4 10             	add    $0x10,%esp
  80144c:	85 c0                	test   %eax,%eax
  80144e:	78 0f                	js     80145f <getchar+0x29>
		return r;
	if (r < 1)
  801450:	85 c0                	test   %eax,%eax
  801452:	7e 06                	jle    80145a <getchar+0x24>
		return -E_EOF;
	return c;
  801454:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801458:	eb 05                	jmp    80145f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80145a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80145f:	c9                   	leave  
  801460:	c3                   	ret    

00801461 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801461:	55                   	push   %ebp
  801462:	89 e5                	mov    %esp,%ebp
  801464:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801467:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146a:	50                   	push   %eax
  80146b:	ff 75 08             	pushl  0x8(%ebp)
  80146e:	e8 99 ef ff ff       	call   80040c <fd_lookup>
  801473:	83 c4 10             	add    $0x10,%esp
  801476:	85 c0                	test   %eax,%eax
  801478:	78 11                	js     80148b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80147a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147d:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801483:	39 10                	cmp    %edx,(%eax)
  801485:	0f 94 c0             	sete   %al
  801488:	0f b6 c0             	movzbl %al,%eax
}
  80148b:	c9                   	leave  
  80148c:	c3                   	ret    

0080148d <opencons>:

int
opencons(void)
{
  80148d:	55                   	push   %ebp
  80148e:	89 e5                	mov    %esp,%ebp
  801490:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801493:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801496:	50                   	push   %eax
  801497:	e8 21 ef ff ff       	call   8003bd <fd_alloc>
  80149c:	83 c4 10             	add    $0x10,%esp
		return r;
  80149f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014a1:	85 c0                	test   %eax,%eax
  8014a3:	78 3e                	js     8014e3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014a5:	83 ec 04             	sub    $0x4,%esp
  8014a8:	68 07 04 00 00       	push   $0x407
  8014ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b0:	6a 00                	push   $0x0
  8014b2:	e8 af ec ff ff       	call   800166 <sys_page_alloc>
  8014b7:	83 c4 10             	add    $0x10,%esp
		return r;
  8014ba:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014bc:	85 c0                	test   %eax,%eax
  8014be:	78 23                	js     8014e3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014c0:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ce:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014d5:	83 ec 0c             	sub    $0xc,%esp
  8014d8:	50                   	push   %eax
  8014d9:	e8 b8 ee ff ff       	call   800396 <fd2num>
  8014de:	89 c2                	mov    %eax,%edx
  8014e0:	83 c4 10             	add    $0x10,%esp
}
  8014e3:	89 d0                	mov    %edx,%eax
  8014e5:	c9                   	leave  
  8014e6:	c3                   	ret    

008014e7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014e7:	55                   	push   %ebp
  8014e8:	89 e5                	mov    %esp,%ebp
  8014ea:	56                   	push   %esi
  8014eb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014ec:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014ef:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014f5:	e8 2e ec ff ff       	call   800128 <sys_getenvid>
  8014fa:	83 ec 0c             	sub    $0xc,%esp
  8014fd:	ff 75 0c             	pushl  0xc(%ebp)
  801500:	ff 75 08             	pushl  0x8(%ebp)
  801503:	56                   	push   %esi
  801504:	50                   	push   %eax
  801505:	68 40 24 80 00       	push   $0x802440
  80150a:	e8 b1 00 00 00       	call   8015c0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80150f:	83 c4 18             	add    $0x18,%esp
  801512:	53                   	push   %ebx
  801513:	ff 75 10             	pushl  0x10(%ebp)
  801516:	e8 54 00 00 00       	call   80156f <vcprintf>
	cprintf("\n");
  80151b:	c7 04 24 2c 24 80 00 	movl   $0x80242c,(%esp)
  801522:	e8 99 00 00 00       	call   8015c0 <cprintf>
  801527:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80152a:	cc                   	int3   
  80152b:	eb fd                	jmp    80152a <_panic+0x43>

0080152d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
  801530:	53                   	push   %ebx
  801531:	83 ec 04             	sub    $0x4,%esp
  801534:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801537:	8b 13                	mov    (%ebx),%edx
  801539:	8d 42 01             	lea    0x1(%edx),%eax
  80153c:	89 03                	mov    %eax,(%ebx)
  80153e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801541:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801545:	3d ff 00 00 00       	cmp    $0xff,%eax
  80154a:	75 1a                	jne    801566 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80154c:	83 ec 08             	sub    $0x8,%esp
  80154f:	68 ff 00 00 00       	push   $0xff
  801554:	8d 43 08             	lea    0x8(%ebx),%eax
  801557:	50                   	push   %eax
  801558:	e8 4d eb ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  80155d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801563:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801566:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80156a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156d:	c9                   	leave  
  80156e:	c3                   	ret    

0080156f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80156f:	55                   	push   %ebp
  801570:	89 e5                	mov    %esp,%ebp
  801572:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801578:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80157f:	00 00 00 
	b.cnt = 0;
  801582:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801589:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80158c:	ff 75 0c             	pushl  0xc(%ebp)
  80158f:	ff 75 08             	pushl  0x8(%ebp)
  801592:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801598:	50                   	push   %eax
  801599:	68 2d 15 80 00       	push   $0x80152d
  80159e:	e8 1a 01 00 00       	call   8016bd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015a3:	83 c4 08             	add    $0x8,%esp
  8015a6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015ac:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015b2:	50                   	push   %eax
  8015b3:	e8 f2 ea ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  8015b8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015be:	c9                   	leave  
  8015bf:	c3                   	ret    

008015c0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015c0:	55                   	push   %ebp
  8015c1:	89 e5                	mov    %esp,%ebp
  8015c3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015c6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015c9:	50                   	push   %eax
  8015ca:	ff 75 08             	pushl  0x8(%ebp)
  8015cd:	e8 9d ff ff ff       	call   80156f <vcprintf>
	va_end(ap);

	return cnt;
}
  8015d2:	c9                   	leave  
  8015d3:	c3                   	ret    

008015d4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015d4:	55                   	push   %ebp
  8015d5:	89 e5                	mov    %esp,%ebp
  8015d7:	57                   	push   %edi
  8015d8:	56                   	push   %esi
  8015d9:	53                   	push   %ebx
  8015da:	83 ec 1c             	sub    $0x1c,%esp
  8015dd:	89 c7                	mov    %eax,%edi
  8015df:	89 d6                	mov    %edx,%esi
  8015e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015ea:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015f5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015f8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015fb:	39 d3                	cmp    %edx,%ebx
  8015fd:	72 05                	jb     801604 <printnum+0x30>
  8015ff:	39 45 10             	cmp    %eax,0x10(%ebp)
  801602:	77 45                	ja     801649 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801604:	83 ec 0c             	sub    $0xc,%esp
  801607:	ff 75 18             	pushl  0x18(%ebp)
  80160a:	8b 45 14             	mov    0x14(%ebp),%eax
  80160d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801610:	53                   	push   %ebx
  801611:	ff 75 10             	pushl  0x10(%ebp)
  801614:	83 ec 08             	sub    $0x8,%esp
  801617:	ff 75 e4             	pushl  -0x1c(%ebp)
  80161a:	ff 75 e0             	pushl  -0x20(%ebp)
  80161d:	ff 75 dc             	pushl  -0x24(%ebp)
  801620:	ff 75 d8             	pushl  -0x28(%ebp)
  801623:	e8 18 0a 00 00       	call   802040 <__udivdi3>
  801628:	83 c4 18             	add    $0x18,%esp
  80162b:	52                   	push   %edx
  80162c:	50                   	push   %eax
  80162d:	89 f2                	mov    %esi,%edx
  80162f:	89 f8                	mov    %edi,%eax
  801631:	e8 9e ff ff ff       	call   8015d4 <printnum>
  801636:	83 c4 20             	add    $0x20,%esp
  801639:	eb 18                	jmp    801653 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80163b:	83 ec 08             	sub    $0x8,%esp
  80163e:	56                   	push   %esi
  80163f:	ff 75 18             	pushl  0x18(%ebp)
  801642:	ff d7                	call   *%edi
  801644:	83 c4 10             	add    $0x10,%esp
  801647:	eb 03                	jmp    80164c <printnum+0x78>
  801649:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80164c:	83 eb 01             	sub    $0x1,%ebx
  80164f:	85 db                	test   %ebx,%ebx
  801651:	7f e8                	jg     80163b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801653:	83 ec 08             	sub    $0x8,%esp
  801656:	56                   	push   %esi
  801657:	83 ec 04             	sub    $0x4,%esp
  80165a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80165d:	ff 75 e0             	pushl  -0x20(%ebp)
  801660:	ff 75 dc             	pushl  -0x24(%ebp)
  801663:	ff 75 d8             	pushl  -0x28(%ebp)
  801666:	e8 05 0b 00 00       	call   802170 <__umoddi3>
  80166b:	83 c4 14             	add    $0x14,%esp
  80166e:	0f be 80 63 24 80 00 	movsbl 0x802463(%eax),%eax
  801675:	50                   	push   %eax
  801676:	ff d7                	call   *%edi
}
  801678:	83 c4 10             	add    $0x10,%esp
  80167b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80167e:	5b                   	pop    %ebx
  80167f:	5e                   	pop    %esi
  801680:	5f                   	pop    %edi
  801681:	5d                   	pop    %ebp
  801682:	c3                   	ret    

00801683 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801689:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80168d:	8b 10                	mov    (%eax),%edx
  80168f:	3b 50 04             	cmp    0x4(%eax),%edx
  801692:	73 0a                	jae    80169e <sprintputch+0x1b>
		*b->buf++ = ch;
  801694:	8d 4a 01             	lea    0x1(%edx),%ecx
  801697:	89 08                	mov    %ecx,(%eax)
  801699:	8b 45 08             	mov    0x8(%ebp),%eax
  80169c:	88 02                	mov    %al,(%edx)
}
  80169e:	5d                   	pop    %ebp
  80169f:	c3                   	ret    

008016a0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016a0:	55                   	push   %ebp
  8016a1:	89 e5                	mov    %esp,%ebp
  8016a3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016a6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016a9:	50                   	push   %eax
  8016aa:	ff 75 10             	pushl  0x10(%ebp)
  8016ad:	ff 75 0c             	pushl  0xc(%ebp)
  8016b0:	ff 75 08             	pushl  0x8(%ebp)
  8016b3:	e8 05 00 00 00       	call   8016bd <vprintfmt>
	va_end(ap);
}
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	c9                   	leave  
  8016bc:	c3                   	ret    

008016bd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	57                   	push   %edi
  8016c1:	56                   	push   %esi
  8016c2:	53                   	push   %ebx
  8016c3:	83 ec 2c             	sub    $0x2c,%esp
  8016c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8016c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016cc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016cf:	eb 12                	jmp    8016e3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016d1:	85 c0                	test   %eax,%eax
  8016d3:	0f 84 42 04 00 00    	je     801b1b <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8016d9:	83 ec 08             	sub    $0x8,%esp
  8016dc:	53                   	push   %ebx
  8016dd:	50                   	push   %eax
  8016de:	ff d6                	call   *%esi
  8016e0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016e3:	83 c7 01             	add    $0x1,%edi
  8016e6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016ea:	83 f8 25             	cmp    $0x25,%eax
  8016ed:	75 e2                	jne    8016d1 <vprintfmt+0x14>
  8016ef:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8016f3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8016fa:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801701:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801708:	b9 00 00 00 00       	mov    $0x0,%ecx
  80170d:	eb 07                	jmp    801716 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80170f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801712:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801716:	8d 47 01             	lea    0x1(%edi),%eax
  801719:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80171c:	0f b6 07             	movzbl (%edi),%eax
  80171f:	0f b6 d0             	movzbl %al,%edx
  801722:	83 e8 23             	sub    $0x23,%eax
  801725:	3c 55                	cmp    $0x55,%al
  801727:	0f 87 d3 03 00 00    	ja     801b00 <vprintfmt+0x443>
  80172d:	0f b6 c0             	movzbl %al,%eax
  801730:	ff 24 85 a0 25 80 00 	jmp    *0x8025a0(,%eax,4)
  801737:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80173a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80173e:	eb d6                	jmp    801716 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801740:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801743:	b8 00 00 00 00       	mov    $0x0,%eax
  801748:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80174b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80174e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801752:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801755:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801758:	83 f9 09             	cmp    $0x9,%ecx
  80175b:	77 3f                	ja     80179c <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80175d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801760:	eb e9                	jmp    80174b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801762:	8b 45 14             	mov    0x14(%ebp),%eax
  801765:	8b 00                	mov    (%eax),%eax
  801767:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80176a:	8b 45 14             	mov    0x14(%ebp),%eax
  80176d:	8d 40 04             	lea    0x4(%eax),%eax
  801770:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801773:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801776:	eb 2a                	jmp    8017a2 <vprintfmt+0xe5>
  801778:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80177b:	85 c0                	test   %eax,%eax
  80177d:	ba 00 00 00 00       	mov    $0x0,%edx
  801782:	0f 49 d0             	cmovns %eax,%edx
  801785:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801788:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80178b:	eb 89                	jmp    801716 <vprintfmt+0x59>
  80178d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801790:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801797:	e9 7a ff ff ff       	jmp    801716 <vprintfmt+0x59>
  80179c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80179f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017a6:	0f 89 6a ff ff ff    	jns    801716 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017ac:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017b2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017b9:	e9 58 ff ff ff       	jmp    801716 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017be:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017c4:	e9 4d ff ff ff       	jmp    801716 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8017cc:	8d 78 04             	lea    0x4(%eax),%edi
  8017cf:	83 ec 08             	sub    $0x8,%esp
  8017d2:	53                   	push   %ebx
  8017d3:	ff 30                	pushl  (%eax)
  8017d5:	ff d6                	call   *%esi
			break;
  8017d7:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017da:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8017e0:	e9 fe fe ff ff       	jmp    8016e3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8017e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8017e8:	8d 78 04             	lea    0x4(%eax),%edi
  8017eb:	8b 00                	mov    (%eax),%eax
  8017ed:	99                   	cltd   
  8017ee:	31 d0                	xor    %edx,%eax
  8017f0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017f2:	83 f8 0f             	cmp    $0xf,%eax
  8017f5:	7f 0b                	jg     801802 <vprintfmt+0x145>
  8017f7:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  8017fe:	85 d2                	test   %edx,%edx
  801800:	75 1b                	jne    80181d <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  801802:	50                   	push   %eax
  801803:	68 7b 24 80 00       	push   $0x80247b
  801808:	53                   	push   %ebx
  801809:	56                   	push   %esi
  80180a:	e8 91 fe ff ff       	call   8016a0 <printfmt>
  80180f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801812:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801815:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801818:	e9 c6 fe ff ff       	jmp    8016e3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80181d:	52                   	push   %edx
  80181e:	68 c1 23 80 00       	push   $0x8023c1
  801823:	53                   	push   %ebx
  801824:	56                   	push   %esi
  801825:	e8 76 fe ff ff       	call   8016a0 <printfmt>
  80182a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80182d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801830:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801833:	e9 ab fe ff ff       	jmp    8016e3 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801838:	8b 45 14             	mov    0x14(%ebp),%eax
  80183b:	83 c0 04             	add    $0x4,%eax
  80183e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801841:	8b 45 14             	mov    0x14(%ebp),%eax
  801844:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801846:	85 ff                	test   %edi,%edi
  801848:	b8 74 24 80 00       	mov    $0x802474,%eax
  80184d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801850:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801854:	0f 8e 94 00 00 00    	jle    8018ee <vprintfmt+0x231>
  80185a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80185e:	0f 84 98 00 00 00    	je     8018fc <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  801864:	83 ec 08             	sub    $0x8,%esp
  801867:	ff 75 d0             	pushl  -0x30(%ebp)
  80186a:	57                   	push   %edi
  80186b:	e8 33 03 00 00       	call   801ba3 <strnlen>
  801870:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801873:	29 c1                	sub    %eax,%ecx
  801875:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801878:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80187b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80187f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801882:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801885:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801887:	eb 0f                	jmp    801898 <vprintfmt+0x1db>
					putch(padc, putdat);
  801889:	83 ec 08             	sub    $0x8,%esp
  80188c:	53                   	push   %ebx
  80188d:	ff 75 e0             	pushl  -0x20(%ebp)
  801890:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801892:	83 ef 01             	sub    $0x1,%edi
  801895:	83 c4 10             	add    $0x10,%esp
  801898:	85 ff                	test   %edi,%edi
  80189a:	7f ed                	jg     801889 <vprintfmt+0x1cc>
  80189c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80189f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8018a2:	85 c9                	test   %ecx,%ecx
  8018a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a9:	0f 49 c1             	cmovns %ecx,%eax
  8018ac:	29 c1                	sub    %eax,%ecx
  8018ae:	89 75 08             	mov    %esi,0x8(%ebp)
  8018b1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018b4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018b7:	89 cb                	mov    %ecx,%ebx
  8018b9:	eb 4d                	jmp    801908 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018bb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018bf:	74 1b                	je     8018dc <vprintfmt+0x21f>
  8018c1:	0f be c0             	movsbl %al,%eax
  8018c4:	83 e8 20             	sub    $0x20,%eax
  8018c7:	83 f8 5e             	cmp    $0x5e,%eax
  8018ca:	76 10                	jbe    8018dc <vprintfmt+0x21f>
					putch('?', putdat);
  8018cc:	83 ec 08             	sub    $0x8,%esp
  8018cf:	ff 75 0c             	pushl  0xc(%ebp)
  8018d2:	6a 3f                	push   $0x3f
  8018d4:	ff 55 08             	call   *0x8(%ebp)
  8018d7:	83 c4 10             	add    $0x10,%esp
  8018da:	eb 0d                	jmp    8018e9 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8018dc:	83 ec 08             	sub    $0x8,%esp
  8018df:	ff 75 0c             	pushl  0xc(%ebp)
  8018e2:	52                   	push   %edx
  8018e3:	ff 55 08             	call   *0x8(%ebp)
  8018e6:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018e9:	83 eb 01             	sub    $0x1,%ebx
  8018ec:	eb 1a                	jmp    801908 <vprintfmt+0x24b>
  8018ee:	89 75 08             	mov    %esi,0x8(%ebp)
  8018f1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018f4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018f7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018fa:	eb 0c                	jmp    801908 <vprintfmt+0x24b>
  8018fc:	89 75 08             	mov    %esi,0x8(%ebp)
  8018ff:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801902:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801905:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801908:	83 c7 01             	add    $0x1,%edi
  80190b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80190f:	0f be d0             	movsbl %al,%edx
  801912:	85 d2                	test   %edx,%edx
  801914:	74 23                	je     801939 <vprintfmt+0x27c>
  801916:	85 f6                	test   %esi,%esi
  801918:	78 a1                	js     8018bb <vprintfmt+0x1fe>
  80191a:	83 ee 01             	sub    $0x1,%esi
  80191d:	79 9c                	jns    8018bb <vprintfmt+0x1fe>
  80191f:	89 df                	mov    %ebx,%edi
  801921:	8b 75 08             	mov    0x8(%ebp),%esi
  801924:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801927:	eb 18                	jmp    801941 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801929:	83 ec 08             	sub    $0x8,%esp
  80192c:	53                   	push   %ebx
  80192d:	6a 20                	push   $0x20
  80192f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801931:	83 ef 01             	sub    $0x1,%edi
  801934:	83 c4 10             	add    $0x10,%esp
  801937:	eb 08                	jmp    801941 <vprintfmt+0x284>
  801939:	89 df                	mov    %ebx,%edi
  80193b:	8b 75 08             	mov    0x8(%ebp),%esi
  80193e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801941:	85 ff                	test   %edi,%edi
  801943:	7f e4                	jg     801929 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801945:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801948:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80194b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80194e:	e9 90 fd ff ff       	jmp    8016e3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801953:	83 f9 01             	cmp    $0x1,%ecx
  801956:	7e 19                	jle    801971 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  801958:	8b 45 14             	mov    0x14(%ebp),%eax
  80195b:	8b 50 04             	mov    0x4(%eax),%edx
  80195e:	8b 00                	mov    (%eax),%eax
  801960:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801963:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801966:	8b 45 14             	mov    0x14(%ebp),%eax
  801969:	8d 40 08             	lea    0x8(%eax),%eax
  80196c:	89 45 14             	mov    %eax,0x14(%ebp)
  80196f:	eb 38                	jmp    8019a9 <vprintfmt+0x2ec>
	else if (lflag)
  801971:	85 c9                	test   %ecx,%ecx
  801973:	74 1b                	je     801990 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  801975:	8b 45 14             	mov    0x14(%ebp),%eax
  801978:	8b 00                	mov    (%eax),%eax
  80197a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80197d:	89 c1                	mov    %eax,%ecx
  80197f:	c1 f9 1f             	sar    $0x1f,%ecx
  801982:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801985:	8b 45 14             	mov    0x14(%ebp),%eax
  801988:	8d 40 04             	lea    0x4(%eax),%eax
  80198b:	89 45 14             	mov    %eax,0x14(%ebp)
  80198e:	eb 19                	jmp    8019a9 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  801990:	8b 45 14             	mov    0x14(%ebp),%eax
  801993:	8b 00                	mov    (%eax),%eax
  801995:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801998:	89 c1                	mov    %eax,%ecx
  80199a:	c1 f9 1f             	sar    $0x1f,%ecx
  80199d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a3:	8d 40 04             	lea    0x4(%eax),%eax
  8019a6:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019a9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8019ac:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019af:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019b4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019b8:	0f 89 0e 01 00 00    	jns    801acc <vprintfmt+0x40f>
				putch('-', putdat);
  8019be:	83 ec 08             	sub    $0x8,%esp
  8019c1:	53                   	push   %ebx
  8019c2:	6a 2d                	push   $0x2d
  8019c4:	ff d6                	call   *%esi
				num = -(long long) num;
  8019c6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8019c9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8019cc:	f7 da                	neg    %edx
  8019ce:	83 d1 00             	adc    $0x0,%ecx
  8019d1:	f7 d9                	neg    %ecx
  8019d3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019d6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8019db:	e9 ec 00 00 00       	jmp    801acc <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8019e0:	83 f9 01             	cmp    $0x1,%ecx
  8019e3:	7e 18                	jle    8019fd <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8019e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8019e8:	8b 10                	mov    (%eax),%edx
  8019ea:	8b 48 04             	mov    0x4(%eax),%ecx
  8019ed:	8d 40 08             	lea    0x8(%eax),%eax
  8019f0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8019f3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8019f8:	e9 cf 00 00 00       	jmp    801acc <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8019fd:	85 c9                	test   %ecx,%ecx
  8019ff:	74 1a                	je     801a1b <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  801a01:	8b 45 14             	mov    0x14(%ebp),%eax
  801a04:	8b 10                	mov    (%eax),%edx
  801a06:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a0b:	8d 40 04             	lea    0x4(%eax),%eax
  801a0e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801a11:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a16:	e9 b1 00 00 00       	jmp    801acc <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801a1b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a1e:	8b 10                	mov    (%eax),%edx
  801a20:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a25:	8d 40 04             	lea    0x4(%eax),%eax
  801a28:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801a2b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a30:	e9 97 00 00 00       	jmp    801acc <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801a35:	83 ec 08             	sub    $0x8,%esp
  801a38:	53                   	push   %ebx
  801a39:	6a 58                	push   $0x58
  801a3b:	ff d6                	call   *%esi
			putch('X', putdat);
  801a3d:	83 c4 08             	add    $0x8,%esp
  801a40:	53                   	push   %ebx
  801a41:	6a 58                	push   $0x58
  801a43:	ff d6                	call   *%esi
			putch('X', putdat);
  801a45:	83 c4 08             	add    $0x8,%esp
  801a48:	53                   	push   %ebx
  801a49:	6a 58                	push   $0x58
  801a4b:	ff d6                	call   *%esi
			break;
  801a4d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a50:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  801a53:	e9 8b fc ff ff       	jmp    8016e3 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  801a58:	83 ec 08             	sub    $0x8,%esp
  801a5b:	53                   	push   %ebx
  801a5c:	6a 30                	push   $0x30
  801a5e:	ff d6                	call   *%esi
			putch('x', putdat);
  801a60:	83 c4 08             	add    $0x8,%esp
  801a63:	53                   	push   %ebx
  801a64:	6a 78                	push   $0x78
  801a66:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a68:	8b 45 14             	mov    0x14(%ebp),%eax
  801a6b:	8b 10                	mov    (%eax),%edx
  801a6d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a72:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a75:	8d 40 04             	lea    0x4(%eax),%eax
  801a78:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a7b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801a80:	eb 4a                	jmp    801acc <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a82:	83 f9 01             	cmp    $0x1,%ecx
  801a85:	7e 15                	jle    801a9c <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  801a87:	8b 45 14             	mov    0x14(%ebp),%eax
  801a8a:	8b 10                	mov    (%eax),%edx
  801a8c:	8b 48 04             	mov    0x4(%eax),%ecx
  801a8f:	8d 40 08             	lea    0x8(%eax),%eax
  801a92:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801a95:	b8 10 00 00 00       	mov    $0x10,%eax
  801a9a:	eb 30                	jmp    801acc <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801a9c:	85 c9                	test   %ecx,%ecx
  801a9e:	74 17                	je     801ab7 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  801aa0:	8b 45 14             	mov    0x14(%ebp),%eax
  801aa3:	8b 10                	mov    (%eax),%edx
  801aa5:	b9 00 00 00 00       	mov    $0x0,%ecx
  801aaa:	8d 40 04             	lea    0x4(%eax),%eax
  801aad:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801ab0:	b8 10 00 00 00       	mov    $0x10,%eax
  801ab5:	eb 15                	jmp    801acc <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801ab7:	8b 45 14             	mov    0x14(%ebp),%eax
  801aba:	8b 10                	mov    (%eax),%edx
  801abc:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ac1:	8d 40 04             	lea    0x4(%eax),%eax
  801ac4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801ac7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801acc:	83 ec 0c             	sub    $0xc,%esp
  801acf:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801ad3:	57                   	push   %edi
  801ad4:	ff 75 e0             	pushl  -0x20(%ebp)
  801ad7:	50                   	push   %eax
  801ad8:	51                   	push   %ecx
  801ad9:	52                   	push   %edx
  801ada:	89 da                	mov    %ebx,%edx
  801adc:	89 f0                	mov    %esi,%eax
  801ade:	e8 f1 fa ff ff       	call   8015d4 <printnum>
			break;
  801ae3:	83 c4 20             	add    $0x20,%esp
  801ae6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ae9:	e9 f5 fb ff ff       	jmp    8016e3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801aee:	83 ec 08             	sub    $0x8,%esp
  801af1:	53                   	push   %ebx
  801af2:	52                   	push   %edx
  801af3:	ff d6                	call   *%esi
			break;
  801af5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801af8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801afb:	e9 e3 fb ff ff       	jmp    8016e3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b00:	83 ec 08             	sub    $0x8,%esp
  801b03:	53                   	push   %ebx
  801b04:	6a 25                	push   $0x25
  801b06:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b08:	83 c4 10             	add    $0x10,%esp
  801b0b:	eb 03                	jmp    801b10 <vprintfmt+0x453>
  801b0d:	83 ef 01             	sub    $0x1,%edi
  801b10:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b14:	75 f7                	jne    801b0d <vprintfmt+0x450>
  801b16:	e9 c8 fb ff ff       	jmp    8016e3 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1e:	5b                   	pop    %ebx
  801b1f:	5e                   	pop    %esi
  801b20:	5f                   	pop    %edi
  801b21:	5d                   	pop    %ebp
  801b22:	c3                   	ret    

00801b23 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b23:	55                   	push   %ebp
  801b24:	89 e5                	mov    %esp,%ebp
  801b26:	83 ec 18             	sub    $0x18,%esp
  801b29:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b2f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b32:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b36:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b39:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b40:	85 c0                	test   %eax,%eax
  801b42:	74 26                	je     801b6a <vsnprintf+0x47>
  801b44:	85 d2                	test   %edx,%edx
  801b46:	7e 22                	jle    801b6a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b48:	ff 75 14             	pushl  0x14(%ebp)
  801b4b:	ff 75 10             	pushl  0x10(%ebp)
  801b4e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b51:	50                   	push   %eax
  801b52:	68 83 16 80 00       	push   $0x801683
  801b57:	e8 61 fb ff ff       	call   8016bd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b5f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b65:	83 c4 10             	add    $0x10,%esp
  801b68:	eb 05                	jmp    801b6f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b6a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b6f:	c9                   	leave  
  801b70:	c3                   	ret    

00801b71 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b71:	55                   	push   %ebp
  801b72:	89 e5                	mov    %esp,%ebp
  801b74:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b77:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b7a:	50                   	push   %eax
  801b7b:	ff 75 10             	pushl  0x10(%ebp)
  801b7e:	ff 75 0c             	pushl  0xc(%ebp)
  801b81:	ff 75 08             	pushl  0x8(%ebp)
  801b84:	e8 9a ff ff ff       	call   801b23 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b89:	c9                   	leave  
  801b8a:	c3                   	ret    

00801b8b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b91:	b8 00 00 00 00       	mov    $0x0,%eax
  801b96:	eb 03                	jmp    801b9b <strlen+0x10>
		n++;
  801b98:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b9b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b9f:	75 f7                	jne    801b98 <strlen+0xd>
		n++;
	return n;
}
  801ba1:	5d                   	pop    %ebp
  801ba2:	c3                   	ret    

00801ba3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801ba3:	55                   	push   %ebp
  801ba4:	89 e5                	mov    %esp,%ebp
  801ba6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ba9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bac:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb1:	eb 03                	jmp    801bb6 <strnlen+0x13>
		n++;
  801bb3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bb6:	39 c2                	cmp    %eax,%edx
  801bb8:	74 08                	je     801bc2 <strnlen+0x1f>
  801bba:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801bbe:	75 f3                	jne    801bb3 <strnlen+0x10>
  801bc0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801bc2:	5d                   	pop    %ebp
  801bc3:	c3                   	ret    

00801bc4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801bc4:	55                   	push   %ebp
  801bc5:	89 e5                	mov    %esp,%ebp
  801bc7:	53                   	push   %ebx
  801bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801bce:	89 c2                	mov    %eax,%edx
  801bd0:	83 c2 01             	add    $0x1,%edx
  801bd3:	83 c1 01             	add    $0x1,%ecx
  801bd6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801bda:	88 5a ff             	mov    %bl,-0x1(%edx)
  801bdd:	84 db                	test   %bl,%bl
  801bdf:	75 ef                	jne    801bd0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801be1:	5b                   	pop    %ebx
  801be2:	5d                   	pop    %ebp
  801be3:	c3                   	ret    

00801be4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	53                   	push   %ebx
  801be8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801beb:	53                   	push   %ebx
  801bec:	e8 9a ff ff ff       	call   801b8b <strlen>
  801bf1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801bf4:	ff 75 0c             	pushl  0xc(%ebp)
  801bf7:	01 d8                	add    %ebx,%eax
  801bf9:	50                   	push   %eax
  801bfa:	e8 c5 ff ff ff       	call   801bc4 <strcpy>
	return dst;
}
  801bff:	89 d8                	mov    %ebx,%eax
  801c01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c04:	c9                   	leave  
  801c05:	c3                   	ret    

00801c06 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c06:	55                   	push   %ebp
  801c07:	89 e5                	mov    %esp,%ebp
  801c09:	56                   	push   %esi
  801c0a:	53                   	push   %ebx
  801c0b:	8b 75 08             	mov    0x8(%ebp),%esi
  801c0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c11:	89 f3                	mov    %esi,%ebx
  801c13:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c16:	89 f2                	mov    %esi,%edx
  801c18:	eb 0f                	jmp    801c29 <strncpy+0x23>
		*dst++ = *src;
  801c1a:	83 c2 01             	add    $0x1,%edx
  801c1d:	0f b6 01             	movzbl (%ecx),%eax
  801c20:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c23:	80 39 01             	cmpb   $0x1,(%ecx)
  801c26:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c29:	39 da                	cmp    %ebx,%edx
  801c2b:	75 ed                	jne    801c1a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c2d:	89 f0                	mov    %esi,%eax
  801c2f:	5b                   	pop    %ebx
  801c30:	5e                   	pop    %esi
  801c31:	5d                   	pop    %ebp
  801c32:	c3                   	ret    

00801c33 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c33:	55                   	push   %ebp
  801c34:	89 e5                	mov    %esp,%ebp
  801c36:	56                   	push   %esi
  801c37:	53                   	push   %ebx
  801c38:	8b 75 08             	mov    0x8(%ebp),%esi
  801c3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c3e:	8b 55 10             	mov    0x10(%ebp),%edx
  801c41:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c43:	85 d2                	test   %edx,%edx
  801c45:	74 21                	je     801c68 <strlcpy+0x35>
  801c47:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c4b:	89 f2                	mov    %esi,%edx
  801c4d:	eb 09                	jmp    801c58 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c4f:	83 c2 01             	add    $0x1,%edx
  801c52:	83 c1 01             	add    $0x1,%ecx
  801c55:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c58:	39 c2                	cmp    %eax,%edx
  801c5a:	74 09                	je     801c65 <strlcpy+0x32>
  801c5c:	0f b6 19             	movzbl (%ecx),%ebx
  801c5f:	84 db                	test   %bl,%bl
  801c61:	75 ec                	jne    801c4f <strlcpy+0x1c>
  801c63:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c65:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c68:	29 f0                	sub    %esi,%eax
}
  801c6a:	5b                   	pop    %ebx
  801c6b:	5e                   	pop    %esi
  801c6c:	5d                   	pop    %ebp
  801c6d:	c3                   	ret    

00801c6e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c6e:	55                   	push   %ebp
  801c6f:	89 e5                	mov    %esp,%ebp
  801c71:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c74:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c77:	eb 06                	jmp    801c7f <strcmp+0x11>
		p++, q++;
  801c79:	83 c1 01             	add    $0x1,%ecx
  801c7c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c7f:	0f b6 01             	movzbl (%ecx),%eax
  801c82:	84 c0                	test   %al,%al
  801c84:	74 04                	je     801c8a <strcmp+0x1c>
  801c86:	3a 02                	cmp    (%edx),%al
  801c88:	74 ef                	je     801c79 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c8a:	0f b6 c0             	movzbl %al,%eax
  801c8d:	0f b6 12             	movzbl (%edx),%edx
  801c90:	29 d0                	sub    %edx,%eax
}
  801c92:	5d                   	pop    %ebp
  801c93:	c3                   	ret    

00801c94 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c94:	55                   	push   %ebp
  801c95:	89 e5                	mov    %esp,%ebp
  801c97:	53                   	push   %ebx
  801c98:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c9e:	89 c3                	mov    %eax,%ebx
  801ca0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801ca3:	eb 06                	jmp    801cab <strncmp+0x17>
		n--, p++, q++;
  801ca5:	83 c0 01             	add    $0x1,%eax
  801ca8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801cab:	39 d8                	cmp    %ebx,%eax
  801cad:	74 15                	je     801cc4 <strncmp+0x30>
  801caf:	0f b6 08             	movzbl (%eax),%ecx
  801cb2:	84 c9                	test   %cl,%cl
  801cb4:	74 04                	je     801cba <strncmp+0x26>
  801cb6:	3a 0a                	cmp    (%edx),%cl
  801cb8:	74 eb                	je     801ca5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801cba:	0f b6 00             	movzbl (%eax),%eax
  801cbd:	0f b6 12             	movzbl (%edx),%edx
  801cc0:	29 d0                	sub    %edx,%eax
  801cc2:	eb 05                	jmp    801cc9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801cc4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801cc9:	5b                   	pop    %ebx
  801cca:	5d                   	pop    %ebp
  801ccb:	c3                   	ret    

00801ccc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cd6:	eb 07                	jmp    801cdf <strchr+0x13>
		if (*s == c)
  801cd8:	38 ca                	cmp    %cl,%dl
  801cda:	74 0f                	je     801ceb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801cdc:	83 c0 01             	add    $0x1,%eax
  801cdf:	0f b6 10             	movzbl (%eax),%edx
  801ce2:	84 d2                	test   %dl,%dl
  801ce4:	75 f2                	jne    801cd8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801ce6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ceb:	5d                   	pop    %ebp
  801cec:	c3                   	ret    

00801ced <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801ced:	55                   	push   %ebp
  801cee:	89 e5                	mov    %esp,%ebp
  801cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cf7:	eb 03                	jmp    801cfc <strfind+0xf>
  801cf9:	83 c0 01             	add    $0x1,%eax
  801cfc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cff:	38 ca                	cmp    %cl,%dl
  801d01:	74 04                	je     801d07 <strfind+0x1a>
  801d03:	84 d2                	test   %dl,%dl
  801d05:	75 f2                	jne    801cf9 <strfind+0xc>
			break;
	return (char *) s;
}
  801d07:	5d                   	pop    %ebp
  801d08:	c3                   	ret    

00801d09 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d09:	55                   	push   %ebp
  801d0a:	89 e5                	mov    %esp,%ebp
  801d0c:	57                   	push   %edi
  801d0d:	56                   	push   %esi
  801d0e:	53                   	push   %ebx
  801d0f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d12:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d15:	85 c9                	test   %ecx,%ecx
  801d17:	74 36                	je     801d4f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d19:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d1f:	75 28                	jne    801d49 <memset+0x40>
  801d21:	f6 c1 03             	test   $0x3,%cl
  801d24:	75 23                	jne    801d49 <memset+0x40>
		c &= 0xFF;
  801d26:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d2a:	89 d3                	mov    %edx,%ebx
  801d2c:	c1 e3 08             	shl    $0x8,%ebx
  801d2f:	89 d6                	mov    %edx,%esi
  801d31:	c1 e6 18             	shl    $0x18,%esi
  801d34:	89 d0                	mov    %edx,%eax
  801d36:	c1 e0 10             	shl    $0x10,%eax
  801d39:	09 f0                	or     %esi,%eax
  801d3b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d3d:	89 d8                	mov    %ebx,%eax
  801d3f:	09 d0                	or     %edx,%eax
  801d41:	c1 e9 02             	shr    $0x2,%ecx
  801d44:	fc                   	cld    
  801d45:	f3 ab                	rep stos %eax,%es:(%edi)
  801d47:	eb 06                	jmp    801d4f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d49:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d4c:	fc                   	cld    
  801d4d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d4f:	89 f8                	mov    %edi,%eax
  801d51:	5b                   	pop    %ebx
  801d52:	5e                   	pop    %esi
  801d53:	5f                   	pop    %edi
  801d54:	5d                   	pop    %ebp
  801d55:	c3                   	ret    

00801d56 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d56:	55                   	push   %ebp
  801d57:	89 e5                	mov    %esp,%ebp
  801d59:	57                   	push   %edi
  801d5a:	56                   	push   %esi
  801d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d61:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d64:	39 c6                	cmp    %eax,%esi
  801d66:	73 35                	jae    801d9d <memmove+0x47>
  801d68:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d6b:	39 d0                	cmp    %edx,%eax
  801d6d:	73 2e                	jae    801d9d <memmove+0x47>
		s += n;
		d += n;
  801d6f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d72:	89 d6                	mov    %edx,%esi
  801d74:	09 fe                	or     %edi,%esi
  801d76:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d7c:	75 13                	jne    801d91 <memmove+0x3b>
  801d7e:	f6 c1 03             	test   $0x3,%cl
  801d81:	75 0e                	jne    801d91 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d83:	83 ef 04             	sub    $0x4,%edi
  801d86:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d89:	c1 e9 02             	shr    $0x2,%ecx
  801d8c:	fd                   	std    
  801d8d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d8f:	eb 09                	jmp    801d9a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d91:	83 ef 01             	sub    $0x1,%edi
  801d94:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d97:	fd                   	std    
  801d98:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d9a:	fc                   	cld    
  801d9b:	eb 1d                	jmp    801dba <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d9d:	89 f2                	mov    %esi,%edx
  801d9f:	09 c2                	or     %eax,%edx
  801da1:	f6 c2 03             	test   $0x3,%dl
  801da4:	75 0f                	jne    801db5 <memmove+0x5f>
  801da6:	f6 c1 03             	test   $0x3,%cl
  801da9:	75 0a                	jne    801db5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801dab:	c1 e9 02             	shr    $0x2,%ecx
  801dae:	89 c7                	mov    %eax,%edi
  801db0:	fc                   	cld    
  801db1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801db3:	eb 05                	jmp    801dba <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801db5:	89 c7                	mov    %eax,%edi
  801db7:	fc                   	cld    
  801db8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801dba:	5e                   	pop    %esi
  801dbb:	5f                   	pop    %edi
  801dbc:	5d                   	pop    %ebp
  801dbd:	c3                   	ret    

00801dbe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801dbe:	55                   	push   %ebp
  801dbf:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801dc1:	ff 75 10             	pushl  0x10(%ebp)
  801dc4:	ff 75 0c             	pushl  0xc(%ebp)
  801dc7:	ff 75 08             	pushl  0x8(%ebp)
  801dca:	e8 87 ff ff ff       	call   801d56 <memmove>
}
  801dcf:	c9                   	leave  
  801dd0:	c3                   	ret    

00801dd1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801dd1:	55                   	push   %ebp
  801dd2:	89 e5                	mov    %esp,%ebp
  801dd4:	56                   	push   %esi
  801dd5:	53                   	push   %ebx
  801dd6:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ddc:	89 c6                	mov    %eax,%esi
  801dde:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801de1:	eb 1a                	jmp    801dfd <memcmp+0x2c>
		if (*s1 != *s2)
  801de3:	0f b6 08             	movzbl (%eax),%ecx
  801de6:	0f b6 1a             	movzbl (%edx),%ebx
  801de9:	38 d9                	cmp    %bl,%cl
  801deb:	74 0a                	je     801df7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801ded:	0f b6 c1             	movzbl %cl,%eax
  801df0:	0f b6 db             	movzbl %bl,%ebx
  801df3:	29 d8                	sub    %ebx,%eax
  801df5:	eb 0f                	jmp    801e06 <memcmp+0x35>
		s1++, s2++;
  801df7:	83 c0 01             	add    $0x1,%eax
  801dfa:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dfd:	39 f0                	cmp    %esi,%eax
  801dff:	75 e2                	jne    801de3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e01:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e06:	5b                   	pop    %ebx
  801e07:	5e                   	pop    %esi
  801e08:	5d                   	pop    %ebp
  801e09:	c3                   	ret    

00801e0a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e0a:	55                   	push   %ebp
  801e0b:	89 e5                	mov    %esp,%ebp
  801e0d:	53                   	push   %ebx
  801e0e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e11:	89 c1                	mov    %eax,%ecx
  801e13:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e16:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e1a:	eb 0a                	jmp    801e26 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e1c:	0f b6 10             	movzbl (%eax),%edx
  801e1f:	39 da                	cmp    %ebx,%edx
  801e21:	74 07                	je     801e2a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e23:	83 c0 01             	add    $0x1,%eax
  801e26:	39 c8                	cmp    %ecx,%eax
  801e28:	72 f2                	jb     801e1c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e2a:	5b                   	pop    %ebx
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    

00801e2d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e2d:	55                   	push   %ebp
  801e2e:	89 e5                	mov    %esp,%ebp
  801e30:	57                   	push   %edi
  801e31:	56                   	push   %esi
  801e32:	53                   	push   %ebx
  801e33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e39:	eb 03                	jmp    801e3e <strtol+0x11>
		s++;
  801e3b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e3e:	0f b6 01             	movzbl (%ecx),%eax
  801e41:	3c 20                	cmp    $0x20,%al
  801e43:	74 f6                	je     801e3b <strtol+0xe>
  801e45:	3c 09                	cmp    $0x9,%al
  801e47:	74 f2                	je     801e3b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e49:	3c 2b                	cmp    $0x2b,%al
  801e4b:	75 0a                	jne    801e57 <strtol+0x2a>
		s++;
  801e4d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e50:	bf 00 00 00 00       	mov    $0x0,%edi
  801e55:	eb 11                	jmp    801e68 <strtol+0x3b>
  801e57:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e5c:	3c 2d                	cmp    $0x2d,%al
  801e5e:	75 08                	jne    801e68 <strtol+0x3b>
		s++, neg = 1;
  801e60:	83 c1 01             	add    $0x1,%ecx
  801e63:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e68:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e6e:	75 15                	jne    801e85 <strtol+0x58>
  801e70:	80 39 30             	cmpb   $0x30,(%ecx)
  801e73:	75 10                	jne    801e85 <strtol+0x58>
  801e75:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e79:	75 7c                	jne    801ef7 <strtol+0xca>
		s += 2, base = 16;
  801e7b:	83 c1 02             	add    $0x2,%ecx
  801e7e:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e83:	eb 16                	jmp    801e9b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e85:	85 db                	test   %ebx,%ebx
  801e87:	75 12                	jne    801e9b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e89:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e8e:	80 39 30             	cmpb   $0x30,(%ecx)
  801e91:	75 08                	jne    801e9b <strtol+0x6e>
		s++, base = 8;
  801e93:	83 c1 01             	add    $0x1,%ecx
  801e96:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e9b:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801ea3:	0f b6 11             	movzbl (%ecx),%edx
  801ea6:	8d 72 d0             	lea    -0x30(%edx),%esi
  801ea9:	89 f3                	mov    %esi,%ebx
  801eab:	80 fb 09             	cmp    $0x9,%bl
  801eae:	77 08                	ja     801eb8 <strtol+0x8b>
			dig = *s - '0';
  801eb0:	0f be d2             	movsbl %dl,%edx
  801eb3:	83 ea 30             	sub    $0x30,%edx
  801eb6:	eb 22                	jmp    801eda <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801eb8:	8d 72 9f             	lea    -0x61(%edx),%esi
  801ebb:	89 f3                	mov    %esi,%ebx
  801ebd:	80 fb 19             	cmp    $0x19,%bl
  801ec0:	77 08                	ja     801eca <strtol+0x9d>
			dig = *s - 'a' + 10;
  801ec2:	0f be d2             	movsbl %dl,%edx
  801ec5:	83 ea 57             	sub    $0x57,%edx
  801ec8:	eb 10                	jmp    801eda <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801eca:	8d 72 bf             	lea    -0x41(%edx),%esi
  801ecd:	89 f3                	mov    %esi,%ebx
  801ecf:	80 fb 19             	cmp    $0x19,%bl
  801ed2:	77 16                	ja     801eea <strtol+0xbd>
			dig = *s - 'A' + 10;
  801ed4:	0f be d2             	movsbl %dl,%edx
  801ed7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801eda:	3b 55 10             	cmp    0x10(%ebp),%edx
  801edd:	7d 0b                	jge    801eea <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801edf:	83 c1 01             	add    $0x1,%ecx
  801ee2:	0f af 45 10          	imul   0x10(%ebp),%eax
  801ee6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801ee8:	eb b9                	jmp    801ea3 <strtol+0x76>

	if (endptr)
  801eea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801eee:	74 0d                	je     801efd <strtol+0xd0>
		*endptr = (char *) s;
  801ef0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ef3:	89 0e                	mov    %ecx,(%esi)
  801ef5:	eb 06                	jmp    801efd <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ef7:	85 db                	test   %ebx,%ebx
  801ef9:	74 98                	je     801e93 <strtol+0x66>
  801efb:	eb 9e                	jmp    801e9b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801efd:	89 c2                	mov    %eax,%edx
  801eff:	f7 da                	neg    %edx
  801f01:	85 ff                	test   %edi,%edi
  801f03:	0f 45 c2             	cmovne %edx,%eax
}
  801f06:	5b                   	pop    %ebx
  801f07:	5e                   	pop    %esi
  801f08:	5f                   	pop    %edi
  801f09:	5d                   	pop    %ebp
  801f0a:	c3                   	ret    

00801f0b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f0b:	55                   	push   %ebp
  801f0c:	89 e5                	mov    %esp,%ebp
  801f0e:	56                   	push   %esi
  801f0f:	53                   	push   %ebx
  801f10:	8b 75 08             	mov    0x8(%ebp),%esi
  801f13:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f16:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801f19:	85 c0                	test   %eax,%eax
  801f1b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f20:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801f23:	83 ec 0c             	sub    $0xc,%esp
  801f26:	50                   	push   %eax
  801f27:	e8 ea e3 ff ff       	call   800316 <sys_ipc_recv>
  801f2c:	83 c4 10             	add    $0x10,%esp
  801f2f:	85 c0                	test   %eax,%eax
  801f31:	79 16                	jns    801f49 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801f33:	85 f6                	test   %esi,%esi
  801f35:	74 06                	je     801f3d <ipc_recv+0x32>
            *from_env_store = 0;
  801f37:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801f3d:	85 db                	test   %ebx,%ebx
  801f3f:	74 2c                	je     801f6d <ipc_recv+0x62>
            *perm_store = 0;
  801f41:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f47:	eb 24                	jmp    801f6d <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801f49:	85 f6                	test   %esi,%esi
  801f4b:	74 0a                	je     801f57 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801f4d:	a1 08 40 80 00       	mov    0x804008,%eax
  801f52:	8b 40 74             	mov    0x74(%eax),%eax
  801f55:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801f57:	85 db                	test   %ebx,%ebx
  801f59:	74 0a                	je     801f65 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801f5b:	a1 08 40 80 00       	mov    0x804008,%eax
  801f60:	8b 40 78             	mov    0x78(%eax),%eax
  801f63:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801f65:	a1 08 40 80 00       	mov    0x804008,%eax
  801f6a:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801f6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f70:	5b                   	pop    %ebx
  801f71:	5e                   	pop    %esi
  801f72:	5d                   	pop    %ebp
  801f73:	c3                   	ret    

00801f74 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f74:	55                   	push   %ebp
  801f75:	89 e5                	mov    %esp,%ebp
  801f77:	57                   	push   %edi
  801f78:	56                   	push   %esi
  801f79:	53                   	push   %ebx
  801f7a:	83 ec 0c             	sub    $0xc,%esp
  801f7d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f80:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f83:	8b 45 10             	mov    0x10(%ebp),%eax
  801f86:	85 c0                	test   %eax,%eax
  801f88:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801f8d:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801f90:	eb 1c                	jmp    801fae <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801f92:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f95:	74 12                	je     801fa9 <ipc_send+0x35>
  801f97:	50                   	push   %eax
  801f98:	68 60 27 80 00       	push   $0x802760
  801f9d:	6a 3b                	push   $0x3b
  801f9f:	68 76 27 80 00       	push   $0x802776
  801fa4:	e8 3e f5 ff ff       	call   8014e7 <_panic>
		sys_yield();
  801fa9:	e8 99 e1 ff ff       	call   800147 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801fae:	ff 75 14             	pushl  0x14(%ebp)
  801fb1:	53                   	push   %ebx
  801fb2:	56                   	push   %esi
  801fb3:	57                   	push   %edi
  801fb4:	e8 3a e3 ff ff       	call   8002f3 <sys_ipc_try_send>
  801fb9:	83 c4 10             	add    $0x10,%esp
  801fbc:	85 c0                	test   %eax,%eax
  801fbe:	78 d2                	js     801f92 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801fc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fc3:	5b                   	pop    %ebx
  801fc4:	5e                   	pop    %esi
  801fc5:	5f                   	pop    %edi
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    

00801fc8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fce:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fd3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fd6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fdc:	8b 52 50             	mov    0x50(%edx),%edx
  801fdf:	39 ca                	cmp    %ecx,%edx
  801fe1:	75 0d                	jne    801ff0 <ipc_find_env+0x28>
			return envs[i].env_id;
  801fe3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fe6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801feb:	8b 40 48             	mov    0x48(%eax),%eax
  801fee:	eb 0f                	jmp    801fff <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ff0:	83 c0 01             	add    $0x1,%eax
  801ff3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ff8:	75 d9                	jne    801fd3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ffa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fff:	5d                   	pop    %ebp
  802000:	c3                   	ret    

00802001 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802001:	55                   	push   %ebp
  802002:	89 e5                	mov    %esp,%ebp
  802004:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802007:	89 d0                	mov    %edx,%eax
  802009:	c1 e8 16             	shr    $0x16,%eax
  80200c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802013:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802018:	f6 c1 01             	test   $0x1,%cl
  80201b:	74 1d                	je     80203a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80201d:	c1 ea 0c             	shr    $0xc,%edx
  802020:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802027:	f6 c2 01             	test   $0x1,%dl
  80202a:	74 0e                	je     80203a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80202c:	c1 ea 0c             	shr    $0xc,%edx
  80202f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802036:	ef 
  802037:	0f b7 c0             	movzwl %ax,%eax
}
  80203a:	5d                   	pop    %ebp
  80203b:	c3                   	ret    
  80203c:	66 90                	xchg   %ax,%ax
  80203e:	66 90                	xchg   %ax,%ax

00802040 <__udivdi3>:
  802040:	55                   	push   %ebp
  802041:	57                   	push   %edi
  802042:	56                   	push   %esi
  802043:	53                   	push   %ebx
  802044:	83 ec 1c             	sub    $0x1c,%esp
  802047:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80204b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80204f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802053:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802057:	85 f6                	test   %esi,%esi
  802059:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80205d:	89 ca                	mov    %ecx,%edx
  80205f:	89 f8                	mov    %edi,%eax
  802061:	75 3d                	jne    8020a0 <__udivdi3+0x60>
  802063:	39 cf                	cmp    %ecx,%edi
  802065:	0f 87 c5 00 00 00    	ja     802130 <__udivdi3+0xf0>
  80206b:	85 ff                	test   %edi,%edi
  80206d:	89 fd                	mov    %edi,%ebp
  80206f:	75 0b                	jne    80207c <__udivdi3+0x3c>
  802071:	b8 01 00 00 00       	mov    $0x1,%eax
  802076:	31 d2                	xor    %edx,%edx
  802078:	f7 f7                	div    %edi
  80207a:	89 c5                	mov    %eax,%ebp
  80207c:	89 c8                	mov    %ecx,%eax
  80207e:	31 d2                	xor    %edx,%edx
  802080:	f7 f5                	div    %ebp
  802082:	89 c1                	mov    %eax,%ecx
  802084:	89 d8                	mov    %ebx,%eax
  802086:	89 cf                	mov    %ecx,%edi
  802088:	f7 f5                	div    %ebp
  80208a:	89 c3                	mov    %eax,%ebx
  80208c:	89 d8                	mov    %ebx,%eax
  80208e:	89 fa                	mov    %edi,%edx
  802090:	83 c4 1c             	add    $0x1c,%esp
  802093:	5b                   	pop    %ebx
  802094:	5e                   	pop    %esi
  802095:	5f                   	pop    %edi
  802096:	5d                   	pop    %ebp
  802097:	c3                   	ret    
  802098:	90                   	nop
  802099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	39 ce                	cmp    %ecx,%esi
  8020a2:	77 74                	ja     802118 <__udivdi3+0xd8>
  8020a4:	0f bd fe             	bsr    %esi,%edi
  8020a7:	83 f7 1f             	xor    $0x1f,%edi
  8020aa:	0f 84 98 00 00 00    	je     802148 <__udivdi3+0x108>
  8020b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020b5:	89 f9                	mov    %edi,%ecx
  8020b7:	89 c5                	mov    %eax,%ebp
  8020b9:	29 fb                	sub    %edi,%ebx
  8020bb:	d3 e6                	shl    %cl,%esi
  8020bd:	89 d9                	mov    %ebx,%ecx
  8020bf:	d3 ed                	shr    %cl,%ebp
  8020c1:	89 f9                	mov    %edi,%ecx
  8020c3:	d3 e0                	shl    %cl,%eax
  8020c5:	09 ee                	or     %ebp,%esi
  8020c7:	89 d9                	mov    %ebx,%ecx
  8020c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020cd:	89 d5                	mov    %edx,%ebp
  8020cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020d3:	d3 ed                	shr    %cl,%ebp
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	d3 e2                	shl    %cl,%edx
  8020d9:	89 d9                	mov    %ebx,%ecx
  8020db:	d3 e8                	shr    %cl,%eax
  8020dd:	09 c2                	or     %eax,%edx
  8020df:	89 d0                	mov    %edx,%eax
  8020e1:	89 ea                	mov    %ebp,%edx
  8020e3:	f7 f6                	div    %esi
  8020e5:	89 d5                	mov    %edx,%ebp
  8020e7:	89 c3                	mov    %eax,%ebx
  8020e9:	f7 64 24 0c          	mull   0xc(%esp)
  8020ed:	39 d5                	cmp    %edx,%ebp
  8020ef:	72 10                	jb     802101 <__udivdi3+0xc1>
  8020f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	d3 e6                	shl    %cl,%esi
  8020f9:	39 c6                	cmp    %eax,%esi
  8020fb:	73 07                	jae    802104 <__udivdi3+0xc4>
  8020fd:	39 d5                	cmp    %edx,%ebp
  8020ff:	75 03                	jne    802104 <__udivdi3+0xc4>
  802101:	83 eb 01             	sub    $0x1,%ebx
  802104:	31 ff                	xor    %edi,%edi
  802106:	89 d8                	mov    %ebx,%eax
  802108:	89 fa                	mov    %edi,%edx
  80210a:	83 c4 1c             	add    $0x1c,%esp
  80210d:	5b                   	pop    %ebx
  80210e:	5e                   	pop    %esi
  80210f:	5f                   	pop    %edi
  802110:	5d                   	pop    %ebp
  802111:	c3                   	ret    
  802112:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802118:	31 ff                	xor    %edi,%edi
  80211a:	31 db                	xor    %ebx,%ebx
  80211c:	89 d8                	mov    %ebx,%eax
  80211e:	89 fa                	mov    %edi,%edx
  802120:	83 c4 1c             	add    $0x1c,%esp
  802123:	5b                   	pop    %ebx
  802124:	5e                   	pop    %esi
  802125:	5f                   	pop    %edi
  802126:	5d                   	pop    %ebp
  802127:	c3                   	ret    
  802128:	90                   	nop
  802129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802130:	89 d8                	mov    %ebx,%eax
  802132:	f7 f7                	div    %edi
  802134:	31 ff                	xor    %edi,%edi
  802136:	89 c3                	mov    %eax,%ebx
  802138:	89 d8                	mov    %ebx,%eax
  80213a:	89 fa                	mov    %edi,%edx
  80213c:	83 c4 1c             	add    $0x1c,%esp
  80213f:	5b                   	pop    %ebx
  802140:	5e                   	pop    %esi
  802141:	5f                   	pop    %edi
  802142:	5d                   	pop    %ebp
  802143:	c3                   	ret    
  802144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802148:	39 ce                	cmp    %ecx,%esi
  80214a:	72 0c                	jb     802158 <__udivdi3+0x118>
  80214c:	31 db                	xor    %ebx,%ebx
  80214e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802152:	0f 87 34 ff ff ff    	ja     80208c <__udivdi3+0x4c>
  802158:	bb 01 00 00 00       	mov    $0x1,%ebx
  80215d:	e9 2a ff ff ff       	jmp    80208c <__udivdi3+0x4c>
  802162:	66 90                	xchg   %ax,%ax
  802164:	66 90                	xchg   %ax,%ax
  802166:	66 90                	xchg   %ax,%ax
  802168:	66 90                	xchg   %ax,%ax
  80216a:	66 90                	xchg   %ax,%ax
  80216c:	66 90                	xchg   %ax,%ax
  80216e:	66 90                	xchg   %ax,%ax

00802170 <__umoddi3>:
  802170:	55                   	push   %ebp
  802171:	57                   	push   %edi
  802172:	56                   	push   %esi
  802173:	53                   	push   %ebx
  802174:	83 ec 1c             	sub    $0x1c,%esp
  802177:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80217b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80217f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802183:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802187:	85 d2                	test   %edx,%edx
  802189:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80218d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802191:	89 f3                	mov    %esi,%ebx
  802193:	89 3c 24             	mov    %edi,(%esp)
  802196:	89 74 24 04          	mov    %esi,0x4(%esp)
  80219a:	75 1c                	jne    8021b8 <__umoddi3+0x48>
  80219c:	39 f7                	cmp    %esi,%edi
  80219e:	76 50                	jbe    8021f0 <__umoddi3+0x80>
  8021a0:	89 c8                	mov    %ecx,%eax
  8021a2:	89 f2                	mov    %esi,%edx
  8021a4:	f7 f7                	div    %edi
  8021a6:	89 d0                	mov    %edx,%eax
  8021a8:	31 d2                	xor    %edx,%edx
  8021aa:	83 c4 1c             	add    $0x1c,%esp
  8021ad:	5b                   	pop    %ebx
  8021ae:	5e                   	pop    %esi
  8021af:	5f                   	pop    %edi
  8021b0:	5d                   	pop    %ebp
  8021b1:	c3                   	ret    
  8021b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021b8:	39 f2                	cmp    %esi,%edx
  8021ba:	89 d0                	mov    %edx,%eax
  8021bc:	77 52                	ja     802210 <__umoddi3+0xa0>
  8021be:	0f bd ea             	bsr    %edx,%ebp
  8021c1:	83 f5 1f             	xor    $0x1f,%ebp
  8021c4:	75 5a                	jne    802220 <__umoddi3+0xb0>
  8021c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021ca:	0f 82 e0 00 00 00    	jb     8022b0 <__umoddi3+0x140>
  8021d0:	39 0c 24             	cmp    %ecx,(%esp)
  8021d3:	0f 86 d7 00 00 00    	jbe    8022b0 <__umoddi3+0x140>
  8021d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021e1:	83 c4 1c             	add    $0x1c,%esp
  8021e4:	5b                   	pop    %ebx
  8021e5:	5e                   	pop    %esi
  8021e6:	5f                   	pop    %edi
  8021e7:	5d                   	pop    %ebp
  8021e8:	c3                   	ret    
  8021e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	85 ff                	test   %edi,%edi
  8021f2:	89 fd                	mov    %edi,%ebp
  8021f4:	75 0b                	jne    802201 <__umoddi3+0x91>
  8021f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021fb:	31 d2                	xor    %edx,%edx
  8021fd:	f7 f7                	div    %edi
  8021ff:	89 c5                	mov    %eax,%ebp
  802201:	89 f0                	mov    %esi,%eax
  802203:	31 d2                	xor    %edx,%edx
  802205:	f7 f5                	div    %ebp
  802207:	89 c8                	mov    %ecx,%eax
  802209:	f7 f5                	div    %ebp
  80220b:	89 d0                	mov    %edx,%eax
  80220d:	eb 99                	jmp    8021a8 <__umoddi3+0x38>
  80220f:	90                   	nop
  802210:	89 c8                	mov    %ecx,%eax
  802212:	89 f2                	mov    %esi,%edx
  802214:	83 c4 1c             	add    $0x1c,%esp
  802217:	5b                   	pop    %ebx
  802218:	5e                   	pop    %esi
  802219:	5f                   	pop    %edi
  80221a:	5d                   	pop    %ebp
  80221b:	c3                   	ret    
  80221c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802220:	8b 34 24             	mov    (%esp),%esi
  802223:	bf 20 00 00 00       	mov    $0x20,%edi
  802228:	89 e9                	mov    %ebp,%ecx
  80222a:	29 ef                	sub    %ebp,%edi
  80222c:	d3 e0                	shl    %cl,%eax
  80222e:	89 f9                	mov    %edi,%ecx
  802230:	89 f2                	mov    %esi,%edx
  802232:	d3 ea                	shr    %cl,%edx
  802234:	89 e9                	mov    %ebp,%ecx
  802236:	09 c2                	or     %eax,%edx
  802238:	89 d8                	mov    %ebx,%eax
  80223a:	89 14 24             	mov    %edx,(%esp)
  80223d:	89 f2                	mov    %esi,%edx
  80223f:	d3 e2                	shl    %cl,%edx
  802241:	89 f9                	mov    %edi,%ecx
  802243:	89 54 24 04          	mov    %edx,0x4(%esp)
  802247:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80224b:	d3 e8                	shr    %cl,%eax
  80224d:	89 e9                	mov    %ebp,%ecx
  80224f:	89 c6                	mov    %eax,%esi
  802251:	d3 e3                	shl    %cl,%ebx
  802253:	89 f9                	mov    %edi,%ecx
  802255:	89 d0                	mov    %edx,%eax
  802257:	d3 e8                	shr    %cl,%eax
  802259:	89 e9                	mov    %ebp,%ecx
  80225b:	09 d8                	or     %ebx,%eax
  80225d:	89 d3                	mov    %edx,%ebx
  80225f:	89 f2                	mov    %esi,%edx
  802261:	f7 34 24             	divl   (%esp)
  802264:	89 d6                	mov    %edx,%esi
  802266:	d3 e3                	shl    %cl,%ebx
  802268:	f7 64 24 04          	mull   0x4(%esp)
  80226c:	39 d6                	cmp    %edx,%esi
  80226e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802272:	89 d1                	mov    %edx,%ecx
  802274:	89 c3                	mov    %eax,%ebx
  802276:	72 08                	jb     802280 <__umoddi3+0x110>
  802278:	75 11                	jne    80228b <__umoddi3+0x11b>
  80227a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80227e:	73 0b                	jae    80228b <__umoddi3+0x11b>
  802280:	2b 44 24 04          	sub    0x4(%esp),%eax
  802284:	1b 14 24             	sbb    (%esp),%edx
  802287:	89 d1                	mov    %edx,%ecx
  802289:	89 c3                	mov    %eax,%ebx
  80228b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80228f:	29 da                	sub    %ebx,%edx
  802291:	19 ce                	sbb    %ecx,%esi
  802293:	89 f9                	mov    %edi,%ecx
  802295:	89 f0                	mov    %esi,%eax
  802297:	d3 e0                	shl    %cl,%eax
  802299:	89 e9                	mov    %ebp,%ecx
  80229b:	d3 ea                	shr    %cl,%edx
  80229d:	89 e9                	mov    %ebp,%ecx
  80229f:	d3 ee                	shr    %cl,%esi
  8022a1:	09 d0                	or     %edx,%eax
  8022a3:	89 f2                	mov    %esi,%edx
  8022a5:	83 c4 1c             	add    $0x1c,%esp
  8022a8:	5b                   	pop    %ebx
  8022a9:	5e                   	pop    %esi
  8022aa:	5f                   	pop    %edi
  8022ab:	5d                   	pop    %ebp
  8022ac:	c3                   	ret    
  8022ad:	8d 76 00             	lea    0x0(%esi),%esi
  8022b0:	29 f9                	sub    %edi,%ecx
  8022b2:	19 d6                	sbb    %edx,%esi
  8022b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022bc:	e9 18 ff ff ff       	jmp    8021d9 <__umoddi3+0x69>
