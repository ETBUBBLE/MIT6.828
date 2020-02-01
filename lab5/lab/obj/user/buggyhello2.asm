
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
  80006b:	a3 04 40 80 00       	mov    %eax,0x804004

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
  80009a:	e8 87 04 00 00       	call   800526 <close_all>
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
  800113:	68 58 1e 80 00       	push   $0x801e58
  800118:	6a 23                	push   $0x23
  80011a:	68 75 1e 80 00       	push   $0x801e75
  80011f:	e8 21 0f 00 00       	call   801045 <_panic>

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
  800194:	68 58 1e 80 00       	push   $0x801e58
  800199:	6a 23                	push   $0x23
  80019b:	68 75 1e 80 00       	push   $0x801e75
  8001a0:	e8 a0 0e 00 00       	call   801045 <_panic>

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
  8001d6:	68 58 1e 80 00       	push   $0x801e58
  8001db:	6a 23                	push   $0x23
  8001dd:	68 75 1e 80 00       	push   $0x801e75
  8001e2:	e8 5e 0e 00 00       	call   801045 <_panic>

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
  800218:	68 58 1e 80 00       	push   $0x801e58
  80021d:	6a 23                	push   $0x23
  80021f:	68 75 1e 80 00       	push   $0x801e75
  800224:	e8 1c 0e 00 00       	call   801045 <_panic>

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
  80025a:	68 58 1e 80 00       	push   $0x801e58
  80025f:	6a 23                	push   $0x23
  800261:	68 75 1e 80 00       	push   $0x801e75
  800266:	e8 da 0d 00 00       	call   801045 <_panic>

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
  80029c:	68 58 1e 80 00       	push   $0x801e58
  8002a1:	6a 23                	push   $0x23
  8002a3:	68 75 1e 80 00       	push   $0x801e75
  8002a8:	e8 98 0d 00 00       	call   801045 <_panic>

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
  8002de:	68 58 1e 80 00       	push   $0x801e58
  8002e3:	6a 23                	push   $0x23
  8002e5:	68 75 1e 80 00       	push   $0x801e75
  8002ea:	e8 56 0d 00 00       	call   801045 <_panic>

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
  800342:	68 58 1e 80 00       	push   $0x801e58
  800347:	6a 23                	push   $0x23
  800349:	68 75 1e 80 00       	push   $0x801e75
  80034e:	e8 f2 0c 00 00       	call   801045 <_panic>

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

0080035b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	05 00 00 00 30       	add    $0x30000000,%eax
  800366:	c1 e8 0c             	shr    $0xc,%eax
}
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	05 00 00 00 30       	add    $0x30000000,%eax
  800376:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80037b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800388:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80038d:	89 c2                	mov    %eax,%edx
  80038f:	c1 ea 16             	shr    $0x16,%edx
  800392:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800399:	f6 c2 01             	test   $0x1,%dl
  80039c:	74 11                	je     8003af <fd_alloc+0x2d>
  80039e:	89 c2                	mov    %eax,%edx
  8003a0:	c1 ea 0c             	shr    $0xc,%edx
  8003a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003aa:	f6 c2 01             	test   $0x1,%dl
  8003ad:	75 09                	jne    8003b8 <fd_alloc+0x36>
			*fd_store = fd;
  8003af:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b6:	eb 17                	jmp    8003cf <fd_alloc+0x4d>
  8003b8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003bd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003c2:	75 c9                	jne    80038d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003c4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ca:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003cf:	5d                   	pop    %ebp
  8003d0:	c3                   	ret    

008003d1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d7:	83 f8 1f             	cmp    $0x1f,%eax
  8003da:	77 36                	ja     800412 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003dc:	c1 e0 0c             	shl    $0xc,%eax
  8003df:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e4:	89 c2                	mov    %eax,%edx
  8003e6:	c1 ea 16             	shr    $0x16,%edx
  8003e9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003f0:	f6 c2 01             	test   $0x1,%dl
  8003f3:	74 24                	je     800419 <fd_lookup+0x48>
  8003f5:	89 c2                	mov    %eax,%edx
  8003f7:	c1 ea 0c             	shr    $0xc,%edx
  8003fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800401:	f6 c2 01             	test   $0x1,%dl
  800404:	74 1a                	je     800420 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800406:	8b 55 0c             	mov    0xc(%ebp),%edx
  800409:	89 02                	mov    %eax,(%edx)
	return 0;
  80040b:	b8 00 00 00 00       	mov    $0x0,%eax
  800410:	eb 13                	jmp    800425 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb 0c                	jmp    800425 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041e:	eb 05                	jmp    800425 <fd_lookup+0x54>
  800420:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800425:	5d                   	pop    %ebp
  800426:	c3                   	ret    

00800427 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800430:	ba 00 1f 80 00       	mov    $0x801f00,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800435:	eb 13                	jmp    80044a <dev_lookup+0x23>
  800437:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80043a:	39 08                	cmp    %ecx,(%eax)
  80043c:	75 0c                	jne    80044a <dev_lookup+0x23>
			*dev = devtab[i];
  80043e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800441:	89 01                	mov    %eax,(%ecx)
			return 0;
  800443:	b8 00 00 00 00       	mov    $0x0,%eax
  800448:	eb 2e                	jmp    800478 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80044a:	8b 02                	mov    (%edx),%eax
  80044c:	85 c0                	test   %eax,%eax
  80044e:	75 e7                	jne    800437 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800450:	a1 04 40 80 00       	mov    0x804004,%eax
  800455:	8b 40 48             	mov    0x48(%eax),%eax
  800458:	83 ec 04             	sub    $0x4,%esp
  80045b:	51                   	push   %ecx
  80045c:	50                   	push   %eax
  80045d:	68 84 1e 80 00       	push   $0x801e84
  800462:	e8 b7 0c 00 00       	call   80111e <cprintf>
	*dev = 0;
  800467:	8b 45 0c             	mov    0xc(%ebp),%eax
  80046a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800470:	83 c4 10             	add    $0x10,%esp
  800473:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800478:	c9                   	leave  
  800479:	c3                   	ret    

0080047a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	56                   	push   %esi
  80047e:	53                   	push   %ebx
  80047f:	83 ec 10             	sub    $0x10,%esp
  800482:	8b 75 08             	mov    0x8(%ebp),%esi
  800485:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800488:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80048b:	50                   	push   %eax
  80048c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800492:	c1 e8 0c             	shr    $0xc,%eax
  800495:	50                   	push   %eax
  800496:	e8 36 ff ff ff       	call   8003d1 <fd_lookup>
  80049b:	83 c4 08             	add    $0x8,%esp
  80049e:	85 c0                	test   %eax,%eax
  8004a0:	78 05                	js     8004a7 <fd_close+0x2d>
	    || fd != fd2)
  8004a2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004a5:	74 0c                	je     8004b3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a7:	84 db                	test   %bl,%bl
  8004a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ae:	0f 44 c2             	cmove  %edx,%eax
  8004b1:	eb 41                	jmp    8004f4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b9:	50                   	push   %eax
  8004ba:	ff 36                	pushl  (%esi)
  8004bc:	e8 66 ff ff ff       	call   800427 <dev_lookup>
  8004c1:	89 c3                	mov    %eax,%ebx
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	85 c0                	test   %eax,%eax
  8004c8:	78 1a                	js     8004e4 <fd_close+0x6a>
		if (dev->dev_close)
  8004ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004cd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004d0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	74 0b                	je     8004e4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d9:	83 ec 0c             	sub    $0xc,%esp
  8004dc:	56                   	push   %esi
  8004dd:	ff d0                	call   *%eax
  8004df:	89 c3                	mov    %eax,%ebx
  8004e1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004e4:	83 ec 08             	sub    $0x8,%esp
  8004e7:	56                   	push   %esi
  8004e8:	6a 00                	push   $0x0
  8004ea:	e8 00 fd ff ff       	call   8001ef <sys_page_unmap>
	return r;
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	89 d8                	mov    %ebx,%eax
}
  8004f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f7:	5b                   	pop    %ebx
  8004f8:	5e                   	pop    %esi
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800501:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800504:	50                   	push   %eax
  800505:	ff 75 08             	pushl  0x8(%ebp)
  800508:	e8 c4 fe ff ff       	call   8003d1 <fd_lookup>
  80050d:	83 c4 08             	add    $0x8,%esp
  800510:	85 c0                	test   %eax,%eax
  800512:	78 10                	js     800524 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800514:	83 ec 08             	sub    $0x8,%esp
  800517:	6a 01                	push   $0x1
  800519:	ff 75 f4             	pushl  -0xc(%ebp)
  80051c:	e8 59 ff ff ff       	call   80047a <fd_close>
  800521:	83 c4 10             	add    $0x10,%esp
}
  800524:	c9                   	leave  
  800525:	c3                   	ret    

00800526 <close_all>:

void
close_all(void)
{
  800526:	55                   	push   %ebp
  800527:	89 e5                	mov    %esp,%ebp
  800529:	53                   	push   %ebx
  80052a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80052d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800532:	83 ec 0c             	sub    $0xc,%esp
  800535:	53                   	push   %ebx
  800536:	e8 c0 ff ff ff       	call   8004fb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80053b:	83 c3 01             	add    $0x1,%ebx
  80053e:	83 c4 10             	add    $0x10,%esp
  800541:	83 fb 20             	cmp    $0x20,%ebx
  800544:	75 ec                	jne    800532 <close_all+0xc>
		close(i);
}
  800546:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800549:	c9                   	leave  
  80054a:	c3                   	ret    

0080054b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80054b:	55                   	push   %ebp
  80054c:	89 e5                	mov    %esp,%ebp
  80054e:	57                   	push   %edi
  80054f:	56                   	push   %esi
  800550:	53                   	push   %ebx
  800551:	83 ec 2c             	sub    $0x2c,%esp
  800554:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800557:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80055a:	50                   	push   %eax
  80055b:	ff 75 08             	pushl  0x8(%ebp)
  80055e:	e8 6e fe ff ff       	call   8003d1 <fd_lookup>
  800563:	83 c4 08             	add    $0x8,%esp
  800566:	85 c0                	test   %eax,%eax
  800568:	0f 88 c1 00 00 00    	js     80062f <dup+0xe4>
		return r;
	close(newfdnum);
  80056e:	83 ec 0c             	sub    $0xc,%esp
  800571:	56                   	push   %esi
  800572:	e8 84 ff ff ff       	call   8004fb <close>

	newfd = INDEX2FD(newfdnum);
  800577:	89 f3                	mov    %esi,%ebx
  800579:	c1 e3 0c             	shl    $0xc,%ebx
  80057c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800582:	83 c4 04             	add    $0x4,%esp
  800585:	ff 75 e4             	pushl  -0x1c(%ebp)
  800588:	e8 de fd ff ff       	call   80036b <fd2data>
  80058d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80058f:	89 1c 24             	mov    %ebx,(%esp)
  800592:	e8 d4 fd ff ff       	call   80036b <fd2data>
  800597:	83 c4 10             	add    $0x10,%esp
  80059a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80059d:	89 f8                	mov    %edi,%eax
  80059f:	c1 e8 16             	shr    $0x16,%eax
  8005a2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a9:	a8 01                	test   $0x1,%al
  8005ab:	74 37                	je     8005e4 <dup+0x99>
  8005ad:	89 f8                	mov    %edi,%eax
  8005af:	c1 e8 0c             	shr    $0xc,%eax
  8005b2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b9:	f6 c2 01             	test   $0x1,%dl
  8005bc:	74 26                	je     8005e4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c5:	83 ec 0c             	sub    $0xc,%esp
  8005c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005cd:	50                   	push   %eax
  8005ce:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005d1:	6a 00                	push   $0x0
  8005d3:	57                   	push   %edi
  8005d4:	6a 00                	push   $0x0
  8005d6:	e8 d2 fb ff ff       	call   8001ad <sys_page_map>
  8005db:	89 c7                	mov    %eax,%edi
  8005dd:	83 c4 20             	add    $0x20,%esp
  8005e0:	85 c0                	test   %eax,%eax
  8005e2:	78 2e                	js     800612 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e7:	89 d0                	mov    %edx,%eax
  8005e9:	c1 e8 0c             	shr    $0xc,%eax
  8005ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f3:	83 ec 0c             	sub    $0xc,%esp
  8005f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005fb:	50                   	push   %eax
  8005fc:	53                   	push   %ebx
  8005fd:	6a 00                	push   $0x0
  8005ff:	52                   	push   %edx
  800600:	6a 00                	push   $0x0
  800602:	e8 a6 fb ff ff       	call   8001ad <sys_page_map>
  800607:	89 c7                	mov    %eax,%edi
  800609:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80060c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060e:	85 ff                	test   %edi,%edi
  800610:	79 1d                	jns    80062f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 00                	push   $0x0
  800618:	e8 d2 fb ff ff       	call   8001ef <sys_page_unmap>
	sys_page_unmap(0, nva);
  80061d:	83 c4 08             	add    $0x8,%esp
  800620:	ff 75 d4             	pushl  -0x2c(%ebp)
  800623:	6a 00                	push   $0x0
  800625:	e8 c5 fb ff ff       	call   8001ef <sys_page_unmap>
	return r;
  80062a:	83 c4 10             	add    $0x10,%esp
  80062d:	89 f8                	mov    %edi,%eax
}
  80062f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800632:	5b                   	pop    %ebx
  800633:	5e                   	pop    %esi
  800634:	5f                   	pop    %edi
  800635:	5d                   	pop    %ebp
  800636:	c3                   	ret    

00800637 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800637:	55                   	push   %ebp
  800638:	89 e5                	mov    %esp,%ebp
  80063a:	53                   	push   %ebx
  80063b:	83 ec 14             	sub    $0x14,%esp
  80063e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800641:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800644:	50                   	push   %eax
  800645:	53                   	push   %ebx
  800646:	e8 86 fd ff ff       	call   8003d1 <fd_lookup>
  80064b:	83 c4 08             	add    $0x8,%esp
  80064e:	89 c2                	mov    %eax,%edx
  800650:	85 c0                	test   %eax,%eax
  800652:	78 6d                	js     8006c1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80065a:	50                   	push   %eax
  80065b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065e:	ff 30                	pushl  (%eax)
  800660:	e8 c2 fd ff ff       	call   800427 <dev_lookup>
  800665:	83 c4 10             	add    $0x10,%esp
  800668:	85 c0                	test   %eax,%eax
  80066a:	78 4c                	js     8006b8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80066c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80066f:	8b 42 08             	mov    0x8(%edx),%eax
  800672:	83 e0 03             	and    $0x3,%eax
  800675:	83 f8 01             	cmp    $0x1,%eax
  800678:	75 21                	jne    80069b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80067a:	a1 04 40 80 00       	mov    0x804004,%eax
  80067f:	8b 40 48             	mov    0x48(%eax),%eax
  800682:	83 ec 04             	sub    $0x4,%esp
  800685:	53                   	push   %ebx
  800686:	50                   	push   %eax
  800687:	68 c5 1e 80 00       	push   $0x801ec5
  80068c:	e8 8d 0a 00 00       	call   80111e <cprintf>
		return -E_INVAL;
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800699:	eb 26                	jmp    8006c1 <read+0x8a>
	}
	if (!dev->dev_read)
  80069b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069e:	8b 40 08             	mov    0x8(%eax),%eax
  8006a1:	85 c0                	test   %eax,%eax
  8006a3:	74 17                	je     8006bc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a5:	83 ec 04             	sub    $0x4,%esp
  8006a8:	ff 75 10             	pushl  0x10(%ebp)
  8006ab:	ff 75 0c             	pushl  0xc(%ebp)
  8006ae:	52                   	push   %edx
  8006af:	ff d0                	call   *%eax
  8006b1:	89 c2                	mov    %eax,%edx
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	eb 09                	jmp    8006c1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b8:	89 c2                	mov    %eax,%edx
  8006ba:	eb 05                	jmp    8006c1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006bc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006c1:	89 d0                	mov    %edx,%eax
  8006c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c6:	c9                   	leave  
  8006c7:	c3                   	ret    

008006c8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	57                   	push   %edi
  8006cc:	56                   	push   %esi
  8006cd:	53                   	push   %ebx
  8006ce:	83 ec 0c             	sub    $0xc,%esp
  8006d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006dc:	eb 21                	jmp    8006ff <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006de:	83 ec 04             	sub    $0x4,%esp
  8006e1:	89 f0                	mov    %esi,%eax
  8006e3:	29 d8                	sub    %ebx,%eax
  8006e5:	50                   	push   %eax
  8006e6:	89 d8                	mov    %ebx,%eax
  8006e8:	03 45 0c             	add    0xc(%ebp),%eax
  8006eb:	50                   	push   %eax
  8006ec:	57                   	push   %edi
  8006ed:	e8 45 ff ff ff       	call   800637 <read>
		if (m < 0)
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	78 10                	js     800709 <readn+0x41>
			return m;
		if (m == 0)
  8006f9:	85 c0                	test   %eax,%eax
  8006fb:	74 0a                	je     800707 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006fd:	01 c3                	add    %eax,%ebx
  8006ff:	39 f3                	cmp    %esi,%ebx
  800701:	72 db                	jb     8006de <readn+0x16>
  800703:	89 d8                	mov    %ebx,%eax
  800705:	eb 02                	jmp    800709 <readn+0x41>
  800707:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800709:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070c:	5b                   	pop    %ebx
  80070d:	5e                   	pop    %esi
  80070e:	5f                   	pop    %edi
  80070f:	5d                   	pop    %ebp
  800710:	c3                   	ret    

00800711 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	53                   	push   %ebx
  800715:	83 ec 14             	sub    $0x14,%esp
  800718:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80071b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071e:	50                   	push   %eax
  80071f:	53                   	push   %ebx
  800720:	e8 ac fc ff ff       	call   8003d1 <fd_lookup>
  800725:	83 c4 08             	add    $0x8,%esp
  800728:	89 c2                	mov    %eax,%edx
  80072a:	85 c0                	test   %eax,%eax
  80072c:	78 68                	js     800796 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072e:	83 ec 08             	sub    $0x8,%esp
  800731:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800734:	50                   	push   %eax
  800735:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800738:	ff 30                	pushl  (%eax)
  80073a:	e8 e8 fc ff ff       	call   800427 <dev_lookup>
  80073f:	83 c4 10             	add    $0x10,%esp
  800742:	85 c0                	test   %eax,%eax
  800744:	78 47                	js     80078d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800746:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800749:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80074d:	75 21                	jne    800770 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074f:	a1 04 40 80 00       	mov    0x804004,%eax
  800754:	8b 40 48             	mov    0x48(%eax),%eax
  800757:	83 ec 04             	sub    $0x4,%esp
  80075a:	53                   	push   %ebx
  80075b:	50                   	push   %eax
  80075c:	68 e1 1e 80 00       	push   $0x801ee1
  800761:	e8 b8 09 00 00       	call   80111e <cprintf>
		return -E_INVAL;
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80076e:	eb 26                	jmp    800796 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800770:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800773:	8b 52 0c             	mov    0xc(%edx),%edx
  800776:	85 d2                	test   %edx,%edx
  800778:	74 17                	je     800791 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80077a:	83 ec 04             	sub    $0x4,%esp
  80077d:	ff 75 10             	pushl  0x10(%ebp)
  800780:	ff 75 0c             	pushl  0xc(%ebp)
  800783:	50                   	push   %eax
  800784:	ff d2                	call   *%edx
  800786:	89 c2                	mov    %eax,%edx
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	eb 09                	jmp    800796 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80078d:	89 c2                	mov    %eax,%edx
  80078f:	eb 05                	jmp    800796 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800791:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800796:	89 d0                	mov    %edx,%eax
  800798:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    

0080079d <seek>:

int
seek(int fdnum, off_t offset)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007a3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007a6:	50                   	push   %eax
  8007a7:	ff 75 08             	pushl  0x8(%ebp)
  8007aa:	e8 22 fc ff ff       	call   8003d1 <fd_lookup>
  8007af:	83 c4 08             	add    $0x8,%esp
  8007b2:	85 c0                	test   %eax,%eax
  8007b4:	78 0e                	js     8007c4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c4:	c9                   	leave  
  8007c5:	c3                   	ret    

008007c6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	53                   	push   %ebx
  8007ca:	83 ec 14             	sub    $0x14,%esp
  8007cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007d3:	50                   	push   %eax
  8007d4:	53                   	push   %ebx
  8007d5:	e8 f7 fb ff ff       	call   8003d1 <fd_lookup>
  8007da:	83 c4 08             	add    $0x8,%esp
  8007dd:	89 c2                	mov    %eax,%edx
  8007df:	85 c0                	test   %eax,%eax
  8007e1:	78 65                	js     800848 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007e3:	83 ec 08             	sub    $0x8,%esp
  8007e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e9:	50                   	push   %eax
  8007ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ed:	ff 30                	pushl  (%eax)
  8007ef:	e8 33 fc ff ff       	call   800427 <dev_lookup>
  8007f4:	83 c4 10             	add    $0x10,%esp
  8007f7:	85 c0                	test   %eax,%eax
  8007f9:	78 44                	js     80083f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800802:	75 21                	jne    800825 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800804:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800809:	8b 40 48             	mov    0x48(%eax),%eax
  80080c:	83 ec 04             	sub    $0x4,%esp
  80080f:	53                   	push   %ebx
  800810:	50                   	push   %eax
  800811:	68 a4 1e 80 00       	push   $0x801ea4
  800816:	e8 03 09 00 00       	call   80111e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80081b:	83 c4 10             	add    $0x10,%esp
  80081e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800823:	eb 23                	jmp    800848 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800825:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800828:	8b 52 18             	mov    0x18(%edx),%edx
  80082b:	85 d2                	test   %edx,%edx
  80082d:	74 14                	je     800843 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80082f:	83 ec 08             	sub    $0x8,%esp
  800832:	ff 75 0c             	pushl  0xc(%ebp)
  800835:	50                   	push   %eax
  800836:	ff d2                	call   *%edx
  800838:	89 c2                	mov    %eax,%edx
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	eb 09                	jmp    800848 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083f:	89 c2                	mov    %eax,%edx
  800841:	eb 05                	jmp    800848 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800843:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800848:	89 d0                	mov    %edx,%eax
  80084a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    

0080084f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	53                   	push   %ebx
  800853:	83 ec 14             	sub    $0x14,%esp
  800856:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800859:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80085c:	50                   	push   %eax
  80085d:	ff 75 08             	pushl  0x8(%ebp)
  800860:	e8 6c fb ff ff       	call   8003d1 <fd_lookup>
  800865:	83 c4 08             	add    $0x8,%esp
  800868:	89 c2                	mov    %eax,%edx
  80086a:	85 c0                	test   %eax,%eax
  80086c:	78 58                	js     8008c6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800874:	50                   	push   %eax
  800875:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800878:	ff 30                	pushl  (%eax)
  80087a:	e8 a8 fb ff ff       	call   800427 <dev_lookup>
  80087f:	83 c4 10             	add    $0x10,%esp
  800882:	85 c0                	test   %eax,%eax
  800884:	78 37                	js     8008bd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800886:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800889:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80088d:	74 32                	je     8008c1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80088f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800892:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800899:	00 00 00 
	stat->st_isdir = 0;
  80089c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008a3:	00 00 00 
	stat->st_dev = dev;
  8008a6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	53                   	push   %ebx
  8008b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8008b3:	ff 50 14             	call   *0x14(%eax)
  8008b6:	89 c2                	mov    %eax,%edx
  8008b8:	83 c4 10             	add    $0x10,%esp
  8008bb:	eb 09                	jmp    8008c6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008bd:	89 c2                	mov    %eax,%edx
  8008bf:	eb 05                	jmp    8008c6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008c1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008c6:	89 d0                	mov    %edx,%eax
  8008c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008cb:	c9                   	leave  
  8008cc:	c3                   	ret    

008008cd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	56                   	push   %esi
  8008d1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008d2:	83 ec 08             	sub    $0x8,%esp
  8008d5:	6a 00                	push   $0x0
  8008d7:	ff 75 08             	pushl  0x8(%ebp)
  8008da:	e8 e3 01 00 00       	call   800ac2 <open>
  8008df:	89 c3                	mov    %eax,%ebx
  8008e1:	83 c4 10             	add    $0x10,%esp
  8008e4:	85 c0                	test   %eax,%eax
  8008e6:	78 1b                	js     800903 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e8:	83 ec 08             	sub    $0x8,%esp
  8008eb:	ff 75 0c             	pushl  0xc(%ebp)
  8008ee:	50                   	push   %eax
  8008ef:	e8 5b ff ff ff       	call   80084f <fstat>
  8008f4:	89 c6                	mov    %eax,%esi
	close(fd);
  8008f6:	89 1c 24             	mov    %ebx,(%esp)
  8008f9:	e8 fd fb ff ff       	call   8004fb <close>
	return r;
  8008fe:	83 c4 10             	add    $0x10,%esp
  800901:	89 f0                	mov    %esi,%eax
}
  800903:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800906:	5b                   	pop    %ebx
  800907:	5e                   	pop    %esi
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	56                   	push   %esi
  80090e:	53                   	push   %ebx
  80090f:	89 c6                	mov    %eax,%esi
  800911:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800913:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80091a:	75 12                	jne    80092e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80091c:	83 ec 0c             	sub    $0xc,%esp
  80091f:	6a 01                	push   $0x1
  800921:	e8 00 12 00 00       	call   801b26 <ipc_find_env>
  800926:	a3 00 40 80 00       	mov    %eax,0x804000
  80092b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80092e:	6a 07                	push   $0x7
  800930:	68 00 50 80 00       	push   $0x805000
  800935:	56                   	push   %esi
  800936:	ff 35 00 40 80 00    	pushl  0x804000
  80093c:	e8 91 11 00 00       	call   801ad2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800941:	83 c4 0c             	add    $0xc,%esp
  800944:	6a 00                	push   $0x0
  800946:	53                   	push   %ebx
  800947:	6a 00                	push   $0x0
  800949:	e8 1b 11 00 00       	call   801a69 <ipc_recv>
}
  80094e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800951:	5b                   	pop    %ebx
  800952:	5e                   	pop    %esi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	8b 40 0c             	mov    0xc(%eax),%eax
  800961:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800966:	8b 45 0c             	mov    0xc(%ebp),%eax
  800969:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80096e:	ba 00 00 00 00       	mov    $0x0,%edx
  800973:	b8 02 00 00 00       	mov    $0x2,%eax
  800978:	e8 8d ff ff ff       	call   80090a <fsipc>
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 40 0c             	mov    0xc(%eax),%eax
  80098b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800990:	ba 00 00 00 00       	mov    $0x0,%edx
  800995:	b8 06 00 00 00       	mov    $0x6,%eax
  80099a:	e8 6b ff ff ff       	call   80090a <fsipc>
}
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    

008009a1 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	53                   	push   %ebx
  8009a5:	83 ec 04             	sub    $0x4,%esp
  8009a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bb:	b8 05 00 00 00       	mov    $0x5,%eax
  8009c0:	e8 45 ff ff ff       	call   80090a <fsipc>
  8009c5:	85 c0                	test   %eax,%eax
  8009c7:	78 2c                	js     8009f5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c9:	83 ec 08             	sub    $0x8,%esp
  8009cc:	68 00 50 80 00       	push   $0x805000
  8009d1:	53                   	push   %ebx
  8009d2:	e8 4b 0d 00 00       	call   801722 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d7:	a1 80 50 80 00       	mov    0x805080,%eax
  8009dc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009e2:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009ed:	83 c4 10             	add    $0x10,%esp
  8009f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f8:	c9                   	leave  
  8009f9:	c3                   	ret    

008009fa <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	83 ec 0c             	sub    $0xc,%esp
  800a00:	8b 45 10             	mov    0x10(%ebp),%eax
  800a03:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a08:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a0d:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a10:	8b 55 08             	mov    0x8(%ebp),%edx
  800a13:	8b 52 0c             	mov    0xc(%edx),%edx
  800a16:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a1c:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a21:	50                   	push   %eax
  800a22:	ff 75 0c             	pushl  0xc(%ebp)
  800a25:	68 08 50 80 00       	push   $0x805008
  800a2a:	e8 85 0e 00 00       	call   8018b4 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a34:	b8 04 00 00 00       	mov    $0x4,%eax
  800a39:	e8 cc fe ff ff       	call   80090a <fsipc>
	//panic("devfile_write not implemented");
}
  800a3e:	c9                   	leave  
  800a3f:	c3                   	ret    

00800a40 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	56                   	push   %esi
  800a44:	53                   	push   %ebx
  800a45:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a48:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a4e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a53:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a59:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5e:	b8 03 00 00 00       	mov    $0x3,%eax
  800a63:	e8 a2 fe ff ff       	call   80090a <fsipc>
  800a68:	89 c3                	mov    %eax,%ebx
  800a6a:	85 c0                	test   %eax,%eax
  800a6c:	78 4b                	js     800ab9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a6e:	39 c6                	cmp    %eax,%esi
  800a70:	73 16                	jae    800a88 <devfile_read+0x48>
  800a72:	68 10 1f 80 00       	push   $0x801f10
  800a77:	68 17 1f 80 00       	push   $0x801f17
  800a7c:	6a 7c                	push   $0x7c
  800a7e:	68 2c 1f 80 00       	push   $0x801f2c
  800a83:	e8 bd 05 00 00       	call   801045 <_panic>
	assert(r <= PGSIZE);
  800a88:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a8d:	7e 16                	jle    800aa5 <devfile_read+0x65>
  800a8f:	68 37 1f 80 00       	push   $0x801f37
  800a94:	68 17 1f 80 00       	push   $0x801f17
  800a99:	6a 7d                	push   $0x7d
  800a9b:	68 2c 1f 80 00       	push   $0x801f2c
  800aa0:	e8 a0 05 00 00       	call   801045 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aa5:	83 ec 04             	sub    $0x4,%esp
  800aa8:	50                   	push   %eax
  800aa9:	68 00 50 80 00       	push   $0x805000
  800aae:	ff 75 0c             	pushl  0xc(%ebp)
  800ab1:	e8 fe 0d 00 00       	call   8018b4 <memmove>
	return r;
  800ab6:	83 c4 10             	add    $0x10,%esp
}
  800ab9:	89 d8                	mov    %ebx,%eax
  800abb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800abe:	5b                   	pop    %ebx
  800abf:	5e                   	pop    %esi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    

00800ac2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	53                   	push   %ebx
  800ac6:	83 ec 20             	sub    $0x20,%esp
  800ac9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800acc:	53                   	push   %ebx
  800acd:	e8 17 0c 00 00       	call   8016e9 <strlen>
  800ad2:	83 c4 10             	add    $0x10,%esp
  800ad5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ada:	7f 67                	jg     800b43 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800adc:	83 ec 0c             	sub    $0xc,%esp
  800adf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ae2:	50                   	push   %eax
  800ae3:	e8 9a f8 ff ff       	call   800382 <fd_alloc>
  800ae8:	83 c4 10             	add    $0x10,%esp
		return r;
  800aeb:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aed:	85 c0                	test   %eax,%eax
  800aef:	78 57                	js     800b48 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800af1:	83 ec 08             	sub    $0x8,%esp
  800af4:	53                   	push   %ebx
  800af5:	68 00 50 80 00       	push   $0x805000
  800afa:	e8 23 0c 00 00       	call   801722 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800aff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b02:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b07:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b0a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b0f:	e8 f6 fd ff ff       	call   80090a <fsipc>
  800b14:	89 c3                	mov    %eax,%ebx
  800b16:	83 c4 10             	add    $0x10,%esp
  800b19:	85 c0                	test   %eax,%eax
  800b1b:	79 14                	jns    800b31 <open+0x6f>
		fd_close(fd, 0);
  800b1d:	83 ec 08             	sub    $0x8,%esp
  800b20:	6a 00                	push   $0x0
  800b22:	ff 75 f4             	pushl  -0xc(%ebp)
  800b25:	e8 50 f9 ff ff       	call   80047a <fd_close>
		return r;
  800b2a:	83 c4 10             	add    $0x10,%esp
  800b2d:	89 da                	mov    %ebx,%edx
  800b2f:	eb 17                	jmp    800b48 <open+0x86>
	}

	return fd2num(fd);
  800b31:	83 ec 0c             	sub    $0xc,%esp
  800b34:	ff 75 f4             	pushl  -0xc(%ebp)
  800b37:	e8 1f f8 ff ff       	call   80035b <fd2num>
  800b3c:	89 c2                	mov    %eax,%edx
  800b3e:	83 c4 10             	add    $0x10,%esp
  800b41:	eb 05                	jmp    800b48 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b43:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b48:	89 d0                	mov    %edx,%eax
  800b4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b4d:	c9                   	leave  
  800b4e:	c3                   	ret    

00800b4f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b55:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5a:	b8 08 00 00 00       	mov    $0x8,%eax
  800b5f:	e8 a6 fd ff ff       	call   80090a <fsipc>
}
  800b64:	c9                   	leave  
  800b65:	c3                   	ret    

00800b66 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	56                   	push   %esi
  800b6a:	53                   	push   %ebx
  800b6b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b6e:	83 ec 0c             	sub    $0xc,%esp
  800b71:	ff 75 08             	pushl  0x8(%ebp)
  800b74:	e8 f2 f7 ff ff       	call   80036b <fd2data>
  800b79:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b7b:	83 c4 08             	add    $0x8,%esp
  800b7e:	68 43 1f 80 00       	push   $0x801f43
  800b83:	53                   	push   %ebx
  800b84:	e8 99 0b 00 00       	call   801722 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b89:	8b 46 04             	mov    0x4(%esi),%eax
  800b8c:	2b 06                	sub    (%esi),%eax
  800b8e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b94:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b9b:	00 00 00 
	stat->st_dev = &devpipe;
  800b9e:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800ba5:	30 80 00 
	return 0;
}
  800ba8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5d                   	pop    %ebp
  800bb3:	c3                   	ret    

00800bb4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	53                   	push   %ebx
  800bb8:	83 ec 0c             	sub    $0xc,%esp
  800bbb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bbe:	53                   	push   %ebx
  800bbf:	6a 00                	push   $0x0
  800bc1:	e8 29 f6 ff ff       	call   8001ef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bc6:	89 1c 24             	mov    %ebx,(%esp)
  800bc9:	e8 9d f7 ff ff       	call   80036b <fd2data>
  800bce:	83 c4 08             	add    $0x8,%esp
  800bd1:	50                   	push   %eax
  800bd2:	6a 00                	push   $0x0
  800bd4:	e8 16 f6 ff ff       	call   8001ef <sys_page_unmap>
}
  800bd9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bdc:	c9                   	leave  
  800bdd:	c3                   	ret    

00800bde <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
  800be4:	83 ec 1c             	sub    $0x1c,%esp
  800be7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bea:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bec:	a1 04 40 80 00       	mov    0x804004,%eax
  800bf1:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bf4:	83 ec 0c             	sub    $0xc,%esp
  800bf7:	ff 75 e0             	pushl  -0x20(%ebp)
  800bfa:	e8 60 0f 00 00       	call   801b5f <pageref>
  800bff:	89 c3                	mov    %eax,%ebx
  800c01:	89 3c 24             	mov    %edi,(%esp)
  800c04:	e8 56 0f 00 00       	call   801b5f <pageref>
  800c09:	83 c4 10             	add    $0x10,%esp
  800c0c:	39 c3                	cmp    %eax,%ebx
  800c0e:	0f 94 c1             	sete   %cl
  800c11:	0f b6 c9             	movzbl %cl,%ecx
  800c14:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c17:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c1d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c20:	39 ce                	cmp    %ecx,%esi
  800c22:	74 1b                	je     800c3f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c24:	39 c3                	cmp    %eax,%ebx
  800c26:	75 c4                	jne    800bec <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c28:	8b 42 58             	mov    0x58(%edx),%eax
  800c2b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c2e:	50                   	push   %eax
  800c2f:	56                   	push   %esi
  800c30:	68 4a 1f 80 00       	push   $0x801f4a
  800c35:	e8 e4 04 00 00       	call   80111e <cprintf>
  800c3a:	83 c4 10             	add    $0x10,%esp
  800c3d:	eb ad                	jmp    800bec <_pipeisclosed+0xe>
	}
}
  800c3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	57                   	push   %edi
  800c4e:	56                   	push   %esi
  800c4f:	53                   	push   %ebx
  800c50:	83 ec 28             	sub    $0x28,%esp
  800c53:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c56:	56                   	push   %esi
  800c57:	e8 0f f7 ff ff       	call   80036b <fd2data>
  800c5c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c5e:	83 c4 10             	add    $0x10,%esp
  800c61:	bf 00 00 00 00       	mov    $0x0,%edi
  800c66:	eb 4b                	jmp    800cb3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c68:	89 da                	mov    %ebx,%edx
  800c6a:	89 f0                	mov    %esi,%eax
  800c6c:	e8 6d ff ff ff       	call   800bde <_pipeisclosed>
  800c71:	85 c0                	test   %eax,%eax
  800c73:	75 48                	jne    800cbd <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c75:	e8 d1 f4 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c7a:	8b 43 04             	mov    0x4(%ebx),%eax
  800c7d:	8b 0b                	mov    (%ebx),%ecx
  800c7f:	8d 51 20             	lea    0x20(%ecx),%edx
  800c82:	39 d0                	cmp    %edx,%eax
  800c84:	73 e2                	jae    800c68 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c89:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c8d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c90:	89 c2                	mov    %eax,%edx
  800c92:	c1 fa 1f             	sar    $0x1f,%edx
  800c95:	89 d1                	mov    %edx,%ecx
  800c97:	c1 e9 1b             	shr    $0x1b,%ecx
  800c9a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c9d:	83 e2 1f             	and    $0x1f,%edx
  800ca0:	29 ca                	sub    %ecx,%edx
  800ca2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ca6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800caa:	83 c0 01             	add    $0x1,%eax
  800cad:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cb0:	83 c7 01             	add    $0x1,%edi
  800cb3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cb6:	75 c2                	jne    800c7a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cb8:	8b 45 10             	mov    0x10(%ebp),%eax
  800cbb:	eb 05                	jmp    800cc2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cbd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    

00800cca <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
  800cd0:	83 ec 18             	sub    $0x18,%esp
  800cd3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cd6:	57                   	push   %edi
  800cd7:	e8 8f f6 ff ff       	call   80036b <fd2data>
  800cdc:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cde:	83 c4 10             	add    $0x10,%esp
  800ce1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce6:	eb 3d                	jmp    800d25 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ce8:	85 db                	test   %ebx,%ebx
  800cea:	74 04                	je     800cf0 <devpipe_read+0x26>
				return i;
  800cec:	89 d8                	mov    %ebx,%eax
  800cee:	eb 44                	jmp    800d34 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cf0:	89 f2                	mov    %esi,%edx
  800cf2:	89 f8                	mov    %edi,%eax
  800cf4:	e8 e5 fe ff ff       	call   800bde <_pipeisclosed>
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	75 32                	jne    800d2f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cfd:	e8 49 f4 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d02:	8b 06                	mov    (%esi),%eax
  800d04:	3b 46 04             	cmp    0x4(%esi),%eax
  800d07:	74 df                	je     800ce8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d09:	99                   	cltd   
  800d0a:	c1 ea 1b             	shr    $0x1b,%edx
  800d0d:	01 d0                	add    %edx,%eax
  800d0f:	83 e0 1f             	and    $0x1f,%eax
  800d12:	29 d0                	sub    %edx,%eax
  800d14:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d1f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d22:	83 c3 01             	add    $0x1,%ebx
  800d25:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d28:	75 d8                	jne    800d02 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d2a:	8b 45 10             	mov    0x10(%ebp),%eax
  800d2d:	eb 05                	jmp    800d34 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d2f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d47:	50                   	push   %eax
  800d48:	e8 35 f6 ff ff       	call   800382 <fd_alloc>
  800d4d:	83 c4 10             	add    $0x10,%esp
  800d50:	89 c2                	mov    %eax,%edx
  800d52:	85 c0                	test   %eax,%eax
  800d54:	0f 88 2c 01 00 00    	js     800e86 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d5a:	83 ec 04             	sub    $0x4,%esp
  800d5d:	68 07 04 00 00       	push   $0x407
  800d62:	ff 75 f4             	pushl  -0xc(%ebp)
  800d65:	6a 00                	push   $0x0
  800d67:	e8 fe f3 ff ff       	call   80016a <sys_page_alloc>
  800d6c:	83 c4 10             	add    $0x10,%esp
  800d6f:	89 c2                	mov    %eax,%edx
  800d71:	85 c0                	test   %eax,%eax
  800d73:	0f 88 0d 01 00 00    	js     800e86 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d79:	83 ec 0c             	sub    $0xc,%esp
  800d7c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d7f:	50                   	push   %eax
  800d80:	e8 fd f5 ff ff       	call   800382 <fd_alloc>
  800d85:	89 c3                	mov    %eax,%ebx
  800d87:	83 c4 10             	add    $0x10,%esp
  800d8a:	85 c0                	test   %eax,%eax
  800d8c:	0f 88 e2 00 00 00    	js     800e74 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d92:	83 ec 04             	sub    $0x4,%esp
  800d95:	68 07 04 00 00       	push   $0x407
  800d9a:	ff 75 f0             	pushl  -0x10(%ebp)
  800d9d:	6a 00                	push   $0x0
  800d9f:	e8 c6 f3 ff ff       	call   80016a <sys_page_alloc>
  800da4:	89 c3                	mov    %eax,%ebx
  800da6:	83 c4 10             	add    $0x10,%esp
  800da9:	85 c0                	test   %eax,%eax
  800dab:	0f 88 c3 00 00 00    	js     800e74 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800db1:	83 ec 0c             	sub    $0xc,%esp
  800db4:	ff 75 f4             	pushl  -0xc(%ebp)
  800db7:	e8 af f5 ff ff       	call   80036b <fd2data>
  800dbc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dbe:	83 c4 0c             	add    $0xc,%esp
  800dc1:	68 07 04 00 00       	push   $0x407
  800dc6:	50                   	push   %eax
  800dc7:	6a 00                	push   $0x0
  800dc9:	e8 9c f3 ff ff       	call   80016a <sys_page_alloc>
  800dce:	89 c3                	mov    %eax,%ebx
  800dd0:	83 c4 10             	add    $0x10,%esp
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	0f 88 89 00 00 00    	js     800e64 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ddb:	83 ec 0c             	sub    $0xc,%esp
  800dde:	ff 75 f0             	pushl  -0x10(%ebp)
  800de1:	e8 85 f5 ff ff       	call   80036b <fd2data>
  800de6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800ded:	50                   	push   %eax
  800dee:	6a 00                	push   $0x0
  800df0:	56                   	push   %esi
  800df1:	6a 00                	push   $0x0
  800df3:	e8 b5 f3 ff ff       	call   8001ad <sys_page_map>
  800df8:	89 c3                	mov    %eax,%ebx
  800dfa:	83 c4 20             	add    $0x20,%esp
  800dfd:	85 c0                	test   %eax,%eax
  800dff:	78 55                	js     800e56 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e01:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e0a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e0f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e16:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e1f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e21:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e24:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e2b:	83 ec 0c             	sub    $0xc,%esp
  800e2e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e31:	e8 25 f5 ff ff       	call   80035b <fd2num>
  800e36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e39:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e3b:	83 c4 04             	add    $0x4,%esp
  800e3e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e41:	e8 15 f5 ff ff       	call   80035b <fd2num>
  800e46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e49:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e4c:	83 c4 10             	add    $0x10,%esp
  800e4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e54:	eb 30                	jmp    800e86 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e56:	83 ec 08             	sub    $0x8,%esp
  800e59:	56                   	push   %esi
  800e5a:	6a 00                	push   $0x0
  800e5c:	e8 8e f3 ff ff       	call   8001ef <sys_page_unmap>
  800e61:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e64:	83 ec 08             	sub    $0x8,%esp
  800e67:	ff 75 f0             	pushl  -0x10(%ebp)
  800e6a:	6a 00                	push   $0x0
  800e6c:	e8 7e f3 ff ff       	call   8001ef <sys_page_unmap>
  800e71:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e74:	83 ec 08             	sub    $0x8,%esp
  800e77:	ff 75 f4             	pushl  -0xc(%ebp)
  800e7a:	6a 00                	push   $0x0
  800e7c:	e8 6e f3 ff ff       	call   8001ef <sys_page_unmap>
  800e81:	83 c4 10             	add    $0x10,%esp
  800e84:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e86:	89 d0                	mov    %edx,%eax
  800e88:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e8b:	5b                   	pop    %ebx
  800e8c:	5e                   	pop    %esi
  800e8d:	5d                   	pop    %ebp
  800e8e:	c3                   	ret    

00800e8f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e95:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e98:	50                   	push   %eax
  800e99:	ff 75 08             	pushl  0x8(%ebp)
  800e9c:	e8 30 f5 ff ff       	call   8003d1 <fd_lookup>
  800ea1:	83 c4 10             	add    $0x10,%esp
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	78 18                	js     800ec0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ea8:	83 ec 0c             	sub    $0xc,%esp
  800eab:	ff 75 f4             	pushl  -0xc(%ebp)
  800eae:	e8 b8 f4 ff ff       	call   80036b <fd2data>
	return _pipeisclosed(fd, p);
  800eb3:	89 c2                	mov    %eax,%edx
  800eb5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb8:	e8 21 fd ff ff       	call   800bde <_pipeisclosed>
  800ebd:	83 c4 10             	add    $0x10,%esp
}
  800ec0:	c9                   	leave  
  800ec1:	c3                   	ret    

00800ec2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ec2:	55                   	push   %ebp
  800ec3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ec5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    

00800ecc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ed2:	68 62 1f 80 00       	push   $0x801f62
  800ed7:	ff 75 0c             	pushl  0xc(%ebp)
  800eda:	e8 43 08 00 00       	call   801722 <strcpy>
	return 0;
}
  800edf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee4:	c9                   	leave  
  800ee5:	c3                   	ret    

00800ee6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	57                   	push   %edi
  800eea:	56                   	push   %esi
  800eeb:	53                   	push   %ebx
  800eec:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ef7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800efd:	eb 2d                	jmp    800f2c <devcons_write+0x46>
		m = n - tot;
  800eff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f02:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f04:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f07:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f0c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f0f:	83 ec 04             	sub    $0x4,%esp
  800f12:	53                   	push   %ebx
  800f13:	03 45 0c             	add    0xc(%ebp),%eax
  800f16:	50                   	push   %eax
  800f17:	57                   	push   %edi
  800f18:	e8 97 09 00 00       	call   8018b4 <memmove>
		sys_cputs(buf, m);
  800f1d:	83 c4 08             	add    $0x8,%esp
  800f20:	53                   	push   %ebx
  800f21:	57                   	push   %edi
  800f22:	e8 87 f1 ff ff       	call   8000ae <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f27:	01 de                	add    %ebx,%esi
  800f29:	83 c4 10             	add    $0x10,%esp
  800f2c:	89 f0                	mov    %esi,%eax
  800f2e:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f31:	72 cc                	jb     800eff <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f36:	5b                   	pop    %ebx
  800f37:	5e                   	pop    %esi
  800f38:	5f                   	pop    %edi
  800f39:	5d                   	pop    %ebp
  800f3a:	c3                   	ret    

00800f3b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	83 ec 08             	sub    $0x8,%esp
  800f41:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f46:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f4a:	74 2a                	je     800f76 <devcons_read+0x3b>
  800f4c:	eb 05                	jmp    800f53 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f4e:	e8 f8 f1 ff ff       	call   80014b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f53:	e8 74 f1 ff ff       	call   8000cc <sys_cgetc>
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	74 f2                	je     800f4e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	78 16                	js     800f76 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f60:	83 f8 04             	cmp    $0x4,%eax
  800f63:	74 0c                	je     800f71 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f65:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f68:	88 02                	mov    %al,(%edx)
	return 1;
  800f6a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6f:	eb 05                	jmp    800f76 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f71:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f76:	c9                   	leave  
  800f77:	c3                   	ret    

00800f78 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f81:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f84:	6a 01                	push   $0x1
  800f86:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f89:	50                   	push   %eax
  800f8a:	e8 1f f1 ff ff       	call   8000ae <sys_cputs>
}
  800f8f:	83 c4 10             	add    $0x10,%esp
  800f92:	c9                   	leave  
  800f93:	c3                   	ret    

00800f94 <getchar>:

int
getchar(void)
{
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f9a:	6a 01                	push   $0x1
  800f9c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f9f:	50                   	push   %eax
  800fa0:	6a 00                	push   $0x0
  800fa2:	e8 90 f6 ff ff       	call   800637 <read>
	if (r < 0)
  800fa7:	83 c4 10             	add    $0x10,%esp
  800faa:	85 c0                	test   %eax,%eax
  800fac:	78 0f                	js     800fbd <getchar+0x29>
		return r;
	if (r < 1)
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	7e 06                	jle    800fb8 <getchar+0x24>
		return -E_EOF;
	return c;
  800fb2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fb6:	eb 05                	jmp    800fbd <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fb8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fbd:	c9                   	leave  
  800fbe:	c3                   	ret    

00800fbf <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fc5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc8:	50                   	push   %eax
  800fc9:	ff 75 08             	pushl  0x8(%ebp)
  800fcc:	e8 00 f4 ff ff       	call   8003d1 <fd_lookup>
  800fd1:	83 c4 10             	add    $0x10,%esp
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	78 11                	js     800fe9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fdb:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800fe1:	39 10                	cmp    %edx,(%eax)
  800fe3:	0f 94 c0             	sete   %al
  800fe6:	0f b6 c0             	movzbl %al,%eax
}
  800fe9:	c9                   	leave  
  800fea:	c3                   	ret    

00800feb <opencons>:

int
opencons(void)
{
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800ff1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff4:	50                   	push   %eax
  800ff5:	e8 88 f3 ff ff       	call   800382 <fd_alloc>
  800ffa:	83 c4 10             	add    $0x10,%esp
		return r;
  800ffd:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fff:	85 c0                	test   %eax,%eax
  801001:	78 3e                	js     801041 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801003:	83 ec 04             	sub    $0x4,%esp
  801006:	68 07 04 00 00       	push   $0x407
  80100b:	ff 75 f4             	pushl  -0xc(%ebp)
  80100e:	6a 00                	push   $0x0
  801010:	e8 55 f1 ff ff       	call   80016a <sys_page_alloc>
  801015:	83 c4 10             	add    $0x10,%esp
		return r;
  801018:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80101a:	85 c0                	test   %eax,%eax
  80101c:	78 23                	js     801041 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80101e:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801024:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801027:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801029:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80102c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801033:	83 ec 0c             	sub    $0xc,%esp
  801036:	50                   	push   %eax
  801037:	e8 1f f3 ff ff       	call   80035b <fd2num>
  80103c:	89 c2                	mov    %eax,%edx
  80103e:	83 c4 10             	add    $0x10,%esp
}
  801041:	89 d0                	mov    %edx,%eax
  801043:	c9                   	leave  
  801044:	c3                   	ret    

00801045 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801045:	55                   	push   %ebp
  801046:	89 e5                	mov    %esp,%ebp
  801048:	56                   	push   %esi
  801049:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80104a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80104d:	8b 35 04 30 80 00    	mov    0x803004,%esi
  801053:	e8 d4 f0 ff ff       	call   80012c <sys_getenvid>
  801058:	83 ec 0c             	sub    $0xc,%esp
  80105b:	ff 75 0c             	pushl  0xc(%ebp)
  80105e:	ff 75 08             	pushl  0x8(%ebp)
  801061:	56                   	push   %esi
  801062:	50                   	push   %eax
  801063:	68 70 1f 80 00       	push   $0x801f70
  801068:	e8 b1 00 00 00       	call   80111e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80106d:	83 c4 18             	add    $0x18,%esp
  801070:	53                   	push   %ebx
  801071:	ff 75 10             	pushl  0x10(%ebp)
  801074:	e8 54 00 00 00       	call   8010cd <vcprintf>
	cprintf("\n");
  801079:	c7 04 24 5b 1f 80 00 	movl   $0x801f5b,(%esp)
  801080:	e8 99 00 00 00       	call   80111e <cprintf>
  801085:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801088:	cc                   	int3   
  801089:	eb fd                	jmp    801088 <_panic+0x43>

0080108b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	53                   	push   %ebx
  80108f:	83 ec 04             	sub    $0x4,%esp
  801092:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801095:	8b 13                	mov    (%ebx),%edx
  801097:	8d 42 01             	lea    0x1(%edx),%eax
  80109a:	89 03                	mov    %eax,(%ebx)
  80109c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80109f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010a3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010a8:	75 1a                	jne    8010c4 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010aa:	83 ec 08             	sub    $0x8,%esp
  8010ad:	68 ff 00 00 00       	push   $0xff
  8010b2:	8d 43 08             	lea    0x8(%ebx),%eax
  8010b5:	50                   	push   %eax
  8010b6:	e8 f3 ef ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  8010bb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010c1:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010c4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010cb:	c9                   	leave  
  8010cc:	c3                   	ret    

008010cd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
  8010d0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010d6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010dd:	00 00 00 
	b.cnt = 0;
  8010e0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010e7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010ea:	ff 75 0c             	pushl  0xc(%ebp)
  8010ed:	ff 75 08             	pushl  0x8(%ebp)
  8010f0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010f6:	50                   	push   %eax
  8010f7:	68 8b 10 80 00       	push   $0x80108b
  8010fc:	e8 1a 01 00 00       	call   80121b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801101:	83 c4 08             	add    $0x8,%esp
  801104:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80110a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801110:	50                   	push   %eax
  801111:	e8 98 ef ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  801116:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80111c:	c9                   	leave  
  80111d:	c3                   	ret    

0080111e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80111e:	55                   	push   %ebp
  80111f:	89 e5                	mov    %esp,%ebp
  801121:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801124:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801127:	50                   	push   %eax
  801128:	ff 75 08             	pushl  0x8(%ebp)
  80112b:	e8 9d ff ff ff       	call   8010cd <vcprintf>
	va_end(ap);

	return cnt;
}
  801130:	c9                   	leave  
  801131:	c3                   	ret    

00801132 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801132:	55                   	push   %ebp
  801133:	89 e5                	mov    %esp,%ebp
  801135:	57                   	push   %edi
  801136:	56                   	push   %esi
  801137:	53                   	push   %ebx
  801138:	83 ec 1c             	sub    $0x1c,%esp
  80113b:	89 c7                	mov    %eax,%edi
  80113d:	89 d6                	mov    %edx,%esi
  80113f:	8b 45 08             	mov    0x8(%ebp),%eax
  801142:	8b 55 0c             	mov    0xc(%ebp),%edx
  801145:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801148:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80114b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80114e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801153:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801156:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801159:	39 d3                	cmp    %edx,%ebx
  80115b:	72 05                	jb     801162 <printnum+0x30>
  80115d:	39 45 10             	cmp    %eax,0x10(%ebp)
  801160:	77 45                	ja     8011a7 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801162:	83 ec 0c             	sub    $0xc,%esp
  801165:	ff 75 18             	pushl  0x18(%ebp)
  801168:	8b 45 14             	mov    0x14(%ebp),%eax
  80116b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80116e:	53                   	push   %ebx
  80116f:	ff 75 10             	pushl  0x10(%ebp)
  801172:	83 ec 08             	sub    $0x8,%esp
  801175:	ff 75 e4             	pushl  -0x1c(%ebp)
  801178:	ff 75 e0             	pushl  -0x20(%ebp)
  80117b:	ff 75 dc             	pushl  -0x24(%ebp)
  80117e:	ff 75 d8             	pushl  -0x28(%ebp)
  801181:	e8 1a 0a 00 00       	call   801ba0 <__udivdi3>
  801186:	83 c4 18             	add    $0x18,%esp
  801189:	52                   	push   %edx
  80118a:	50                   	push   %eax
  80118b:	89 f2                	mov    %esi,%edx
  80118d:	89 f8                	mov    %edi,%eax
  80118f:	e8 9e ff ff ff       	call   801132 <printnum>
  801194:	83 c4 20             	add    $0x20,%esp
  801197:	eb 18                	jmp    8011b1 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801199:	83 ec 08             	sub    $0x8,%esp
  80119c:	56                   	push   %esi
  80119d:	ff 75 18             	pushl  0x18(%ebp)
  8011a0:	ff d7                	call   *%edi
  8011a2:	83 c4 10             	add    $0x10,%esp
  8011a5:	eb 03                	jmp    8011aa <printnum+0x78>
  8011a7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011aa:	83 eb 01             	sub    $0x1,%ebx
  8011ad:	85 db                	test   %ebx,%ebx
  8011af:	7f e8                	jg     801199 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011b1:	83 ec 08             	sub    $0x8,%esp
  8011b4:	56                   	push   %esi
  8011b5:	83 ec 04             	sub    $0x4,%esp
  8011b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8011be:	ff 75 dc             	pushl  -0x24(%ebp)
  8011c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8011c4:	e8 07 0b 00 00       	call   801cd0 <__umoddi3>
  8011c9:	83 c4 14             	add    $0x14,%esp
  8011cc:	0f be 80 93 1f 80 00 	movsbl 0x801f93(%eax),%eax
  8011d3:	50                   	push   %eax
  8011d4:	ff d7                	call   *%edi
}
  8011d6:	83 c4 10             	add    $0x10,%esp
  8011d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011dc:	5b                   	pop    %ebx
  8011dd:	5e                   	pop    %esi
  8011de:	5f                   	pop    %edi
  8011df:	5d                   	pop    %ebp
  8011e0:	c3                   	ret    

008011e1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
  8011e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011e7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011eb:	8b 10                	mov    (%eax),%edx
  8011ed:	3b 50 04             	cmp    0x4(%eax),%edx
  8011f0:	73 0a                	jae    8011fc <sprintputch+0x1b>
		*b->buf++ = ch;
  8011f2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011f5:	89 08                	mov    %ecx,(%eax)
  8011f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011fa:	88 02                	mov    %al,(%edx)
}
  8011fc:	5d                   	pop    %ebp
  8011fd:	c3                   	ret    

008011fe <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011fe:	55                   	push   %ebp
  8011ff:	89 e5                	mov    %esp,%ebp
  801201:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801204:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801207:	50                   	push   %eax
  801208:	ff 75 10             	pushl  0x10(%ebp)
  80120b:	ff 75 0c             	pushl  0xc(%ebp)
  80120e:	ff 75 08             	pushl  0x8(%ebp)
  801211:	e8 05 00 00 00       	call   80121b <vprintfmt>
	va_end(ap);
}
  801216:	83 c4 10             	add    $0x10,%esp
  801219:	c9                   	leave  
  80121a:	c3                   	ret    

0080121b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	57                   	push   %edi
  80121f:	56                   	push   %esi
  801220:	53                   	push   %ebx
  801221:	83 ec 2c             	sub    $0x2c,%esp
  801224:	8b 75 08             	mov    0x8(%ebp),%esi
  801227:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80122a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80122d:	eb 12                	jmp    801241 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80122f:	85 c0                	test   %eax,%eax
  801231:	0f 84 42 04 00 00    	je     801679 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  801237:	83 ec 08             	sub    $0x8,%esp
  80123a:	53                   	push   %ebx
  80123b:	50                   	push   %eax
  80123c:	ff d6                	call   *%esi
  80123e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801241:	83 c7 01             	add    $0x1,%edi
  801244:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801248:	83 f8 25             	cmp    $0x25,%eax
  80124b:	75 e2                	jne    80122f <vprintfmt+0x14>
  80124d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801251:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801258:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80125f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801266:	b9 00 00 00 00       	mov    $0x0,%ecx
  80126b:	eb 07                	jmp    801274 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80126d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801270:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801274:	8d 47 01             	lea    0x1(%edi),%eax
  801277:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80127a:	0f b6 07             	movzbl (%edi),%eax
  80127d:	0f b6 d0             	movzbl %al,%edx
  801280:	83 e8 23             	sub    $0x23,%eax
  801283:	3c 55                	cmp    $0x55,%al
  801285:	0f 87 d3 03 00 00    	ja     80165e <vprintfmt+0x443>
  80128b:	0f b6 c0             	movzbl %al,%eax
  80128e:	ff 24 85 e0 20 80 00 	jmp    *0x8020e0(,%eax,4)
  801295:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801298:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80129c:	eb d6                	jmp    801274 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80129e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012a9:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012ac:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8012b0:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8012b3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8012b6:	83 f9 09             	cmp    $0x9,%ecx
  8012b9:	77 3f                	ja     8012fa <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012bb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012be:	eb e9                	jmp    8012a9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c3:	8b 00                	mov    (%eax),%eax
  8012c5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8012cb:	8d 40 04             	lea    0x4(%eax),%eax
  8012ce:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012d4:	eb 2a                	jmp    801300 <vprintfmt+0xe5>
  8012d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012d9:	85 c0                	test   %eax,%eax
  8012db:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e0:	0f 49 d0             	cmovns %eax,%edx
  8012e3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012e9:	eb 89                	jmp    801274 <vprintfmt+0x59>
  8012eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012ee:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012f5:	e9 7a ff ff ff       	jmp    801274 <vprintfmt+0x59>
  8012fa:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012fd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801300:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801304:	0f 89 6a ff ff ff    	jns    801274 <vprintfmt+0x59>
				width = precision, precision = -1;
  80130a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80130d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801310:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801317:	e9 58 ff ff ff       	jmp    801274 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80131c:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801322:	e9 4d ff ff ff       	jmp    801274 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801327:	8b 45 14             	mov    0x14(%ebp),%eax
  80132a:	8d 78 04             	lea    0x4(%eax),%edi
  80132d:	83 ec 08             	sub    $0x8,%esp
  801330:	53                   	push   %ebx
  801331:	ff 30                	pushl  (%eax)
  801333:	ff d6                	call   *%esi
			break;
  801335:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801338:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80133b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80133e:	e9 fe fe ff ff       	jmp    801241 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801343:	8b 45 14             	mov    0x14(%ebp),%eax
  801346:	8d 78 04             	lea    0x4(%eax),%edi
  801349:	8b 00                	mov    (%eax),%eax
  80134b:	99                   	cltd   
  80134c:	31 d0                	xor    %edx,%eax
  80134e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801350:	83 f8 0f             	cmp    $0xf,%eax
  801353:	7f 0b                	jg     801360 <vprintfmt+0x145>
  801355:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  80135c:	85 d2                	test   %edx,%edx
  80135e:	75 1b                	jne    80137b <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  801360:	50                   	push   %eax
  801361:	68 ab 1f 80 00       	push   $0x801fab
  801366:	53                   	push   %ebx
  801367:	56                   	push   %esi
  801368:	e8 91 fe ff ff       	call   8011fe <printfmt>
  80136d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801370:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801373:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801376:	e9 c6 fe ff ff       	jmp    801241 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80137b:	52                   	push   %edx
  80137c:	68 29 1f 80 00       	push   $0x801f29
  801381:	53                   	push   %ebx
  801382:	56                   	push   %esi
  801383:	e8 76 fe ff ff       	call   8011fe <printfmt>
  801388:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80138b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80138e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801391:	e9 ab fe ff ff       	jmp    801241 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801396:	8b 45 14             	mov    0x14(%ebp),%eax
  801399:	83 c0 04             	add    $0x4,%eax
  80139c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80139f:	8b 45 14             	mov    0x14(%ebp),%eax
  8013a2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013a4:	85 ff                	test   %edi,%edi
  8013a6:	b8 a4 1f 80 00       	mov    $0x801fa4,%eax
  8013ab:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013ae:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013b2:	0f 8e 94 00 00 00    	jle    80144c <vprintfmt+0x231>
  8013b8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013bc:	0f 84 98 00 00 00    	je     80145a <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013c2:	83 ec 08             	sub    $0x8,%esp
  8013c5:	ff 75 d0             	pushl  -0x30(%ebp)
  8013c8:	57                   	push   %edi
  8013c9:	e8 33 03 00 00       	call   801701 <strnlen>
  8013ce:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013d1:	29 c1                	sub    %eax,%ecx
  8013d3:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013d6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013d9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013e0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013e3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e5:	eb 0f                	jmp    8013f6 <vprintfmt+0x1db>
					putch(padc, putdat);
  8013e7:	83 ec 08             	sub    $0x8,%esp
  8013ea:	53                   	push   %ebx
  8013eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8013ee:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013f0:	83 ef 01             	sub    $0x1,%edi
  8013f3:	83 c4 10             	add    $0x10,%esp
  8013f6:	85 ff                	test   %edi,%edi
  8013f8:	7f ed                	jg     8013e7 <vprintfmt+0x1cc>
  8013fa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013fd:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  801400:	85 c9                	test   %ecx,%ecx
  801402:	b8 00 00 00 00       	mov    $0x0,%eax
  801407:	0f 49 c1             	cmovns %ecx,%eax
  80140a:	29 c1                	sub    %eax,%ecx
  80140c:	89 75 08             	mov    %esi,0x8(%ebp)
  80140f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801412:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801415:	89 cb                	mov    %ecx,%ebx
  801417:	eb 4d                	jmp    801466 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801419:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80141d:	74 1b                	je     80143a <vprintfmt+0x21f>
  80141f:	0f be c0             	movsbl %al,%eax
  801422:	83 e8 20             	sub    $0x20,%eax
  801425:	83 f8 5e             	cmp    $0x5e,%eax
  801428:	76 10                	jbe    80143a <vprintfmt+0x21f>
					putch('?', putdat);
  80142a:	83 ec 08             	sub    $0x8,%esp
  80142d:	ff 75 0c             	pushl  0xc(%ebp)
  801430:	6a 3f                	push   $0x3f
  801432:	ff 55 08             	call   *0x8(%ebp)
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	eb 0d                	jmp    801447 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80143a:	83 ec 08             	sub    $0x8,%esp
  80143d:	ff 75 0c             	pushl  0xc(%ebp)
  801440:	52                   	push   %edx
  801441:	ff 55 08             	call   *0x8(%ebp)
  801444:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801447:	83 eb 01             	sub    $0x1,%ebx
  80144a:	eb 1a                	jmp    801466 <vprintfmt+0x24b>
  80144c:	89 75 08             	mov    %esi,0x8(%ebp)
  80144f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801452:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801455:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801458:	eb 0c                	jmp    801466 <vprintfmt+0x24b>
  80145a:	89 75 08             	mov    %esi,0x8(%ebp)
  80145d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801460:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801463:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801466:	83 c7 01             	add    $0x1,%edi
  801469:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80146d:	0f be d0             	movsbl %al,%edx
  801470:	85 d2                	test   %edx,%edx
  801472:	74 23                	je     801497 <vprintfmt+0x27c>
  801474:	85 f6                	test   %esi,%esi
  801476:	78 a1                	js     801419 <vprintfmt+0x1fe>
  801478:	83 ee 01             	sub    $0x1,%esi
  80147b:	79 9c                	jns    801419 <vprintfmt+0x1fe>
  80147d:	89 df                	mov    %ebx,%edi
  80147f:	8b 75 08             	mov    0x8(%ebp),%esi
  801482:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801485:	eb 18                	jmp    80149f <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801487:	83 ec 08             	sub    $0x8,%esp
  80148a:	53                   	push   %ebx
  80148b:	6a 20                	push   $0x20
  80148d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80148f:	83 ef 01             	sub    $0x1,%edi
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	eb 08                	jmp    80149f <vprintfmt+0x284>
  801497:	89 df                	mov    %ebx,%edi
  801499:	8b 75 08             	mov    0x8(%ebp),%esi
  80149c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80149f:	85 ff                	test   %edi,%edi
  8014a1:	7f e4                	jg     801487 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8014a3:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8014a6:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014ac:	e9 90 fd ff ff       	jmp    801241 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014b1:	83 f9 01             	cmp    $0x1,%ecx
  8014b4:	7e 19                	jle    8014cf <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8014b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b9:	8b 50 04             	mov    0x4(%eax),%edx
  8014bc:	8b 00                	mov    (%eax),%eax
  8014be:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014c1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c7:	8d 40 08             	lea    0x8(%eax),%eax
  8014ca:	89 45 14             	mov    %eax,0x14(%ebp)
  8014cd:	eb 38                	jmp    801507 <vprintfmt+0x2ec>
	else if (lflag)
  8014cf:	85 c9                	test   %ecx,%ecx
  8014d1:	74 1b                	je     8014ee <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8014d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d6:	8b 00                	mov    (%eax),%eax
  8014d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014db:	89 c1                	mov    %eax,%ecx
  8014dd:	c1 f9 1f             	sar    $0x1f,%ecx
  8014e0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e6:	8d 40 04             	lea    0x4(%eax),%eax
  8014e9:	89 45 14             	mov    %eax,0x14(%ebp)
  8014ec:	eb 19                	jmp    801507 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8014ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f1:	8b 00                	mov    (%eax),%eax
  8014f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f6:	89 c1                	mov    %eax,%ecx
  8014f8:	c1 f9 1f             	sar    $0x1f,%ecx
  8014fb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014fe:	8b 45 14             	mov    0x14(%ebp),%eax
  801501:	8d 40 04             	lea    0x4(%eax),%eax
  801504:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801507:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80150a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80150d:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801512:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801516:	0f 89 0e 01 00 00    	jns    80162a <vprintfmt+0x40f>
				putch('-', putdat);
  80151c:	83 ec 08             	sub    $0x8,%esp
  80151f:	53                   	push   %ebx
  801520:	6a 2d                	push   $0x2d
  801522:	ff d6                	call   *%esi
				num = -(long long) num;
  801524:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801527:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80152a:	f7 da                	neg    %edx
  80152c:	83 d1 00             	adc    $0x0,%ecx
  80152f:	f7 d9                	neg    %ecx
  801531:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801534:	b8 0a 00 00 00       	mov    $0xa,%eax
  801539:	e9 ec 00 00 00       	jmp    80162a <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80153e:	83 f9 01             	cmp    $0x1,%ecx
  801541:	7e 18                	jle    80155b <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  801543:	8b 45 14             	mov    0x14(%ebp),%eax
  801546:	8b 10                	mov    (%eax),%edx
  801548:	8b 48 04             	mov    0x4(%eax),%ecx
  80154b:	8d 40 08             	lea    0x8(%eax),%eax
  80154e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801551:	b8 0a 00 00 00       	mov    $0xa,%eax
  801556:	e9 cf 00 00 00       	jmp    80162a <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80155b:	85 c9                	test   %ecx,%ecx
  80155d:	74 1a                	je     801579 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80155f:	8b 45 14             	mov    0x14(%ebp),%eax
  801562:	8b 10                	mov    (%eax),%edx
  801564:	b9 00 00 00 00       	mov    $0x0,%ecx
  801569:	8d 40 04             	lea    0x4(%eax),%eax
  80156c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80156f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801574:	e9 b1 00 00 00       	jmp    80162a <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801579:	8b 45 14             	mov    0x14(%ebp),%eax
  80157c:	8b 10                	mov    (%eax),%edx
  80157e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801583:	8d 40 04             	lea    0x4(%eax),%eax
  801586:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801589:	b8 0a 00 00 00       	mov    $0xa,%eax
  80158e:	e9 97 00 00 00       	jmp    80162a <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801593:	83 ec 08             	sub    $0x8,%esp
  801596:	53                   	push   %ebx
  801597:	6a 58                	push   $0x58
  801599:	ff d6                	call   *%esi
			putch('X', putdat);
  80159b:	83 c4 08             	add    $0x8,%esp
  80159e:	53                   	push   %ebx
  80159f:	6a 58                	push   $0x58
  8015a1:	ff d6                	call   *%esi
			putch('X', putdat);
  8015a3:	83 c4 08             	add    $0x8,%esp
  8015a6:	53                   	push   %ebx
  8015a7:	6a 58                	push   $0x58
  8015a9:	ff d6                	call   *%esi
			break;
  8015ab:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8015b1:	e9 8b fc ff ff       	jmp    801241 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8015b6:	83 ec 08             	sub    $0x8,%esp
  8015b9:	53                   	push   %ebx
  8015ba:	6a 30                	push   $0x30
  8015bc:	ff d6                	call   *%esi
			putch('x', putdat);
  8015be:	83 c4 08             	add    $0x8,%esp
  8015c1:	53                   	push   %ebx
  8015c2:	6a 78                	push   $0x78
  8015c4:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c9:	8b 10                	mov    (%eax),%edx
  8015cb:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015d0:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015d3:	8d 40 04             	lea    0x4(%eax),%eax
  8015d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015d9:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015de:	eb 4a                	jmp    80162a <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015e0:	83 f9 01             	cmp    $0x1,%ecx
  8015e3:	7e 15                	jle    8015fa <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8015e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e8:	8b 10                	mov    (%eax),%edx
  8015ea:	8b 48 04             	mov    0x4(%eax),%ecx
  8015ed:	8d 40 08             	lea    0x8(%eax),%eax
  8015f0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8015f3:	b8 10 00 00 00       	mov    $0x10,%eax
  8015f8:	eb 30                	jmp    80162a <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8015fa:	85 c9                	test   %ecx,%ecx
  8015fc:	74 17                	je     801615 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8015fe:	8b 45 14             	mov    0x14(%ebp),%eax
  801601:	8b 10                	mov    (%eax),%edx
  801603:	b9 00 00 00 00       	mov    $0x0,%ecx
  801608:	8d 40 04             	lea    0x4(%eax),%eax
  80160b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80160e:	b8 10 00 00 00       	mov    $0x10,%eax
  801613:	eb 15                	jmp    80162a <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801615:	8b 45 14             	mov    0x14(%ebp),%eax
  801618:	8b 10                	mov    (%eax),%edx
  80161a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80161f:	8d 40 04             	lea    0x4(%eax),%eax
  801622:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801625:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80162a:	83 ec 0c             	sub    $0xc,%esp
  80162d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801631:	57                   	push   %edi
  801632:	ff 75 e0             	pushl  -0x20(%ebp)
  801635:	50                   	push   %eax
  801636:	51                   	push   %ecx
  801637:	52                   	push   %edx
  801638:	89 da                	mov    %ebx,%edx
  80163a:	89 f0                	mov    %esi,%eax
  80163c:	e8 f1 fa ff ff       	call   801132 <printnum>
			break;
  801641:	83 c4 20             	add    $0x20,%esp
  801644:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801647:	e9 f5 fb ff ff       	jmp    801241 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80164c:	83 ec 08             	sub    $0x8,%esp
  80164f:	53                   	push   %ebx
  801650:	52                   	push   %edx
  801651:	ff d6                	call   *%esi
			break;
  801653:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801656:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801659:	e9 e3 fb ff ff       	jmp    801241 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80165e:	83 ec 08             	sub    $0x8,%esp
  801661:	53                   	push   %ebx
  801662:	6a 25                	push   $0x25
  801664:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801666:	83 c4 10             	add    $0x10,%esp
  801669:	eb 03                	jmp    80166e <vprintfmt+0x453>
  80166b:	83 ef 01             	sub    $0x1,%edi
  80166e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801672:	75 f7                	jne    80166b <vprintfmt+0x450>
  801674:	e9 c8 fb ff ff       	jmp    801241 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801679:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80167c:	5b                   	pop    %ebx
  80167d:	5e                   	pop    %esi
  80167e:	5f                   	pop    %edi
  80167f:	5d                   	pop    %ebp
  801680:	c3                   	ret    

00801681 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	83 ec 18             	sub    $0x18,%esp
  801687:	8b 45 08             	mov    0x8(%ebp),%eax
  80168a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80168d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801690:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801694:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801697:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	74 26                	je     8016c8 <vsnprintf+0x47>
  8016a2:	85 d2                	test   %edx,%edx
  8016a4:	7e 22                	jle    8016c8 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8016a6:	ff 75 14             	pushl  0x14(%ebp)
  8016a9:	ff 75 10             	pushl  0x10(%ebp)
  8016ac:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016af:	50                   	push   %eax
  8016b0:	68 e1 11 80 00       	push   $0x8011e1
  8016b5:	e8 61 fb ff ff       	call   80121b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016ba:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016bd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c3:	83 c4 10             	add    $0x10,%esp
  8016c6:	eb 05                	jmp    8016cd <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016cd:	c9                   	leave  
  8016ce:	c3                   	ret    

008016cf <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016cf:	55                   	push   %ebp
  8016d0:	89 e5                	mov    %esp,%ebp
  8016d2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016d5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016d8:	50                   	push   %eax
  8016d9:	ff 75 10             	pushl  0x10(%ebp)
  8016dc:	ff 75 0c             	pushl  0xc(%ebp)
  8016df:	ff 75 08             	pushl  0x8(%ebp)
  8016e2:	e8 9a ff ff ff       	call   801681 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016e7:	c9                   	leave  
  8016e8:	c3                   	ret    

008016e9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
  8016ec:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f4:	eb 03                	jmp    8016f9 <strlen+0x10>
		n++;
  8016f6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016f9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016fd:	75 f7                	jne    8016f6 <strlen+0xd>
		n++;
	return n;
}
  8016ff:	5d                   	pop    %ebp
  801700:	c3                   	ret    

00801701 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801701:	55                   	push   %ebp
  801702:	89 e5                	mov    %esp,%ebp
  801704:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801707:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80170a:	ba 00 00 00 00       	mov    $0x0,%edx
  80170f:	eb 03                	jmp    801714 <strnlen+0x13>
		n++;
  801711:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801714:	39 c2                	cmp    %eax,%edx
  801716:	74 08                	je     801720 <strnlen+0x1f>
  801718:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80171c:	75 f3                	jne    801711 <strnlen+0x10>
  80171e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801720:	5d                   	pop    %ebp
  801721:	c3                   	ret    

00801722 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	53                   	push   %ebx
  801726:	8b 45 08             	mov    0x8(%ebp),%eax
  801729:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80172c:	89 c2                	mov    %eax,%edx
  80172e:	83 c2 01             	add    $0x1,%edx
  801731:	83 c1 01             	add    $0x1,%ecx
  801734:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801738:	88 5a ff             	mov    %bl,-0x1(%edx)
  80173b:	84 db                	test   %bl,%bl
  80173d:	75 ef                	jne    80172e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80173f:	5b                   	pop    %ebx
  801740:	5d                   	pop    %ebp
  801741:	c3                   	ret    

00801742 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	53                   	push   %ebx
  801746:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801749:	53                   	push   %ebx
  80174a:	e8 9a ff ff ff       	call   8016e9 <strlen>
  80174f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801752:	ff 75 0c             	pushl  0xc(%ebp)
  801755:	01 d8                	add    %ebx,%eax
  801757:	50                   	push   %eax
  801758:	e8 c5 ff ff ff       	call   801722 <strcpy>
	return dst;
}
  80175d:	89 d8                	mov    %ebx,%eax
  80175f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801762:	c9                   	leave  
  801763:	c3                   	ret    

00801764 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801764:	55                   	push   %ebp
  801765:	89 e5                	mov    %esp,%ebp
  801767:	56                   	push   %esi
  801768:	53                   	push   %ebx
  801769:	8b 75 08             	mov    0x8(%ebp),%esi
  80176c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80176f:	89 f3                	mov    %esi,%ebx
  801771:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801774:	89 f2                	mov    %esi,%edx
  801776:	eb 0f                	jmp    801787 <strncpy+0x23>
		*dst++ = *src;
  801778:	83 c2 01             	add    $0x1,%edx
  80177b:	0f b6 01             	movzbl (%ecx),%eax
  80177e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801781:	80 39 01             	cmpb   $0x1,(%ecx)
  801784:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801787:	39 da                	cmp    %ebx,%edx
  801789:	75 ed                	jne    801778 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80178b:	89 f0                	mov    %esi,%eax
  80178d:	5b                   	pop    %ebx
  80178e:	5e                   	pop    %esi
  80178f:	5d                   	pop    %ebp
  801790:	c3                   	ret    

00801791 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801791:	55                   	push   %ebp
  801792:	89 e5                	mov    %esp,%ebp
  801794:	56                   	push   %esi
  801795:	53                   	push   %ebx
  801796:	8b 75 08             	mov    0x8(%ebp),%esi
  801799:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80179c:	8b 55 10             	mov    0x10(%ebp),%edx
  80179f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8017a1:	85 d2                	test   %edx,%edx
  8017a3:	74 21                	je     8017c6 <strlcpy+0x35>
  8017a5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8017a9:	89 f2                	mov    %esi,%edx
  8017ab:	eb 09                	jmp    8017b6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017ad:	83 c2 01             	add    $0x1,%edx
  8017b0:	83 c1 01             	add    $0x1,%ecx
  8017b3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017b6:	39 c2                	cmp    %eax,%edx
  8017b8:	74 09                	je     8017c3 <strlcpy+0x32>
  8017ba:	0f b6 19             	movzbl (%ecx),%ebx
  8017bd:	84 db                	test   %bl,%bl
  8017bf:	75 ec                	jne    8017ad <strlcpy+0x1c>
  8017c1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017c3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017c6:	29 f0                	sub    %esi,%eax
}
  8017c8:	5b                   	pop    %ebx
  8017c9:	5e                   	pop    %esi
  8017ca:	5d                   	pop    %ebp
  8017cb:	c3                   	ret    

008017cc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017d2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017d5:	eb 06                	jmp    8017dd <strcmp+0x11>
		p++, q++;
  8017d7:	83 c1 01             	add    $0x1,%ecx
  8017da:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017dd:	0f b6 01             	movzbl (%ecx),%eax
  8017e0:	84 c0                	test   %al,%al
  8017e2:	74 04                	je     8017e8 <strcmp+0x1c>
  8017e4:	3a 02                	cmp    (%edx),%al
  8017e6:	74 ef                	je     8017d7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017e8:	0f b6 c0             	movzbl %al,%eax
  8017eb:	0f b6 12             	movzbl (%edx),%edx
  8017ee:	29 d0                	sub    %edx,%eax
}
  8017f0:	5d                   	pop    %ebp
  8017f1:	c3                   	ret    

008017f2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	53                   	push   %ebx
  8017f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017fc:	89 c3                	mov    %eax,%ebx
  8017fe:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801801:	eb 06                	jmp    801809 <strncmp+0x17>
		n--, p++, q++;
  801803:	83 c0 01             	add    $0x1,%eax
  801806:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801809:	39 d8                	cmp    %ebx,%eax
  80180b:	74 15                	je     801822 <strncmp+0x30>
  80180d:	0f b6 08             	movzbl (%eax),%ecx
  801810:	84 c9                	test   %cl,%cl
  801812:	74 04                	je     801818 <strncmp+0x26>
  801814:	3a 0a                	cmp    (%edx),%cl
  801816:	74 eb                	je     801803 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801818:	0f b6 00             	movzbl (%eax),%eax
  80181b:	0f b6 12             	movzbl (%edx),%edx
  80181e:	29 d0                	sub    %edx,%eax
  801820:	eb 05                	jmp    801827 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801822:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801827:	5b                   	pop    %ebx
  801828:	5d                   	pop    %ebp
  801829:	c3                   	ret    

0080182a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80182a:	55                   	push   %ebp
  80182b:	89 e5                	mov    %esp,%ebp
  80182d:	8b 45 08             	mov    0x8(%ebp),%eax
  801830:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801834:	eb 07                	jmp    80183d <strchr+0x13>
		if (*s == c)
  801836:	38 ca                	cmp    %cl,%dl
  801838:	74 0f                	je     801849 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80183a:	83 c0 01             	add    $0x1,%eax
  80183d:	0f b6 10             	movzbl (%eax),%edx
  801840:	84 d2                	test   %dl,%dl
  801842:	75 f2                	jne    801836 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801844:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801849:	5d                   	pop    %ebp
  80184a:	c3                   	ret    

0080184b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	8b 45 08             	mov    0x8(%ebp),%eax
  801851:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801855:	eb 03                	jmp    80185a <strfind+0xf>
  801857:	83 c0 01             	add    $0x1,%eax
  80185a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80185d:	38 ca                	cmp    %cl,%dl
  80185f:	74 04                	je     801865 <strfind+0x1a>
  801861:	84 d2                	test   %dl,%dl
  801863:	75 f2                	jne    801857 <strfind+0xc>
			break;
	return (char *) s;
}
  801865:	5d                   	pop    %ebp
  801866:	c3                   	ret    

00801867 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801867:	55                   	push   %ebp
  801868:	89 e5                	mov    %esp,%ebp
  80186a:	57                   	push   %edi
  80186b:	56                   	push   %esi
  80186c:	53                   	push   %ebx
  80186d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801870:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801873:	85 c9                	test   %ecx,%ecx
  801875:	74 36                	je     8018ad <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801877:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80187d:	75 28                	jne    8018a7 <memset+0x40>
  80187f:	f6 c1 03             	test   $0x3,%cl
  801882:	75 23                	jne    8018a7 <memset+0x40>
		c &= 0xFF;
  801884:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801888:	89 d3                	mov    %edx,%ebx
  80188a:	c1 e3 08             	shl    $0x8,%ebx
  80188d:	89 d6                	mov    %edx,%esi
  80188f:	c1 e6 18             	shl    $0x18,%esi
  801892:	89 d0                	mov    %edx,%eax
  801894:	c1 e0 10             	shl    $0x10,%eax
  801897:	09 f0                	or     %esi,%eax
  801899:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80189b:	89 d8                	mov    %ebx,%eax
  80189d:	09 d0                	or     %edx,%eax
  80189f:	c1 e9 02             	shr    $0x2,%ecx
  8018a2:	fc                   	cld    
  8018a3:	f3 ab                	rep stos %eax,%es:(%edi)
  8018a5:	eb 06                	jmp    8018ad <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8018a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018aa:	fc                   	cld    
  8018ab:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8018ad:	89 f8                	mov    %edi,%eax
  8018af:	5b                   	pop    %ebx
  8018b0:	5e                   	pop    %esi
  8018b1:	5f                   	pop    %edi
  8018b2:	5d                   	pop    %ebp
  8018b3:	c3                   	ret    

008018b4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018b4:	55                   	push   %ebp
  8018b5:	89 e5                	mov    %esp,%ebp
  8018b7:	57                   	push   %edi
  8018b8:	56                   	push   %esi
  8018b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018c2:	39 c6                	cmp    %eax,%esi
  8018c4:	73 35                	jae    8018fb <memmove+0x47>
  8018c6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018c9:	39 d0                	cmp    %edx,%eax
  8018cb:	73 2e                	jae    8018fb <memmove+0x47>
		s += n;
		d += n;
  8018cd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018d0:	89 d6                	mov    %edx,%esi
  8018d2:	09 fe                	or     %edi,%esi
  8018d4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018da:	75 13                	jne    8018ef <memmove+0x3b>
  8018dc:	f6 c1 03             	test   $0x3,%cl
  8018df:	75 0e                	jne    8018ef <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018e1:	83 ef 04             	sub    $0x4,%edi
  8018e4:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018e7:	c1 e9 02             	shr    $0x2,%ecx
  8018ea:	fd                   	std    
  8018eb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ed:	eb 09                	jmp    8018f8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018ef:	83 ef 01             	sub    $0x1,%edi
  8018f2:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018f5:	fd                   	std    
  8018f6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018f8:	fc                   	cld    
  8018f9:	eb 1d                	jmp    801918 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018fb:	89 f2                	mov    %esi,%edx
  8018fd:	09 c2                	or     %eax,%edx
  8018ff:	f6 c2 03             	test   $0x3,%dl
  801902:	75 0f                	jne    801913 <memmove+0x5f>
  801904:	f6 c1 03             	test   $0x3,%cl
  801907:	75 0a                	jne    801913 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801909:	c1 e9 02             	shr    $0x2,%ecx
  80190c:	89 c7                	mov    %eax,%edi
  80190e:	fc                   	cld    
  80190f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801911:	eb 05                	jmp    801918 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801913:	89 c7                	mov    %eax,%edi
  801915:	fc                   	cld    
  801916:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801918:	5e                   	pop    %esi
  801919:	5f                   	pop    %edi
  80191a:	5d                   	pop    %ebp
  80191b:	c3                   	ret    

0080191c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80191f:	ff 75 10             	pushl  0x10(%ebp)
  801922:	ff 75 0c             	pushl  0xc(%ebp)
  801925:	ff 75 08             	pushl  0x8(%ebp)
  801928:	e8 87 ff ff ff       	call   8018b4 <memmove>
}
  80192d:	c9                   	leave  
  80192e:	c3                   	ret    

0080192f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	56                   	push   %esi
  801933:	53                   	push   %ebx
  801934:	8b 45 08             	mov    0x8(%ebp),%eax
  801937:	8b 55 0c             	mov    0xc(%ebp),%edx
  80193a:	89 c6                	mov    %eax,%esi
  80193c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80193f:	eb 1a                	jmp    80195b <memcmp+0x2c>
		if (*s1 != *s2)
  801941:	0f b6 08             	movzbl (%eax),%ecx
  801944:	0f b6 1a             	movzbl (%edx),%ebx
  801947:	38 d9                	cmp    %bl,%cl
  801949:	74 0a                	je     801955 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80194b:	0f b6 c1             	movzbl %cl,%eax
  80194e:	0f b6 db             	movzbl %bl,%ebx
  801951:	29 d8                	sub    %ebx,%eax
  801953:	eb 0f                	jmp    801964 <memcmp+0x35>
		s1++, s2++;
  801955:	83 c0 01             	add    $0x1,%eax
  801958:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80195b:	39 f0                	cmp    %esi,%eax
  80195d:	75 e2                	jne    801941 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80195f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801964:	5b                   	pop    %ebx
  801965:	5e                   	pop    %esi
  801966:	5d                   	pop    %ebp
  801967:	c3                   	ret    

00801968 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
  80196b:	53                   	push   %ebx
  80196c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80196f:	89 c1                	mov    %eax,%ecx
  801971:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801974:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801978:	eb 0a                	jmp    801984 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80197a:	0f b6 10             	movzbl (%eax),%edx
  80197d:	39 da                	cmp    %ebx,%edx
  80197f:	74 07                	je     801988 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801981:	83 c0 01             	add    $0x1,%eax
  801984:	39 c8                	cmp    %ecx,%eax
  801986:	72 f2                	jb     80197a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801988:	5b                   	pop    %ebx
  801989:	5d                   	pop    %ebp
  80198a:	c3                   	ret    

0080198b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80198b:	55                   	push   %ebp
  80198c:	89 e5                	mov    %esp,%ebp
  80198e:	57                   	push   %edi
  80198f:	56                   	push   %esi
  801990:	53                   	push   %ebx
  801991:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801994:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801997:	eb 03                	jmp    80199c <strtol+0x11>
		s++;
  801999:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80199c:	0f b6 01             	movzbl (%ecx),%eax
  80199f:	3c 20                	cmp    $0x20,%al
  8019a1:	74 f6                	je     801999 <strtol+0xe>
  8019a3:	3c 09                	cmp    $0x9,%al
  8019a5:	74 f2                	je     801999 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8019a7:	3c 2b                	cmp    $0x2b,%al
  8019a9:	75 0a                	jne    8019b5 <strtol+0x2a>
		s++;
  8019ab:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019ae:	bf 00 00 00 00       	mov    $0x0,%edi
  8019b3:	eb 11                	jmp    8019c6 <strtol+0x3b>
  8019b5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019ba:	3c 2d                	cmp    $0x2d,%al
  8019bc:	75 08                	jne    8019c6 <strtol+0x3b>
		s++, neg = 1;
  8019be:	83 c1 01             	add    $0x1,%ecx
  8019c1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019c6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019cc:	75 15                	jne    8019e3 <strtol+0x58>
  8019ce:	80 39 30             	cmpb   $0x30,(%ecx)
  8019d1:	75 10                	jne    8019e3 <strtol+0x58>
  8019d3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019d7:	75 7c                	jne    801a55 <strtol+0xca>
		s += 2, base = 16;
  8019d9:	83 c1 02             	add    $0x2,%ecx
  8019dc:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019e1:	eb 16                	jmp    8019f9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019e3:	85 db                	test   %ebx,%ebx
  8019e5:	75 12                	jne    8019f9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019e7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019ec:	80 39 30             	cmpb   $0x30,(%ecx)
  8019ef:	75 08                	jne    8019f9 <strtol+0x6e>
		s++, base = 8;
  8019f1:	83 c1 01             	add    $0x1,%ecx
  8019f4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8019fe:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801a01:	0f b6 11             	movzbl (%ecx),%edx
  801a04:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a07:	89 f3                	mov    %esi,%ebx
  801a09:	80 fb 09             	cmp    $0x9,%bl
  801a0c:	77 08                	ja     801a16 <strtol+0x8b>
			dig = *s - '0';
  801a0e:	0f be d2             	movsbl %dl,%edx
  801a11:	83 ea 30             	sub    $0x30,%edx
  801a14:	eb 22                	jmp    801a38 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a16:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a19:	89 f3                	mov    %esi,%ebx
  801a1b:	80 fb 19             	cmp    $0x19,%bl
  801a1e:	77 08                	ja     801a28 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a20:	0f be d2             	movsbl %dl,%edx
  801a23:	83 ea 57             	sub    $0x57,%edx
  801a26:	eb 10                	jmp    801a38 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a28:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a2b:	89 f3                	mov    %esi,%ebx
  801a2d:	80 fb 19             	cmp    $0x19,%bl
  801a30:	77 16                	ja     801a48 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a32:	0f be d2             	movsbl %dl,%edx
  801a35:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a38:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a3b:	7d 0b                	jge    801a48 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a3d:	83 c1 01             	add    $0x1,%ecx
  801a40:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a44:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a46:	eb b9                	jmp    801a01 <strtol+0x76>

	if (endptr)
  801a48:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a4c:	74 0d                	je     801a5b <strtol+0xd0>
		*endptr = (char *) s;
  801a4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a51:	89 0e                	mov    %ecx,(%esi)
  801a53:	eb 06                	jmp    801a5b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a55:	85 db                	test   %ebx,%ebx
  801a57:	74 98                	je     8019f1 <strtol+0x66>
  801a59:	eb 9e                	jmp    8019f9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a5b:	89 c2                	mov    %eax,%edx
  801a5d:	f7 da                	neg    %edx
  801a5f:	85 ff                	test   %edi,%edi
  801a61:	0f 45 c2             	cmovne %edx,%eax
}
  801a64:	5b                   	pop    %ebx
  801a65:	5e                   	pop    %esi
  801a66:	5f                   	pop    %edi
  801a67:	5d                   	pop    %ebp
  801a68:	c3                   	ret    

00801a69 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a69:	55                   	push   %ebp
  801a6a:	89 e5                	mov    %esp,%ebp
  801a6c:	56                   	push   %esi
  801a6d:	53                   	push   %ebx
  801a6e:	8b 75 08             	mov    0x8(%ebp),%esi
  801a71:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a74:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801a77:	85 c0                	test   %eax,%eax
  801a79:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a7e:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801a81:	83 ec 0c             	sub    $0xc,%esp
  801a84:	50                   	push   %eax
  801a85:	e8 90 e8 ff ff       	call   80031a <sys_ipc_recv>
  801a8a:	83 c4 10             	add    $0x10,%esp
  801a8d:	85 c0                	test   %eax,%eax
  801a8f:	79 16                	jns    801aa7 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801a91:	85 f6                	test   %esi,%esi
  801a93:	74 06                	je     801a9b <ipc_recv+0x32>
            *from_env_store = 0;
  801a95:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801a9b:	85 db                	test   %ebx,%ebx
  801a9d:	74 2c                	je     801acb <ipc_recv+0x62>
            *perm_store = 0;
  801a9f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801aa5:	eb 24                	jmp    801acb <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801aa7:	85 f6                	test   %esi,%esi
  801aa9:	74 0a                	je     801ab5 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801aab:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab0:	8b 40 74             	mov    0x74(%eax),%eax
  801ab3:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801ab5:	85 db                	test   %ebx,%ebx
  801ab7:	74 0a                	je     801ac3 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801ab9:	a1 04 40 80 00       	mov    0x804004,%eax
  801abe:	8b 40 78             	mov    0x78(%eax),%eax
  801ac1:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801ac3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac8:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801acb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ace:	5b                   	pop    %ebx
  801acf:	5e                   	pop    %esi
  801ad0:	5d                   	pop    %ebp
  801ad1:	c3                   	ret    

00801ad2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ad2:	55                   	push   %ebp
  801ad3:	89 e5                	mov    %esp,%ebp
  801ad5:	57                   	push   %edi
  801ad6:	56                   	push   %esi
  801ad7:	53                   	push   %ebx
  801ad8:	83 ec 0c             	sub    $0xc,%esp
  801adb:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ade:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ae1:	8b 45 10             	mov    0x10(%ebp),%eax
  801ae4:	85 c0                	test   %eax,%eax
  801ae6:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801aeb:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801aee:	eb 1c                	jmp    801b0c <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801af0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801af3:	74 12                	je     801b07 <ipc_send+0x35>
  801af5:	50                   	push   %eax
  801af6:	68 a0 22 80 00       	push   $0x8022a0
  801afb:	6a 3a                	push   $0x3a
  801afd:	68 b6 22 80 00       	push   $0x8022b6
  801b02:	e8 3e f5 ff ff       	call   801045 <_panic>
		sys_yield();
  801b07:	e8 3f e6 ff ff       	call   80014b <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801b0c:	ff 75 14             	pushl  0x14(%ebp)
  801b0f:	53                   	push   %ebx
  801b10:	56                   	push   %esi
  801b11:	57                   	push   %edi
  801b12:	e8 e0 e7 ff ff       	call   8002f7 <sys_ipc_try_send>
  801b17:	83 c4 10             	add    $0x10,%esp
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	78 d2                	js     801af0 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801b1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b21:	5b                   	pop    %ebx
  801b22:	5e                   	pop    %esi
  801b23:	5f                   	pop    %edi
  801b24:	5d                   	pop    %ebp
  801b25:	c3                   	ret    

00801b26 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b26:	55                   	push   %ebp
  801b27:	89 e5                	mov    %esp,%ebp
  801b29:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b2c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b31:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b34:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b3a:	8b 52 50             	mov    0x50(%edx),%edx
  801b3d:	39 ca                	cmp    %ecx,%edx
  801b3f:	75 0d                	jne    801b4e <ipc_find_env+0x28>
			return envs[i].env_id;
  801b41:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b44:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b49:	8b 40 48             	mov    0x48(%eax),%eax
  801b4c:	eb 0f                	jmp    801b5d <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b4e:	83 c0 01             	add    $0x1,%eax
  801b51:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b56:	75 d9                	jne    801b31 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b58:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b5d:	5d                   	pop    %ebp
  801b5e:	c3                   	ret    

00801b5f <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b5f:	55                   	push   %ebp
  801b60:	89 e5                	mov    %esp,%ebp
  801b62:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b65:	89 d0                	mov    %edx,%eax
  801b67:	c1 e8 16             	shr    $0x16,%eax
  801b6a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b71:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b76:	f6 c1 01             	test   $0x1,%cl
  801b79:	74 1d                	je     801b98 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b7b:	c1 ea 0c             	shr    $0xc,%edx
  801b7e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b85:	f6 c2 01             	test   $0x1,%dl
  801b88:	74 0e                	je     801b98 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b8a:	c1 ea 0c             	shr    $0xc,%edx
  801b8d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b94:	ef 
  801b95:	0f b7 c0             	movzwl %ax,%eax
}
  801b98:	5d                   	pop    %ebp
  801b99:	c3                   	ret    
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
