
obj/user/buggyhello2.debug：     文件格式 elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 30 80 00    	pushl  0x803000
  800044:	e8 65 00 00 00       	call   8000ae <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 ce 00 00 00       	call   80012c <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 08 40 80 00       	mov    %eax,0x804008

    // save the name of the program so that panic() can use it
    if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
        binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 30 80 00       	mov    %eax,0x803004

    // call user main routine
    umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 c6 04 00 00       	call   800565 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 42 00 00 00       	call   8000eb <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bf:	89 c3                	mov    %eax,%ebx
  8000c1:	89 c7                	mov    %eax,%edi
  8000c3:	89 c6                	mov    %eax,%esi
  8000c5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dc:	89 d1                	mov    %edx,%ecx
  8000de:	89 d3                	mov    %edx,%ebx
  8000e0:	89 d7                	mov    %edx,%edi
  8000e2:	89 d6                	mov    %edx,%esi
  8000e4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800101:	89 cb                	mov    %ecx,%ebx
  800103:	89 cf                	mov    %ecx,%edi
  800105:	89 ce                	mov    %ecx,%esi
  800107:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800109:	85 c0                	test   %eax,%eax
  80010b:	7e 17                	jle    800124 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	50                   	push   %eax
  800111:	6a 03                	push   $0x3
  800113:	68 f8 22 80 00       	push   $0x8022f8
  800118:	6a 23                	push   $0x23
  80011a:	68 15 23 80 00       	push   $0x802315
  80011f:	e8 c7 13 00 00       	call   8014eb <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5f                   	pop    %edi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    

0080012c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	57                   	push   %edi
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	b8 02 00 00 00       	mov    $0x2,%eax
  80013c:	89 d1                	mov    %edx,%ecx
  80013e:	89 d3                	mov    %edx,%ebx
  800140:	89 d7                	mov    %edx,%edi
  800142:	89 d6                	mov    %edx,%esi
  800144:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_yield>:

void
sys_yield(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
  800170:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800173:	be 00 00 00 00       	mov    $0x0,%esi
  800178:	b8 04 00 00 00       	mov    $0x4,%eax
  80017d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800180:	8b 55 08             	mov    0x8(%ebp),%edx
  800183:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800186:	89 f7                	mov    %esi,%edi
  800188:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80018a:	85 c0                	test   %eax,%eax
  80018c:	7e 17                	jle    8001a5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	50                   	push   %eax
  800192:	6a 04                	push   $0x4
  800194:	68 f8 22 80 00       	push   $0x8022f8
  800199:	6a 23                	push   $0x23
  80019b:	68 15 23 80 00       	push   $0x802315
  8001a0:	e8 46 13 00 00       	call   8014eb <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a8:	5b                   	pop    %ebx
  8001a9:	5e                   	pop    %esi
  8001aa:	5f                   	pop    %edi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    

008001ad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	57                   	push   %edi
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001be:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001cc:	85 c0                	test   %eax,%eax
  8001ce:	7e 17                	jle    8001e7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d0:	83 ec 0c             	sub    $0xc,%esp
  8001d3:	50                   	push   %eax
  8001d4:	6a 05                	push   $0x5
  8001d6:	68 f8 22 80 00       	push   $0x8022f8
  8001db:	6a 23                	push   $0x23
  8001dd:	68 15 23 80 00       	push   $0x802315
  8001e2:	e8 04 13 00 00       	call   8014eb <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ea:	5b                   	pop    %ebx
  8001eb:	5e                   	pop    %esi
  8001ec:	5f                   	pop    %edi
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    

008001ef <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	57                   	push   %edi
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fd:	b8 06 00 00 00       	mov    $0x6,%eax
  800202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800205:	8b 55 08             	mov    0x8(%ebp),%edx
  800208:	89 df                	mov    %ebx,%edi
  80020a:	89 de                	mov    %ebx,%esi
  80020c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80020e:	85 c0                	test   %eax,%eax
  800210:	7e 17                	jle    800229 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	50                   	push   %eax
  800216:	6a 06                	push   $0x6
  800218:	68 f8 22 80 00       	push   $0x8022f8
  80021d:	6a 23                	push   $0x23
  80021f:	68 15 23 80 00       	push   $0x802315
  800224:	e8 c2 12 00 00       	call   8014eb <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800229:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022c:	5b                   	pop    %ebx
  80022d:	5e                   	pop    %esi
  80022e:	5f                   	pop    %edi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    

00800231 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	57                   	push   %edi
  800235:	56                   	push   %esi
  800236:	53                   	push   %ebx
  800237:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023f:	b8 08 00 00 00       	mov    $0x8,%eax
  800244:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800247:	8b 55 08             	mov    0x8(%ebp),%edx
  80024a:	89 df                	mov    %ebx,%edi
  80024c:	89 de                	mov    %ebx,%esi
  80024e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800250:	85 c0                	test   %eax,%eax
  800252:	7e 17                	jle    80026b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800254:	83 ec 0c             	sub    $0xc,%esp
  800257:	50                   	push   %eax
  800258:	6a 08                	push   $0x8
  80025a:	68 f8 22 80 00       	push   $0x8022f8
  80025f:	6a 23                	push   $0x23
  800261:	68 15 23 80 00       	push   $0x802315
  800266:	e8 80 12 00 00       	call   8014eb <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	b8 09 00 00 00       	mov    $0x9,%eax
  800286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800289:	8b 55 08             	mov    0x8(%ebp),%edx
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7e 17                	jle    8002ad <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800296:	83 ec 0c             	sub    $0xc,%esp
  800299:	50                   	push   %eax
  80029a:	6a 09                	push   $0x9
  80029c:	68 f8 22 80 00       	push   $0x8022f8
  8002a1:	6a 23                	push   $0x23
  8002a3:	68 15 23 80 00       	push   $0x802315
  8002a8:	e8 3e 12 00 00       	call   8014eb <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	57                   	push   %edi
  8002b9:	56                   	push   %esi
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ce:	89 df                	mov    %ebx,%edi
  8002d0:	89 de                	mov    %ebx,%esi
  8002d2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	7e 17                	jle    8002ef <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	50                   	push   %eax
  8002dc:	6a 0a                	push   $0xa
  8002de:	68 f8 22 80 00       	push   $0x8022f8
  8002e3:	6a 23                	push   $0x23
  8002e5:	68 15 23 80 00       	push   $0x802315
  8002ea:	e8 fc 11 00 00       	call   8014eb <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	57                   	push   %edi
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fd:	be 00 00 00 00       	mov    $0x0,%esi
  800302:	b8 0c 00 00 00       	mov    $0xc,%eax
  800307:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030a:	8b 55 08             	mov    0x8(%ebp),%edx
  80030d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800310:	8b 7d 14             	mov    0x14(%ebp),%edi
  800313:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800323:	b9 00 00 00 00       	mov    $0x0,%ecx
  800328:	b8 0d 00 00 00       	mov    $0xd,%eax
  80032d:	8b 55 08             	mov    0x8(%ebp),%edx
  800330:	89 cb                	mov    %ecx,%ebx
  800332:	89 cf                	mov    %ecx,%edi
  800334:	89 ce                	mov    %ecx,%esi
  800336:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7e 17                	jle    800353 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	50                   	push   %eax
  800340:	6a 0d                	push   $0xd
  800342:	68 f8 22 80 00       	push   $0x8022f8
  800347:	6a 23                	push   $0x23
  800349:	68 15 23 80 00       	push   $0x802315
  80034e:	e8 98 11 00 00       	call   8014eb <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800353:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	57                   	push   %edi
  80035f:	56                   	push   %esi
  800360:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800361:	ba 00 00 00 00       	mov    $0x0,%edx
  800366:	b8 0e 00 00 00       	mov    $0xe,%eax
  80036b:	89 d1                	mov    %edx,%ecx
  80036d:	89 d3                	mov    %edx,%ebx
  80036f:	89 d7                	mov    %edx,%edi
  800371:	89 d6                	mov    %edx,%esi
  800373:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	57                   	push   %edi
  80037e:	56                   	push   %esi
  80037f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800380:	b9 00 00 00 00       	mov    $0x0,%ecx
  800385:	b8 10 00 00 00       	mov    $0x10,%eax
  80038a:	8b 55 08             	mov    0x8(%ebp),%edx
  80038d:	89 cb                	mov    %ecx,%ebx
  80038f:	89 cf                	mov    %ecx,%edi
  800391:	89 ce                	mov    %ecx,%esi
  800393:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800395:	5b                   	pop    %ebx
  800396:	5e                   	pop    %esi
  800397:	5f                   	pop    %edi
  800398:	5d                   	pop    %ebp
  800399:	c3                   	ret    

0080039a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80039d:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a0:	05 00 00 00 30       	add    $0x30000000,%eax
  8003a5:	c1 e8 0c             	shr    $0xc,%eax
}
  8003a8:	5d                   	pop    %ebp
  8003a9:	c3                   	ret    

008003aa <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003aa:	55                   	push   %ebp
  8003ab:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b0:	05 00 00 00 30       	add    $0x30000000,%eax
  8003b5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003ba:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003bf:	5d                   	pop    %ebp
  8003c0:	c3                   	ret    

008003c1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003c1:	55                   	push   %ebp
  8003c2:	89 e5                	mov    %esp,%ebp
  8003c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003cc:	89 c2                	mov    %eax,%edx
  8003ce:	c1 ea 16             	shr    $0x16,%edx
  8003d1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003d8:	f6 c2 01             	test   $0x1,%dl
  8003db:	74 11                	je     8003ee <fd_alloc+0x2d>
  8003dd:	89 c2                	mov    %eax,%edx
  8003df:	c1 ea 0c             	shr    $0xc,%edx
  8003e2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003e9:	f6 c2 01             	test   $0x1,%dl
  8003ec:	75 09                	jne    8003f7 <fd_alloc+0x36>
			*fd_store = fd;
  8003ee:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003f5:	eb 17                	jmp    80040e <fd_alloc+0x4d>
  8003f7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003fc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800401:	75 c9                	jne    8003cc <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800403:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800409:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80040e:	5d                   	pop    %ebp
  80040f:	c3                   	ret    

00800410 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800416:	83 f8 1f             	cmp    $0x1f,%eax
  800419:	77 36                	ja     800451 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80041b:	c1 e0 0c             	shl    $0xc,%eax
  80041e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800423:	89 c2                	mov    %eax,%edx
  800425:	c1 ea 16             	shr    $0x16,%edx
  800428:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80042f:	f6 c2 01             	test   $0x1,%dl
  800432:	74 24                	je     800458 <fd_lookup+0x48>
  800434:	89 c2                	mov    %eax,%edx
  800436:	c1 ea 0c             	shr    $0xc,%edx
  800439:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800440:	f6 c2 01             	test   $0x1,%dl
  800443:	74 1a                	je     80045f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800445:	8b 55 0c             	mov    0xc(%ebp),%edx
  800448:	89 02                	mov    %eax,(%edx)
	return 0;
  80044a:	b8 00 00 00 00       	mov    $0x0,%eax
  80044f:	eb 13                	jmp    800464 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800451:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800456:	eb 0c                	jmp    800464 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800458:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80045d:	eb 05                	jmp    800464 <fd_lookup+0x54>
  80045f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800464:	5d                   	pop    %ebp
  800465:	c3                   	ret    

00800466 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800466:	55                   	push   %ebp
  800467:	89 e5                	mov    %esp,%ebp
  800469:	83 ec 08             	sub    $0x8,%esp
  80046c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80046f:	ba a0 23 80 00       	mov    $0x8023a0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800474:	eb 13                	jmp    800489 <dev_lookup+0x23>
  800476:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800479:	39 08                	cmp    %ecx,(%eax)
  80047b:	75 0c                	jne    800489 <dev_lookup+0x23>
			*dev = devtab[i];
  80047d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800480:	89 01                	mov    %eax,(%ecx)
			return 0;
  800482:	b8 00 00 00 00       	mov    $0x0,%eax
  800487:	eb 2e                	jmp    8004b7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800489:	8b 02                	mov    (%edx),%eax
  80048b:	85 c0                	test   %eax,%eax
  80048d:	75 e7                	jne    800476 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80048f:	a1 08 40 80 00       	mov    0x804008,%eax
  800494:	8b 40 48             	mov    0x48(%eax),%eax
  800497:	83 ec 04             	sub    $0x4,%esp
  80049a:	51                   	push   %ecx
  80049b:	50                   	push   %eax
  80049c:	68 24 23 80 00       	push   $0x802324
  8004a1:	e8 1e 11 00 00       	call   8015c4 <cprintf>
	*dev = 0;
  8004a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004af:	83 c4 10             	add    $0x10,%esp
  8004b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004b7:	c9                   	leave  
  8004b8:	c3                   	ret    

008004b9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004b9:	55                   	push   %ebp
  8004ba:	89 e5                	mov    %esp,%ebp
  8004bc:	56                   	push   %esi
  8004bd:	53                   	push   %ebx
  8004be:	83 ec 10             	sub    $0x10,%esp
  8004c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ca:	50                   	push   %eax
  8004cb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004d1:	c1 e8 0c             	shr    $0xc,%eax
  8004d4:	50                   	push   %eax
  8004d5:	e8 36 ff ff ff       	call   800410 <fd_lookup>
  8004da:	83 c4 08             	add    $0x8,%esp
  8004dd:	85 c0                	test   %eax,%eax
  8004df:	78 05                	js     8004e6 <fd_close+0x2d>
	    || fd != fd2)
  8004e1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004e4:	74 0c                	je     8004f2 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004e6:	84 db                	test   %bl,%bl
  8004e8:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ed:	0f 44 c2             	cmove  %edx,%eax
  8004f0:	eb 41                	jmp    800533 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004f8:	50                   	push   %eax
  8004f9:	ff 36                	pushl  (%esi)
  8004fb:	e8 66 ff ff ff       	call   800466 <dev_lookup>
  800500:	89 c3                	mov    %eax,%ebx
  800502:	83 c4 10             	add    $0x10,%esp
  800505:	85 c0                	test   %eax,%eax
  800507:	78 1a                	js     800523 <fd_close+0x6a>
		if (dev->dev_close)
  800509:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80050c:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80050f:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800514:	85 c0                	test   %eax,%eax
  800516:	74 0b                	je     800523 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800518:	83 ec 0c             	sub    $0xc,%esp
  80051b:	56                   	push   %esi
  80051c:	ff d0                	call   *%eax
  80051e:	89 c3                	mov    %eax,%ebx
  800520:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800523:	83 ec 08             	sub    $0x8,%esp
  800526:	56                   	push   %esi
  800527:	6a 00                	push   $0x0
  800529:	e8 c1 fc ff ff       	call   8001ef <sys_page_unmap>
	return r;
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	89 d8                	mov    %ebx,%eax
}
  800533:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800536:	5b                   	pop    %ebx
  800537:	5e                   	pop    %esi
  800538:	5d                   	pop    %ebp
  800539:	c3                   	ret    

0080053a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80053a:	55                   	push   %ebp
  80053b:	89 e5                	mov    %esp,%ebp
  80053d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800540:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800543:	50                   	push   %eax
  800544:	ff 75 08             	pushl  0x8(%ebp)
  800547:	e8 c4 fe ff ff       	call   800410 <fd_lookup>
  80054c:	83 c4 08             	add    $0x8,%esp
  80054f:	85 c0                	test   %eax,%eax
  800551:	78 10                	js     800563 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800553:	83 ec 08             	sub    $0x8,%esp
  800556:	6a 01                	push   $0x1
  800558:	ff 75 f4             	pushl  -0xc(%ebp)
  80055b:	e8 59 ff ff ff       	call   8004b9 <fd_close>
  800560:	83 c4 10             	add    $0x10,%esp
}
  800563:	c9                   	leave  
  800564:	c3                   	ret    

00800565 <close_all>:

void
close_all(void)
{
  800565:	55                   	push   %ebp
  800566:	89 e5                	mov    %esp,%ebp
  800568:	53                   	push   %ebx
  800569:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80056c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800571:	83 ec 0c             	sub    $0xc,%esp
  800574:	53                   	push   %ebx
  800575:	e8 c0 ff ff ff       	call   80053a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80057a:	83 c3 01             	add    $0x1,%ebx
  80057d:	83 c4 10             	add    $0x10,%esp
  800580:	83 fb 20             	cmp    $0x20,%ebx
  800583:	75 ec                	jne    800571 <close_all+0xc>
		close(i);
}
  800585:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800588:	c9                   	leave  
  800589:	c3                   	ret    

0080058a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80058a:	55                   	push   %ebp
  80058b:	89 e5                	mov    %esp,%ebp
  80058d:	57                   	push   %edi
  80058e:	56                   	push   %esi
  80058f:	53                   	push   %ebx
  800590:	83 ec 2c             	sub    $0x2c,%esp
  800593:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800596:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800599:	50                   	push   %eax
  80059a:	ff 75 08             	pushl  0x8(%ebp)
  80059d:	e8 6e fe ff ff       	call   800410 <fd_lookup>
  8005a2:	83 c4 08             	add    $0x8,%esp
  8005a5:	85 c0                	test   %eax,%eax
  8005a7:	0f 88 c1 00 00 00    	js     80066e <dup+0xe4>
		return r;
	close(newfdnum);
  8005ad:	83 ec 0c             	sub    $0xc,%esp
  8005b0:	56                   	push   %esi
  8005b1:	e8 84 ff ff ff       	call   80053a <close>

	newfd = INDEX2FD(newfdnum);
  8005b6:	89 f3                	mov    %esi,%ebx
  8005b8:	c1 e3 0c             	shl    $0xc,%ebx
  8005bb:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005c1:	83 c4 04             	add    $0x4,%esp
  8005c4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005c7:	e8 de fd ff ff       	call   8003aa <fd2data>
  8005cc:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005ce:	89 1c 24             	mov    %ebx,(%esp)
  8005d1:	e8 d4 fd ff ff       	call   8003aa <fd2data>
  8005d6:	83 c4 10             	add    $0x10,%esp
  8005d9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005dc:	89 f8                	mov    %edi,%eax
  8005de:	c1 e8 16             	shr    $0x16,%eax
  8005e1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005e8:	a8 01                	test   $0x1,%al
  8005ea:	74 37                	je     800623 <dup+0x99>
  8005ec:	89 f8                	mov    %edi,%eax
  8005ee:	c1 e8 0c             	shr    $0xc,%eax
  8005f1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005f8:	f6 c2 01             	test   $0x1,%dl
  8005fb:	74 26                	je     800623 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005fd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800604:	83 ec 0c             	sub    $0xc,%esp
  800607:	25 07 0e 00 00       	and    $0xe07,%eax
  80060c:	50                   	push   %eax
  80060d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800610:	6a 00                	push   $0x0
  800612:	57                   	push   %edi
  800613:	6a 00                	push   $0x0
  800615:	e8 93 fb ff ff       	call   8001ad <sys_page_map>
  80061a:	89 c7                	mov    %eax,%edi
  80061c:	83 c4 20             	add    $0x20,%esp
  80061f:	85 c0                	test   %eax,%eax
  800621:	78 2e                	js     800651 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800623:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800626:	89 d0                	mov    %edx,%eax
  800628:	c1 e8 0c             	shr    $0xc,%eax
  80062b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800632:	83 ec 0c             	sub    $0xc,%esp
  800635:	25 07 0e 00 00       	and    $0xe07,%eax
  80063a:	50                   	push   %eax
  80063b:	53                   	push   %ebx
  80063c:	6a 00                	push   $0x0
  80063e:	52                   	push   %edx
  80063f:	6a 00                	push   $0x0
  800641:	e8 67 fb ff ff       	call   8001ad <sys_page_map>
  800646:	89 c7                	mov    %eax,%edi
  800648:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80064b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80064d:	85 ff                	test   %edi,%edi
  80064f:	79 1d                	jns    80066e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	53                   	push   %ebx
  800655:	6a 00                	push   $0x0
  800657:	e8 93 fb ff ff       	call   8001ef <sys_page_unmap>
	sys_page_unmap(0, nva);
  80065c:	83 c4 08             	add    $0x8,%esp
  80065f:	ff 75 d4             	pushl  -0x2c(%ebp)
  800662:	6a 00                	push   $0x0
  800664:	e8 86 fb ff ff       	call   8001ef <sys_page_unmap>
	return r;
  800669:	83 c4 10             	add    $0x10,%esp
  80066c:	89 f8                	mov    %edi,%eax
}
  80066e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800671:	5b                   	pop    %ebx
  800672:	5e                   	pop    %esi
  800673:	5f                   	pop    %edi
  800674:	5d                   	pop    %ebp
  800675:	c3                   	ret    

00800676 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800676:	55                   	push   %ebp
  800677:	89 e5                	mov    %esp,%ebp
  800679:	53                   	push   %ebx
  80067a:	83 ec 14             	sub    $0x14,%esp
  80067d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800680:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800683:	50                   	push   %eax
  800684:	53                   	push   %ebx
  800685:	e8 86 fd ff ff       	call   800410 <fd_lookup>
  80068a:	83 c4 08             	add    $0x8,%esp
  80068d:	89 c2                	mov    %eax,%edx
  80068f:	85 c0                	test   %eax,%eax
  800691:	78 6d                	js     800700 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800693:	83 ec 08             	sub    $0x8,%esp
  800696:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800699:	50                   	push   %eax
  80069a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80069d:	ff 30                	pushl  (%eax)
  80069f:	e8 c2 fd ff ff       	call   800466 <dev_lookup>
  8006a4:	83 c4 10             	add    $0x10,%esp
  8006a7:	85 c0                	test   %eax,%eax
  8006a9:	78 4c                	js     8006f7 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006ab:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006ae:	8b 42 08             	mov    0x8(%edx),%eax
  8006b1:	83 e0 03             	and    $0x3,%eax
  8006b4:	83 f8 01             	cmp    $0x1,%eax
  8006b7:	75 21                	jne    8006da <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006b9:	a1 08 40 80 00       	mov    0x804008,%eax
  8006be:	8b 40 48             	mov    0x48(%eax),%eax
  8006c1:	83 ec 04             	sub    $0x4,%esp
  8006c4:	53                   	push   %ebx
  8006c5:	50                   	push   %eax
  8006c6:	68 65 23 80 00       	push   $0x802365
  8006cb:	e8 f4 0e 00 00       	call   8015c4 <cprintf>
		return -E_INVAL;
  8006d0:	83 c4 10             	add    $0x10,%esp
  8006d3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006d8:	eb 26                	jmp    800700 <read+0x8a>
	}
	if (!dev->dev_read)
  8006da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006dd:	8b 40 08             	mov    0x8(%eax),%eax
  8006e0:	85 c0                	test   %eax,%eax
  8006e2:	74 17                	je     8006fb <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006e4:	83 ec 04             	sub    $0x4,%esp
  8006e7:	ff 75 10             	pushl  0x10(%ebp)
  8006ea:	ff 75 0c             	pushl  0xc(%ebp)
  8006ed:	52                   	push   %edx
  8006ee:	ff d0                	call   *%eax
  8006f0:	89 c2                	mov    %eax,%edx
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	eb 09                	jmp    800700 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006f7:	89 c2                	mov    %eax,%edx
  8006f9:	eb 05                	jmp    800700 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006fb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800700:	89 d0                	mov    %edx,%eax
  800702:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800705:	c9                   	leave  
  800706:	c3                   	ret    

00800707 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800707:	55                   	push   %ebp
  800708:	89 e5                	mov    %esp,%ebp
  80070a:	57                   	push   %edi
  80070b:	56                   	push   %esi
  80070c:	53                   	push   %ebx
  80070d:	83 ec 0c             	sub    $0xc,%esp
  800710:	8b 7d 08             	mov    0x8(%ebp),%edi
  800713:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800716:	bb 00 00 00 00       	mov    $0x0,%ebx
  80071b:	eb 21                	jmp    80073e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80071d:	83 ec 04             	sub    $0x4,%esp
  800720:	89 f0                	mov    %esi,%eax
  800722:	29 d8                	sub    %ebx,%eax
  800724:	50                   	push   %eax
  800725:	89 d8                	mov    %ebx,%eax
  800727:	03 45 0c             	add    0xc(%ebp),%eax
  80072a:	50                   	push   %eax
  80072b:	57                   	push   %edi
  80072c:	e8 45 ff ff ff       	call   800676 <read>
		if (m < 0)
  800731:	83 c4 10             	add    $0x10,%esp
  800734:	85 c0                	test   %eax,%eax
  800736:	78 10                	js     800748 <readn+0x41>
			return m;
		if (m == 0)
  800738:	85 c0                	test   %eax,%eax
  80073a:	74 0a                	je     800746 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80073c:	01 c3                	add    %eax,%ebx
  80073e:	39 f3                	cmp    %esi,%ebx
  800740:	72 db                	jb     80071d <readn+0x16>
  800742:	89 d8                	mov    %ebx,%eax
  800744:	eb 02                	jmp    800748 <readn+0x41>
  800746:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800748:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074b:	5b                   	pop    %ebx
  80074c:	5e                   	pop    %esi
  80074d:	5f                   	pop    %edi
  80074e:	5d                   	pop    %ebp
  80074f:	c3                   	ret    

00800750 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	53                   	push   %ebx
  800754:	83 ec 14             	sub    $0x14,%esp
  800757:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80075a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80075d:	50                   	push   %eax
  80075e:	53                   	push   %ebx
  80075f:	e8 ac fc ff ff       	call   800410 <fd_lookup>
  800764:	83 c4 08             	add    $0x8,%esp
  800767:	89 c2                	mov    %eax,%edx
  800769:	85 c0                	test   %eax,%eax
  80076b:	78 68                	js     8007d5 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80076d:	83 ec 08             	sub    $0x8,%esp
  800770:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800773:	50                   	push   %eax
  800774:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800777:	ff 30                	pushl  (%eax)
  800779:	e8 e8 fc ff ff       	call   800466 <dev_lookup>
  80077e:	83 c4 10             	add    $0x10,%esp
  800781:	85 c0                	test   %eax,%eax
  800783:	78 47                	js     8007cc <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800785:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800788:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80078c:	75 21                	jne    8007af <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80078e:	a1 08 40 80 00       	mov    0x804008,%eax
  800793:	8b 40 48             	mov    0x48(%eax),%eax
  800796:	83 ec 04             	sub    $0x4,%esp
  800799:	53                   	push   %ebx
  80079a:	50                   	push   %eax
  80079b:	68 81 23 80 00       	push   $0x802381
  8007a0:	e8 1f 0e 00 00       	call   8015c4 <cprintf>
		return -E_INVAL;
  8007a5:	83 c4 10             	add    $0x10,%esp
  8007a8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007ad:	eb 26                	jmp    8007d5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007af:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007b2:	8b 52 0c             	mov    0xc(%edx),%edx
  8007b5:	85 d2                	test   %edx,%edx
  8007b7:	74 17                	je     8007d0 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007b9:	83 ec 04             	sub    $0x4,%esp
  8007bc:	ff 75 10             	pushl  0x10(%ebp)
  8007bf:	ff 75 0c             	pushl  0xc(%ebp)
  8007c2:	50                   	push   %eax
  8007c3:	ff d2                	call   *%edx
  8007c5:	89 c2                	mov    %eax,%edx
  8007c7:	83 c4 10             	add    $0x10,%esp
  8007ca:	eb 09                	jmp    8007d5 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007cc:	89 c2                	mov    %eax,%edx
  8007ce:	eb 05                	jmp    8007d5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007d0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007d5:	89 d0                	mov    %edx,%eax
  8007d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    

008007dc <seek>:

int
seek(int fdnum, off_t offset)
{
  8007dc:	55                   	push   %ebp
  8007dd:	89 e5                	mov    %esp,%ebp
  8007df:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007e2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007e5:	50                   	push   %eax
  8007e6:	ff 75 08             	pushl  0x8(%ebp)
  8007e9:	e8 22 fc ff ff       	call   800410 <fd_lookup>
  8007ee:	83 c4 08             	add    $0x8,%esp
  8007f1:	85 c0                	test   %eax,%eax
  8007f3:	78 0e                	js     800803 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800803:	c9                   	leave  
  800804:	c3                   	ret    

00800805 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800805:	55                   	push   %ebp
  800806:	89 e5                	mov    %esp,%ebp
  800808:	53                   	push   %ebx
  800809:	83 ec 14             	sub    $0x14,%esp
  80080c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80080f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800812:	50                   	push   %eax
  800813:	53                   	push   %ebx
  800814:	e8 f7 fb ff ff       	call   800410 <fd_lookup>
  800819:	83 c4 08             	add    $0x8,%esp
  80081c:	89 c2                	mov    %eax,%edx
  80081e:	85 c0                	test   %eax,%eax
  800820:	78 65                	js     800887 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800822:	83 ec 08             	sub    $0x8,%esp
  800825:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800828:	50                   	push   %eax
  800829:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80082c:	ff 30                	pushl  (%eax)
  80082e:	e8 33 fc ff ff       	call   800466 <dev_lookup>
  800833:	83 c4 10             	add    $0x10,%esp
  800836:	85 c0                	test   %eax,%eax
  800838:	78 44                	js     80087e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80083a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80083d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800841:	75 21                	jne    800864 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800843:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800848:	8b 40 48             	mov    0x48(%eax),%eax
  80084b:	83 ec 04             	sub    $0x4,%esp
  80084e:	53                   	push   %ebx
  80084f:	50                   	push   %eax
  800850:	68 44 23 80 00       	push   $0x802344
  800855:	e8 6a 0d 00 00       	call   8015c4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80085a:	83 c4 10             	add    $0x10,%esp
  80085d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800862:	eb 23                	jmp    800887 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800864:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800867:	8b 52 18             	mov    0x18(%edx),%edx
  80086a:	85 d2                	test   %edx,%edx
  80086c:	74 14                	je     800882 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	ff 75 0c             	pushl  0xc(%ebp)
  800874:	50                   	push   %eax
  800875:	ff d2                	call   *%edx
  800877:	89 c2                	mov    %eax,%edx
  800879:	83 c4 10             	add    $0x10,%esp
  80087c:	eb 09                	jmp    800887 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80087e:	89 c2                	mov    %eax,%edx
  800880:	eb 05                	jmp    800887 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800882:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800887:	89 d0                	mov    %edx,%eax
  800889:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088c:	c9                   	leave  
  80088d:	c3                   	ret    

0080088e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	53                   	push   %ebx
  800892:	83 ec 14             	sub    $0x14,%esp
  800895:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800898:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80089b:	50                   	push   %eax
  80089c:	ff 75 08             	pushl  0x8(%ebp)
  80089f:	e8 6c fb ff ff       	call   800410 <fd_lookup>
  8008a4:	83 c4 08             	add    $0x8,%esp
  8008a7:	89 c2                	mov    %eax,%edx
  8008a9:	85 c0                	test   %eax,%eax
  8008ab:	78 58                	js     800905 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008ad:	83 ec 08             	sub    $0x8,%esp
  8008b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008b3:	50                   	push   %eax
  8008b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008b7:	ff 30                	pushl  (%eax)
  8008b9:	e8 a8 fb ff ff       	call   800466 <dev_lookup>
  8008be:	83 c4 10             	add    $0x10,%esp
  8008c1:	85 c0                	test   %eax,%eax
  8008c3:	78 37                	js     8008fc <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008cc:	74 32                	je     800900 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008ce:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008d1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008d8:	00 00 00 
	stat->st_isdir = 0;
  8008db:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008e2:	00 00 00 
	stat->st_dev = dev;
  8008e5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008eb:	83 ec 08             	sub    $0x8,%esp
  8008ee:	53                   	push   %ebx
  8008ef:	ff 75 f0             	pushl  -0x10(%ebp)
  8008f2:	ff 50 14             	call   *0x14(%eax)
  8008f5:	89 c2                	mov    %eax,%edx
  8008f7:	83 c4 10             	add    $0x10,%esp
  8008fa:	eb 09                	jmp    800905 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008fc:	89 c2                	mov    %eax,%edx
  8008fe:	eb 05                	jmp    800905 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800900:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800905:	89 d0                	mov    %edx,%eax
  800907:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80090a:	c9                   	leave  
  80090b:	c3                   	ret    

0080090c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	56                   	push   %esi
  800910:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800911:	83 ec 08             	sub    $0x8,%esp
  800914:	6a 00                	push   $0x0
  800916:	ff 75 08             	pushl  0x8(%ebp)
  800919:	e8 e3 01 00 00       	call   800b01 <open>
  80091e:	89 c3                	mov    %eax,%ebx
  800920:	83 c4 10             	add    $0x10,%esp
  800923:	85 c0                	test   %eax,%eax
  800925:	78 1b                	js     800942 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800927:	83 ec 08             	sub    $0x8,%esp
  80092a:	ff 75 0c             	pushl  0xc(%ebp)
  80092d:	50                   	push   %eax
  80092e:	e8 5b ff ff ff       	call   80088e <fstat>
  800933:	89 c6                	mov    %eax,%esi
	close(fd);
  800935:	89 1c 24             	mov    %ebx,(%esp)
  800938:	e8 fd fb ff ff       	call   80053a <close>
	return r;
  80093d:	83 c4 10             	add    $0x10,%esp
  800940:	89 f0                	mov    %esi,%eax
}
  800942:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800945:	5b                   	pop    %ebx
  800946:	5e                   	pop    %esi
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	56                   	push   %esi
  80094d:	53                   	push   %ebx
  80094e:	89 c6                	mov    %eax,%esi
  800950:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800952:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800959:	75 12                	jne    80096d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80095b:	83 ec 0c             	sub    $0xc,%esp
  80095e:	6a 01                	push   $0x1
  800960:	e8 67 16 00 00       	call   801fcc <ipc_find_env>
  800965:	a3 00 40 80 00       	mov    %eax,0x804000
  80096a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80096d:	6a 07                	push   $0x7
  80096f:	68 00 50 80 00       	push   $0x805000
  800974:	56                   	push   %esi
  800975:	ff 35 00 40 80 00    	pushl  0x804000
  80097b:	e8 f8 15 00 00       	call   801f78 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800980:	83 c4 0c             	add    $0xc,%esp
  800983:	6a 00                	push   $0x0
  800985:	53                   	push   %ebx
  800986:	6a 00                	push   $0x0
  800988:	e8 82 15 00 00       	call   801f0f <ipc_recv>
}
  80098d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800990:	5b                   	pop    %ebx
  800991:	5e                   	pop    %esi
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80099a:	8b 45 08             	mov    0x8(%ebp),%eax
  80099d:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b2:	b8 02 00 00 00       	mov    $0x2,%eax
  8009b7:	e8 8d ff ff ff       	call   800949 <fsipc>
}
  8009bc:	c9                   	leave  
  8009bd:	c3                   	ret    

008009be <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ca:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d4:	b8 06 00 00 00       	mov    $0x6,%eax
  8009d9:	e8 6b ff ff ff       	call   800949 <fsipc>
}
  8009de:	c9                   	leave  
  8009df:	c3                   	ret    

008009e0 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	53                   	push   %ebx
  8009e4:	83 ec 04             	sub    $0x4,%esp
  8009e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009fa:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ff:	e8 45 ff ff ff       	call   800949 <fsipc>
  800a04:	85 c0                	test   %eax,%eax
  800a06:	78 2c                	js     800a34 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a08:	83 ec 08             	sub    $0x8,%esp
  800a0b:	68 00 50 80 00       	push   $0x805000
  800a10:	53                   	push   %ebx
  800a11:	e8 b2 11 00 00       	call   801bc8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a16:	a1 80 50 80 00       	mov    0x805080,%eax
  800a1b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a21:	a1 84 50 80 00       	mov    0x805084,%eax
  800a26:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a2c:	83 c4 10             	add    $0x10,%esp
  800a2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a37:	c9                   	leave  
  800a38:	c3                   	ret    

00800a39 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	83 ec 0c             	sub    $0xc,%esp
  800a3f:	8b 45 10             	mov    0x10(%ebp),%eax
  800a42:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a47:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a4c:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a52:	8b 52 0c             	mov    0xc(%edx),%edx
  800a55:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a5b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a60:	50                   	push   %eax
  800a61:	ff 75 0c             	pushl  0xc(%ebp)
  800a64:	68 08 50 80 00       	push   $0x805008
  800a69:	e8 ec 12 00 00       	call   801d5a <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a73:	b8 04 00 00 00       	mov    $0x4,%eax
  800a78:	e8 cc fe ff ff       	call   800949 <fsipc>
	//panic("devfile_write not implemented");
}
  800a7d:	c9                   	leave  
  800a7e:	c3                   	ret    

00800a7f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
  800a84:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a87:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8a:	8b 40 0c             	mov    0xc(%eax),%eax
  800a8d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a92:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a98:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9d:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa2:	e8 a2 fe ff ff       	call   800949 <fsipc>
  800aa7:	89 c3                	mov    %eax,%ebx
  800aa9:	85 c0                	test   %eax,%eax
  800aab:	78 4b                	js     800af8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aad:	39 c6                	cmp    %eax,%esi
  800aaf:	73 16                	jae    800ac7 <devfile_read+0x48>
  800ab1:	68 b4 23 80 00       	push   $0x8023b4
  800ab6:	68 bb 23 80 00       	push   $0x8023bb
  800abb:	6a 7c                	push   $0x7c
  800abd:	68 d0 23 80 00       	push   $0x8023d0
  800ac2:	e8 24 0a 00 00       	call   8014eb <_panic>
	assert(r <= PGSIZE);
  800ac7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800acc:	7e 16                	jle    800ae4 <devfile_read+0x65>
  800ace:	68 db 23 80 00       	push   $0x8023db
  800ad3:	68 bb 23 80 00       	push   $0x8023bb
  800ad8:	6a 7d                	push   $0x7d
  800ada:	68 d0 23 80 00       	push   $0x8023d0
  800adf:	e8 07 0a 00 00       	call   8014eb <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae4:	83 ec 04             	sub    $0x4,%esp
  800ae7:	50                   	push   %eax
  800ae8:	68 00 50 80 00       	push   $0x805000
  800aed:	ff 75 0c             	pushl  0xc(%ebp)
  800af0:	e8 65 12 00 00       	call   801d5a <memmove>
	return r;
  800af5:	83 c4 10             	add    $0x10,%esp
}
  800af8:	89 d8                	mov    %ebx,%eax
  800afa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800afd:	5b                   	pop    %ebx
  800afe:	5e                   	pop    %esi
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	53                   	push   %ebx
  800b05:	83 ec 20             	sub    $0x20,%esp
  800b08:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b0b:	53                   	push   %ebx
  800b0c:	e8 7e 10 00 00       	call   801b8f <strlen>
  800b11:	83 c4 10             	add    $0x10,%esp
  800b14:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b19:	7f 67                	jg     800b82 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b1b:	83 ec 0c             	sub    $0xc,%esp
  800b1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b21:	50                   	push   %eax
  800b22:	e8 9a f8 ff ff       	call   8003c1 <fd_alloc>
  800b27:	83 c4 10             	add    $0x10,%esp
		return r;
  800b2a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b2c:	85 c0                	test   %eax,%eax
  800b2e:	78 57                	js     800b87 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b30:	83 ec 08             	sub    $0x8,%esp
  800b33:	53                   	push   %ebx
  800b34:	68 00 50 80 00       	push   $0x805000
  800b39:	e8 8a 10 00 00       	call   801bc8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b41:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b46:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b49:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4e:	e8 f6 fd ff ff       	call   800949 <fsipc>
  800b53:	89 c3                	mov    %eax,%ebx
  800b55:	83 c4 10             	add    $0x10,%esp
  800b58:	85 c0                	test   %eax,%eax
  800b5a:	79 14                	jns    800b70 <open+0x6f>
		fd_close(fd, 0);
  800b5c:	83 ec 08             	sub    $0x8,%esp
  800b5f:	6a 00                	push   $0x0
  800b61:	ff 75 f4             	pushl  -0xc(%ebp)
  800b64:	e8 50 f9 ff ff       	call   8004b9 <fd_close>
		return r;
  800b69:	83 c4 10             	add    $0x10,%esp
  800b6c:	89 da                	mov    %ebx,%edx
  800b6e:	eb 17                	jmp    800b87 <open+0x86>
	}

	return fd2num(fd);
  800b70:	83 ec 0c             	sub    $0xc,%esp
  800b73:	ff 75 f4             	pushl  -0xc(%ebp)
  800b76:	e8 1f f8 ff ff       	call   80039a <fd2num>
  800b7b:	89 c2                	mov    %eax,%edx
  800b7d:	83 c4 10             	add    $0x10,%esp
  800b80:	eb 05                	jmp    800b87 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b82:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b87:	89 d0                	mov    %edx,%eax
  800b89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b8c:	c9                   	leave  
  800b8d:	c3                   	ret    

00800b8e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b94:	ba 00 00 00 00       	mov    $0x0,%edx
  800b99:	b8 08 00 00 00       	mov    $0x8,%eax
  800b9e:	e8 a6 fd ff ff       	call   800949 <fsipc>
}
  800ba3:	c9                   	leave  
  800ba4:	c3                   	ret    

00800ba5 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bab:	68 e7 23 80 00       	push   $0x8023e7
  800bb0:	ff 75 0c             	pushl  0xc(%ebp)
  800bb3:	e8 10 10 00 00       	call   801bc8 <strcpy>
	return 0;
}
  800bb8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbd:	c9                   	leave  
  800bbe:	c3                   	ret    

00800bbf <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bbf:	55                   	push   %ebp
  800bc0:	89 e5                	mov    %esp,%ebp
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 10             	sub    $0x10,%esp
  800bc6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bc9:	53                   	push   %ebx
  800bca:	e8 36 14 00 00       	call   802005 <pageref>
  800bcf:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bd2:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800bd7:	83 f8 01             	cmp    $0x1,%eax
  800bda:	75 10                	jne    800bec <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800bdc:	83 ec 0c             	sub    $0xc,%esp
  800bdf:	ff 73 0c             	pushl  0xc(%ebx)
  800be2:	e8 c0 02 00 00       	call   800ea7 <nsipc_close>
  800be7:	89 c2                	mov    %eax,%edx
  800be9:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800bec:	89 d0                	mov    %edx,%eax
  800bee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf1:	c9                   	leave  
  800bf2:	c3                   	ret    

00800bf3 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800bf3:	55                   	push   %ebp
  800bf4:	89 e5                	mov    %esp,%ebp
  800bf6:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bf9:	6a 00                	push   $0x0
  800bfb:	ff 75 10             	pushl  0x10(%ebp)
  800bfe:	ff 75 0c             	pushl  0xc(%ebp)
  800c01:	8b 45 08             	mov    0x8(%ebp),%eax
  800c04:	ff 70 0c             	pushl  0xc(%eax)
  800c07:	e8 78 03 00 00       	call   800f84 <nsipc_send>
}
  800c0c:	c9                   	leave  
  800c0d:	c3                   	ret    

00800c0e <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c14:	6a 00                	push   $0x0
  800c16:	ff 75 10             	pushl  0x10(%ebp)
  800c19:	ff 75 0c             	pushl  0xc(%ebp)
  800c1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1f:	ff 70 0c             	pushl  0xc(%eax)
  800c22:	e8 f1 02 00 00       	call   800f18 <nsipc_recv>
}
  800c27:	c9                   	leave  
  800c28:	c3                   	ret    

00800c29 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c29:	55                   	push   %ebp
  800c2a:	89 e5                	mov    %esp,%ebp
  800c2c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c2f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c32:	52                   	push   %edx
  800c33:	50                   	push   %eax
  800c34:	e8 d7 f7 ff ff       	call   800410 <fd_lookup>
  800c39:	83 c4 10             	add    $0x10,%esp
  800c3c:	85 c0                	test   %eax,%eax
  800c3e:	78 17                	js     800c57 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c43:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  800c49:	39 08                	cmp    %ecx,(%eax)
  800c4b:	75 05                	jne    800c52 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c4d:	8b 40 0c             	mov    0xc(%eax),%eax
  800c50:	eb 05                	jmp    800c57 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c52:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c57:	c9                   	leave  
  800c58:	c3                   	ret    

00800c59 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c59:	55                   	push   %ebp
  800c5a:	89 e5                	mov    %esp,%ebp
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
  800c5e:	83 ec 1c             	sub    $0x1c,%esp
  800c61:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c66:	50                   	push   %eax
  800c67:	e8 55 f7 ff ff       	call   8003c1 <fd_alloc>
  800c6c:	89 c3                	mov    %eax,%ebx
  800c6e:	83 c4 10             	add    $0x10,%esp
  800c71:	85 c0                	test   %eax,%eax
  800c73:	78 1b                	js     800c90 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c75:	83 ec 04             	sub    $0x4,%esp
  800c78:	68 07 04 00 00       	push   $0x407
  800c7d:	ff 75 f4             	pushl  -0xc(%ebp)
  800c80:	6a 00                	push   $0x0
  800c82:	e8 e3 f4 ff ff       	call   80016a <sys_page_alloc>
  800c87:	89 c3                	mov    %eax,%ebx
  800c89:	83 c4 10             	add    $0x10,%esp
  800c8c:	85 c0                	test   %eax,%eax
  800c8e:	79 10                	jns    800ca0 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c90:	83 ec 0c             	sub    $0xc,%esp
  800c93:	56                   	push   %esi
  800c94:	e8 0e 02 00 00       	call   800ea7 <nsipc_close>
		return r;
  800c99:	83 c4 10             	add    $0x10,%esp
  800c9c:	89 d8                	mov    %ebx,%eax
  800c9e:	eb 24                	jmp    800cc4 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800ca0:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca9:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cae:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cb5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cb8:	83 ec 0c             	sub    $0xc,%esp
  800cbb:	50                   	push   %eax
  800cbc:	e8 d9 f6 ff ff       	call   80039a <fd2num>
  800cc1:	83 c4 10             	add    $0x10,%esp
}
  800cc4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5d                   	pop    %ebp
  800cca:	c3                   	ret    

00800ccb <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cd1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd4:	e8 50 ff ff ff       	call   800c29 <fd2sockid>
		return r;
  800cd9:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	78 1f                	js     800cfe <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cdf:	83 ec 04             	sub    $0x4,%esp
  800ce2:	ff 75 10             	pushl  0x10(%ebp)
  800ce5:	ff 75 0c             	pushl  0xc(%ebp)
  800ce8:	50                   	push   %eax
  800ce9:	e8 12 01 00 00       	call   800e00 <nsipc_accept>
  800cee:	83 c4 10             	add    $0x10,%esp
		return r;
  800cf1:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cf3:	85 c0                	test   %eax,%eax
  800cf5:	78 07                	js     800cfe <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800cf7:	e8 5d ff ff ff       	call   800c59 <alloc_sockfd>
  800cfc:	89 c1                	mov    %eax,%ecx
}
  800cfe:	89 c8                	mov    %ecx,%eax
  800d00:	c9                   	leave  
  800d01:	c3                   	ret    

00800d02 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d08:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0b:	e8 19 ff ff ff       	call   800c29 <fd2sockid>
  800d10:	85 c0                	test   %eax,%eax
  800d12:	78 12                	js     800d26 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d14:	83 ec 04             	sub    $0x4,%esp
  800d17:	ff 75 10             	pushl  0x10(%ebp)
  800d1a:	ff 75 0c             	pushl  0xc(%ebp)
  800d1d:	50                   	push   %eax
  800d1e:	e8 2d 01 00 00       	call   800e50 <nsipc_bind>
  800d23:	83 c4 10             	add    $0x10,%esp
}
  800d26:	c9                   	leave  
  800d27:	c3                   	ret    

00800d28 <shutdown>:

int
shutdown(int s, int how)
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d31:	e8 f3 fe ff ff       	call   800c29 <fd2sockid>
  800d36:	85 c0                	test   %eax,%eax
  800d38:	78 0f                	js     800d49 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d3a:	83 ec 08             	sub    $0x8,%esp
  800d3d:	ff 75 0c             	pushl  0xc(%ebp)
  800d40:	50                   	push   %eax
  800d41:	e8 3f 01 00 00       	call   800e85 <nsipc_shutdown>
  800d46:	83 c4 10             	add    $0x10,%esp
}
  800d49:	c9                   	leave  
  800d4a:	c3                   	ret    

00800d4b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d51:	8b 45 08             	mov    0x8(%ebp),%eax
  800d54:	e8 d0 fe ff ff       	call   800c29 <fd2sockid>
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	78 12                	js     800d6f <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d5d:	83 ec 04             	sub    $0x4,%esp
  800d60:	ff 75 10             	pushl  0x10(%ebp)
  800d63:	ff 75 0c             	pushl  0xc(%ebp)
  800d66:	50                   	push   %eax
  800d67:	e8 55 01 00 00       	call   800ec1 <nsipc_connect>
  800d6c:	83 c4 10             	add    $0x10,%esp
}
  800d6f:	c9                   	leave  
  800d70:	c3                   	ret    

00800d71 <listen>:

int
listen(int s, int backlog)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d77:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7a:	e8 aa fe ff ff       	call   800c29 <fd2sockid>
  800d7f:	85 c0                	test   %eax,%eax
  800d81:	78 0f                	js     800d92 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d83:	83 ec 08             	sub    $0x8,%esp
  800d86:	ff 75 0c             	pushl  0xc(%ebp)
  800d89:	50                   	push   %eax
  800d8a:	e8 67 01 00 00       	call   800ef6 <nsipc_listen>
  800d8f:	83 c4 10             	add    $0x10,%esp
}
  800d92:	c9                   	leave  
  800d93:	c3                   	ret    

00800d94 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d9a:	ff 75 10             	pushl  0x10(%ebp)
  800d9d:	ff 75 0c             	pushl  0xc(%ebp)
  800da0:	ff 75 08             	pushl  0x8(%ebp)
  800da3:	e8 3a 02 00 00       	call   800fe2 <nsipc_socket>
  800da8:	83 c4 10             	add    $0x10,%esp
  800dab:	85 c0                	test   %eax,%eax
  800dad:	78 05                	js     800db4 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800daf:	e8 a5 fe ff ff       	call   800c59 <alloc_sockfd>
}
  800db4:	c9                   	leave  
  800db5:	c3                   	ret    

00800db6 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800db6:	55                   	push   %ebp
  800db7:	89 e5                	mov    %esp,%ebp
  800db9:	53                   	push   %ebx
  800dba:	83 ec 04             	sub    $0x4,%esp
  800dbd:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dbf:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dc6:	75 12                	jne    800dda <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dc8:	83 ec 0c             	sub    $0xc,%esp
  800dcb:	6a 02                	push   $0x2
  800dcd:	e8 fa 11 00 00       	call   801fcc <ipc_find_env>
  800dd2:	a3 04 40 80 00       	mov    %eax,0x804004
  800dd7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dda:	6a 07                	push   $0x7
  800ddc:	68 00 60 80 00       	push   $0x806000
  800de1:	53                   	push   %ebx
  800de2:	ff 35 04 40 80 00    	pushl  0x804004
  800de8:	e8 8b 11 00 00       	call   801f78 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800ded:	83 c4 0c             	add    $0xc,%esp
  800df0:	6a 00                	push   $0x0
  800df2:	6a 00                	push   $0x0
  800df4:	6a 00                	push   $0x0
  800df6:	e8 14 11 00 00       	call   801f0f <ipc_recv>
}
  800dfb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dfe:	c9                   	leave  
  800dff:	c3                   	ret    

00800e00 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	56                   	push   %esi
  800e04:	53                   	push   %ebx
  800e05:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e08:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e10:	8b 06                	mov    (%esi),%eax
  800e12:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e17:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1c:	e8 95 ff ff ff       	call   800db6 <nsipc>
  800e21:	89 c3                	mov    %eax,%ebx
  800e23:	85 c0                	test   %eax,%eax
  800e25:	78 20                	js     800e47 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e27:	83 ec 04             	sub    $0x4,%esp
  800e2a:	ff 35 10 60 80 00    	pushl  0x806010
  800e30:	68 00 60 80 00       	push   $0x806000
  800e35:	ff 75 0c             	pushl  0xc(%ebp)
  800e38:	e8 1d 0f 00 00       	call   801d5a <memmove>
		*addrlen = ret->ret_addrlen;
  800e3d:	a1 10 60 80 00       	mov    0x806010,%eax
  800e42:	89 06                	mov    %eax,(%esi)
  800e44:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e47:	89 d8                	mov    %ebx,%eax
  800e49:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e4c:	5b                   	pop    %ebx
  800e4d:	5e                   	pop    %esi
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	53                   	push   %ebx
  800e54:	83 ec 08             	sub    $0x8,%esp
  800e57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e62:	53                   	push   %ebx
  800e63:	ff 75 0c             	pushl  0xc(%ebp)
  800e66:	68 04 60 80 00       	push   $0x806004
  800e6b:	e8 ea 0e 00 00       	call   801d5a <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e70:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e76:	b8 02 00 00 00       	mov    $0x2,%eax
  800e7b:	e8 36 ff ff ff       	call   800db6 <nsipc>
}
  800e80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e83:	c9                   	leave  
  800e84:	c3                   	ret    

00800e85 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e93:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e96:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e9b:	b8 03 00 00 00       	mov    $0x3,%eax
  800ea0:	e8 11 ff ff ff       	call   800db6 <nsipc>
}
  800ea5:	c9                   	leave  
  800ea6:	c3                   	ret    

00800ea7 <nsipc_close>:

int
nsipc_close(int s)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ead:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb0:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800eb5:	b8 04 00 00 00       	mov    $0x4,%eax
  800eba:	e8 f7 fe ff ff       	call   800db6 <nsipc>
}
  800ebf:	c9                   	leave  
  800ec0:	c3                   	ret    

00800ec1 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	53                   	push   %ebx
  800ec5:	83 ec 08             	sub    $0x8,%esp
  800ec8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ecb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ece:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ed3:	53                   	push   %ebx
  800ed4:	ff 75 0c             	pushl  0xc(%ebp)
  800ed7:	68 04 60 80 00       	push   $0x806004
  800edc:	e8 79 0e 00 00       	call   801d5a <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ee1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ee7:	b8 05 00 00 00       	mov    $0x5,%eax
  800eec:	e8 c5 fe ff ff       	call   800db6 <nsipc>
}
  800ef1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef4:	c9                   	leave  
  800ef5:	c3                   	ret    

00800ef6 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800efc:	8b 45 08             	mov    0x8(%ebp),%eax
  800eff:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f04:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f07:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f0c:	b8 06 00 00 00       	mov    $0x6,%eax
  800f11:	e8 a0 fe ff ff       	call   800db6 <nsipc>
}
  800f16:	c9                   	leave  
  800f17:	c3                   	ret    

00800f18 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	56                   	push   %esi
  800f1c:	53                   	push   %ebx
  800f1d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f20:	8b 45 08             	mov    0x8(%ebp),%eax
  800f23:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f28:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f2e:	8b 45 14             	mov    0x14(%ebp),%eax
  800f31:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f36:	b8 07 00 00 00       	mov    $0x7,%eax
  800f3b:	e8 76 fe ff ff       	call   800db6 <nsipc>
  800f40:	89 c3                	mov    %eax,%ebx
  800f42:	85 c0                	test   %eax,%eax
  800f44:	78 35                	js     800f7b <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f46:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f4b:	7f 04                	jg     800f51 <nsipc_recv+0x39>
  800f4d:	39 c6                	cmp    %eax,%esi
  800f4f:	7d 16                	jge    800f67 <nsipc_recv+0x4f>
  800f51:	68 f3 23 80 00       	push   $0x8023f3
  800f56:	68 bb 23 80 00       	push   $0x8023bb
  800f5b:	6a 62                	push   $0x62
  800f5d:	68 08 24 80 00       	push   $0x802408
  800f62:	e8 84 05 00 00       	call   8014eb <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f67:	83 ec 04             	sub    $0x4,%esp
  800f6a:	50                   	push   %eax
  800f6b:	68 00 60 80 00       	push   $0x806000
  800f70:	ff 75 0c             	pushl  0xc(%ebp)
  800f73:	e8 e2 0d 00 00       	call   801d5a <memmove>
  800f78:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f7b:	89 d8                	mov    %ebx,%eax
  800f7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f80:	5b                   	pop    %ebx
  800f81:	5e                   	pop    %esi
  800f82:	5d                   	pop    %ebp
  800f83:	c3                   	ret    

00800f84 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	53                   	push   %ebx
  800f88:	83 ec 04             	sub    $0x4,%esp
  800f8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f91:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f96:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f9c:	7e 16                	jle    800fb4 <nsipc_send+0x30>
  800f9e:	68 14 24 80 00       	push   $0x802414
  800fa3:	68 bb 23 80 00       	push   $0x8023bb
  800fa8:	6a 6d                	push   $0x6d
  800faa:	68 08 24 80 00       	push   $0x802408
  800faf:	e8 37 05 00 00       	call   8014eb <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fb4:	83 ec 04             	sub    $0x4,%esp
  800fb7:	53                   	push   %ebx
  800fb8:	ff 75 0c             	pushl  0xc(%ebp)
  800fbb:	68 0c 60 80 00       	push   $0x80600c
  800fc0:	e8 95 0d 00 00       	call   801d5a <memmove>
	nsipcbuf.send.req_size = size;
  800fc5:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fcb:	8b 45 14             	mov    0x14(%ebp),%eax
  800fce:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fd3:	b8 08 00 00 00       	mov    $0x8,%eax
  800fd8:	e8 d9 fd ff ff       	call   800db6 <nsipc>
}
  800fdd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe0:	c9                   	leave  
  800fe1:	c3                   	ret    

00800fe2 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fe8:	8b 45 08             	mov    0x8(%ebp),%eax
  800feb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800ff0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff3:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800ff8:	8b 45 10             	mov    0x10(%ebp),%eax
  800ffb:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801000:	b8 09 00 00 00       	mov    $0x9,%eax
  801005:	e8 ac fd ff ff       	call   800db6 <nsipc>
}
  80100a:	c9                   	leave  
  80100b:	c3                   	ret    

0080100c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	56                   	push   %esi
  801010:	53                   	push   %ebx
  801011:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801014:	83 ec 0c             	sub    $0xc,%esp
  801017:	ff 75 08             	pushl  0x8(%ebp)
  80101a:	e8 8b f3 ff ff       	call   8003aa <fd2data>
  80101f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801021:	83 c4 08             	add    $0x8,%esp
  801024:	68 20 24 80 00       	push   $0x802420
  801029:	53                   	push   %ebx
  80102a:	e8 99 0b 00 00       	call   801bc8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80102f:	8b 46 04             	mov    0x4(%esi),%eax
  801032:	2b 06                	sub    (%esi),%eax
  801034:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80103a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801041:	00 00 00 
	stat->st_dev = &devpipe;
  801044:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  80104b:	30 80 00 
	return 0;
}
  80104e:	b8 00 00 00 00       	mov    $0x0,%eax
  801053:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801056:	5b                   	pop    %ebx
  801057:	5e                   	pop    %esi
  801058:	5d                   	pop    %ebp
  801059:	c3                   	ret    

0080105a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80105a:	55                   	push   %ebp
  80105b:	89 e5                	mov    %esp,%ebp
  80105d:	53                   	push   %ebx
  80105e:	83 ec 0c             	sub    $0xc,%esp
  801061:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801064:	53                   	push   %ebx
  801065:	6a 00                	push   $0x0
  801067:	e8 83 f1 ff ff       	call   8001ef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80106c:	89 1c 24             	mov    %ebx,(%esp)
  80106f:	e8 36 f3 ff ff       	call   8003aa <fd2data>
  801074:	83 c4 08             	add    $0x8,%esp
  801077:	50                   	push   %eax
  801078:	6a 00                	push   $0x0
  80107a:	e8 70 f1 ff ff       	call   8001ef <sys_page_unmap>
}
  80107f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801082:	c9                   	leave  
  801083:	c3                   	ret    

00801084 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	57                   	push   %edi
  801088:	56                   	push   %esi
  801089:	53                   	push   %ebx
  80108a:	83 ec 1c             	sub    $0x1c,%esp
  80108d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801090:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801092:	a1 08 40 80 00       	mov    0x804008,%eax
  801097:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80109a:	83 ec 0c             	sub    $0xc,%esp
  80109d:	ff 75 e0             	pushl  -0x20(%ebp)
  8010a0:	e8 60 0f 00 00       	call   802005 <pageref>
  8010a5:	89 c3                	mov    %eax,%ebx
  8010a7:	89 3c 24             	mov    %edi,(%esp)
  8010aa:	e8 56 0f 00 00       	call   802005 <pageref>
  8010af:	83 c4 10             	add    $0x10,%esp
  8010b2:	39 c3                	cmp    %eax,%ebx
  8010b4:	0f 94 c1             	sete   %cl
  8010b7:	0f b6 c9             	movzbl %cl,%ecx
  8010ba:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010bd:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010c3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010c6:	39 ce                	cmp    %ecx,%esi
  8010c8:	74 1b                	je     8010e5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010ca:	39 c3                	cmp    %eax,%ebx
  8010cc:	75 c4                	jne    801092 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010ce:	8b 42 58             	mov    0x58(%edx),%eax
  8010d1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010d4:	50                   	push   %eax
  8010d5:	56                   	push   %esi
  8010d6:	68 27 24 80 00       	push   $0x802427
  8010db:	e8 e4 04 00 00       	call   8015c4 <cprintf>
  8010e0:	83 c4 10             	add    $0x10,%esp
  8010e3:	eb ad                	jmp    801092 <_pipeisclosed+0xe>
	}
}
  8010e5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010eb:	5b                   	pop    %ebx
  8010ec:	5e                   	pop    %esi
  8010ed:	5f                   	pop    %edi
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	57                   	push   %edi
  8010f4:	56                   	push   %esi
  8010f5:	53                   	push   %ebx
  8010f6:	83 ec 28             	sub    $0x28,%esp
  8010f9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8010fc:	56                   	push   %esi
  8010fd:	e8 a8 f2 ff ff       	call   8003aa <fd2data>
  801102:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801104:	83 c4 10             	add    $0x10,%esp
  801107:	bf 00 00 00 00       	mov    $0x0,%edi
  80110c:	eb 4b                	jmp    801159 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80110e:	89 da                	mov    %ebx,%edx
  801110:	89 f0                	mov    %esi,%eax
  801112:	e8 6d ff ff ff       	call   801084 <_pipeisclosed>
  801117:	85 c0                	test   %eax,%eax
  801119:	75 48                	jne    801163 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80111b:	e8 2b f0 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801120:	8b 43 04             	mov    0x4(%ebx),%eax
  801123:	8b 0b                	mov    (%ebx),%ecx
  801125:	8d 51 20             	lea    0x20(%ecx),%edx
  801128:	39 d0                	cmp    %edx,%eax
  80112a:	73 e2                	jae    80110e <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80112c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801133:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801136:	89 c2                	mov    %eax,%edx
  801138:	c1 fa 1f             	sar    $0x1f,%edx
  80113b:	89 d1                	mov    %edx,%ecx
  80113d:	c1 e9 1b             	shr    $0x1b,%ecx
  801140:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801143:	83 e2 1f             	and    $0x1f,%edx
  801146:	29 ca                	sub    %ecx,%edx
  801148:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80114c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801150:	83 c0 01             	add    $0x1,%eax
  801153:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801156:	83 c7 01             	add    $0x1,%edi
  801159:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80115c:	75 c2                	jne    801120 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80115e:	8b 45 10             	mov    0x10(%ebp),%eax
  801161:	eb 05                	jmp    801168 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801163:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801168:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116b:	5b                   	pop    %ebx
  80116c:	5e                   	pop    %esi
  80116d:	5f                   	pop    %edi
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    

00801170 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	57                   	push   %edi
  801174:	56                   	push   %esi
  801175:	53                   	push   %ebx
  801176:	83 ec 18             	sub    $0x18,%esp
  801179:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80117c:	57                   	push   %edi
  80117d:	e8 28 f2 ff ff       	call   8003aa <fd2data>
  801182:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801184:	83 c4 10             	add    $0x10,%esp
  801187:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118c:	eb 3d                	jmp    8011cb <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80118e:	85 db                	test   %ebx,%ebx
  801190:	74 04                	je     801196 <devpipe_read+0x26>
				return i;
  801192:	89 d8                	mov    %ebx,%eax
  801194:	eb 44                	jmp    8011da <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801196:	89 f2                	mov    %esi,%edx
  801198:	89 f8                	mov    %edi,%eax
  80119a:	e8 e5 fe ff ff       	call   801084 <_pipeisclosed>
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	75 32                	jne    8011d5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011a3:	e8 a3 ef ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011a8:	8b 06                	mov    (%esi),%eax
  8011aa:	3b 46 04             	cmp    0x4(%esi),%eax
  8011ad:	74 df                	je     80118e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011af:	99                   	cltd   
  8011b0:	c1 ea 1b             	shr    $0x1b,%edx
  8011b3:	01 d0                	add    %edx,%eax
  8011b5:	83 e0 1f             	and    $0x1f,%eax
  8011b8:	29 d0                	sub    %edx,%eax
  8011ba:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011c2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011c5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011c8:	83 c3 01             	add    $0x1,%ebx
  8011cb:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011ce:	75 d8                	jne    8011a8 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8011d3:	eb 05                	jmp    8011da <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011d5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011dd:	5b                   	pop    %ebx
  8011de:	5e                   	pop    %esi
  8011df:	5f                   	pop    %edi
  8011e0:	5d                   	pop    %ebp
  8011e1:	c3                   	ret    

008011e2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
  8011e5:	56                   	push   %esi
  8011e6:	53                   	push   %ebx
  8011e7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ed:	50                   	push   %eax
  8011ee:	e8 ce f1 ff ff       	call   8003c1 <fd_alloc>
  8011f3:	83 c4 10             	add    $0x10,%esp
  8011f6:	89 c2                	mov    %eax,%edx
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	0f 88 2c 01 00 00    	js     80132c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801200:	83 ec 04             	sub    $0x4,%esp
  801203:	68 07 04 00 00       	push   $0x407
  801208:	ff 75 f4             	pushl  -0xc(%ebp)
  80120b:	6a 00                	push   $0x0
  80120d:	e8 58 ef ff ff       	call   80016a <sys_page_alloc>
  801212:	83 c4 10             	add    $0x10,%esp
  801215:	89 c2                	mov    %eax,%edx
  801217:	85 c0                	test   %eax,%eax
  801219:	0f 88 0d 01 00 00    	js     80132c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80121f:	83 ec 0c             	sub    $0xc,%esp
  801222:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801225:	50                   	push   %eax
  801226:	e8 96 f1 ff ff       	call   8003c1 <fd_alloc>
  80122b:	89 c3                	mov    %eax,%ebx
  80122d:	83 c4 10             	add    $0x10,%esp
  801230:	85 c0                	test   %eax,%eax
  801232:	0f 88 e2 00 00 00    	js     80131a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801238:	83 ec 04             	sub    $0x4,%esp
  80123b:	68 07 04 00 00       	push   $0x407
  801240:	ff 75 f0             	pushl  -0x10(%ebp)
  801243:	6a 00                	push   $0x0
  801245:	e8 20 ef ff ff       	call   80016a <sys_page_alloc>
  80124a:	89 c3                	mov    %eax,%ebx
  80124c:	83 c4 10             	add    $0x10,%esp
  80124f:	85 c0                	test   %eax,%eax
  801251:	0f 88 c3 00 00 00    	js     80131a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801257:	83 ec 0c             	sub    $0xc,%esp
  80125a:	ff 75 f4             	pushl  -0xc(%ebp)
  80125d:	e8 48 f1 ff ff       	call   8003aa <fd2data>
  801262:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801264:	83 c4 0c             	add    $0xc,%esp
  801267:	68 07 04 00 00       	push   $0x407
  80126c:	50                   	push   %eax
  80126d:	6a 00                	push   $0x0
  80126f:	e8 f6 ee ff ff       	call   80016a <sys_page_alloc>
  801274:	89 c3                	mov    %eax,%ebx
  801276:	83 c4 10             	add    $0x10,%esp
  801279:	85 c0                	test   %eax,%eax
  80127b:	0f 88 89 00 00 00    	js     80130a <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801281:	83 ec 0c             	sub    $0xc,%esp
  801284:	ff 75 f0             	pushl  -0x10(%ebp)
  801287:	e8 1e f1 ff ff       	call   8003aa <fd2data>
  80128c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801293:	50                   	push   %eax
  801294:	6a 00                	push   $0x0
  801296:	56                   	push   %esi
  801297:	6a 00                	push   $0x0
  801299:	e8 0f ef ff ff       	call   8001ad <sys_page_map>
  80129e:	89 c3                	mov    %eax,%ebx
  8012a0:	83 c4 20             	add    $0x20,%esp
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	78 55                	js     8012fc <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012a7:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8012ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012bc:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8012c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ca:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012d1:	83 ec 0c             	sub    $0xc,%esp
  8012d4:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d7:	e8 be f0 ff ff       	call   80039a <fd2num>
  8012dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012df:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012e1:	83 c4 04             	add    $0x4,%esp
  8012e4:	ff 75 f0             	pushl  -0x10(%ebp)
  8012e7:	e8 ae f0 ff ff       	call   80039a <fd2num>
  8012ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ef:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012f2:	83 c4 10             	add    $0x10,%esp
  8012f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8012fa:	eb 30                	jmp    80132c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8012fc:	83 ec 08             	sub    $0x8,%esp
  8012ff:	56                   	push   %esi
  801300:	6a 00                	push   $0x0
  801302:	e8 e8 ee ff ff       	call   8001ef <sys_page_unmap>
  801307:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80130a:	83 ec 08             	sub    $0x8,%esp
  80130d:	ff 75 f0             	pushl  -0x10(%ebp)
  801310:	6a 00                	push   $0x0
  801312:	e8 d8 ee ff ff       	call   8001ef <sys_page_unmap>
  801317:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80131a:	83 ec 08             	sub    $0x8,%esp
  80131d:	ff 75 f4             	pushl  -0xc(%ebp)
  801320:	6a 00                	push   $0x0
  801322:	e8 c8 ee ff ff       	call   8001ef <sys_page_unmap>
  801327:	83 c4 10             	add    $0x10,%esp
  80132a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80132c:	89 d0                	mov    %edx,%eax
  80132e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801331:	5b                   	pop    %ebx
  801332:	5e                   	pop    %esi
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    

00801335 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80133b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133e:	50                   	push   %eax
  80133f:	ff 75 08             	pushl  0x8(%ebp)
  801342:	e8 c9 f0 ff ff       	call   800410 <fd_lookup>
  801347:	83 c4 10             	add    $0x10,%esp
  80134a:	85 c0                	test   %eax,%eax
  80134c:	78 18                	js     801366 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80134e:	83 ec 0c             	sub    $0xc,%esp
  801351:	ff 75 f4             	pushl  -0xc(%ebp)
  801354:	e8 51 f0 ff ff       	call   8003aa <fd2data>
	return _pipeisclosed(fd, p);
  801359:	89 c2                	mov    %eax,%edx
  80135b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135e:	e8 21 fd ff ff       	call   801084 <_pipeisclosed>
  801363:	83 c4 10             	add    $0x10,%esp
}
  801366:	c9                   	leave  
  801367:	c3                   	ret    

00801368 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801368:	55                   	push   %ebp
  801369:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80136b:	b8 00 00 00 00       	mov    $0x0,%eax
  801370:	5d                   	pop    %ebp
  801371:	c3                   	ret    

00801372 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801378:	68 3f 24 80 00       	push   $0x80243f
  80137d:	ff 75 0c             	pushl  0xc(%ebp)
  801380:	e8 43 08 00 00       	call   801bc8 <strcpy>
	return 0;
}
  801385:	b8 00 00 00 00       	mov    $0x0,%eax
  80138a:	c9                   	leave  
  80138b:	c3                   	ret    

0080138c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80138c:	55                   	push   %ebp
  80138d:	89 e5                	mov    %esp,%ebp
  80138f:	57                   	push   %edi
  801390:	56                   	push   %esi
  801391:	53                   	push   %ebx
  801392:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801398:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80139d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013a3:	eb 2d                	jmp    8013d2 <devcons_write+0x46>
		m = n - tot;
  8013a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013a8:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013aa:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013ad:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013b2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013b5:	83 ec 04             	sub    $0x4,%esp
  8013b8:	53                   	push   %ebx
  8013b9:	03 45 0c             	add    0xc(%ebp),%eax
  8013bc:	50                   	push   %eax
  8013bd:	57                   	push   %edi
  8013be:	e8 97 09 00 00       	call   801d5a <memmove>
		sys_cputs(buf, m);
  8013c3:	83 c4 08             	add    $0x8,%esp
  8013c6:	53                   	push   %ebx
  8013c7:	57                   	push   %edi
  8013c8:	e8 e1 ec ff ff       	call   8000ae <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013cd:	01 de                	add    %ebx,%esi
  8013cf:	83 c4 10             	add    $0x10,%esp
  8013d2:	89 f0                	mov    %esi,%eax
  8013d4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013d7:	72 cc                	jb     8013a5 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013dc:	5b                   	pop    %ebx
  8013dd:	5e                   	pop    %esi
  8013de:	5f                   	pop    %edi
  8013df:	5d                   	pop    %ebp
  8013e0:	c3                   	ret    

008013e1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013e1:	55                   	push   %ebp
  8013e2:	89 e5                	mov    %esp,%ebp
  8013e4:	83 ec 08             	sub    $0x8,%esp
  8013e7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013ec:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013f0:	74 2a                	je     80141c <devcons_read+0x3b>
  8013f2:	eb 05                	jmp    8013f9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013f4:	e8 52 ed ff ff       	call   80014b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013f9:	e8 ce ec ff ff       	call   8000cc <sys_cgetc>
  8013fe:	85 c0                	test   %eax,%eax
  801400:	74 f2                	je     8013f4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801402:	85 c0                	test   %eax,%eax
  801404:	78 16                	js     80141c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801406:	83 f8 04             	cmp    $0x4,%eax
  801409:	74 0c                	je     801417 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80140b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80140e:	88 02                	mov    %al,(%edx)
	return 1;
  801410:	b8 01 00 00 00       	mov    $0x1,%eax
  801415:	eb 05                	jmp    80141c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801417:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80141c:	c9                   	leave  
  80141d:	c3                   	ret    

0080141e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801424:	8b 45 08             	mov    0x8(%ebp),%eax
  801427:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80142a:	6a 01                	push   $0x1
  80142c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80142f:	50                   	push   %eax
  801430:	e8 79 ec ff ff       	call   8000ae <sys_cputs>
}
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	c9                   	leave  
  801439:	c3                   	ret    

0080143a <getchar>:

int
getchar(void)
{
  80143a:	55                   	push   %ebp
  80143b:	89 e5                	mov    %esp,%ebp
  80143d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801440:	6a 01                	push   $0x1
  801442:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801445:	50                   	push   %eax
  801446:	6a 00                	push   $0x0
  801448:	e8 29 f2 ff ff       	call   800676 <read>
	if (r < 0)
  80144d:	83 c4 10             	add    $0x10,%esp
  801450:	85 c0                	test   %eax,%eax
  801452:	78 0f                	js     801463 <getchar+0x29>
		return r;
	if (r < 1)
  801454:	85 c0                	test   %eax,%eax
  801456:	7e 06                	jle    80145e <getchar+0x24>
		return -E_EOF;
	return c;
  801458:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80145c:	eb 05                	jmp    801463 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80145e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801463:	c9                   	leave  
  801464:	c3                   	ret    

00801465 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801465:	55                   	push   %ebp
  801466:	89 e5                	mov    %esp,%ebp
  801468:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80146b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146e:	50                   	push   %eax
  80146f:	ff 75 08             	pushl  0x8(%ebp)
  801472:	e8 99 ef ff ff       	call   800410 <fd_lookup>
  801477:	83 c4 10             	add    $0x10,%esp
  80147a:	85 c0                	test   %eax,%eax
  80147c:	78 11                	js     80148f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80147e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801481:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  801487:	39 10                	cmp    %edx,(%eax)
  801489:	0f 94 c0             	sete   %al
  80148c:	0f b6 c0             	movzbl %al,%eax
}
  80148f:	c9                   	leave  
  801490:	c3                   	ret    

00801491 <opencons>:

int
opencons(void)
{
  801491:	55                   	push   %ebp
  801492:	89 e5                	mov    %esp,%ebp
  801494:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801497:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149a:	50                   	push   %eax
  80149b:	e8 21 ef ff ff       	call   8003c1 <fd_alloc>
  8014a0:	83 c4 10             	add    $0x10,%esp
		return r;
  8014a3:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	78 3e                	js     8014e7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014a9:	83 ec 04             	sub    $0x4,%esp
  8014ac:	68 07 04 00 00       	push   $0x407
  8014b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8014b4:	6a 00                	push   $0x0
  8014b6:	e8 af ec ff ff       	call   80016a <sys_page_alloc>
  8014bb:	83 c4 10             	add    $0x10,%esp
		return r;
  8014be:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014c0:	85 c0                	test   %eax,%eax
  8014c2:	78 23                	js     8014e7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014c4:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8014ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014cd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014d9:	83 ec 0c             	sub    $0xc,%esp
  8014dc:	50                   	push   %eax
  8014dd:	e8 b8 ee ff ff       	call   80039a <fd2num>
  8014e2:	89 c2                	mov    %eax,%edx
  8014e4:	83 c4 10             	add    $0x10,%esp
}
  8014e7:	89 d0                	mov    %edx,%eax
  8014e9:	c9                   	leave  
  8014ea:	c3                   	ret    

008014eb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014eb:	55                   	push   %ebp
  8014ec:	89 e5                	mov    %esp,%ebp
  8014ee:	56                   	push   %esi
  8014ef:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014f0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014f3:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8014f9:	e8 2e ec ff ff       	call   80012c <sys_getenvid>
  8014fe:	83 ec 0c             	sub    $0xc,%esp
  801501:	ff 75 0c             	pushl  0xc(%ebp)
  801504:	ff 75 08             	pushl  0x8(%ebp)
  801507:	56                   	push   %esi
  801508:	50                   	push   %eax
  801509:	68 4c 24 80 00       	push   $0x80244c
  80150e:	e8 b1 00 00 00       	call   8015c4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801513:	83 c4 18             	add    $0x18,%esp
  801516:	53                   	push   %ebx
  801517:	ff 75 10             	pushl  0x10(%ebp)
  80151a:	e8 54 00 00 00       	call   801573 <vcprintf>
	cprintf("\n");
  80151f:	c7 04 24 38 24 80 00 	movl   $0x802438,(%esp)
  801526:	e8 99 00 00 00       	call   8015c4 <cprintf>
  80152b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80152e:	cc                   	int3   
  80152f:	eb fd                	jmp    80152e <_panic+0x43>

00801531 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801531:	55                   	push   %ebp
  801532:	89 e5                	mov    %esp,%ebp
  801534:	53                   	push   %ebx
  801535:	83 ec 04             	sub    $0x4,%esp
  801538:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80153b:	8b 13                	mov    (%ebx),%edx
  80153d:	8d 42 01             	lea    0x1(%edx),%eax
  801540:	89 03                	mov    %eax,(%ebx)
  801542:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801545:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801549:	3d ff 00 00 00       	cmp    $0xff,%eax
  80154e:	75 1a                	jne    80156a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801550:	83 ec 08             	sub    $0x8,%esp
  801553:	68 ff 00 00 00       	push   $0xff
  801558:	8d 43 08             	lea    0x8(%ebx),%eax
  80155b:	50                   	push   %eax
  80155c:	e8 4d eb ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  801561:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801567:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80156a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80156e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801571:	c9                   	leave  
  801572:	c3                   	ret    

00801573 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801573:	55                   	push   %ebp
  801574:	89 e5                	mov    %esp,%ebp
  801576:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80157c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801583:	00 00 00 
	b.cnt = 0;
  801586:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80158d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801590:	ff 75 0c             	pushl  0xc(%ebp)
  801593:	ff 75 08             	pushl  0x8(%ebp)
  801596:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80159c:	50                   	push   %eax
  80159d:	68 31 15 80 00       	push   $0x801531
  8015a2:	e8 1a 01 00 00       	call   8016c1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015a7:	83 c4 08             	add    $0x8,%esp
  8015aa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015b0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015b6:	50                   	push   %eax
  8015b7:	e8 f2 ea ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  8015bc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015c2:	c9                   	leave  
  8015c3:	c3                   	ret    

008015c4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015c4:	55                   	push   %ebp
  8015c5:	89 e5                	mov    %esp,%ebp
  8015c7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015ca:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015cd:	50                   	push   %eax
  8015ce:	ff 75 08             	pushl  0x8(%ebp)
  8015d1:	e8 9d ff ff ff       	call   801573 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015d6:	c9                   	leave  
  8015d7:	c3                   	ret    

008015d8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015d8:	55                   	push   %ebp
  8015d9:	89 e5                	mov    %esp,%ebp
  8015db:	57                   	push   %edi
  8015dc:	56                   	push   %esi
  8015dd:	53                   	push   %ebx
  8015de:	83 ec 1c             	sub    $0x1c,%esp
  8015e1:	89 c7                	mov    %eax,%edi
  8015e3:	89 d6                	mov    %edx,%esi
  8015e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015ee:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015f9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015fc:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015ff:	39 d3                	cmp    %edx,%ebx
  801601:	72 05                	jb     801608 <printnum+0x30>
  801603:	39 45 10             	cmp    %eax,0x10(%ebp)
  801606:	77 45                	ja     80164d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801608:	83 ec 0c             	sub    $0xc,%esp
  80160b:	ff 75 18             	pushl  0x18(%ebp)
  80160e:	8b 45 14             	mov    0x14(%ebp),%eax
  801611:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801614:	53                   	push   %ebx
  801615:	ff 75 10             	pushl  0x10(%ebp)
  801618:	83 ec 08             	sub    $0x8,%esp
  80161b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80161e:	ff 75 e0             	pushl  -0x20(%ebp)
  801621:	ff 75 dc             	pushl  -0x24(%ebp)
  801624:	ff 75 d8             	pushl  -0x28(%ebp)
  801627:	e8 14 0a 00 00       	call   802040 <__udivdi3>
  80162c:	83 c4 18             	add    $0x18,%esp
  80162f:	52                   	push   %edx
  801630:	50                   	push   %eax
  801631:	89 f2                	mov    %esi,%edx
  801633:	89 f8                	mov    %edi,%eax
  801635:	e8 9e ff ff ff       	call   8015d8 <printnum>
  80163a:	83 c4 20             	add    $0x20,%esp
  80163d:	eb 18                	jmp    801657 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80163f:	83 ec 08             	sub    $0x8,%esp
  801642:	56                   	push   %esi
  801643:	ff 75 18             	pushl  0x18(%ebp)
  801646:	ff d7                	call   *%edi
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	eb 03                	jmp    801650 <printnum+0x78>
  80164d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801650:	83 eb 01             	sub    $0x1,%ebx
  801653:	85 db                	test   %ebx,%ebx
  801655:	7f e8                	jg     80163f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801657:	83 ec 08             	sub    $0x8,%esp
  80165a:	56                   	push   %esi
  80165b:	83 ec 04             	sub    $0x4,%esp
  80165e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801661:	ff 75 e0             	pushl  -0x20(%ebp)
  801664:	ff 75 dc             	pushl  -0x24(%ebp)
  801667:	ff 75 d8             	pushl  -0x28(%ebp)
  80166a:	e8 01 0b 00 00       	call   802170 <__umoddi3>
  80166f:	83 c4 14             	add    $0x14,%esp
  801672:	0f be 80 6f 24 80 00 	movsbl 0x80246f(%eax),%eax
  801679:	50                   	push   %eax
  80167a:	ff d7                	call   *%edi
}
  80167c:	83 c4 10             	add    $0x10,%esp
  80167f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801682:	5b                   	pop    %ebx
  801683:	5e                   	pop    %esi
  801684:	5f                   	pop    %edi
  801685:	5d                   	pop    %ebp
  801686:	c3                   	ret    

00801687 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80168d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801691:	8b 10                	mov    (%eax),%edx
  801693:	3b 50 04             	cmp    0x4(%eax),%edx
  801696:	73 0a                	jae    8016a2 <sprintputch+0x1b>
		*b->buf++ = ch;
  801698:	8d 4a 01             	lea    0x1(%edx),%ecx
  80169b:	89 08                	mov    %ecx,(%eax)
  80169d:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a0:	88 02                	mov    %al,(%edx)
}
  8016a2:	5d                   	pop    %ebp
  8016a3:	c3                   	ret    

008016a4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
  8016a7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016aa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016ad:	50                   	push   %eax
  8016ae:	ff 75 10             	pushl  0x10(%ebp)
  8016b1:	ff 75 0c             	pushl  0xc(%ebp)
  8016b4:	ff 75 08             	pushl  0x8(%ebp)
  8016b7:	e8 05 00 00 00       	call   8016c1 <vprintfmt>
	va_end(ap);
}
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	c9                   	leave  
  8016c0:	c3                   	ret    

008016c1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	57                   	push   %edi
  8016c5:	56                   	push   %esi
  8016c6:	53                   	push   %ebx
  8016c7:	83 ec 2c             	sub    $0x2c,%esp
  8016ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8016cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016d0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016d3:	eb 12                	jmp    8016e7 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016d5:	85 c0                	test   %eax,%eax
  8016d7:	0f 84 42 04 00 00    	je     801b1f <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8016dd:	83 ec 08             	sub    $0x8,%esp
  8016e0:	53                   	push   %ebx
  8016e1:	50                   	push   %eax
  8016e2:	ff d6                	call   *%esi
  8016e4:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016e7:	83 c7 01             	add    $0x1,%edi
  8016ea:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016ee:	83 f8 25             	cmp    $0x25,%eax
  8016f1:	75 e2                	jne    8016d5 <vprintfmt+0x14>
  8016f3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8016f7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8016fe:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801705:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80170c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801711:	eb 07                	jmp    80171a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801713:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801716:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80171a:	8d 47 01             	lea    0x1(%edi),%eax
  80171d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801720:	0f b6 07             	movzbl (%edi),%eax
  801723:	0f b6 d0             	movzbl %al,%edx
  801726:	83 e8 23             	sub    $0x23,%eax
  801729:	3c 55                	cmp    $0x55,%al
  80172b:	0f 87 d3 03 00 00    	ja     801b04 <vprintfmt+0x443>
  801731:	0f b6 c0             	movzbl %al,%eax
  801734:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  80173b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80173e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801742:	eb d6                	jmp    80171a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801744:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801747:	b8 00 00 00 00       	mov    $0x0,%eax
  80174c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80174f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801752:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801756:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801759:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80175c:	83 f9 09             	cmp    $0x9,%ecx
  80175f:	77 3f                	ja     8017a0 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801761:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801764:	eb e9                	jmp    80174f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801766:	8b 45 14             	mov    0x14(%ebp),%eax
  801769:	8b 00                	mov    (%eax),%eax
  80176b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80176e:	8b 45 14             	mov    0x14(%ebp),%eax
  801771:	8d 40 04             	lea    0x4(%eax),%eax
  801774:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801777:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80177a:	eb 2a                	jmp    8017a6 <vprintfmt+0xe5>
  80177c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80177f:	85 c0                	test   %eax,%eax
  801781:	ba 00 00 00 00       	mov    $0x0,%edx
  801786:	0f 49 d0             	cmovns %eax,%edx
  801789:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80178c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80178f:	eb 89                	jmp    80171a <vprintfmt+0x59>
  801791:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801794:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80179b:	e9 7a ff ff ff       	jmp    80171a <vprintfmt+0x59>
  8017a0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8017a3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017a6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017aa:	0f 89 6a ff ff ff    	jns    80171a <vprintfmt+0x59>
				width = precision, precision = -1;
  8017b0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017b6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017bd:	e9 58 ff ff ff       	jmp    80171a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017c2:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017c8:	e9 4d ff ff ff       	jmp    80171a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8017d0:	8d 78 04             	lea    0x4(%eax),%edi
  8017d3:	83 ec 08             	sub    $0x8,%esp
  8017d6:	53                   	push   %ebx
  8017d7:	ff 30                	pushl  (%eax)
  8017d9:	ff d6                	call   *%esi
			break;
  8017db:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017de:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8017e4:	e9 fe fe ff ff       	jmp    8016e7 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8017e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ec:	8d 78 04             	lea    0x4(%eax),%edi
  8017ef:	8b 00                	mov    (%eax),%eax
  8017f1:	99                   	cltd   
  8017f2:	31 d0                	xor    %edx,%eax
  8017f4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017f6:	83 f8 0f             	cmp    $0xf,%eax
  8017f9:	7f 0b                	jg     801806 <vprintfmt+0x145>
  8017fb:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  801802:	85 d2                	test   %edx,%edx
  801804:	75 1b                	jne    801821 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  801806:	50                   	push   %eax
  801807:	68 87 24 80 00       	push   $0x802487
  80180c:	53                   	push   %ebx
  80180d:	56                   	push   %esi
  80180e:	e8 91 fe ff ff       	call   8016a4 <printfmt>
  801813:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801816:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801819:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80181c:	e9 c6 fe ff ff       	jmp    8016e7 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801821:	52                   	push   %edx
  801822:	68 cd 23 80 00       	push   $0x8023cd
  801827:	53                   	push   %ebx
  801828:	56                   	push   %esi
  801829:	e8 76 fe ff ff       	call   8016a4 <printfmt>
  80182e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801831:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801834:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801837:	e9 ab fe ff ff       	jmp    8016e7 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80183c:	8b 45 14             	mov    0x14(%ebp),%eax
  80183f:	83 c0 04             	add    $0x4,%eax
  801842:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801845:	8b 45 14             	mov    0x14(%ebp),%eax
  801848:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80184a:	85 ff                	test   %edi,%edi
  80184c:	b8 80 24 80 00       	mov    $0x802480,%eax
  801851:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801854:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801858:	0f 8e 94 00 00 00    	jle    8018f2 <vprintfmt+0x231>
  80185e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801862:	0f 84 98 00 00 00    	je     801900 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  801868:	83 ec 08             	sub    $0x8,%esp
  80186b:	ff 75 d0             	pushl  -0x30(%ebp)
  80186e:	57                   	push   %edi
  80186f:	e8 33 03 00 00       	call   801ba7 <strnlen>
  801874:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801877:	29 c1                	sub    %eax,%ecx
  801879:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80187c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80187f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801883:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801886:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801889:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80188b:	eb 0f                	jmp    80189c <vprintfmt+0x1db>
					putch(padc, putdat);
  80188d:	83 ec 08             	sub    $0x8,%esp
  801890:	53                   	push   %ebx
  801891:	ff 75 e0             	pushl  -0x20(%ebp)
  801894:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801896:	83 ef 01             	sub    $0x1,%edi
  801899:	83 c4 10             	add    $0x10,%esp
  80189c:	85 ff                	test   %edi,%edi
  80189e:	7f ed                	jg     80188d <vprintfmt+0x1cc>
  8018a0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018a3:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8018a6:	85 c9                	test   %ecx,%ecx
  8018a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ad:	0f 49 c1             	cmovns %ecx,%eax
  8018b0:	29 c1                	sub    %eax,%ecx
  8018b2:	89 75 08             	mov    %esi,0x8(%ebp)
  8018b5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018b8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018bb:	89 cb                	mov    %ecx,%ebx
  8018bd:	eb 4d                	jmp    80190c <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018bf:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018c3:	74 1b                	je     8018e0 <vprintfmt+0x21f>
  8018c5:	0f be c0             	movsbl %al,%eax
  8018c8:	83 e8 20             	sub    $0x20,%eax
  8018cb:	83 f8 5e             	cmp    $0x5e,%eax
  8018ce:	76 10                	jbe    8018e0 <vprintfmt+0x21f>
					putch('?', putdat);
  8018d0:	83 ec 08             	sub    $0x8,%esp
  8018d3:	ff 75 0c             	pushl  0xc(%ebp)
  8018d6:	6a 3f                	push   $0x3f
  8018d8:	ff 55 08             	call   *0x8(%ebp)
  8018db:	83 c4 10             	add    $0x10,%esp
  8018de:	eb 0d                	jmp    8018ed <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8018e0:	83 ec 08             	sub    $0x8,%esp
  8018e3:	ff 75 0c             	pushl  0xc(%ebp)
  8018e6:	52                   	push   %edx
  8018e7:	ff 55 08             	call   *0x8(%ebp)
  8018ea:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018ed:	83 eb 01             	sub    $0x1,%ebx
  8018f0:	eb 1a                	jmp    80190c <vprintfmt+0x24b>
  8018f2:	89 75 08             	mov    %esi,0x8(%ebp)
  8018f5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018f8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018fb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018fe:	eb 0c                	jmp    80190c <vprintfmt+0x24b>
  801900:	89 75 08             	mov    %esi,0x8(%ebp)
  801903:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801906:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801909:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80190c:	83 c7 01             	add    $0x1,%edi
  80190f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801913:	0f be d0             	movsbl %al,%edx
  801916:	85 d2                	test   %edx,%edx
  801918:	74 23                	je     80193d <vprintfmt+0x27c>
  80191a:	85 f6                	test   %esi,%esi
  80191c:	78 a1                	js     8018bf <vprintfmt+0x1fe>
  80191e:	83 ee 01             	sub    $0x1,%esi
  801921:	79 9c                	jns    8018bf <vprintfmt+0x1fe>
  801923:	89 df                	mov    %ebx,%edi
  801925:	8b 75 08             	mov    0x8(%ebp),%esi
  801928:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80192b:	eb 18                	jmp    801945 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80192d:	83 ec 08             	sub    $0x8,%esp
  801930:	53                   	push   %ebx
  801931:	6a 20                	push   $0x20
  801933:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801935:	83 ef 01             	sub    $0x1,%edi
  801938:	83 c4 10             	add    $0x10,%esp
  80193b:	eb 08                	jmp    801945 <vprintfmt+0x284>
  80193d:	89 df                	mov    %ebx,%edi
  80193f:	8b 75 08             	mov    0x8(%ebp),%esi
  801942:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801945:	85 ff                	test   %edi,%edi
  801947:	7f e4                	jg     80192d <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801949:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80194c:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80194f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801952:	e9 90 fd ff ff       	jmp    8016e7 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801957:	83 f9 01             	cmp    $0x1,%ecx
  80195a:	7e 19                	jle    801975 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80195c:	8b 45 14             	mov    0x14(%ebp),%eax
  80195f:	8b 50 04             	mov    0x4(%eax),%edx
  801962:	8b 00                	mov    (%eax),%eax
  801964:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801967:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80196a:	8b 45 14             	mov    0x14(%ebp),%eax
  80196d:	8d 40 08             	lea    0x8(%eax),%eax
  801970:	89 45 14             	mov    %eax,0x14(%ebp)
  801973:	eb 38                	jmp    8019ad <vprintfmt+0x2ec>
	else if (lflag)
  801975:	85 c9                	test   %ecx,%ecx
  801977:	74 1b                	je     801994 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  801979:	8b 45 14             	mov    0x14(%ebp),%eax
  80197c:	8b 00                	mov    (%eax),%eax
  80197e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801981:	89 c1                	mov    %eax,%ecx
  801983:	c1 f9 1f             	sar    $0x1f,%ecx
  801986:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801989:	8b 45 14             	mov    0x14(%ebp),%eax
  80198c:	8d 40 04             	lea    0x4(%eax),%eax
  80198f:	89 45 14             	mov    %eax,0x14(%ebp)
  801992:	eb 19                	jmp    8019ad <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  801994:	8b 45 14             	mov    0x14(%ebp),%eax
  801997:	8b 00                	mov    (%eax),%eax
  801999:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80199c:	89 c1                	mov    %eax,%ecx
  80199e:	c1 f9 1f             	sar    $0x1f,%ecx
  8019a1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a7:	8d 40 04             	lea    0x4(%eax),%eax
  8019aa:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019ad:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8019b0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019b3:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019b8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019bc:	0f 89 0e 01 00 00    	jns    801ad0 <vprintfmt+0x40f>
				putch('-', putdat);
  8019c2:	83 ec 08             	sub    $0x8,%esp
  8019c5:	53                   	push   %ebx
  8019c6:	6a 2d                	push   $0x2d
  8019c8:	ff d6                	call   *%esi
				num = -(long long) num;
  8019ca:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8019cd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8019d0:	f7 da                	neg    %edx
  8019d2:	83 d1 00             	adc    $0x0,%ecx
  8019d5:	f7 d9                	neg    %ecx
  8019d7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8019df:	e9 ec 00 00 00       	jmp    801ad0 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8019e4:	83 f9 01             	cmp    $0x1,%ecx
  8019e7:	7e 18                	jle    801a01 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8019e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ec:	8b 10                	mov    (%eax),%edx
  8019ee:	8b 48 04             	mov    0x4(%eax),%ecx
  8019f1:	8d 40 08             	lea    0x8(%eax),%eax
  8019f4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8019f7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8019fc:	e9 cf 00 00 00       	jmp    801ad0 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801a01:	85 c9                	test   %ecx,%ecx
  801a03:	74 1a                	je     801a1f <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  801a05:	8b 45 14             	mov    0x14(%ebp),%eax
  801a08:	8b 10                	mov    (%eax),%edx
  801a0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a0f:	8d 40 04             	lea    0x4(%eax),%eax
  801a12:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801a15:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a1a:	e9 b1 00 00 00       	jmp    801ad0 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801a1f:	8b 45 14             	mov    0x14(%ebp),%eax
  801a22:	8b 10                	mov    (%eax),%edx
  801a24:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a29:	8d 40 04             	lea    0x4(%eax),%eax
  801a2c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801a2f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a34:	e9 97 00 00 00       	jmp    801ad0 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801a39:	83 ec 08             	sub    $0x8,%esp
  801a3c:	53                   	push   %ebx
  801a3d:	6a 58                	push   $0x58
  801a3f:	ff d6                	call   *%esi
			putch('X', putdat);
  801a41:	83 c4 08             	add    $0x8,%esp
  801a44:	53                   	push   %ebx
  801a45:	6a 58                	push   $0x58
  801a47:	ff d6                	call   *%esi
			putch('X', putdat);
  801a49:	83 c4 08             	add    $0x8,%esp
  801a4c:	53                   	push   %ebx
  801a4d:	6a 58                	push   $0x58
  801a4f:	ff d6                	call   *%esi
			break;
  801a51:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a54:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  801a57:	e9 8b fc ff ff       	jmp    8016e7 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  801a5c:	83 ec 08             	sub    $0x8,%esp
  801a5f:	53                   	push   %ebx
  801a60:	6a 30                	push   $0x30
  801a62:	ff d6                	call   *%esi
			putch('x', putdat);
  801a64:	83 c4 08             	add    $0x8,%esp
  801a67:	53                   	push   %ebx
  801a68:	6a 78                	push   $0x78
  801a6a:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a6c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a6f:	8b 10                	mov    (%eax),%edx
  801a71:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a76:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a79:	8d 40 04             	lea    0x4(%eax),%eax
  801a7c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a7f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801a84:	eb 4a                	jmp    801ad0 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a86:	83 f9 01             	cmp    $0x1,%ecx
  801a89:	7e 15                	jle    801aa0 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  801a8b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a8e:	8b 10                	mov    (%eax),%edx
  801a90:	8b 48 04             	mov    0x4(%eax),%ecx
  801a93:	8d 40 08             	lea    0x8(%eax),%eax
  801a96:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801a99:	b8 10 00 00 00       	mov    $0x10,%eax
  801a9e:	eb 30                	jmp    801ad0 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801aa0:	85 c9                	test   %ecx,%ecx
  801aa2:	74 17                	je     801abb <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  801aa4:	8b 45 14             	mov    0x14(%ebp),%eax
  801aa7:	8b 10                	mov    (%eax),%edx
  801aa9:	b9 00 00 00 00       	mov    $0x0,%ecx
  801aae:	8d 40 04             	lea    0x4(%eax),%eax
  801ab1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801ab4:	b8 10 00 00 00       	mov    $0x10,%eax
  801ab9:	eb 15                	jmp    801ad0 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801abb:	8b 45 14             	mov    0x14(%ebp),%eax
  801abe:	8b 10                	mov    (%eax),%edx
  801ac0:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ac5:	8d 40 04             	lea    0x4(%eax),%eax
  801ac8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801acb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801ad0:	83 ec 0c             	sub    $0xc,%esp
  801ad3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801ad7:	57                   	push   %edi
  801ad8:	ff 75 e0             	pushl  -0x20(%ebp)
  801adb:	50                   	push   %eax
  801adc:	51                   	push   %ecx
  801add:	52                   	push   %edx
  801ade:	89 da                	mov    %ebx,%edx
  801ae0:	89 f0                	mov    %esi,%eax
  801ae2:	e8 f1 fa ff ff       	call   8015d8 <printnum>
			break;
  801ae7:	83 c4 20             	add    $0x20,%esp
  801aea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801aed:	e9 f5 fb ff ff       	jmp    8016e7 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801af2:	83 ec 08             	sub    $0x8,%esp
  801af5:	53                   	push   %ebx
  801af6:	52                   	push   %edx
  801af7:	ff d6                	call   *%esi
			break;
  801af9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801afc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801aff:	e9 e3 fb ff ff       	jmp    8016e7 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b04:	83 ec 08             	sub    $0x8,%esp
  801b07:	53                   	push   %ebx
  801b08:	6a 25                	push   $0x25
  801b0a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b0c:	83 c4 10             	add    $0x10,%esp
  801b0f:	eb 03                	jmp    801b14 <vprintfmt+0x453>
  801b11:	83 ef 01             	sub    $0x1,%edi
  801b14:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b18:	75 f7                	jne    801b11 <vprintfmt+0x450>
  801b1a:	e9 c8 fb ff ff       	jmp    8016e7 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b22:	5b                   	pop    %ebx
  801b23:	5e                   	pop    %esi
  801b24:	5f                   	pop    %edi
  801b25:	5d                   	pop    %ebp
  801b26:	c3                   	ret    

00801b27 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	83 ec 18             	sub    $0x18,%esp
  801b2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b30:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b33:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b36:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b3a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b3d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b44:	85 c0                	test   %eax,%eax
  801b46:	74 26                	je     801b6e <vsnprintf+0x47>
  801b48:	85 d2                	test   %edx,%edx
  801b4a:	7e 22                	jle    801b6e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b4c:	ff 75 14             	pushl  0x14(%ebp)
  801b4f:	ff 75 10             	pushl  0x10(%ebp)
  801b52:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b55:	50                   	push   %eax
  801b56:	68 87 16 80 00       	push   $0x801687
  801b5b:	e8 61 fb ff ff       	call   8016c1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b60:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b63:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b69:	83 c4 10             	add    $0x10,%esp
  801b6c:	eb 05                	jmp    801b73 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b6e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b73:	c9                   	leave  
  801b74:	c3                   	ret    

00801b75 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b7b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b7e:	50                   	push   %eax
  801b7f:	ff 75 10             	pushl  0x10(%ebp)
  801b82:	ff 75 0c             	pushl  0xc(%ebp)
  801b85:	ff 75 08             	pushl  0x8(%ebp)
  801b88:	e8 9a ff ff ff       	call   801b27 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b8d:	c9                   	leave  
  801b8e:	c3                   	ret    

00801b8f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b8f:	55                   	push   %ebp
  801b90:	89 e5                	mov    %esp,%ebp
  801b92:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b95:	b8 00 00 00 00       	mov    $0x0,%eax
  801b9a:	eb 03                	jmp    801b9f <strlen+0x10>
		n++;
  801b9c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b9f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801ba3:	75 f7                	jne    801b9c <strlen+0xd>
		n++;
	return n;
}
  801ba5:	5d                   	pop    %ebp
  801ba6:	c3                   	ret    

00801ba7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801ba7:	55                   	push   %ebp
  801ba8:	89 e5                	mov    %esp,%ebp
  801baa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bad:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bb0:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb5:	eb 03                	jmp    801bba <strnlen+0x13>
		n++;
  801bb7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bba:	39 c2                	cmp    %eax,%edx
  801bbc:	74 08                	je     801bc6 <strnlen+0x1f>
  801bbe:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801bc2:	75 f3                	jne    801bb7 <strnlen+0x10>
  801bc4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801bc6:	5d                   	pop    %ebp
  801bc7:	c3                   	ret    

00801bc8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801bc8:	55                   	push   %ebp
  801bc9:	89 e5                	mov    %esp,%ebp
  801bcb:	53                   	push   %ebx
  801bcc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801bd2:	89 c2                	mov    %eax,%edx
  801bd4:	83 c2 01             	add    $0x1,%edx
  801bd7:	83 c1 01             	add    $0x1,%ecx
  801bda:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801bde:	88 5a ff             	mov    %bl,-0x1(%edx)
  801be1:	84 db                	test   %bl,%bl
  801be3:	75 ef                	jne    801bd4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801be5:	5b                   	pop    %ebx
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    

00801be8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801be8:	55                   	push   %ebp
  801be9:	89 e5                	mov    %esp,%ebp
  801beb:	53                   	push   %ebx
  801bec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801bef:	53                   	push   %ebx
  801bf0:	e8 9a ff ff ff       	call   801b8f <strlen>
  801bf5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801bf8:	ff 75 0c             	pushl  0xc(%ebp)
  801bfb:	01 d8                	add    %ebx,%eax
  801bfd:	50                   	push   %eax
  801bfe:	e8 c5 ff ff ff       	call   801bc8 <strcpy>
	return dst;
}
  801c03:	89 d8                	mov    %ebx,%eax
  801c05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c08:	c9                   	leave  
  801c09:	c3                   	ret    

00801c0a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c0a:	55                   	push   %ebp
  801c0b:	89 e5                	mov    %esp,%ebp
  801c0d:	56                   	push   %esi
  801c0e:	53                   	push   %ebx
  801c0f:	8b 75 08             	mov    0x8(%ebp),%esi
  801c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c15:	89 f3                	mov    %esi,%ebx
  801c17:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c1a:	89 f2                	mov    %esi,%edx
  801c1c:	eb 0f                	jmp    801c2d <strncpy+0x23>
		*dst++ = *src;
  801c1e:	83 c2 01             	add    $0x1,%edx
  801c21:	0f b6 01             	movzbl (%ecx),%eax
  801c24:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c27:	80 39 01             	cmpb   $0x1,(%ecx)
  801c2a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c2d:	39 da                	cmp    %ebx,%edx
  801c2f:	75 ed                	jne    801c1e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c31:	89 f0                	mov    %esi,%eax
  801c33:	5b                   	pop    %ebx
  801c34:	5e                   	pop    %esi
  801c35:	5d                   	pop    %ebp
  801c36:	c3                   	ret    

00801c37 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c37:	55                   	push   %ebp
  801c38:	89 e5                	mov    %esp,%ebp
  801c3a:	56                   	push   %esi
  801c3b:	53                   	push   %ebx
  801c3c:	8b 75 08             	mov    0x8(%ebp),%esi
  801c3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c42:	8b 55 10             	mov    0x10(%ebp),%edx
  801c45:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c47:	85 d2                	test   %edx,%edx
  801c49:	74 21                	je     801c6c <strlcpy+0x35>
  801c4b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c4f:	89 f2                	mov    %esi,%edx
  801c51:	eb 09                	jmp    801c5c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c53:	83 c2 01             	add    $0x1,%edx
  801c56:	83 c1 01             	add    $0x1,%ecx
  801c59:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c5c:	39 c2                	cmp    %eax,%edx
  801c5e:	74 09                	je     801c69 <strlcpy+0x32>
  801c60:	0f b6 19             	movzbl (%ecx),%ebx
  801c63:	84 db                	test   %bl,%bl
  801c65:	75 ec                	jne    801c53 <strlcpy+0x1c>
  801c67:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c69:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c6c:	29 f0                	sub    %esi,%eax
}
  801c6e:	5b                   	pop    %ebx
  801c6f:	5e                   	pop    %esi
  801c70:	5d                   	pop    %ebp
  801c71:	c3                   	ret    

00801c72 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c72:	55                   	push   %ebp
  801c73:	89 e5                	mov    %esp,%ebp
  801c75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c78:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c7b:	eb 06                	jmp    801c83 <strcmp+0x11>
		p++, q++;
  801c7d:	83 c1 01             	add    $0x1,%ecx
  801c80:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c83:	0f b6 01             	movzbl (%ecx),%eax
  801c86:	84 c0                	test   %al,%al
  801c88:	74 04                	je     801c8e <strcmp+0x1c>
  801c8a:	3a 02                	cmp    (%edx),%al
  801c8c:	74 ef                	je     801c7d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c8e:	0f b6 c0             	movzbl %al,%eax
  801c91:	0f b6 12             	movzbl (%edx),%edx
  801c94:	29 d0                	sub    %edx,%eax
}
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    

00801c98 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c98:	55                   	push   %ebp
  801c99:	89 e5                	mov    %esp,%ebp
  801c9b:	53                   	push   %ebx
  801c9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ca2:	89 c3                	mov    %eax,%ebx
  801ca4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801ca7:	eb 06                	jmp    801caf <strncmp+0x17>
		n--, p++, q++;
  801ca9:	83 c0 01             	add    $0x1,%eax
  801cac:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801caf:	39 d8                	cmp    %ebx,%eax
  801cb1:	74 15                	je     801cc8 <strncmp+0x30>
  801cb3:	0f b6 08             	movzbl (%eax),%ecx
  801cb6:	84 c9                	test   %cl,%cl
  801cb8:	74 04                	je     801cbe <strncmp+0x26>
  801cba:	3a 0a                	cmp    (%edx),%cl
  801cbc:	74 eb                	je     801ca9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801cbe:	0f b6 00             	movzbl (%eax),%eax
  801cc1:	0f b6 12             	movzbl (%edx),%edx
  801cc4:	29 d0                	sub    %edx,%eax
  801cc6:	eb 05                	jmp    801ccd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801cc8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801ccd:	5b                   	pop    %ebx
  801cce:	5d                   	pop    %ebp
  801ccf:	c3                   	ret    

00801cd0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cda:	eb 07                	jmp    801ce3 <strchr+0x13>
		if (*s == c)
  801cdc:	38 ca                	cmp    %cl,%dl
  801cde:	74 0f                	je     801cef <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801ce0:	83 c0 01             	add    $0x1,%eax
  801ce3:	0f b6 10             	movzbl (%eax),%edx
  801ce6:	84 d2                	test   %dl,%dl
  801ce8:	75 f2                	jne    801cdc <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801cea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cef:	5d                   	pop    %ebp
  801cf0:	c3                   	ret    

00801cf1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cf1:	55                   	push   %ebp
  801cf2:	89 e5                	mov    %esp,%ebp
  801cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cfb:	eb 03                	jmp    801d00 <strfind+0xf>
  801cfd:	83 c0 01             	add    $0x1,%eax
  801d00:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d03:	38 ca                	cmp    %cl,%dl
  801d05:	74 04                	je     801d0b <strfind+0x1a>
  801d07:	84 d2                	test   %dl,%dl
  801d09:	75 f2                	jne    801cfd <strfind+0xc>
			break;
	return (char *) s;
}
  801d0b:	5d                   	pop    %ebp
  801d0c:	c3                   	ret    

00801d0d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d0d:	55                   	push   %ebp
  801d0e:	89 e5                	mov    %esp,%ebp
  801d10:	57                   	push   %edi
  801d11:	56                   	push   %esi
  801d12:	53                   	push   %ebx
  801d13:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d16:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d19:	85 c9                	test   %ecx,%ecx
  801d1b:	74 36                	je     801d53 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d1d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d23:	75 28                	jne    801d4d <memset+0x40>
  801d25:	f6 c1 03             	test   $0x3,%cl
  801d28:	75 23                	jne    801d4d <memset+0x40>
		c &= 0xFF;
  801d2a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d2e:	89 d3                	mov    %edx,%ebx
  801d30:	c1 e3 08             	shl    $0x8,%ebx
  801d33:	89 d6                	mov    %edx,%esi
  801d35:	c1 e6 18             	shl    $0x18,%esi
  801d38:	89 d0                	mov    %edx,%eax
  801d3a:	c1 e0 10             	shl    $0x10,%eax
  801d3d:	09 f0                	or     %esi,%eax
  801d3f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d41:	89 d8                	mov    %ebx,%eax
  801d43:	09 d0                	or     %edx,%eax
  801d45:	c1 e9 02             	shr    $0x2,%ecx
  801d48:	fc                   	cld    
  801d49:	f3 ab                	rep stos %eax,%es:(%edi)
  801d4b:	eb 06                	jmp    801d53 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d50:	fc                   	cld    
  801d51:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d53:	89 f8                	mov    %edi,%eax
  801d55:	5b                   	pop    %ebx
  801d56:	5e                   	pop    %esi
  801d57:	5f                   	pop    %edi
  801d58:	5d                   	pop    %ebp
  801d59:	c3                   	ret    

00801d5a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d5a:	55                   	push   %ebp
  801d5b:	89 e5                	mov    %esp,%ebp
  801d5d:	57                   	push   %edi
  801d5e:	56                   	push   %esi
  801d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d62:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d65:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d68:	39 c6                	cmp    %eax,%esi
  801d6a:	73 35                	jae    801da1 <memmove+0x47>
  801d6c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d6f:	39 d0                	cmp    %edx,%eax
  801d71:	73 2e                	jae    801da1 <memmove+0x47>
		s += n;
		d += n;
  801d73:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d76:	89 d6                	mov    %edx,%esi
  801d78:	09 fe                	or     %edi,%esi
  801d7a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d80:	75 13                	jne    801d95 <memmove+0x3b>
  801d82:	f6 c1 03             	test   $0x3,%cl
  801d85:	75 0e                	jne    801d95 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d87:	83 ef 04             	sub    $0x4,%edi
  801d8a:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d8d:	c1 e9 02             	shr    $0x2,%ecx
  801d90:	fd                   	std    
  801d91:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d93:	eb 09                	jmp    801d9e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d95:	83 ef 01             	sub    $0x1,%edi
  801d98:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d9b:	fd                   	std    
  801d9c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d9e:	fc                   	cld    
  801d9f:	eb 1d                	jmp    801dbe <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801da1:	89 f2                	mov    %esi,%edx
  801da3:	09 c2                	or     %eax,%edx
  801da5:	f6 c2 03             	test   $0x3,%dl
  801da8:	75 0f                	jne    801db9 <memmove+0x5f>
  801daa:	f6 c1 03             	test   $0x3,%cl
  801dad:	75 0a                	jne    801db9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801daf:	c1 e9 02             	shr    $0x2,%ecx
  801db2:	89 c7                	mov    %eax,%edi
  801db4:	fc                   	cld    
  801db5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801db7:	eb 05                	jmp    801dbe <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801db9:	89 c7                	mov    %eax,%edi
  801dbb:	fc                   	cld    
  801dbc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801dbe:	5e                   	pop    %esi
  801dbf:	5f                   	pop    %edi
  801dc0:	5d                   	pop    %ebp
  801dc1:	c3                   	ret    

00801dc2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801dc2:	55                   	push   %ebp
  801dc3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801dc5:	ff 75 10             	pushl  0x10(%ebp)
  801dc8:	ff 75 0c             	pushl  0xc(%ebp)
  801dcb:	ff 75 08             	pushl  0x8(%ebp)
  801dce:	e8 87 ff ff ff       	call   801d5a <memmove>
}
  801dd3:	c9                   	leave  
  801dd4:	c3                   	ret    

00801dd5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801dd5:	55                   	push   %ebp
  801dd6:	89 e5                	mov    %esp,%ebp
  801dd8:	56                   	push   %esi
  801dd9:	53                   	push   %ebx
  801dda:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801de0:	89 c6                	mov    %eax,%esi
  801de2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801de5:	eb 1a                	jmp    801e01 <memcmp+0x2c>
		if (*s1 != *s2)
  801de7:	0f b6 08             	movzbl (%eax),%ecx
  801dea:	0f b6 1a             	movzbl (%edx),%ebx
  801ded:	38 d9                	cmp    %bl,%cl
  801def:	74 0a                	je     801dfb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801df1:	0f b6 c1             	movzbl %cl,%eax
  801df4:	0f b6 db             	movzbl %bl,%ebx
  801df7:	29 d8                	sub    %ebx,%eax
  801df9:	eb 0f                	jmp    801e0a <memcmp+0x35>
		s1++, s2++;
  801dfb:	83 c0 01             	add    $0x1,%eax
  801dfe:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e01:	39 f0                	cmp    %esi,%eax
  801e03:	75 e2                	jne    801de7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e05:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e0a:	5b                   	pop    %ebx
  801e0b:	5e                   	pop    %esi
  801e0c:	5d                   	pop    %ebp
  801e0d:	c3                   	ret    

00801e0e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e0e:	55                   	push   %ebp
  801e0f:	89 e5                	mov    %esp,%ebp
  801e11:	53                   	push   %ebx
  801e12:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e15:	89 c1                	mov    %eax,%ecx
  801e17:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e1a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e1e:	eb 0a                	jmp    801e2a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e20:	0f b6 10             	movzbl (%eax),%edx
  801e23:	39 da                	cmp    %ebx,%edx
  801e25:	74 07                	je     801e2e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e27:	83 c0 01             	add    $0x1,%eax
  801e2a:	39 c8                	cmp    %ecx,%eax
  801e2c:	72 f2                	jb     801e20 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e2e:	5b                   	pop    %ebx
  801e2f:	5d                   	pop    %ebp
  801e30:	c3                   	ret    

00801e31 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e31:	55                   	push   %ebp
  801e32:	89 e5                	mov    %esp,%ebp
  801e34:	57                   	push   %edi
  801e35:	56                   	push   %esi
  801e36:	53                   	push   %ebx
  801e37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e3d:	eb 03                	jmp    801e42 <strtol+0x11>
		s++;
  801e3f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e42:	0f b6 01             	movzbl (%ecx),%eax
  801e45:	3c 20                	cmp    $0x20,%al
  801e47:	74 f6                	je     801e3f <strtol+0xe>
  801e49:	3c 09                	cmp    $0x9,%al
  801e4b:	74 f2                	je     801e3f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e4d:	3c 2b                	cmp    $0x2b,%al
  801e4f:	75 0a                	jne    801e5b <strtol+0x2a>
		s++;
  801e51:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e54:	bf 00 00 00 00       	mov    $0x0,%edi
  801e59:	eb 11                	jmp    801e6c <strtol+0x3b>
  801e5b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e60:	3c 2d                	cmp    $0x2d,%al
  801e62:	75 08                	jne    801e6c <strtol+0x3b>
		s++, neg = 1;
  801e64:	83 c1 01             	add    $0x1,%ecx
  801e67:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e6c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e72:	75 15                	jne    801e89 <strtol+0x58>
  801e74:	80 39 30             	cmpb   $0x30,(%ecx)
  801e77:	75 10                	jne    801e89 <strtol+0x58>
  801e79:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e7d:	75 7c                	jne    801efb <strtol+0xca>
		s += 2, base = 16;
  801e7f:	83 c1 02             	add    $0x2,%ecx
  801e82:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e87:	eb 16                	jmp    801e9f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e89:	85 db                	test   %ebx,%ebx
  801e8b:	75 12                	jne    801e9f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e8d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e92:	80 39 30             	cmpb   $0x30,(%ecx)
  801e95:	75 08                	jne    801e9f <strtol+0x6e>
		s++, base = 8;
  801e97:	83 c1 01             	add    $0x1,%ecx
  801e9a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801ea4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801ea7:	0f b6 11             	movzbl (%ecx),%edx
  801eaa:	8d 72 d0             	lea    -0x30(%edx),%esi
  801ead:	89 f3                	mov    %esi,%ebx
  801eaf:	80 fb 09             	cmp    $0x9,%bl
  801eb2:	77 08                	ja     801ebc <strtol+0x8b>
			dig = *s - '0';
  801eb4:	0f be d2             	movsbl %dl,%edx
  801eb7:	83 ea 30             	sub    $0x30,%edx
  801eba:	eb 22                	jmp    801ede <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801ebc:	8d 72 9f             	lea    -0x61(%edx),%esi
  801ebf:	89 f3                	mov    %esi,%ebx
  801ec1:	80 fb 19             	cmp    $0x19,%bl
  801ec4:	77 08                	ja     801ece <strtol+0x9d>
			dig = *s - 'a' + 10;
  801ec6:	0f be d2             	movsbl %dl,%edx
  801ec9:	83 ea 57             	sub    $0x57,%edx
  801ecc:	eb 10                	jmp    801ede <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801ece:	8d 72 bf             	lea    -0x41(%edx),%esi
  801ed1:	89 f3                	mov    %esi,%ebx
  801ed3:	80 fb 19             	cmp    $0x19,%bl
  801ed6:	77 16                	ja     801eee <strtol+0xbd>
			dig = *s - 'A' + 10;
  801ed8:	0f be d2             	movsbl %dl,%edx
  801edb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801ede:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ee1:	7d 0b                	jge    801eee <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801ee3:	83 c1 01             	add    $0x1,%ecx
  801ee6:	0f af 45 10          	imul   0x10(%ebp),%eax
  801eea:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801eec:	eb b9                	jmp    801ea7 <strtol+0x76>

	if (endptr)
  801eee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ef2:	74 0d                	je     801f01 <strtol+0xd0>
		*endptr = (char *) s;
  801ef4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ef7:	89 0e                	mov    %ecx,(%esi)
  801ef9:	eb 06                	jmp    801f01 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801efb:	85 db                	test   %ebx,%ebx
  801efd:	74 98                	je     801e97 <strtol+0x66>
  801eff:	eb 9e                	jmp    801e9f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f01:	89 c2                	mov    %eax,%edx
  801f03:	f7 da                	neg    %edx
  801f05:	85 ff                	test   %edi,%edi
  801f07:	0f 45 c2             	cmovne %edx,%eax
}
  801f0a:	5b                   	pop    %ebx
  801f0b:	5e                   	pop    %esi
  801f0c:	5f                   	pop    %edi
  801f0d:	5d                   	pop    %ebp
  801f0e:	c3                   	ret    

00801f0f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f0f:	55                   	push   %ebp
  801f10:	89 e5                	mov    %esp,%ebp
  801f12:	56                   	push   %esi
  801f13:	53                   	push   %ebx
  801f14:	8b 75 08             	mov    0x8(%ebp),%esi
  801f17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801f1d:	85 c0                	test   %eax,%eax
  801f1f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f24:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801f27:	83 ec 0c             	sub    $0xc,%esp
  801f2a:	50                   	push   %eax
  801f2b:	e8 ea e3 ff ff       	call   80031a <sys_ipc_recv>
  801f30:	83 c4 10             	add    $0x10,%esp
  801f33:	85 c0                	test   %eax,%eax
  801f35:	79 16                	jns    801f4d <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801f37:	85 f6                	test   %esi,%esi
  801f39:	74 06                	je     801f41 <ipc_recv+0x32>
            *from_env_store = 0;
  801f3b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801f41:	85 db                	test   %ebx,%ebx
  801f43:	74 2c                	je     801f71 <ipc_recv+0x62>
            *perm_store = 0;
  801f45:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f4b:	eb 24                	jmp    801f71 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801f4d:	85 f6                	test   %esi,%esi
  801f4f:	74 0a                	je     801f5b <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801f51:	a1 08 40 80 00       	mov    0x804008,%eax
  801f56:	8b 40 74             	mov    0x74(%eax),%eax
  801f59:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801f5b:	85 db                	test   %ebx,%ebx
  801f5d:	74 0a                	je     801f69 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801f5f:	a1 08 40 80 00       	mov    0x804008,%eax
  801f64:	8b 40 78             	mov    0x78(%eax),%eax
  801f67:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801f69:	a1 08 40 80 00       	mov    0x804008,%eax
  801f6e:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801f71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f74:	5b                   	pop    %ebx
  801f75:	5e                   	pop    %esi
  801f76:	5d                   	pop    %ebp
  801f77:	c3                   	ret    

00801f78 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
  801f7b:	57                   	push   %edi
  801f7c:	56                   	push   %esi
  801f7d:	53                   	push   %ebx
  801f7e:	83 ec 0c             	sub    $0xc,%esp
  801f81:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f84:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f87:	8b 45 10             	mov    0x10(%ebp),%eax
  801f8a:	85 c0                	test   %eax,%eax
  801f8c:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801f91:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801f94:	eb 1c                	jmp    801fb2 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801f96:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f99:	74 12                	je     801fad <ipc_send+0x35>
  801f9b:	50                   	push   %eax
  801f9c:	68 80 27 80 00       	push   $0x802780
  801fa1:	6a 3b                	push   $0x3b
  801fa3:	68 96 27 80 00       	push   $0x802796
  801fa8:	e8 3e f5 ff ff       	call   8014eb <_panic>
		sys_yield();
  801fad:	e8 99 e1 ff ff       	call   80014b <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801fb2:	ff 75 14             	pushl  0x14(%ebp)
  801fb5:	53                   	push   %ebx
  801fb6:	56                   	push   %esi
  801fb7:	57                   	push   %edi
  801fb8:	e8 3a e3 ff ff       	call   8002f7 <sys_ipc_try_send>
  801fbd:	83 c4 10             	add    $0x10,%esp
  801fc0:	85 c0                	test   %eax,%eax
  801fc2:	78 d2                	js     801f96 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801fc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fc7:	5b                   	pop    %ebx
  801fc8:	5e                   	pop    %esi
  801fc9:	5f                   	pop    %edi
  801fca:	5d                   	pop    %ebp
  801fcb:	c3                   	ret    

00801fcc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fcc:	55                   	push   %ebp
  801fcd:	89 e5                	mov    %esp,%ebp
  801fcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fd2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fd7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fda:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fe0:	8b 52 50             	mov    0x50(%edx),%edx
  801fe3:	39 ca                	cmp    %ecx,%edx
  801fe5:	75 0d                	jne    801ff4 <ipc_find_env+0x28>
			return envs[i].env_id;
  801fe7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fea:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fef:	8b 40 48             	mov    0x48(%eax),%eax
  801ff2:	eb 0f                	jmp    802003 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ff4:	83 c0 01             	add    $0x1,%eax
  801ff7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ffc:	75 d9                	jne    801fd7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ffe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802003:	5d                   	pop    %ebp
  802004:	c3                   	ret    

00802005 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802005:	55                   	push   %ebp
  802006:	89 e5                	mov    %esp,%ebp
  802008:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80200b:	89 d0                	mov    %edx,%eax
  80200d:	c1 e8 16             	shr    $0x16,%eax
  802010:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802017:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80201c:	f6 c1 01             	test   $0x1,%cl
  80201f:	74 1d                	je     80203e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802021:	c1 ea 0c             	shr    $0xc,%edx
  802024:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80202b:	f6 c2 01             	test   $0x1,%dl
  80202e:	74 0e                	je     80203e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802030:	c1 ea 0c             	shr    $0xc,%edx
  802033:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80203a:	ef 
  80203b:	0f b7 c0             	movzwl %ax,%eax
}
  80203e:	5d                   	pop    %ebp
  80203f:	c3                   	ret    

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
