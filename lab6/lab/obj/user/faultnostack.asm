
obj/user/faultnostack.debug：     文件格式 elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 a0 03 80 00       	push   $0x8003a0
  80003e:	6a 00                	push   $0x0
  800040:	e8 76 02 00 00       	call   8002bb <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  80005f:	e8 ce 00 00 00       	call   800132 <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 08 40 80 00       	mov    %eax,0x804008

    // save the name of the program so that panic() can use it
    if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
        binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a0:	e8 ea 04 00 00       	call   80058f <close_all>
	sys_env_destroy(0);
  8000a5:	83 ec 0c             	sub    $0xc,%esp
  8000a8:	6a 00                	push   $0x0
  8000aa:	e8 42 00 00 00       	call   8000f1 <sys_env_destroy>
}
  8000af:	83 c4 10             	add    $0x10,%esp
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c5:	89 c3                	mov    %eax,%ebx
  8000c7:	89 c7                	mov    %eax,%edi
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e2:	89 d1                	mov    %edx,%ecx
  8000e4:	89 d3                	mov    %edx,%ebx
  8000e6:	89 d7                	mov    %edx,%edi
  8000e8:	89 d6                	mov    %edx,%esi
  8000ea:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7e 17                	jle    80012a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	83 ec 0c             	sub    $0xc,%esp
  800116:	50                   	push   %eax
  800117:	6a 03                	push   $0x3
  800119:	68 6a 23 80 00       	push   $0x80236a
  80011e:	6a 23                	push   $0x23
  800120:	68 87 23 80 00       	push   $0x802387
  800125:	e8 eb 13 00 00       	call   801515 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 02 00 00 00       	mov    $0x2,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <sys_yield>:

void
sys_yield(void)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	57                   	push   %edi
  800155:	56                   	push   %esi
  800156:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800161:	89 d1                	mov    %edx,%ecx
  800163:	89 d3                	mov    %edx,%ebx
  800165:	89 d7                	mov    %edx,%edi
  800167:	89 d6                	mov    %edx,%esi
  800169:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	5f                   	pop    %edi
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800179:	be 00 00 00 00       	mov    $0x0,%esi
  80017e:	b8 04 00 00 00       	mov    $0x4,%eax
  800183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800186:	8b 55 08             	mov    0x8(%ebp),%edx
  800189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018c:	89 f7                	mov    %esi,%edi
  80018e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800190:	85 c0                	test   %eax,%eax
  800192:	7e 17                	jle    8001ab <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	50                   	push   %eax
  800198:	6a 04                	push   $0x4
  80019a:	68 6a 23 80 00       	push   $0x80236a
  80019f:	6a 23                	push   $0x23
  8001a1:	68 87 23 80 00       	push   $0x802387
  8001a6:	e8 6a 13 00 00       	call   801515 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ae:	5b                   	pop    %ebx
  8001af:	5e                   	pop    %esi
  8001b0:	5f                   	pop    %edi
  8001b1:	5d                   	pop    %ebp
  8001b2:	c3                   	ret    

008001b3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	57                   	push   %edi
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001bc:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ca:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001cd:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001d2:	85 c0                	test   %eax,%eax
  8001d4:	7e 17                	jle    8001ed <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	50                   	push   %eax
  8001da:	6a 05                	push   $0x5
  8001dc:	68 6a 23 80 00       	push   $0x80236a
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 87 23 80 00       	push   $0x802387
  8001e8:	e8 28 13 00 00       	call   801515 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f0:	5b                   	pop    %ebx
  8001f1:	5e                   	pop    %esi
  8001f2:	5f                   	pop    %edi
  8001f3:	5d                   	pop    %ebp
  8001f4:	c3                   	ret    

008001f5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	57                   	push   %edi
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800203:	b8 06 00 00 00       	mov    $0x6,%eax
  800208:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020b:	8b 55 08             	mov    0x8(%ebp),%edx
  80020e:	89 df                	mov    %ebx,%edi
  800210:	89 de                	mov    %ebx,%esi
  800212:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800214:	85 c0                	test   %eax,%eax
  800216:	7e 17                	jle    80022f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	6a 06                	push   $0x6
  80021e:	68 6a 23 80 00       	push   $0x80236a
  800223:	6a 23                	push   $0x23
  800225:	68 87 23 80 00       	push   $0x802387
  80022a:	e8 e6 12 00 00       	call   801515 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80022f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800232:	5b                   	pop    %ebx
  800233:	5e                   	pop    %esi
  800234:	5f                   	pop    %edi
  800235:	5d                   	pop    %ebp
  800236:	c3                   	ret    

00800237 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	57                   	push   %edi
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800240:	bb 00 00 00 00       	mov    $0x0,%ebx
  800245:	b8 08 00 00 00       	mov    $0x8,%eax
  80024a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024d:	8b 55 08             	mov    0x8(%ebp),%edx
  800250:	89 df                	mov    %ebx,%edi
  800252:	89 de                	mov    %ebx,%esi
  800254:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800256:	85 c0                	test   %eax,%eax
  800258:	7e 17                	jle    800271 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	6a 08                	push   $0x8
  800260:	68 6a 23 80 00       	push   $0x80236a
  800265:	6a 23                	push   $0x23
  800267:	68 87 23 80 00       	push   $0x802387
  80026c:	e8 a4 12 00 00       	call   801515 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800271:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800274:	5b                   	pop    %ebx
  800275:	5e                   	pop    %esi
  800276:	5f                   	pop    %edi
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	57                   	push   %edi
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800282:	bb 00 00 00 00       	mov    $0x0,%ebx
  800287:	b8 09 00 00 00       	mov    $0x9,%eax
  80028c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028f:	8b 55 08             	mov    0x8(%ebp),%edx
  800292:	89 df                	mov    %ebx,%edi
  800294:	89 de                	mov    %ebx,%esi
  800296:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	7e 17                	jle    8002b3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029c:	83 ec 0c             	sub    $0xc,%esp
  80029f:	50                   	push   %eax
  8002a0:	6a 09                	push   $0x9
  8002a2:	68 6a 23 80 00       	push   $0x80236a
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 87 23 80 00       	push   $0x802387
  8002ae:	e8 62 12 00 00       	call   801515 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	57                   	push   %edi
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d4:	89 df                	mov    %ebx,%edi
  8002d6:	89 de                	mov    %ebx,%esi
  8002d8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7e 17                	jle    8002f5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002de:	83 ec 0c             	sub    $0xc,%esp
  8002e1:	50                   	push   %eax
  8002e2:	6a 0a                	push   $0xa
  8002e4:	68 6a 23 80 00       	push   $0x80236a
  8002e9:	6a 23                	push   $0x23
  8002eb:	68 87 23 80 00       	push   $0x802387
  8002f0:	e8 20 12 00 00       	call   801515 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5e                   	pop    %esi
  8002fa:	5f                   	pop    %edi
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800303:	be 00 00 00 00       	mov    $0x0,%esi
  800308:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800310:	8b 55 08             	mov    0x8(%ebp),%edx
  800313:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800316:	8b 7d 14             	mov    0x14(%ebp),%edi
  800319:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80031b:	5b                   	pop    %ebx
  80031c:	5e                   	pop    %esi
  80031d:	5f                   	pop    %edi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800329:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800333:	8b 55 08             	mov    0x8(%ebp),%edx
  800336:	89 cb                	mov    %ecx,%ebx
  800338:	89 cf                	mov    %ecx,%edi
  80033a:	89 ce                	mov    %ecx,%esi
  80033c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80033e:	85 c0                	test   %eax,%eax
  800340:	7e 17                	jle    800359 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800342:	83 ec 0c             	sub    $0xc,%esp
  800345:	50                   	push   %eax
  800346:	6a 0d                	push   $0xd
  800348:	68 6a 23 80 00       	push   $0x80236a
  80034d:	6a 23                	push   $0x23
  80034f:	68 87 23 80 00       	push   $0x802387
  800354:	e8 bc 11 00 00       	call   801515 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800359:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035c:	5b                   	pop    %ebx
  80035d:	5e                   	pop    %esi
  80035e:	5f                   	pop    %edi
  80035f:	5d                   	pop    %ebp
  800360:	c3                   	ret    

00800361 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	57                   	push   %edi
  800365:	56                   	push   %esi
  800366:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800367:	ba 00 00 00 00       	mov    $0x0,%edx
  80036c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800371:	89 d1                	mov    %edx,%ecx
  800373:	89 d3                	mov    %edx,%ebx
  800375:	89 d7                	mov    %edx,%edi
  800377:	89 d6                	mov    %edx,%esi
  800379:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80037b:	5b                   	pop    %ebx
  80037c:	5e                   	pop    %esi
  80037d:	5f                   	pop    %edi
  80037e:	5d                   	pop    %ebp
  80037f:	c3                   	ret    

00800380 <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	57                   	push   %edi
  800384:	56                   	push   %esi
  800385:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800386:	b9 00 00 00 00       	mov    $0x0,%ecx
  80038b:	b8 10 00 00 00       	mov    $0x10,%eax
  800390:	8b 55 08             	mov    0x8(%ebp),%edx
  800393:	89 cb                	mov    %ecx,%ebx
  800395:	89 cf                	mov    %ecx,%edi
  800397:	89 ce                	mov    %ecx,%esi
  800399:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8003a0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8003a1:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8003a6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8003a8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  8003ab:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  8003ae:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  8003b2:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  8003b7:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  8003bb:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  8003bd:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  8003be:	83 c4 04             	add    $0x4,%esp
	popfl
  8003c1:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  8003c2:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  8003c3:	c3                   	ret    

008003c4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003c4:	55                   	push   %ebp
  8003c5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ca:	05 00 00 00 30       	add    $0x30000000,%eax
  8003cf:	c1 e8 0c             	shr    $0xc,%eax
}
  8003d2:	5d                   	pop    %ebp
  8003d3:	c3                   	ret    

008003d4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003d4:	55                   	push   %ebp
  8003d5:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003da:	05 00 00 00 30       	add    $0x30000000,%eax
  8003df:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003e4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003e9:	5d                   	pop    %ebp
  8003ea:	c3                   	ret    

008003eb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
  8003ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003f6:	89 c2                	mov    %eax,%edx
  8003f8:	c1 ea 16             	shr    $0x16,%edx
  8003fb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800402:	f6 c2 01             	test   $0x1,%dl
  800405:	74 11                	je     800418 <fd_alloc+0x2d>
  800407:	89 c2                	mov    %eax,%edx
  800409:	c1 ea 0c             	shr    $0xc,%edx
  80040c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800413:	f6 c2 01             	test   $0x1,%dl
  800416:	75 09                	jne    800421 <fd_alloc+0x36>
			*fd_store = fd;
  800418:	89 01                	mov    %eax,(%ecx)
			return 0;
  80041a:	b8 00 00 00 00       	mov    $0x0,%eax
  80041f:	eb 17                	jmp    800438 <fd_alloc+0x4d>
  800421:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800426:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80042b:	75 c9                	jne    8003f6 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80042d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800433:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800438:	5d                   	pop    %ebp
  800439:	c3                   	ret    

0080043a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80043a:	55                   	push   %ebp
  80043b:	89 e5                	mov    %esp,%ebp
  80043d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800440:	83 f8 1f             	cmp    $0x1f,%eax
  800443:	77 36                	ja     80047b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800445:	c1 e0 0c             	shl    $0xc,%eax
  800448:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80044d:	89 c2                	mov    %eax,%edx
  80044f:	c1 ea 16             	shr    $0x16,%edx
  800452:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800459:	f6 c2 01             	test   $0x1,%dl
  80045c:	74 24                	je     800482 <fd_lookup+0x48>
  80045e:	89 c2                	mov    %eax,%edx
  800460:	c1 ea 0c             	shr    $0xc,%edx
  800463:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80046a:	f6 c2 01             	test   $0x1,%dl
  80046d:	74 1a                	je     800489 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80046f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800472:	89 02                	mov    %eax,(%edx)
	return 0;
  800474:	b8 00 00 00 00       	mov    $0x0,%eax
  800479:	eb 13                	jmp    80048e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80047b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800480:	eb 0c                	jmp    80048e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800482:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800487:	eb 05                	jmp    80048e <fd_lookup+0x54>
  800489:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80048e:	5d                   	pop    %ebp
  80048f:	c3                   	ret    

00800490 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	83 ec 08             	sub    $0x8,%esp
  800496:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800499:	ba 14 24 80 00       	mov    $0x802414,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80049e:	eb 13                	jmp    8004b3 <dev_lookup+0x23>
  8004a0:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8004a3:	39 08                	cmp    %ecx,(%eax)
  8004a5:	75 0c                	jne    8004b3 <dev_lookup+0x23>
			*dev = devtab[i];
  8004a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004aa:	89 01                	mov    %eax,(%ecx)
			return 0;
  8004ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b1:	eb 2e                	jmp    8004e1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004b3:	8b 02                	mov    (%edx),%eax
  8004b5:	85 c0                	test   %eax,%eax
  8004b7:	75 e7                	jne    8004a0 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004b9:	a1 08 40 80 00       	mov    0x804008,%eax
  8004be:	8b 40 48             	mov    0x48(%eax),%eax
  8004c1:	83 ec 04             	sub    $0x4,%esp
  8004c4:	51                   	push   %ecx
  8004c5:	50                   	push   %eax
  8004c6:	68 98 23 80 00       	push   $0x802398
  8004cb:	e8 1e 11 00 00       	call   8015ee <cprintf>
	*dev = 0;
  8004d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004e1:	c9                   	leave  
  8004e2:	c3                   	ret    

008004e3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004e3:	55                   	push   %ebp
  8004e4:	89 e5                	mov    %esp,%ebp
  8004e6:	56                   	push   %esi
  8004e7:	53                   	push   %ebx
  8004e8:	83 ec 10             	sub    $0x10,%esp
  8004eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f4:	50                   	push   %eax
  8004f5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004fb:	c1 e8 0c             	shr    $0xc,%eax
  8004fe:	50                   	push   %eax
  8004ff:	e8 36 ff ff ff       	call   80043a <fd_lookup>
  800504:	83 c4 08             	add    $0x8,%esp
  800507:	85 c0                	test   %eax,%eax
  800509:	78 05                	js     800510 <fd_close+0x2d>
	    || fd != fd2)
  80050b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80050e:	74 0c                	je     80051c <fd_close+0x39>
		return (must_exist ? r : 0);
  800510:	84 db                	test   %bl,%bl
  800512:	ba 00 00 00 00       	mov    $0x0,%edx
  800517:	0f 44 c2             	cmove  %edx,%eax
  80051a:	eb 41                	jmp    80055d <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800522:	50                   	push   %eax
  800523:	ff 36                	pushl  (%esi)
  800525:	e8 66 ff ff ff       	call   800490 <dev_lookup>
  80052a:	89 c3                	mov    %eax,%ebx
  80052c:	83 c4 10             	add    $0x10,%esp
  80052f:	85 c0                	test   %eax,%eax
  800531:	78 1a                	js     80054d <fd_close+0x6a>
		if (dev->dev_close)
  800533:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800536:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800539:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80053e:	85 c0                	test   %eax,%eax
  800540:	74 0b                	je     80054d <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800542:	83 ec 0c             	sub    $0xc,%esp
  800545:	56                   	push   %esi
  800546:	ff d0                	call   *%eax
  800548:	89 c3                	mov    %eax,%ebx
  80054a:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	56                   	push   %esi
  800551:	6a 00                	push   $0x0
  800553:	e8 9d fc ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800558:	83 c4 10             	add    $0x10,%esp
  80055b:	89 d8                	mov    %ebx,%eax
}
  80055d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800560:	5b                   	pop    %ebx
  800561:	5e                   	pop    %esi
  800562:	5d                   	pop    %ebp
  800563:	c3                   	ret    

00800564 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800564:	55                   	push   %ebp
  800565:	89 e5                	mov    %esp,%ebp
  800567:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80056a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80056d:	50                   	push   %eax
  80056e:	ff 75 08             	pushl  0x8(%ebp)
  800571:	e8 c4 fe ff ff       	call   80043a <fd_lookup>
  800576:	83 c4 08             	add    $0x8,%esp
  800579:	85 c0                	test   %eax,%eax
  80057b:	78 10                	js     80058d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80057d:	83 ec 08             	sub    $0x8,%esp
  800580:	6a 01                	push   $0x1
  800582:	ff 75 f4             	pushl  -0xc(%ebp)
  800585:	e8 59 ff ff ff       	call   8004e3 <fd_close>
  80058a:	83 c4 10             	add    $0x10,%esp
}
  80058d:	c9                   	leave  
  80058e:	c3                   	ret    

0080058f <close_all>:

void
close_all(void)
{
  80058f:	55                   	push   %ebp
  800590:	89 e5                	mov    %esp,%ebp
  800592:	53                   	push   %ebx
  800593:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800596:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80059b:	83 ec 0c             	sub    $0xc,%esp
  80059e:	53                   	push   %ebx
  80059f:	e8 c0 ff ff ff       	call   800564 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8005a4:	83 c3 01             	add    $0x1,%ebx
  8005a7:	83 c4 10             	add    $0x10,%esp
  8005aa:	83 fb 20             	cmp    $0x20,%ebx
  8005ad:	75 ec                	jne    80059b <close_all+0xc>
		close(i);
}
  8005af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005b2:	c9                   	leave  
  8005b3:	c3                   	ret    

008005b4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005b4:	55                   	push   %ebp
  8005b5:	89 e5                	mov    %esp,%ebp
  8005b7:	57                   	push   %edi
  8005b8:	56                   	push   %esi
  8005b9:	53                   	push   %ebx
  8005ba:	83 ec 2c             	sub    $0x2c,%esp
  8005bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005c0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005c3:	50                   	push   %eax
  8005c4:	ff 75 08             	pushl  0x8(%ebp)
  8005c7:	e8 6e fe ff ff       	call   80043a <fd_lookup>
  8005cc:	83 c4 08             	add    $0x8,%esp
  8005cf:	85 c0                	test   %eax,%eax
  8005d1:	0f 88 c1 00 00 00    	js     800698 <dup+0xe4>
		return r;
	close(newfdnum);
  8005d7:	83 ec 0c             	sub    $0xc,%esp
  8005da:	56                   	push   %esi
  8005db:	e8 84 ff ff ff       	call   800564 <close>

	newfd = INDEX2FD(newfdnum);
  8005e0:	89 f3                	mov    %esi,%ebx
  8005e2:	c1 e3 0c             	shl    $0xc,%ebx
  8005e5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005eb:	83 c4 04             	add    $0x4,%esp
  8005ee:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005f1:	e8 de fd ff ff       	call   8003d4 <fd2data>
  8005f6:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005f8:	89 1c 24             	mov    %ebx,(%esp)
  8005fb:	e8 d4 fd ff ff       	call   8003d4 <fd2data>
  800600:	83 c4 10             	add    $0x10,%esp
  800603:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800606:	89 f8                	mov    %edi,%eax
  800608:	c1 e8 16             	shr    $0x16,%eax
  80060b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800612:	a8 01                	test   $0x1,%al
  800614:	74 37                	je     80064d <dup+0x99>
  800616:	89 f8                	mov    %edi,%eax
  800618:	c1 e8 0c             	shr    $0xc,%eax
  80061b:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800622:	f6 c2 01             	test   $0x1,%dl
  800625:	74 26                	je     80064d <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800627:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80062e:	83 ec 0c             	sub    $0xc,%esp
  800631:	25 07 0e 00 00       	and    $0xe07,%eax
  800636:	50                   	push   %eax
  800637:	ff 75 d4             	pushl  -0x2c(%ebp)
  80063a:	6a 00                	push   $0x0
  80063c:	57                   	push   %edi
  80063d:	6a 00                	push   $0x0
  80063f:	e8 6f fb ff ff       	call   8001b3 <sys_page_map>
  800644:	89 c7                	mov    %eax,%edi
  800646:	83 c4 20             	add    $0x20,%esp
  800649:	85 c0                	test   %eax,%eax
  80064b:	78 2e                	js     80067b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80064d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800650:	89 d0                	mov    %edx,%eax
  800652:	c1 e8 0c             	shr    $0xc,%eax
  800655:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80065c:	83 ec 0c             	sub    $0xc,%esp
  80065f:	25 07 0e 00 00       	and    $0xe07,%eax
  800664:	50                   	push   %eax
  800665:	53                   	push   %ebx
  800666:	6a 00                	push   $0x0
  800668:	52                   	push   %edx
  800669:	6a 00                	push   $0x0
  80066b:	e8 43 fb ff ff       	call   8001b3 <sys_page_map>
  800670:	89 c7                	mov    %eax,%edi
  800672:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800675:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800677:	85 ff                	test   %edi,%edi
  800679:	79 1d                	jns    800698 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80067b:	83 ec 08             	sub    $0x8,%esp
  80067e:	53                   	push   %ebx
  80067f:	6a 00                	push   $0x0
  800681:	e8 6f fb ff ff       	call   8001f5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800686:	83 c4 08             	add    $0x8,%esp
  800689:	ff 75 d4             	pushl  -0x2c(%ebp)
  80068c:	6a 00                	push   $0x0
  80068e:	e8 62 fb ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800693:	83 c4 10             	add    $0x10,%esp
  800696:	89 f8                	mov    %edi,%eax
}
  800698:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80069b:	5b                   	pop    %ebx
  80069c:	5e                   	pop    %esi
  80069d:	5f                   	pop    %edi
  80069e:	5d                   	pop    %ebp
  80069f:	c3                   	ret    

008006a0 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006a0:	55                   	push   %ebp
  8006a1:	89 e5                	mov    %esp,%ebp
  8006a3:	53                   	push   %ebx
  8006a4:	83 ec 14             	sub    $0x14,%esp
  8006a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006ad:	50                   	push   %eax
  8006ae:	53                   	push   %ebx
  8006af:	e8 86 fd ff ff       	call   80043a <fd_lookup>
  8006b4:	83 c4 08             	add    $0x8,%esp
  8006b7:	89 c2                	mov    %eax,%edx
  8006b9:	85 c0                	test   %eax,%eax
  8006bb:	78 6d                	js     80072a <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006bd:	83 ec 08             	sub    $0x8,%esp
  8006c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006c3:	50                   	push   %eax
  8006c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006c7:	ff 30                	pushl  (%eax)
  8006c9:	e8 c2 fd ff ff       	call   800490 <dev_lookup>
  8006ce:	83 c4 10             	add    $0x10,%esp
  8006d1:	85 c0                	test   %eax,%eax
  8006d3:	78 4c                	js     800721 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006d8:	8b 42 08             	mov    0x8(%edx),%eax
  8006db:	83 e0 03             	and    $0x3,%eax
  8006de:	83 f8 01             	cmp    $0x1,%eax
  8006e1:	75 21                	jne    800704 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006e3:	a1 08 40 80 00       	mov    0x804008,%eax
  8006e8:	8b 40 48             	mov    0x48(%eax),%eax
  8006eb:	83 ec 04             	sub    $0x4,%esp
  8006ee:	53                   	push   %ebx
  8006ef:	50                   	push   %eax
  8006f0:	68 d9 23 80 00       	push   $0x8023d9
  8006f5:	e8 f4 0e 00 00       	call   8015ee <cprintf>
		return -E_INVAL;
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800702:	eb 26                	jmp    80072a <read+0x8a>
	}
	if (!dev->dev_read)
  800704:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800707:	8b 40 08             	mov    0x8(%eax),%eax
  80070a:	85 c0                	test   %eax,%eax
  80070c:	74 17                	je     800725 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80070e:	83 ec 04             	sub    $0x4,%esp
  800711:	ff 75 10             	pushl  0x10(%ebp)
  800714:	ff 75 0c             	pushl  0xc(%ebp)
  800717:	52                   	push   %edx
  800718:	ff d0                	call   *%eax
  80071a:	89 c2                	mov    %eax,%edx
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	eb 09                	jmp    80072a <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800721:	89 c2                	mov    %eax,%edx
  800723:	eb 05                	jmp    80072a <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800725:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80072a:	89 d0                	mov    %edx,%eax
  80072c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80072f:	c9                   	leave  
  800730:	c3                   	ret    

00800731 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800731:	55                   	push   %ebp
  800732:	89 e5                	mov    %esp,%ebp
  800734:	57                   	push   %edi
  800735:	56                   	push   %esi
  800736:	53                   	push   %ebx
  800737:	83 ec 0c             	sub    $0xc,%esp
  80073a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80073d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800740:	bb 00 00 00 00       	mov    $0x0,%ebx
  800745:	eb 21                	jmp    800768 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800747:	83 ec 04             	sub    $0x4,%esp
  80074a:	89 f0                	mov    %esi,%eax
  80074c:	29 d8                	sub    %ebx,%eax
  80074e:	50                   	push   %eax
  80074f:	89 d8                	mov    %ebx,%eax
  800751:	03 45 0c             	add    0xc(%ebp),%eax
  800754:	50                   	push   %eax
  800755:	57                   	push   %edi
  800756:	e8 45 ff ff ff       	call   8006a0 <read>
		if (m < 0)
  80075b:	83 c4 10             	add    $0x10,%esp
  80075e:	85 c0                	test   %eax,%eax
  800760:	78 10                	js     800772 <readn+0x41>
			return m;
		if (m == 0)
  800762:	85 c0                	test   %eax,%eax
  800764:	74 0a                	je     800770 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800766:	01 c3                	add    %eax,%ebx
  800768:	39 f3                	cmp    %esi,%ebx
  80076a:	72 db                	jb     800747 <readn+0x16>
  80076c:	89 d8                	mov    %ebx,%eax
  80076e:	eb 02                	jmp    800772 <readn+0x41>
  800770:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800772:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800775:	5b                   	pop    %ebx
  800776:	5e                   	pop    %esi
  800777:	5f                   	pop    %edi
  800778:	5d                   	pop    %ebp
  800779:	c3                   	ret    

0080077a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	53                   	push   %ebx
  80077e:	83 ec 14             	sub    $0x14,%esp
  800781:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800784:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800787:	50                   	push   %eax
  800788:	53                   	push   %ebx
  800789:	e8 ac fc ff ff       	call   80043a <fd_lookup>
  80078e:	83 c4 08             	add    $0x8,%esp
  800791:	89 c2                	mov    %eax,%edx
  800793:	85 c0                	test   %eax,%eax
  800795:	78 68                	js     8007ff <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800797:	83 ec 08             	sub    $0x8,%esp
  80079a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80079d:	50                   	push   %eax
  80079e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007a1:	ff 30                	pushl  (%eax)
  8007a3:	e8 e8 fc ff ff       	call   800490 <dev_lookup>
  8007a8:	83 c4 10             	add    $0x10,%esp
  8007ab:	85 c0                	test   %eax,%eax
  8007ad:	78 47                	js     8007f6 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007b2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007b6:	75 21                	jne    8007d9 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007b8:	a1 08 40 80 00       	mov    0x804008,%eax
  8007bd:	8b 40 48             	mov    0x48(%eax),%eax
  8007c0:	83 ec 04             	sub    $0x4,%esp
  8007c3:	53                   	push   %ebx
  8007c4:	50                   	push   %eax
  8007c5:	68 f5 23 80 00       	push   $0x8023f5
  8007ca:	e8 1f 0e 00 00       	call   8015ee <cprintf>
		return -E_INVAL;
  8007cf:	83 c4 10             	add    $0x10,%esp
  8007d2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007d7:	eb 26                	jmp    8007ff <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007dc:	8b 52 0c             	mov    0xc(%edx),%edx
  8007df:	85 d2                	test   %edx,%edx
  8007e1:	74 17                	je     8007fa <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007e3:	83 ec 04             	sub    $0x4,%esp
  8007e6:	ff 75 10             	pushl  0x10(%ebp)
  8007e9:	ff 75 0c             	pushl  0xc(%ebp)
  8007ec:	50                   	push   %eax
  8007ed:	ff d2                	call   *%edx
  8007ef:	89 c2                	mov    %eax,%edx
  8007f1:	83 c4 10             	add    $0x10,%esp
  8007f4:	eb 09                	jmp    8007ff <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007f6:	89 c2                	mov    %eax,%edx
  8007f8:	eb 05                	jmp    8007ff <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007fa:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007ff:	89 d0                	mov    %edx,%eax
  800801:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800804:	c9                   	leave  
  800805:	c3                   	ret    

00800806 <seek>:

int
seek(int fdnum, off_t offset)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80080c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80080f:	50                   	push   %eax
  800810:	ff 75 08             	pushl  0x8(%ebp)
  800813:	e8 22 fc ff ff       	call   80043a <fd_lookup>
  800818:	83 c4 08             	add    $0x8,%esp
  80081b:	85 c0                	test   %eax,%eax
  80081d:	78 0e                	js     80082d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80081f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800822:	8b 55 0c             	mov    0xc(%ebp),%edx
  800825:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800828:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80082d:	c9                   	leave  
  80082e:	c3                   	ret    

0080082f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	53                   	push   %ebx
  800833:	83 ec 14             	sub    $0x14,%esp
  800836:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800839:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80083c:	50                   	push   %eax
  80083d:	53                   	push   %ebx
  80083e:	e8 f7 fb ff ff       	call   80043a <fd_lookup>
  800843:	83 c4 08             	add    $0x8,%esp
  800846:	89 c2                	mov    %eax,%edx
  800848:	85 c0                	test   %eax,%eax
  80084a:	78 65                	js     8008b1 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80084c:	83 ec 08             	sub    $0x8,%esp
  80084f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800852:	50                   	push   %eax
  800853:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800856:	ff 30                	pushl  (%eax)
  800858:	e8 33 fc ff ff       	call   800490 <dev_lookup>
  80085d:	83 c4 10             	add    $0x10,%esp
  800860:	85 c0                	test   %eax,%eax
  800862:	78 44                	js     8008a8 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800864:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800867:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80086b:	75 21                	jne    80088e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80086d:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800872:	8b 40 48             	mov    0x48(%eax),%eax
  800875:	83 ec 04             	sub    $0x4,%esp
  800878:	53                   	push   %ebx
  800879:	50                   	push   %eax
  80087a:	68 b8 23 80 00       	push   $0x8023b8
  80087f:	e8 6a 0d 00 00       	call   8015ee <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800884:	83 c4 10             	add    $0x10,%esp
  800887:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80088c:	eb 23                	jmp    8008b1 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80088e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800891:	8b 52 18             	mov    0x18(%edx),%edx
  800894:	85 d2                	test   %edx,%edx
  800896:	74 14                	je     8008ac <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800898:	83 ec 08             	sub    $0x8,%esp
  80089b:	ff 75 0c             	pushl  0xc(%ebp)
  80089e:	50                   	push   %eax
  80089f:	ff d2                	call   *%edx
  8008a1:	89 c2                	mov    %eax,%edx
  8008a3:	83 c4 10             	add    $0x10,%esp
  8008a6:	eb 09                	jmp    8008b1 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a8:	89 c2                	mov    %eax,%edx
  8008aa:	eb 05                	jmp    8008b1 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8008ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8008b1:	89 d0                	mov    %edx,%eax
  8008b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b6:	c9                   	leave  
  8008b7:	c3                   	ret    

008008b8 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	53                   	push   %ebx
  8008bc:	83 ec 14             	sub    $0x14,%esp
  8008bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008c5:	50                   	push   %eax
  8008c6:	ff 75 08             	pushl  0x8(%ebp)
  8008c9:	e8 6c fb ff ff       	call   80043a <fd_lookup>
  8008ce:	83 c4 08             	add    $0x8,%esp
  8008d1:	89 c2                	mov    %eax,%edx
  8008d3:	85 c0                	test   %eax,%eax
  8008d5:	78 58                	js     80092f <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d7:	83 ec 08             	sub    $0x8,%esp
  8008da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008dd:	50                   	push   %eax
  8008de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008e1:	ff 30                	pushl  (%eax)
  8008e3:	e8 a8 fb ff ff       	call   800490 <dev_lookup>
  8008e8:	83 c4 10             	add    $0x10,%esp
  8008eb:	85 c0                	test   %eax,%eax
  8008ed:	78 37                	js     800926 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008f2:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008f6:	74 32                	je     80092a <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008f8:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008fb:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800902:	00 00 00 
	stat->st_isdir = 0;
  800905:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80090c:	00 00 00 
	stat->st_dev = dev;
  80090f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800915:	83 ec 08             	sub    $0x8,%esp
  800918:	53                   	push   %ebx
  800919:	ff 75 f0             	pushl  -0x10(%ebp)
  80091c:	ff 50 14             	call   *0x14(%eax)
  80091f:	89 c2                	mov    %eax,%edx
  800921:	83 c4 10             	add    $0x10,%esp
  800924:	eb 09                	jmp    80092f <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800926:	89 c2                	mov    %eax,%edx
  800928:	eb 05                	jmp    80092f <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80092a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80092f:	89 d0                	mov    %edx,%eax
  800931:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800934:	c9                   	leave  
  800935:	c3                   	ret    

00800936 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	56                   	push   %esi
  80093a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80093b:	83 ec 08             	sub    $0x8,%esp
  80093e:	6a 00                	push   $0x0
  800940:	ff 75 08             	pushl  0x8(%ebp)
  800943:	e8 e3 01 00 00       	call   800b2b <open>
  800948:	89 c3                	mov    %eax,%ebx
  80094a:	83 c4 10             	add    $0x10,%esp
  80094d:	85 c0                	test   %eax,%eax
  80094f:	78 1b                	js     80096c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800951:	83 ec 08             	sub    $0x8,%esp
  800954:	ff 75 0c             	pushl  0xc(%ebp)
  800957:	50                   	push   %eax
  800958:	e8 5b ff ff ff       	call   8008b8 <fstat>
  80095d:	89 c6                	mov    %eax,%esi
	close(fd);
  80095f:	89 1c 24             	mov    %ebx,(%esp)
  800962:	e8 fd fb ff ff       	call   800564 <close>
	return r;
  800967:	83 c4 10             	add    $0x10,%esp
  80096a:	89 f0                	mov    %esi,%eax
}
  80096c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80096f:	5b                   	pop    %ebx
  800970:	5e                   	pop    %esi
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	56                   	push   %esi
  800977:	53                   	push   %ebx
  800978:	89 c6                	mov    %eax,%esi
  80097a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80097c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800983:	75 12                	jne    800997 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800985:	83 ec 0c             	sub    $0xc,%esp
  800988:	6a 01                	push   $0x1
  80098a:	e8 ca 16 00 00       	call   802059 <ipc_find_env>
  80098f:	a3 00 40 80 00       	mov    %eax,0x804000
  800994:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800997:	6a 07                	push   $0x7
  800999:	68 00 50 80 00       	push   $0x805000
  80099e:	56                   	push   %esi
  80099f:	ff 35 00 40 80 00    	pushl  0x804000
  8009a5:	e8 5b 16 00 00       	call   802005 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8009aa:	83 c4 0c             	add    $0xc,%esp
  8009ad:	6a 00                	push   $0x0
  8009af:	53                   	push   %ebx
  8009b0:	6a 00                	push   $0x0
  8009b2:	e8 e5 15 00 00       	call   801f9c <ipc_recv>
}
  8009b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009ba:	5b                   	pop    %ebx
  8009bb:	5e                   	pop    %esi
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ca:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009dc:	b8 02 00 00 00       	mov    $0x2,%eax
  8009e1:	e8 8d ff ff ff       	call   800973 <fsipc>
}
  8009e6:	c9                   	leave  
  8009e7:	c3                   	ret    

008009e8 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f4:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009fe:	b8 06 00 00 00       	mov    $0x6,%eax
  800a03:	e8 6b ff ff ff       	call   800973 <fsipc>
}
  800a08:	c9                   	leave  
  800a09:	c3                   	ret    

00800a0a <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	53                   	push   %ebx
  800a0e:	83 ec 04             	sub    $0x4,%esp
  800a11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	8b 40 0c             	mov    0xc(%eax),%eax
  800a1a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a24:	b8 05 00 00 00       	mov    $0x5,%eax
  800a29:	e8 45 ff ff ff       	call   800973 <fsipc>
  800a2e:	85 c0                	test   %eax,%eax
  800a30:	78 2c                	js     800a5e <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a32:	83 ec 08             	sub    $0x8,%esp
  800a35:	68 00 50 80 00       	push   $0x805000
  800a3a:	53                   	push   %ebx
  800a3b:	e8 b2 11 00 00       	call   801bf2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a40:	a1 80 50 80 00       	mov    0x805080,%eax
  800a45:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a4b:	a1 84 50 80 00       	mov    0x805084,%eax
  800a50:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a56:	83 c4 10             	add    $0x10,%esp
  800a59:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a61:	c9                   	leave  
  800a62:	c3                   	ret    

00800a63 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	83 ec 0c             	sub    $0xc,%esp
  800a69:	8b 45 10             	mov    0x10(%ebp),%eax
  800a6c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a71:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a76:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a79:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7c:	8b 52 0c             	mov    0xc(%edx),%edx
  800a7f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a85:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a8a:	50                   	push   %eax
  800a8b:	ff 75 0c             	pushl  0xc(%ebp)
  800a8e:	68 08 50 80 00       	push   $0x805008
  800a93:	e8 ec 12 00 00       	call   801d84 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a98:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9d:	b8 04 00 00 00       	mov    $0x4,%eax
  800aa2:	e8 cc fe ff ff       	call   800973 <fsipc>
	//panic("devfile_write not implemented");
}
  800aa7:	c9                   	leave  
  800aa8:	c3                   	ret    

00800aa9 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	56                   	push   %esi
  800aad:	53                   	push   %ebx
  800aae:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ab1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab4:	8b 40 0c             	mov    0xc(%eax),%eax
  800ab7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800abc:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ac2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac7:	b8 03 00 00 00       	mov    $0x3,%eax
  800acc:	e8 a2 fe ff ff       	call   800973 <fsipc>
  800ad1:	89 c3                	mov    %eax,%ebx
  800ad3:	85 c0                	test   %eax,%eax
  800ad5:	78 4b                	js     800b22 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ad7:	39 c6                	cmp    %eax,%esi
  800ad9:	73 16                	jae    800af1 <devfile_read+0x48>
  800adb:	68 28 24 80 00       	push   $0x802428
  800ae0:	68 2f 24 80 00       	push   $0x80242f
  800ae5:	6a 7c                	push   $0x7c
  800ae7:	68 44 24 80 00       	push   $0x802444
  800aec:	e8 24 0a 00 00       	call   801515 <_panic>
	assert(r <= PGSIZE);
  800af1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800af6:	7e 16                	jle    800b0e <devfile_read+0x65>
  800af8:	68 4f 24 80 00       	push   $0x80244f
  800afd:	68 2f 24 80 00       	push   $0x80242f
  800b02:	6a 7d                	push   $0x7d
  800b04:	68 44 24 80 00       	push   $0x802444
  800b09:	e8 07 0a 00 00       	call   801515 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800b0e:	83 ec 04             	sub    $0x4,%esp
  800b11:	50                   	push   %eax
  800b12:	68 00 50 80 00       	push   $0x805000
  800b17:	ff 75 0c             	pushl  0xc(%ebp)
  800b1a:	e8 65 12 00 00       	call   801d84 <memmove>
	return r;
  800b1f:	83 c4 10             	add    $0x10,%esp
}
  800b22:	89 d8                	mov    %ebx,%eax
  800b24:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b27:	5b                   	pop    %ebx
  800b28:	5e                   	pop    %esi
  800b29:	5d                   	pop    %ebp
  800b2a:	c3                   	ret    

00800b2b <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	53                   	push   %ebx
  800b2f:	83 ec 20             	sub    $0x20,%esp
  800b32:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b35:	53                   	push   %ebx
  800b36:	e8 7e 10 00 00       	call   801bb9 <strlen>
  800b3b:	83 c4 10             	add    $0x10,%esp
  800b3e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b43:	7f 67                	jg     800bac <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b45:	83 ec 0c             	sub    $0xc,%esp
  800b48:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b4b:	50                   	push   %eax
  800b4c:	e8 9a f8 ff ff       	call   8003eb <fd_alloc>
  800b51:	83 c4 10             	add    $0x10,%esp
		return r;
  800b54:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b56:	85 c0                	test   %eax,%eax
  800b58:	78 57                	js     800bb1 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b5a:	83 ec 08             	sub    $0x8,%esp
  800b5d:	53                   	push   %ebx
  800b5e:	68 00 50 80 00       	push   $0x805000
  800b63:	e8 8a 10 00 00       	call   801bf2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b70:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b73:	b8 01 00 00 00       	mov    $0x1,%eax
  800b78:	e8 f6 fd ff ff       	call   800973 <fsipc>
  800b7d:	89 c3                	mov    %eax,%ebx
  800b7f:	83 c4 10             	add    $0x10,%esp
  800b82:	85 c0                	test   %eax,%eax
  800b84:	79 14                	jns    800b9a <open+0x6f>
		fd_close(fd, 0);
  800b86:	83 ec 08             	sub    $0x8,%esp
  800b89:	6a 00                	push   $0x0
  800b8b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b8e:	e8 50 f9 ff ff       	call   8004e3 <fd_close>
		return r;
  800b93:	83 c4 10             	add    $0x10,%esp
  800b96:	89 da                	mov    %ebx,%edx
  800b98:	eb 17                	jmp    800bb1 <open+0x86>
	}

	return fd2num(fd);
  800b9a:	83 ec 0c             	sub    $0xc,%esp
  800b9d:	ff 75 f4             	pushl  -0xc(%ebp)
  800ba0:	e8 1f f8 ff ff       	call   8003c4 <fd2num>
  800ba5:	89 c2                	mov    %eax,%edx
  800ba7:	83 c4 10             	add    $0x10,%esp
  800baa:	eb 05                	jmp    800bb1 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800bac:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800bb1:	89 d0                	mov    %edx,%eax
  800bb3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bb6:	c9                   	leave  
  800bb7:	c3                   	ret    

00800bb8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc3:	b8 08 00 00 00       	mov    $0x8,%eax
  800bc8:	e8 a6 fd ff ff       	call   800973 <fsipc>
}
  800bcd:	c9                   	leave  
  800bce:	c3                   	ret    

00800bcf <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bd5:	68 5b 24 80 00       	push   $0x80245b
  800bda:	ff 75 0c             	pushl  0xc(%ebp)
  800bdd:	e8 10 10 00 00       	call   801bf2 <strcpy>
	return 0;
}
  800be2:	b8 00 00 00 00       	mov    $0x0,%eax
  800be7:	c9                   	leave  
  800be8:	c3                   	ret    

00800be9 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	53                   	push   %ebx
  800bed:	83 ec 10             	sub    $0x10,%esp
  800bf0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bf3:	53                   	push   %ebx
  800bf4:	e8 99 14 00 00       	call   802092 <pageref>
  800bf9:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bfc:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800c01:	83 f8 01             	cmp    $0x1,%eax
  800c04:	75 10                	jne    800c16 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800c06:	83 ec 0c             	sub    $0xc,%esp
  800c09:	ff 73 0c             	pushl  0xc(%ebx)
  800c0c:	e8 c0 02 00 00       	call   800ed1 <nsipc_close>
  800c11:	89 c2                	mov    %eax,%edx
  800c13:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800c16:	89 d0                	mov    %edx,%eax
  800c18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c1b:	c9                   	leave  
  800c1c:	c3                   	ret    

00800c1d <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c23:	6a 00                	push   $0x0
  800c25:	ff 75 10             	pushl  0x10(%ebp)
  800c28:	ff 75 0c             	pushl  0xc(%ebp)
  800c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2e:	ff 70 0c             	pushl  0xc(%eax)
  800c31:	e8 78 03 00 00       	call   800fae <nsipc_send>
}
  800c36:	c9                   	leave  
  800c37:	c3                   	ret    

00800c38 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c3e:	6a 00                	push   $0x0
  800c40:	ff 75 10             	pushl  0x10(%ebp)
  800c43:	ff 75 0c             	pushl  0xc(%ebp)
  800c46:	8b 45 08             	mov    0x8(%ebp),%eax
  800c49:	ff 70 0c             	pushl  0xc(%eax)
  800c4c:	e8 f1 02 00 00       	call   800f42 <nsipc_recv>
}
  800c51:	c9                   	leave  
  800c52:	c3                   	ret    

00800c53 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c59:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c5c:	52                   	push   %edx
  800c5d:	50                   	push   %eax
  800c5e:	e8 d7 f7 ff ff       	call   80043a <fd_lookup>
  800c63:	83 c4 10             	add    $0x10,%esp
  800c66:	85 c0                	test   %eax,%eax
  800c68:	78 17                	js     800c81 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c6d:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c73:	39 08                	cmp    %ecx,(%eax)
  800c75:	75 05                	jne    800c7c <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c77:	8b 40 0c             	mov    0xc(%eax),%eax
  800c7a:	eb 05                	jmp    800c81 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c7c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c81:	c9                   	leave  
  800c82:	c3                   	ret    

00800c83 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 1c             	sub    $0x1c,%esp
  800c8b:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c8d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c90:	50                   	push   %eax
  800c91:	e8 55 f7 ff ff       	call   8003eb <fd_alloc>
  800c96:	89 c3                	mov    %eax,%ebx
  800c98:	83 c4 10             	add    $0x10,%esp
  800c9b:	85 c0                	test   %eax,%eax
  800c9d:	78 1b                	js     800cba <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c9f:	83 ec 04             	sub    $0x4,%esp
  800ca2:	68 07 04 00 00       	push   $0x407
  800ca7:	ff 75 f4             	pushl  -0xc(%ebp)
  800caa:	6a 00                	push   $0x0
  800cac:	e8 bf f4 ff ff       	call   800170 <sys_page_alloc>
  800cb1:	89 c3                	mov    %eax,%ebx
  800cb3:	83 c4 10             	add    $0x10,%esp
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	79 10                	jns    800cca <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800cba:	83 ec 0c             	sub    $0xc,%esp
  800cbd:	56                   	push   %esi
  800cbe:	e8 0e 02 00 00       	call   800ed1 <nsipc_close>
		return r;
  800cc3:	83 c4 10             	add    $0x10,%esp
  800cc6:	89 d8                	mov    %ebx,%eax
  800cc8:	eb 24                	jmp    800cee <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800cca:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800cd0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cd3:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cd8:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cdf:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800ce2:	83 ec 0c             	sub    $0xc,%esp
  800ce5:	50                   	push   %eax
  800ce6:	e8 d9 f6 ff ff       	call   8003c4 <fd2num>
  800ceb:	83 c4 10             	add    $0x10,%esp
}
  800cee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    

00800cf5 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cf5:	55                   	push   %ebp
  800cf6:	89 e5                	mov    %esp,%ebp
  800cf8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfe:	e8 50 ff ff ff       	call   800c53 <fd2sockid>
		return r;
  800d03:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d05:	85 c0                	test   %eax,%eax
  800d07:	78 1f                	js     800d28 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d09:	83 ec 04             	sub    $0x4,%esp
  800d0c:	ff 75 10             	pushl  0x10(%ebp)
  800d0f:	ff 75 0c             	pushl  0xc(%ebp)
  800d12:	50                   	push   %eax
  800d13:	e8 12 01 00 00       	call   800e2a <nsipc_accept>
  800d18:	83 c4 10             	add    $0x10,%esp
		return r;
  800d1b:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d1d:	85 c0                	test   %eax,%eax
  800d1f:	78 07                	js     800d28 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d21:	e8 5d ff ff ff       	call   800c83 <alloc_sockfd>
  800d26:	89 c1                	mov    %eax,%ecx
}
  800d28:	89 c8                	mov    %ecx,%eax
  800d2a:	c9                   	leave  
  800d2b:	c3                   	ret    

00800d2c <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d32:	8b 45 08             	mov    0x8(%ebp),%eax
  800d35:	e8 19 ff ff ff       	call   800c53 <fd2sockid>
  800d3a:	85 c0                	test   %eax,%eax
  800d3c:	78 12                	js     800d50 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d3e:	83 ec 04             	sub    $0x4,%esp
  800d41:	ff 75 10             	pushl  0x10(%ebp)
  800d44:	ff 75 0c             	pushl  0xc(%ebp)
  800d47:	50                   	push   %eax
  800d48:	e8 2d 01 00 00       	call   800e7a <nsipc_bind>
  800d4d:	83 c4 10             	add    $0x10,%esp
}
  800d50:	c9                   	leave  
  800d51:	c3                   	ret    

00800d52 <shutdown>:

int
shutdown(int s, int how)
{
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d58:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5b:	e8 f3 fe ff ff       	call   800c53 <fd2sockid>
  800d60:	85 c0                	test   %eax,%eax
  800d62:	78 0f                	js     800d73 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d64:	83 ec 08             	sub    $0x8,%esp
  800d67:	ff 75 0c             	pushl  0xc(%ebp)
  800d6a:	50                   	push   %eax
  800d6b:	e8 3f 01 00 00       	call   800eaf <nsipc_shutdown>
  800d70:	83 c4 10             	add    $0x10,%esp
}
  800d73:	c9                   	leave  
  800d74:	c3                   	ret    

00800d75 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7e:	e8 d0 fe ff ff       	call   800c53 <fd2sockid>
  800d83:	85 c0                	test   %eax,%eax
  800d85:	78 12                	js     800d99 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d87:	83 ec 04             	sub    $0x4,%esp
  800d8a:	ff 75 10             	pushl  0x10(%ebp)
  800d8d:	ff 75 0c             	pushl  0xc(%ebp)
  800d90:	50                   	push   %eax
  800d91:	e8 55 01 00 00       	call   800eeb <nsipc_connect>
  800d96:	83 c4 10             	add    $0x10,%esp
}
  800d99:	c9                   	leave  
  800d9a:	c3                   	ret    

00800d9b <listen>:

int
listen(int s, int backlog)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800da1:	8b 45 08             	mov    0x8(%ebp),%eax
  800da4:	e8 aa fe ff ff       	call   800c53 <fd2sockid>
  800da9:	85 c0                	test   %eax,%eax
  800dab:	78 0f                	js     800dbc <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800dad:	83 ec 08             	sub    $0x8,%esp
  800db0:	ff 75 0c             	pushl  0xc(%ebp)
  800db3:	50                   	push   %eax
  800db4:	e8 67 01 00 00       	call   800f20 <nsipc_listen>
  800db9:	83 c4 10             	add    $0x10,%esp
}
  800dbc:	c9                   	leave  
  800dbd:	c3                   	ret    

00800dbe <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
  800dc1:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800dc4:	ff 75 10             	pushl  0x10(%ebp)
  800dc7:	ff 75 0c             	pushl  0xc(%ebp)
  800dca:	ff 75 08             	pushl  0x8(%ebp)
  800dcd:	e8 3a 02 00 00       	call   80100c <nsipc_socket>
  800dd2:	83 c4 10             	add    $0x10,%esp
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	78 05                	js     800dde <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800dd9:	e8 a5 fe ff ff       	call   800c83 <alloc_sockfd>
}
  800dde:	c9                   	leave  
  800ddf:	c3                   	ret    

00800de0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	53                   	push   %ebx
  800de4:	83 ec 04             	sub    $0x4,%esp
  800de7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800de9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800df0:	75 12                	jne    800e04 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800df2:	83 ec 0c             	sub    $0xc,%esp
  800df5:	6a 02                	push   $0x2
  800df7:	e8 5d 12 00 00       	call   802059 <ipc_find_env>
  800dfc:	a3 04 40 80 00       	mov    %eax,0x804004
  800e01:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800e04:	6a 07                	push   $0x7
  800e06:	68 00 60 80 00       	push   $0x806000
  800e0b:	53                   	push   %ebx
  800e0c:	ff 35 04 40 80 00    	pushl  0x804004
  800e12:	e8 ee 11 00 00       	call   802005 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e17:	83 c4 0c             	add    $0xc,%esp
  800e1a:	6a 00                	push   $0x0
  800e1c:	6a 00                	push   $0x0
  800e1e:	6a 00                	push   $0x0
  800e20:	e8 77 11 00 00       	call   801f9c <ipc_recv>
}
  800e25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e28:	c9                   	leave  
  800e29:	c3                   	ret    

00800e2a <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e32:	8b 45 08             	mov    0x8(%ebp),%eax
  800e35:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e3a:	8b 06                	mov    (%esi),%eax
  800e3c:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e41:	b8 01 00 00 00       	mov    $0x1,%eax
  800e46:	e8 95 ff ff ff       	call   800de0 <nsipc>
  800e4b:	89 c3                	mov    %eax,%ebx
  800e4d:	85 c0                	test   %eax,%eax
  800e4f:	78 20                	js     800e71 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e51:	83 ec 04             	sub    $0x4,%esp
  800e54:	ff 35 10 60 80 00    	pushl  0x806010
  800e5a:	68 00 60 80 00       	push   $0x806000
  800e5f:	ff 75 0c             	pushl  0xc(%ebp)
  800e62:	e8 1d 0f 00 00       	call   801d84 <memmove>
		*addrlen = ret->ret_addrlen;
  800e67:	a1 10 60 80 00       	mov    0x806010,%eax
  800e6c:	89 06                	mov    %eax,(%esi)
  800e6e:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e71:	89 d8                	mov    %ebx,%eax
  800e73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e76:	5b                   	pop    %ebx
  800e77:	5e                   	pop    %esi
  800e78:	5d                   	pop    %ebp
  800e79:	c3                   	ret    

00800e7a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e7a:	55                   	push   %ebp
  800e7b:	89 e5                	mov    %esp,%ebp
  800e7d:	53                   	push   %ebx
  800e7e:	83 ec 08             	sub    $0x8,%esp
  800e81:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e84:	8b 45 08             	mov    0x8(%ebp),%eax
  800e87:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e8c:	53                   	push   %ebx
  800e8d:	ff 75 0c             	pushl  0xc(%ebp)
  800e90:	68 04 60 80 00       	push   $0x806004
  800e95:	e8 ea 0e 00 00       	call   801d84 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e9a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800ea0:	b8 02 00 00 00       	mov    $0x2,%eax
  800ea5:	e8 36 ff ff ff       	call   800de0 <nsipc>
}
  800eaa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ead:	c9                   	leave  
  800eae:	c3                   	ret    

00800eaf <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800eb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800ebd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec0:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800ec5:	b8 03 00 00 00       	mov    $0x3,%eax
  800eca:	e8 11 ff ff ff       	call   800de0 <nsipc>
}
  800ecf:	c9                   	leave  
  800ed0:	c3                   	ret    

00800ed1 <nsipc_close>:

int
nsipc_close(int s)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ed7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eda:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800edf:	b8 04 00 00 00       	mov    $0x4,%eax
  800ee4:	e8 f7 fe ff ff       	call   800de0 <nsipc>
}
  800ee9:	c9                   	leave  
  800eea:	c3                   	ret    

00800eeb <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	53                   	push   %ebx
  800eef:	83 ec 08             	sub    $0x8,%esp
  800ef2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ef5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef8:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800efd:	53                   	push   %ebx
  800efe:	ff 75 0c             	pushl  0xc(%ebp)
  800f01:	68 04 60 80 00       	push   $0x806004
  800f06:	e8 79 0e 00 00       	call   801d84 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f0b:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800f11:	b8 05 00 00 00       	mov    $0x5,%eax
  800f16:	e8 c5 fe ff ff       	call   800de0 <nsipc>
}
  800f1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f1e:	c9                   	leave  
  800f1f:	c3                   	ret    

00800f20 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f26:	8b 45 08             	mov    0x8(%ebp),%eax
  800f29:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f31:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f36:	b8 06 00 00 00       	mov    $0x6,%eax
  800f3b:	e8 a0 fe ff ff       	call   800de0 <nsipc>
}
  800f40:	c9                   	leave  
  800f41:	c3                   	ret    

00800f42 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f42:	55                   	push   %ebp
  800f43:	89 e5                	mov    %esp,%ebp
  800f45:	56                   	push   %esi
  800f46:	53                   	push   %ebx
  800f47:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4d:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f52:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f58:	8b 45 14             	mov    0x14(%ebp),%eax
  800f5b:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f60:	b8 07 00 00 00       	mov    $0x7,%eax
  800f65:	e8 76 fe ff ff       	call   800de0 <nsipc>
  800f6a:	89 c3                	mov    %eax,%ebx
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	78 35                	js     800fa5 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f70:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f75:	7f 04                	jg     800f7b <nsipc_recv+0x39>
  800f77:	39 c6                	cmp    %eax,%esi
  800f79:	7d 16                	jge    800f91 <nsipc_recv+0x4f>
  800f7b:	68 67 24 80 00       	push   $0x802467
  800f80:	68 2f 24 80 00       	push   $0x80242f
  800f85:	6a 62                	push   $0x62
  800f87:	68 7c 24 80 00       	push   $0x80247c
  800f8c:	e8 84 05 00 00       	call   801515 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f91:	83 ec 04             	sub    $0x4,%esp
  800f94:	50                   	push   %eax
  800f95:	68 00 60 80 00       	push   $0x806000
  800f9a:	ff 75 0c             	pushl  0xc(%ebp)
  800f9d:	e8 e2 0d 00 00       	call   801d84 <memmove>
  800fa2:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800fa5:	89 d8                	mov    %ebx,%eax
  800fa7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800faa:	5b                   	pop    %ebx
  800fab:	5e                   	pop    %esi
  800fac:	5d                   	pop    %ebp
  800fad:	c3                   	ret    

00800fae <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800fae:	55                   	push   %ebp
  800faf:	89 e5                	mov    %esp,%ebp
  800fb1:	53                   	push   %ebx
  800fb2:	83 ec 04             	sub    $0x4,%esp
  800fb5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800fb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbb:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800fc0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fc6:	7e 16                	jle    800fde <nsipc_send+0x30>
  800fc8:	68 88 24 80 00       	push   $0x802488
  800fcd:	68 2f 24 80 00       	push   $0x80242f
  800fd2:	6a 6d                	push   $0x6d
  800fd4:	68 7c 24 80 00       	push   $0x80247c
  800fd9:	e8 37 05 00 00       	call   801515 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fde:	83 ec 04             	sub    $0x4,%esp
  800fe1:	53                   	push   %ebx
  800fe2:	ff 75 0c             	pushl  0xc(%ebp)
  800fe5:	68 0c 60 80 00       	push   $0x80600c
  800fea:	e8 95 0d 00 00       	call   801d84 <memmove>
	nsipcbuf.send.req_size = size;
  800fef:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800ff5:	8b 45 14             	mov    0x14(%ebp),%eax
  800ff8:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800ffd:	b8 08 00 00 00       	mov    $0x8,%eax
  801002:	e8 d9 fd ff ff       	call   800de0 <nsipc>
}
  801007:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80100a:	c9                   	leave  
  80100b:	c3                   	ret    

0080100c <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801012:	8b 45 08             	mov    0x8(%ebp),%eax
  801015:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80101a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101d:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801022:	8b 45 10             	mov    0x10(%ebp),%eax
  801025:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80102a:	b8 09 00 00 00       	mov    $0x9,%eax
  80102f:	e8 ac fd ff ff       	call   800de0 <nsipc>
}
  801034:	c9                   	leave  
  801035:	c3                   	ret    

00801036 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	56                   	push   %esi
  80103a:	53                   	push   %ebx
  80103b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80103e:	83 ec 0c             	sub    $0xc,%esp
  801041:	ff 75 08             	pushl  0x8(%ebp)
  801044:	e8 8b f3 ff ff       	call   8003d4 <fd2data>
  801049:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80104b:	83 c4 08             	add    $0x8,%esp
  80104e:	68 94 24 80 00       	push   $0x802494
  801053:	53                   	push   %ebx
  801054:	e8 99 0b 00 00       	call   801bf2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801059:	8b 46 04             	mov    0x4(%esi),%eax
  80105c:	2b 06                	sub    (%esi),%eax
  80105e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801064:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80106b:	00 00 00 
	stat->st_dev = &devpipe;
  80106e:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801075:	30 80 00 
	return 0;
}
  801078:	b8 00 00 00 00       	mov    $0x0,%eax
  80107d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801080:	5b                   	pop    %ebx
  801081:	5e                   	pop    %esi
  801082:	5d                   	pop    %ebp
  801083:	c3                   	ret    

00801084 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	53                   	push   %ebx
  801088:	83 ec 0c             	sub    $0xc,%esp
  80108b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80108e:	53                   	push   %ebx
  80108f:	6a 00                	push   $0x0
  801091:	e8 5f f1 ff ff       	call   8001f5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801096:	89 1c 24             	mov    %ebx,(%esp)
  801099:	e8 36 f3 ff ff       	call   8003d4 <fd2data>
  80109e:	83 c4 08             	add    $0x8,%esp
  8010a1:	50                   	push   %eax
  8010a2:	6a 00                	push   $0x0
  8010a4:	e8 4c f1 ff ff       	call   8001f5 <sys_page_unmap>
}
  8010a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ac:	c9                   	leave  
  8010ad:	c3                   	ret    

008010ae <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8010ae:	55                   	push   %ebp
  8010af:	89 e5                	mov    %esp,%ebp
  8010b1:	57                   	push   %edi
  8010b2:	56                   	push   %esi
  8010b3:	53                   	push   %ebx
  8010b4:	83 ec 1c             	sub    $0x1c,%esp
  8010b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010ba:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8010bc:	a1 08 40 80 00       	mov    0x804008,%eax
  8010c1:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8010c4:	83 ec 0c             	sub    $0xc,%esp
  8010c7:	ff 75 e0             	pushl  -0x20(%ebp)
  8010ca:	e8 c3 0f 00 00       	call   802092 <pageref>
  8010cf:	89 c3                	mov    %eax,%ebx
  8010d1:	89 3c 24             	mov    %edi,(%esp)
  8010d4:	e8 b9 0f 00 00       	call   802092 <pageref>
  8010d9:	83 c4 10             	add    $0x10,%esp
  8010dc:	39 c3                	cmp    %eax,%ebx
  8010de:	0f 94 c1             	sete   %cl
  8010e1:	0f b6 c9             	movzbl %cl,%ecx
  8010e4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010e7:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010ed:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010f0:	39 ce                	cmp    %ecx,%esi
  8010f2:	74 1b                	je     80110f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010f4:	39 c3                	cmp    %eax,%ebx
  8010f6:	75 c4                	jne    8010bc <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010f8:	8b 42 58             	mov    0x58(%edx),%eax
  8010fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010fe:	50                   	push   %eax
  8010ff:	56                   	push   %esi
  801100:	68 9b 24 80 00       	push   $0x80249b
  801105:	e8 e4 04 00 00       	call   8015ee <cprintf>
  80110a:	83 c4 10             	add    $0x10,%esp
  80110d:	eb ad                	jmp    8010bc <_pipeisclosed+0xe>
	}
}
  80110f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801112:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801115:	5b                   	pop    %ebx
  801116:	5e                   	pop    %esi
  801117:	5f                   	pop    %edi
  801118:	5d                   	pop    %ebp
  801119:	c3                   	ret    

0080111a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	57                   	push   %edi
  80111e:	56                   	push   %esi
  80111f:	53                   	push   %ebx
  801120:	83 ec 28             	sub    $0x28,%esp
  801123:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801126:	56                   	push   %esi
  801127:	e8 a8 f2 ff ff       	call   8003d4 <fd2data>
  80112c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80112e:	83 c4 10             	add    $0x10,%esp
  801131:	bf 00 00 00 00       	mov    $0x0,%edi
  801136:	eb 4b                	jmp    801183 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801138:	89 da                	mov    %ebx,%edx
  80113a:	89 f0                	mov    %esi,%eax
  80113c:	e8 6d ff ff ff       	call   8010ae <_pipeisclosed>
  801141:	85 c0                	test   %eax,%eax
  801143:	75 48                	jne    80118d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801145:	e8 07 f0 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80114a:	8b 43 04             	mov    0x4(%ebx),%eax
  80114d:	8b 0b                	mov    (%ebx),%ecx
  80114f:	8d 51 20             	lea    0x20(%ecx),%edx
  801152:	39 d0                	cmp    %edx,%eax
  801154:	73 e2                	jae    801138 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801156:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801159:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80115d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801160:	89 c2                	mov    %eax,%edx
  801162:	c1 fa 1f             	sar    $0x1f,%edx
  801165:	89 d1                	mov    %edx,%ecx
  801167:	c1 e9 1b             	shr    $0x1b,%ecx
  80116a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80116d:	83 e2 1f             	and    $0x1f,%edx
  801170:	29 ca                	sub    %ecx,%edx
  801172:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801176:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80117a:	83 c0 01             	add    $0x1,%eax
  80117d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801180:	83 c7 01             	add    $0x1,%edi
  801183:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801186:	75 c2                	jne    80114a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801188:	8b 45 10             	mov    0x10(%ebp),%eax
  80118b:	eb 05                	jmp    801192 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80118d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801192:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801195:	5b                   	pop    %ebx
  801196:	5e                   	pop    %esi
  801197:	5f                   	pop    %edi
  801198:	5d                   	pop    %ebp
  801199:	c3                   	ret    

0080119a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
  80119d:	57                   	push   %edi
  80119e:	56                   	push   %esi
  80119f:	53                   	push   %ebx
  8011a0:	83 ec 18             	sub    $0x18,%esp
  8011a3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8011a6:	57                   	push   %edi
  8011a7:	e8 28 f2 ff ff       	call   8003d4 <fd2data>
  8011ac:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011ae:	83 c4 10             	add    $0x10,%esp
  8011b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b6:	eb 3d                	jmp    8011f5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8011b8:	85 db                	test   %ebx,%ebx
  8011ba:	74 04                	je     8011c0 <devpipe_read+0x26>
				return i;
  8011bc:	89 d8                	mov    %ebx,%eax
  8011be:	eb 44                	jmp    801204 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8011c0:	89 f2                	mov    %esi,%edx
  8011c2:	89 f8                	mov    %edi,%eax
  8011c4:	e8 e5 fe ff ff       	call   8010ae <_pipeisclosed>
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	75 32                	jne    8011ff <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011cd:	e8 7f ef ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011d2:	8b 06                	mov    (%esi),%eax
  8011d4:	3b 46 04             	cmp    0x4(%esi),%eax
  8011d7:	74 df                	je     8011b8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011d9:	99                   	cltd   
  8011da:	c1 ea 1b             	shr    $0x1b,%edx
  8011dd:	01 d0                	add    %edx,%eax
  8011df:	83 e0 1f             	and    $0x1f,%eax
  8011e2:	29 d0                	sub    %edx,%eax
  8011e4:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ec:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011ef:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011f2:	83 c3 01             	add    $0x1,%ebx
  8011f5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011f8:	75 d8                	jne    8011d2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8011fd:	eb 05                	jmp    801204 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011ff:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801204:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801207:	5b                   	pop    %ebx
  801208:	5e                   	pop    %esi
  801209:	5f                   	pop    %edi
  80120a:	5d                   	pop    %ebp
  80120b:	c3                   	ret    

0080120c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80120c:	55                   	push   %ebp
  80120d:	89 e5                	mov    %esp,%ebp
  80120f:	56                   	push   %esi
  801210:	53                   	push   %ebx
  801211:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801214:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801217:	50                   	push   %eax
  801218:	e8 ce f1 ff ff       	call   8003eb <fd_alloc>
  80121d:	83 c4 10             	add    $0x10,%esp
  801220:	89 c2                	mov    %eax,%edx
  801222:	85 c0                	test   %eax,%eax
  801224:	0f 88 2c 01 00 00    	js     801356 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80122a:	83 ec 04             	sub    $0x4,%esp
  80122d:	68 07 04 00 00       	push   $0x407
  801232:	ff 75 f4             	pushl  -0xc(%ebp)
  801235:	6a 00                	push   $0x0
  801237:	e8 34 ef ff ff       	call   800170 <sys_page_alloc>
  80123c:	83 c4 10             	add    $0x10,%esp
  80123f:	89 c2                	mov    %eax,%edx
  801241:	85 c0                	test   %eax,%eax
  801243:	0f 88 0d 01 00 00    	js     801356 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801249:	83 ec 0c             	sub    $0xc,%esp
  80124c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124f:	50                   	push   %eax
  801250:	e8 96 f1 ff ff       	call   8003eb <fd_alloc>
  801255:	89 c3                	mov    %eax,%ebx
  801257:	83 c4 10             	add    $0x10,%esp
  80125a:	85 c0                	test   %eax,%eax
  80125c:	0f 88 e2 00 00 00    	js     801344 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801262:	83 ec 04             	sub    $0x4,%esp
  801265:	68 07 04 00 00       	push   $0x407
  80126a:	ff 75 f0             	pushl  -0x10(%ebp)
  80126d:	6a 00                	push   $0x0
  80126f:	e8 fc ee ff ff       	call   800170 <sys_page_alloc>
  801274:	89 c3                	mov    %eax,%ebx
  801276:	83 c4 10             	add    $0x10,%esp
  801279:	85 c0                	test   %eax,%eax
  80127b:	0f 88 c3 00 00 00    	js     801344 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801281:	83 ec 0c             	sub    $0xc,%esp
  801284:	ff 75 f4             	pushl  -0xc(%ebp)
  801287:	e8 48 f1 ff ff       	call   8003d4 <fd2data>
  80128c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80128e:	83 c4 0c             	add    $0xc,%esp
  801291:	68 07 04 00 00       	push   $0x407
  801296:	50                   	push   %eax
  801297:	6a 00                	push   $0x0
  801299:	e8 d2 ee ff ff       	call   800170 <sys_page_alloc>
  80129e:	89 c3                	mov    %eax,%ebx
  8012a0:	83 c4 10             	add    $0x10,%esp
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	0f 88 89 00 00 00    	js     801334 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012ab:	83 ec 0c             	sub    $0xc,%esp
  8012ae:	ff 75 f0             	pushl  -0x10(%ebp)
  8012b1:	e8 1e f1 ff ff       	call   8003d4 <fd2data>
  8012b6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012bd:	50                   	push   %eax
  8012be:	6a 00                	push   $0x0
  8012c0:	56                   	push   %esi
  8012c1:	6a 00                	push   $0x0
  8012c3:	e8 eb ee ff ff       	call   8001b3 <sys_page_map>
  8012c8:	89 c3                	mov    %eax,%ebx
  8012ca:	83 c4 20             	add    $0x20,%esp
  8012cd:	85 c0                	test   %eax,%eax
  8012cf:	78 55                	js     801326 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012d1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012da:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012df:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012e6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ef:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012fb:	83 ec 0c             	sub    $0xc,%esp
  8012fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801301:	e8 be f0 ff ff       	call   8003c4 <fd2num>
  801306:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801309:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80130b:	83 c4 04             	add    $0x4,%esp
  80130e:	ff 75 f0             	pushl  -0x10(%ebp)
  801311:	e8 ae f0 ff ff       	call   8003c4 <fd2num>
  801316:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801319:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80131c:	83 c4 10             	add    $0x10,%esp
  80131f:	ba 00 00 00 00       	mov    $0x0,%edx
  801324:	eb 30                	jmp    801356 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801326:	83 ec 08             	sub    $0x8,%esp
  801329:	56                   	push   %esi
  80132a:	6a 00                	push   $0x0
  80132c:	e8 c4 ee ff ff       	call   8001f5 <sys_page_unmap>
  801331:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801334:	83 ec 08             	sub    $0x8,%esp
  801337:	ff 75 f0             	pushl  -0x10(%ebp)
  80133a:	6a 00                	push   $0x0
  80133c:	e8 b4 ee ff ff       	call   8001f5 <sys_page_unmap>
  801341:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801344:	83 ec 08             	sub    $0x8,%esp
  801347:	ff 75 f4             	pushl  -0xc(%ebp)
  80134a:	6a 00                	push   $0x0
  80134c:	e8 a4 ee ff ff       	call   8001f5 <sys_page_unmap>
  801351:	83 c4 10             	add    $0x10,%esp
  801354:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801356:	89 d0                	mov    %edx,%eax
  801358:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80135b:	5b                   	pop    %ebx
  80135c:	5e                   	pop    %esi
  80135d:	5d                   	pop    %ebp
  80135e:	c3                   	ret    

0080135f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80135f:	55                   	push   %ebp
  801360:	89 e5                	mov    %esp,%ebp
  801362:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801365:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801368:	50                   	push   %eax
  801369:	ff 75 08             	pushl  0x8(%ebp)
  80136c:	e8 c9 f0 ff ff       	call   80043a <fd_lookup>
  801371:	83 c4 10             	add    $0x10,%esp
  801374:	85 c0                	test   %eax,%eax
  801376:	78 18                	js     801390 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801378:	83 ec 0c             	sub    $0xc,%esp
  80137b:	ff 75 f4             	pushl  -0xc(%ebp)
  80137e:	e8 51 f0 ff ff       	call   8003d4 <fd2data>
	return _pipeisclosed(fd, p);
  801383:	89 c2                	mov    %eax,%edx
  801385:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801388:	e8 21 fd ff ff       	call   8010ae <_pipeisclosed>
  80138d:	83 c4 10             	add    $0x10,%esp
}
  801390:	c9                   	leave  
  801391:	c3                   	ret    

00801392 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801395:	b8 00 00 00 00       	mov    $0x0,%eax
  80139a:	5d                   	pop    %ebp
  80139b:	c3                   	ret    

0080139c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8013a2:	68 b3 24 80 00       	push   $0x8024b3
  8013a7:	ff 75 0c             	pushl  0xc(%ebp)
  8013aa:	e8 43 08 00 00       	call   801bf2 <strcpy>
	return 0;
}
  8013af:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b4:	c9                   	leave  
  8013b5:	c3                   	ret    

008013b6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8013b6:	55                   	push   %ebp
  8013b7:	89 e5                	mov    %esp,%ebp
  8013b9:	57                   	push   %edi
  8013ba:	56                   	push   %esi
  8013bb:	53                   	push   %ebx
  8013bc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013c2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013c7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013cd:	eb 2d                	jmp    8013fc <devcons_write+0x46>
		m = n - tot;
  8013cf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013d2:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013d4:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013d7:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013dc:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013df:	83 ec 04             	sub    $0x4,%esp
  8013e2:	53                   	push   %ebx
  8013e3:	03 45 0c             	add    0xc(%ebp),%eax
  8013e6:	50                   	push   %eax
  8013e7:	57                   	push   %edi
  8013e8:	e8 97 09 00 00       	call   801d84 <memmove>
		sys_cputs(buf, m);
  8013ed:	83 c4 08             	add    $0x8,%esp
  8013f0:	53                   	push   %ebx
  8013f1:	57                   	push   %edi
  8013f2:	e8 bd ec ff ff       	call   8000b4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013f7:	01 de                	add    %ebx,%esi
  8013f9:	83 c4 10             	add    $0x10,%esp
  8013fc:	89 f0                	mov    %esi,%eax
  8013fe:	3b 75 10             	cmp    0x10(%ebp),%esi
  801401:	72 cc                	jb     8013cf <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801403:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801406:	5b                   	pop    %ebx
  801407:	5e                   	pop    %esi
  801408:	5f                   	pop    %edi
  801409:	5d                   	pop    %ebp
  80140a:	c3                   	ret    

0080140b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	83 ec 08             	sub    $0x8,%esp
  801411:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801416:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80141a:	74 2a                	je     801446 <devcons_read+0x3b>
  80141c:	eb 05                	jmp    801423 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80141e:	e8 2e ed ff ff       	call   800151 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801423:	e8 aa ec ff ff       	call   8000d2 <sys_cgetc>
  801428:	85 c0                	test   %eax,%eax
  80142a:	74 f2                	je     80141e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80142c:	85 c0                	test   %eax,%eax
  80142e:	78 16                	js     801446 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801430:	83 f8 04             	cmp    $0x4,%eax
  801433:	74 0c                	je     801441 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801435:	8b 55 0c             	mov    0xc(%ebp),%edx
  801438:	88 02                	mov    %al,(%edx)
	return 1;
  80143a:	b8 01 00 00 00       	mov    $0x1,%eax
  80143f:	eb 05                	jmp    801446 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801441:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801446:	c9                   	leave  
  801447:	c3                   	ret    

00801448 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80144e:	8b 45 08             	mov    0x8(%ebp),%eax
  801451:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801454:	6a 01                	push   $0x1
  801456:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801459:	50                   	push   %eax
  80145a:	e8 55 ec ff ff       	call   8000b4 <sys_cputs>
}
  80145f:	83 c4 10             	add    $0x10,%esp
  801462:	c9                   	leave  
  801463:	c3                   	ret    

00801464 <getchar>:

int
getchar(void)
{
  801464:	55                   	push   %ebp
  801465:	89 e5                	mov    %esp,%ebp
  801467:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80146a:	6a 01                	push   $0x1
  80146c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80146f:	50                   	push   %eax
  801470:	6a 00                	push   $0x0
  801472:	e8 29 f2 ff ff       	call   8006a0 <read>
	if (r < 0)
  801477:	83 c4 10             	add    $0x10,%esp
  80147a:	85 c0                	test   %eax,%eax
  80147c:	78 0f                	js     80148d <getchar+0x29>
		return r;
	if (r < 1)
  80147e:	85 c0                	test   %eax,%eax
  801480:	7e 06                	jle    801488 <getchar+0x24>
		return -E_EOF;
	return c;
  801482:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801486:	eb 05                	jmp    80148d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801488:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80148d:	c9                   	leave  
  80148e:	c3                   	ret    

0080148f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80148f:	55                   	push   %ebp
  801490:	89 e5                	mov    %esp,%ebp
  801492:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801495:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801498:	50                   	push   %eax
  801499:	ff 75 08             	pushl  0x8(%ebp)
  80149c:	e8 99 ef ff ff       	call   80043a <fd_lookup>
  8014a1:	83 c4 10             	add    $0x10,%esp
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	78 11                	js     8014b9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8014a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ab:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014b1:	39 10                	cmp    %edx,(%eax)
  8014b3:	0f 94 c0             	sete   %al
  8014b6:	0f b6 c0             	movzbl %al,%eax
}
  8014b9:	c9                   	leave  
  8014ba:	c3                   	ret    

008014bb <opencons>:

int
opencons(void)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c4:	50                   	push   %eax
  8014c5:	e8 21 ef ff ff       	call   8003eb <fd_alloc>
  8014ca:	83 c4 10             	add    $0x10,%esp
		return r;
  8014cd:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	78 3e                	js     801511 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014d3:	83 ec 04             	sub    $0x4,%esp
  8014d6:	68 07 04 00 00       	push   $0x407
  8014db:	ff 75 f4             	pushl  -0xc(%ebp)
  8014de:	6a 00                	push   $0x0
  8014e0:	e8 8b ec ff ff       	call   800170 <sys_page_alloc>
  8014e5:	83 c4 10             	add    $0x10,%esp
		return r;
  8014e8:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014ea:	85 c0                	test   %eax,%eax
  8014ec:	78 23                	js     801511 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014ee:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014f7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014fc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801503:	83 ec 0c             	sub    $0xc,%esp
  801506:	50                   	push   %eax
  801507:	e8 b8 ee ff ff       	call   8003c4 <fd2num>
  80150c:	89 c2                	mov    %eax,%edx
  80150e:	83 c4 10             	add    $0x10,%esp
}
  801511:	89 d0                	mov    %edx,%eax
  801513:	c9                   	leave  
  801514:	c3                   	ret    

00801515 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	56                   	push   %esi
  801519:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80151a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80151d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801523:	e8 0a ec ff ff       	call   800132 <sys_getenvid>
  801528:	83 ec 0c             	sub    $0xc,%esp
  80152b:	ff 75 0c             	pushl  0xc(%ebp)
  80152e:	ff 75 08             	pushl  0x8(%ebp)
  801531:	56                   	push   %esi
  801532:	50                   	push   %eax
  801533:	68 c0 24 80 00       	push   $0x8024c0
  801538:	e8 b1 00 00 00       	call   8015ee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80153d:	83 c4 18             	add    $0x18,%esp
  801540:	53                   	push   %ebx
  801541:	ff 75 10             	pushl  0x10(%ebp)
  801544:	e8 54 00 00 00       	call   80159d <vcprintf>
	cprintf("\n");
  801549:	c7 04 24 ac 24 80 00 	movl   $0x8024ac,(%esp)
  801550:	e8 99 00 00 00       	call   8015ee <cprintf>
  801555:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801558:	cc                   	int3   
  801559:	eb fd                	jmp    801558 <_panic+0x43>

0080155b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	53                   	push   %ebx
  80155f:	83 ec 04             	sub    $0x4,%esp
  801562:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801565:	8b 13                	mov    (%ebx),%edx
  801567:	8d 42 01             	lea    0x1(%edx),%eax
  80156a:	89 03                	mov    %eax,(%ebx)
  80156c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80156f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801573:	3d ff 00 00 00       	cmp    $0xff,%eax
  801578:	75 1a                	jne    801594 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80157a:	83 ec 08             	sub    $0x8,%esp
  80157d:	68 ff 00 00 00       	push   $0xff
  801582:	8d 43 08             	lea    0x8(%ebx),%eax
  801585:	50                   	push   %eax
  801586:	e8 29 eb ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  80158b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801591:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801594:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801598:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159b:	c9                   	leave  
  80159c:	c3                   	ret    

0080159d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80159d:	55                   	push   %ebp
  80159e:	89 e5                	mov    %esp,%ebp
  8015a0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8015a6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8015ad:	00 00 00 
	b.cnt = 0;
  8015b0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015b7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015ba:	ff 75 0c             	pushl  0xc(%ebp)
  8015bd:	ff 75 08             	pushl  0x8(%ebp)
  8015c0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015c6:	50                   	push   %eax
  8015c7:	68 5b 15 80 00       	push   $0x80155b
  8015cc:	e8 1a 01 00 00       	call   8016eb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015d1:	83 c4 08             	add    $0x8,%esp
  8015d4:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015da:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015e0:	50                   	push   %eax
  8015e1:	e8 ce ea ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  8015e6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015ec:	c9                   	leave  
  8015ed:	c3                   	ret    

008015ee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015f4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015f7:	50                   	push   %eax
  8015f8:	ff 75 08             	pushl  0x8(%ebp)
  8015fb:	e8 9d ff ff ff       	call   80159d <vcprintf>
	va_end(ap);

	return cnt;
}
  801600:	c9                   	leave  
  801601:	c3                   	ret    

00801602 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801602:	55                   	push   %ebp
  801603:	89 e5                	mov    %esp,%ebp
  801605:	57                   	push   %edi
  801606:	56                   	push   %esi
  801607:	53                   	push   %ebx
  801608:	83 ec 1c             	sub    $0x1c,%esp
  80160b:	89 c7                	mov    %eax,%edi
  80160d:	89 d6                	mov    %edx,%esi
  80160f:	8b 45 08             	mov    0x8(%ebp),%eax
  801612:	8b 55 0c             	mov    0xc(%ebp),%edx
  801615:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801618:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80161b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80161e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801623:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801626:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801629:	39 d3                	cmp    %edx,%ebx
  80162b:	72 05                	jb     801632 <printnum+0x30>
  80162d:	39 45 10             	cmp    %eax,0x10(%ebp)
  801630:	77 45                	ja     801677 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801632:	83 ec 0c             	sub    $0xc,%esp
  801635:	ff 75 18             	pushl  0x18(%ebp)
  801638:	8b 45 14             	mov    0x14(%ebp),%eax
  80163b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80163e:	53                   	push   %ebx
  80163f:	ff 75 10             	pushl  0x10(%ebp)
  801642:	83 ec 08             	sub    $0x8,%esp
  801645:	ff 75 e4             	pushl  -0x1c(%ebp)
  801648:	ff 75 e0             	pushl  -0x20(%ebp)
  80164b:	ff 75 dc             	pushl  -0x24(%ebp)
  80164e:	ff 75 d8             	pushl  -0x28(%ebp)
  801651:	e8 7a 0a 00 00       	call   8020d0 <__udivdi3>
  801656:	83 c4 18             	add    $0x18,%esp
  801659:	52                   	push   %edx
  80165a:	50                   	push   %eax
  80165b:	89 f2                	mov    %esi,%edx
  80165d:	89 f8                	mov    %edi,%eax
  80165f:	e8 9e ff ff ff       	call   801602 <printnum>
  801664:	83 c4 20             	add    $0x20,%esp
  801667:	eb 18                	jmp    801681 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801669:	83 ec 08             	sub    $0x8,%esp
  80166c:	56                   	push   %esi
  80166d:	ff 75 18             	pushl  0x18(%ebp)
  801670:	ff d7                	call   *%edi
  801672:	83 c4 10             	add    $0x10,%esp
  801675:	eb 03                	jmp    80167a <printnum+0x78>
  801677:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80167a:	83 eb 01             	sub    $0x1,%ebx
  80167d:	85 db                	test   %ebx,%ebx
  80167f:	7f e8                	jg     801669 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801681:	83 ec 08             	sub    $0x8,%esp
  801684:	56                   	push   %esi
  801685:	83 ec 04             	sub    $0x4,%esp
  801688:	ff 75 e4             	pushl  -0x1c(%ebp)
  80168b:	ff 75 e0             	pushl  -0x20(%ebp)
  80168e:	ff 75 dc             	pushl  -0x24(%ebp)
  801691:	ff 75 d8             	pushl  -0x28(%ebp)
  801694:	e8 67 0b 00 00       	call   802200 <__umoddi3>
  801699:	83 c4 14             	add    $0x14,%esp
  80169c:	0f be 80 e3 24 80 00 	movsbl 0x8024e3(%eax),%eax
  8016a3:	50                   	push   %eax
  8016a4:	ff d7                	call   *%edi
}
  8016a6:	83 c4 10             	add    $0x10,%esp
  8016a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016ac:	5b                   	pop    %ebx
  8016ad:	5e                   	pop    %esi
  8016ae:	5f                   	pop    %edi
  8016af:	5d                   	pop    %ebp
  8016b0:	c3                   	ret    

008016b1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8016b1:	55                   	push   %ebp
  8016b2:	89 e5                	mov    %esp,%ebp
  8016b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016b7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016bb:	8b 10                	mov    (%eax),%edx
  8016bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8016c0:	73 0a                	jae    8016cc <sprintputch+0x1b>
		*b->buf++ = ch;
  8016c2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016c5:	89 08                	mov    %ecx,(%eax)
  8016c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ca:	88 02                	mov    %al,(%edx)
}
  8016cc:	5d                   	pop    %ebp
  8016cd:	c3                   	ret    

008016ce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016ce:	55                   	push   %ebp
  8016cf:	89 e5                	mov    %esp,%ebp
  8016d1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016d7:	50                   	push   %eax
  8016d8:	ff 75 10             	pushl  0x10(%ebp)
  8016db:	ff 75 0c             	pushl  0xc(%ebp)
  8016de:	ff 75 08             	pushl  0x8(%ebp)
  8016e1:	e8 05 00 00 00       	call   8016eb <vprintfmt>
	va_end(ap);
}
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	c9                   	leave  
  8016ea:	c3                   	ret    

008016eb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016eb:	55                   	push   %ebp
  8016ec:	89 e5                	mov    %esp,%ebp
  8016ee:	57                   	push   %edi
  8016ef:	56                   	push   %esi
  8016f0:	53                   	push   %ebx
  8016f1:	83 ec 2c             	sub    $0x2c,%esp
  8016f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8016f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016fa:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016fd:	eb 12                	jmp    801711 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016ff:	85 c0                	test   %eax,%eax
  801701:	0f 84 42 04 00 00    	je     801b49 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  801707:	83 ec 08             	sub    $0x8,%esp
  80170a:	53                   	push   %ebx
  80170b:	50                   	push   %eax
  80170c:	ff d6                	call   *%esi
  80170e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801711:	83 c7 01             	add    $0x1,%edi
  801714:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801718:	83 f8 25             	cmp    $0x25,%eax
  80171b:	75 e2                	jne    8016ff <vprintfmt+0x14>
  80171d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801721:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801728:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80172f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801736:	b9 00 00 00 00       	mov    $0x0,%ecx
  80173b:	eb 07                	jmp    801744 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80173d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801740:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801744:	8d 47 01             	lea    0x1(%edi),%eax
  801747:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80174a:	0f b6 07             	movzbl (%edi),%eax
  80174d:	0f b6 d0             	movzbl %al,%edx
  801750:	83 e8 23             	sub    $0x23,%eax
  801753:	3c 55                	cmp    $0x55,%al
  801755:	0f 87 d3 03 00 00    	ja     801b2e <vprintfmt+0x443>
  80175b:	0f b6 c0             	movzbl %al,%eax
  80175e:	ff 24 85 20 26 80 00 	jmp    *0x802620(,%eax,4)
  801765:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801768:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80176c:	eb d6                	jmp    801744 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80176e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801771:	b8 00 00 00 00       	mov    $0x0,%eax
  801776:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801779:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80177c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801780:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801783:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801786:	83 f9 09             	cmp    $0x9,%ecx
  801789:	77 3f                	ja     8017ca <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80178b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80178e:	eb e9                	jmp    801779 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801790:	8b 45 14             	mov    0x14(%ebp),%eax
  801793:	8b 00                	mov    (%eax),%eax
  801795:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801798:	8b 45 14             	mov    0x14(%ebp),%eax
  80179b:	8d 40 04             	lea    0x4(%eax),%eax
  80179e:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8017a4:	eb 2a                	jmp    8017d0 <vprintfmt+0xe5>
  8017a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017a9:	85 c0                	test   %eax,%eax
  8017ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b0:	0f 49 d0             	cmovns %eax,%edx
  8017b3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017b9:	eb 89                	jmp    801744 <vprintfmt+0x59>
  8017bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017be:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017c5:	e9 7a ff ff ff       	jmp    801744 <vprintfmt+0x59>
  8017ca:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8017cd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017d0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017d4:	0f 89 6a ff ff ff    	jns    801744 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017da:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017e0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017e7:	e9 58 ff ff ff       	jmp    801744 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017ec:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ef:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017f2:	e9 4d ff ff ff       	jmp    801744 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8017fa:	8d 78 04             	lea    0x4(%eax),%edi
  8017fd:	83 ec 08             	sub    $0x8,%esp
  801800:	53                   	push   %ebx
  801801:	ff 30                	pushl  (%eax)
  801803:	ff d6                	call   *%esi
			break;
  801805:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801808:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80180b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80180e:	e9 fe fe ff ff       	jmp    801711 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801813:	8b 45 14             	mov    0x14(%ebp),%eax
  801816:	8d 78 04             	lea    0x4(%eax),%edi
  801819:	8b 00                	mov    (%eax),%eax
  80181b:	99                   	cltd   
  80181c:	31 d0                	xor    %edx,%eax
  80181e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801820:	83 f8 0f             	cmp    $0xf,%eax
  801823:	7f 0b                	jg     801830 <vprintfmt+0x145>
  801825:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  80182c:	85 d2                	test   %edx,%edx
  80182e:	75 1b                	jne    80184b <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  801830:	50                   	push   %eax
  801831:	68 fb 24 80 00       	push   $0x8024fb
  801836:	53                   	push   %ebx
  801837:	56                   	push   %esi
  801838:	e8 91 fe ff ff       	call   8016ce <printfmt>
  80183d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801840:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801843:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801846:	e9 c6 fe ff ff       	jmp    801711 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80184b:	52                   	push   %edx
  80184c:	68 41 24 80 00       	push   $0x802441
  801851:	53                   	push   %ebx
  801852:	56                   	push   %esi
  801853:	e8 76 fe ff ff       	call   8016ce <printfmt>
  801858:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80185b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80185e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801861:	e9 ab fe ff ff       	jmp    801711 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801866:	8b 45 14             	mov    0x14(%ebp),%eax
  801869:	83 c0 04             	add    $0x4,%eax
  80186c:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80186f:	8b 45 14             	mov    0x14(%ebp),%eax
  801872:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801874:	85 ff                	test   %edi,%edi
  801876:	b8 f4 24 80 00       	mov    $0x8024f4,%eax
  80187b:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80187e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801882:	0f 8e 94 00 00 00    	jle    80191c <vprintfmt+0x231>
  801888:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80188c:	0f 84 98 00 00 00    	je     80192a <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  801892:	83 ec 08             	sub    $0x8,%esp
  801895:	ff 75 d0             	pushl  -0x30(%ebp)
  801898:	57                   	push   %edi
  801899:	e8 33 03 00 00       	call   801bd1 <strnlen>
  80189e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018a1:	29 c1                	sub    %eax,%ecx
  8018a3:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8018a6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8018a9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8018ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018b0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018b3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018b5:	eb 0f                	jmp    8018c6 <vprintfmt+0x1db>
					putch(padc, putdat);
  8018b7:	83 ec 08             	sub    $0x8,%esp
  8018ba:	53                   	push   %ebx
  8018bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8018be:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018c0:	83 ef 01             	sub    $0x1,%edi
  8018c3:	83 c4 10             	add    $0x10,%esp
  8018c6:	85 ff                	test   %edi,%edi
  8018c8:	7f ed                	jg     8018b7 <vprintfmt+0x1cc>
  8018ca:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018cd:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8018d0:	85 c9                	test   %ecx,%ecx
  8018d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d7:	0f 49 c1             	cmovns %ecx,%eax
  8018da:	29 c1                	sub    %eax,%ecx
  8018dc:	89 75 08             	mov    %esi,0x8(%ebp)
  8018df:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018e2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018e5:	89 cb                	mov    %ecx,%ebx
  8018e7:	eb 4d                	jmp    801936 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018e9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018ed:	74 1b                	je     80190a <vprintfmt+0x21f>
  8018ef:	0f be c0             	movsbl %al,%eax
  8018f2:	83 e8 20             	sub    $0x20,%eax
  8018f5:	83 f8 5e             	cmp    $0x5e,%eax
  8018f8:	76 10                	jbe    80190a <vprintfmt+0x21f>
					putch('?', putdat);
  8018fa:	83 ec 08             	sub    $0x8,%esp
  8018fd:	ff 75 0c             	pushl  0xc(%ebp)
  801900:	6a 3f                	push   $0x3f
  801902:	ff 55 08             	call   *0x8(%ebp)
  801905:	83 c4 10             	add    $0x10,%esp
  801908:	eb 0d                	jmp    801917 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80190a:	83 ec 08             	sub    $0x8,%esp
  80190d:	ff 75 0c             	pushl  0xc(%ebp)
  801910:	52                   	push   %edx
  801911:	ff 55 08             	call   *0x8(%ebp)
  801914:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801917:	83 eb 01             	sub    $0x1,%ebx
  80191a:	eb 1a                	jmp    801936 <vprintfmt+0x24b>
  80191c:	89 75 08             	mov    %esi,0x8(%ebp)
  80191f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801922:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801925:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801928:	eb 0c                	jmp    801936 <vprintfmt+0x24b>
  80192a:	89 75 08             	mov    %esi,0x8(%ebp)
  80192d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801930:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801933:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801936:	83 c7 01             	add    $0x1,%edi
  801939:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80193d:	0f be d0             	movsbl %al,%edx
  801940:	85 d2                	test   %edx,%edx
  801942:	74 23                	je     801967 <vprintfmt+0x27c>
  801944:	85 f6                	test   %esi,%esi
  801946:	78 a1                	js     8018e9 <vprintfmt+0x1fe>
  801948:	83 ee 01             	sub    $0x1,%esi
  80194b:	79 9c                	jns    8018e9 <vprintfmt+0x1fe>
  80194d:	89 df                	mov    %ebx,%edi
  80194f:	8b 75 08             	mov    0x8(%ebp),%esi
  801952:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801955:	eb 18                	jmp    80196f <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801957:	83 ec 08             	sub    $0x8,%esp
  80195a:	53                   	push   %ebx
  80195b:	6a 20                	push   $0x20
  80195d:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80195f:	83 ef 01             	sub    $0x1,%edi
  801962:	83 c4 10             	add    $0x10,%esp
  801965:	eb 08                	jmp    80196f <vprintfmt+0x284>
  801967:	89 df                	mov    %ebx,%edi
  801969:	8b 75 08             	mov    0x8(%ebp),%esi
  80196c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80196f:	85 ff                	test   %edi,%edi
  801971:	7f e4                	jg     801957 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801973:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801976:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801979:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80197c:	e9 90 fd ff ff       	jmp    801711 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801981:	83 f9 01             	cmp    $0x1,%ecx
  801984:	7e 19                	jle    80199f <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  801986:	8b 45 14             	mov    0x14(%ebp),%eax
  801989:	8b 50 04             	mov    0x4(%eax),%edx
  80198c:	8b 00                	mov    (%eax),%eax
  80198e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801991:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801994:	8b 45 14             	mov    0x14(%ebp),%eax
  801997:	8d 40 08             	lea    0x8(%eax),%eax
  80199a:	89 45 14             	mov    %eax,0x14(%ebp)
  80199d:	eb 38                	jmp    8019d7 <vprintfmt+0x2ec>
	else if (lflag)
  80199f:	85 c9                	test   %ecx,%ecx
  8019a1:	74 1b                	je     8019be <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8019a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a6:	8b 00                	mov    (%eax),%eax
  8019a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019ab:	89 c1                	mov    %eax,%ecx
  8019ad:	c1 f9 1f             	sar    $0x1f,%ecx
  8019b0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b6:	8d 40 04             	lea    0x4(%eax),%eax
  8019b9:	89 45 14             	mov    %eax,0x14(%ebp)
  8019bc:	eb 19                	jmp    8019d7 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8019be:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c1:	8b 00                	mov    (%eax),%eax
  8019c3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019c6:	89 c1                	mov    %eax,%ecx
  8019c8:	c1 f9 1f             	sar    $0x1f,%ecx
  8019cb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8019d1:	8d 40 04             	lea    0x4(%eax),%eax
  8019d4:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019d7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8019da:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019dd:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019e2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019e6:	0f 89 0e 01 00 00    	jns    801afa <vprintfmt+0x40f>
				putch('-', putdat);
  8019ec:	83 ec 08             	sub    $0x8,%esp
  8019ef:	53                   	push   %ebx
  8019f0:	6a 2d                	push   $0x2d
  8019f2:	ff d6                	call   *%esi
				num = -(long long) num;
  8019f4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8019f7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8019fa:	f7 da                	neg    %edx
  8019fc:	83 d1 00             	adc    $0x0,%ecx
  8019ff:	f7 d9                	neg    %ecx
  801a01:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801a04:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a09:	e9 ec 00 00 00       	jmp    801afa <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a0e:	83 f9 01             	cmp    $0x1,%ecx
  801a11:	7e 18                	jle    801a2b <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  801a13:	8b 45 14             	mov    0x14(%ebp),%eax
  801a16:	8b 10                	mov    (%eax),%edx
  801a18:	8b 48 04             	mov    0x4(%eax),%ecx
  801a1b:	8d 40 08             	lea    0x8(%eax),%eax
  801a1e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801a21:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a26:	e9 cf 00 00 00       	jmp    801afa <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801a2b:	85 c9                	test   %ecx,%ecx
  801a2d:	74 1a                	je     801a49 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  801a2f:	8b 45 14             	mov    0x14(%ebp),%eax
  801a32:	8b 10                	mov    (%eax),%edx
  801a34:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a39:	8d 40 04             	lea    0x4(%eax),%eax
  801a3c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801a3f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a44:	e9 b1 00 00 00       	jmp    801afa <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801a49:	8b 45 14             	mov    0x14(%ebp),%eax
  801a4c:	8b 10                	mov    (%eax),%edx
  801a4e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a53:	8d 40 04             	lea    0x4(%eax),%eax
  801a56:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801a59:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a5e:	e9 97 00 00 00       	jmp    801afa <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801a63:	83 ec 08             	sub    $0x8,%esp
  801a66:	53                   	push   %ebx
  801a67:	6a 58                	push   $0x58
  801a69:	ff d6                	call   *%esi
			putch('X', putdat);
  801a6b:	83 c4 08             	add    $0x8,%esp
  801a6e:	53                   	push   %ebx
  801a6f:	6a 58                	push   $0x58
  801a71:	ff d6                	call   *%esi
			putch('X', putdat);
  801a73:	83 c4 08             	add    $0x8,%esp
  801a76:	53                   	push   %ebx
  801a77:	6a 58                	push   $0x58
  801a79:	ff d6                	call   *%esi
			break;
  801a7b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a7e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  801a81:	e9 8b fc ff ff       	jmp    801711 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  801a86:	83 ec 08             	sub    $0x8,%esp
  801a89:	53                   	push   %ebx
  801a8a:	6a 30                	push   $0x30
  801a8c:	ff d6                	call   *%esi
			putch('x', putdat);
  801a8e:	83 c4 08             	add    $0x8,%esp
  801a91:	53                   	push   %ebx
  801a92:	6a 78                	push   $0x78
  801a94:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a96:	8b 45 14             	mov    0x14(%ebp),%eax
  801a99:	8b 10                	mov    (%eax),%edx
  801a9b:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801aa0:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801aa3:	8d 40 04             	lea    0x4(%eax),%eax
  801aa6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801aa9:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801aae:	eb 4a                	jmp    801afa <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801ab0:	83 f9 01             	cmp    $0x1,%ecx
  801ab3:	7e 15                	jle    801aca <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  801ab5:	8b 45 14             	mov    0x14(%ebp),%eax
  801ab8:	8b 10                	mov    (%eax),%edx
  801aba:	8b 48 04             	mov    0x4(%eax),%ecx
  801abd:	8d 40 08             	lea    0x8(%eax),%eax
  801ac0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801ac3:	b8 10 00 00 00       	mov    $0x10,%eax
  801ac8:	eb 30                	jmp    801afa <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801aca:	85 c9                	test   %ecx,%ecx
  801acc:	74 17                	je     801ae5 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  801ace:	8b 45 14             	mov    0x14(%ebp),%eax
  801ad1:	8b 10                	mov    (%eax),%edx
  801ad3:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ad8:	8d 40 04             	lea    0x4(%eax),%eax
  801adb:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801ade:	b8 10 00 00 00       	mov    $0x10,%eax
  801ae3:	eb 15                	jmp    801afa <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801ae5:	8b 45 14             	mov    0x14(%ebp),%eax
  801ae8:	8b 10                	mov    (%eax),%edx
  801aea:	b9 00 00 00 00       	mov    $0x0,%ecx
  801aef:	8d 40 04             	lea    0x4(%eax),%eax
  801af2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801af5:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801afa:	83 ec 0c             	sub    $0xc,%esp
  801afd:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801b01:	57                   	push   %edi
  801b02:	ff 75 e0             	pushl  -0x20(%ebp)
  801b05:	50                   	push   %eax
  801b06:	51                   	push   %ecx
  801b07:	52                   	push   %edx
  801b08:	89 da                	mov    %ebx,%edx
  801b0a:	89 f0                	mov    %esi,%eax
  801b0c:	e8 f1 fa ff ff       	call   801602 <printnum>
			break;
  801b11:	83 c4 20             	add    $0x20,%esp
  801b14:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b17:	e9 f5 fb ff ff       	jmp    801711 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b1c:	83 ec 08             	sub    $0x8,%esp
  801b1f:	53                   	push   %ebx
  801b20:	52                   	push   %edx
  801b21:	ff d6                	call   *%esi
			break;
  801b23:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b26:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b29:	e9 e3 fb ff ff       	jmp    801711 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b2e:	83 ec 08             	sub    $0x8,%esp
  801b31:	53                   	push   %ebx
  801b32:	6a 25                	push   $0x25
  801b34:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b36:	83 c4 10             	add    $0x10,%esp
  801b39:	eb 03                	jmp    801b3e <vprintfmt+0x453>
  801b3b:	83 ef 01             	sub    $0x1,%edi
  801b3e:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b42:	75 f7                	jne    801b3b <vprintfmt+0x450>
  801b44:	e9 c8 fb ff ff       	jmp    801711 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4c:	5b                   	pop    %ebx
  801b4d:	5e                   	pop    %esi
  801b4e:	5f                   	pop    %edi
  801b4f:	5d                   	pop    %ebp
  801b50:	c3                   	ret    

00801b51 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	83 ec 18             	sub    $0x18,%esp
  801b57:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b60:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b64:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b67:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b6e:	85 c0                	test   %eax,%eax
  801b70:	74 26                	je     801b98 <vsnprintf+0x47>
  801b72:	85 d2                	test   %edx,%edx
  801b74:	7e 22                	jle    801b98 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b76:	ff 75 14             	pushl  0x14(%ebp)
  801b79:	ff 75 10             	pushl  0x10(%ebp)
  801b7c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b7f:	50                   	push   %eax
  801b80:	68 b1 16 80 00       	push   $0x8016b1
  801b85:	e8 61 fb ff ff       	call   8016eb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b8d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b93:	83 c4 10             	add    $0x10,%esp
  801b96:	eb 05                	jmp    801b9d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b98:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b9d:	c9                   	leave  
  801b9e:	c3                   	ret    

00801b9f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b9f:	55                   	push   %ebp
  801ba0:	89 e5                	mov    %esp,%ebp
  801ba2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801ba5:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801ba8:	50                   	push   %eax
  801ba9:	ff 75 10             	pushl  0x10(%ebp)
  801bac:	ff 75 0c             	pushl  0xc(%ebp)
  801baf:	ff 75 08             	pushl  0x8(%ebp)
  801bb2:	e8 9a ff ff ff       	call   801b51 <vsnprintf>
	va_end(ap);

	return rc;
}
  801bb7:	c9                   	leave  
  801bb8:	c3                   	ret    

00801bb9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801bb9:	55                   	push   %ebp
  801bba:	89 e5                	mov    %esp,%ebp
  801bbc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801bbf:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc4:	eb 03                	jmp    801bc9 <strlen+0x10>
		n++;
  801bc6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801bc9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801bcd:	75 f7                	jne    801bc6 <strlen+0xd>
		n++;
	return n;
}
  801bcf:	5d                   	pop    %ebp
  801bd0:	c3                   	ret    

00801bd1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801bd1:	55                   	push   %ebp
  801bd2:	89 e5                	mov    %esp,%ebp
  801bd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bd7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bda:	ba 00 00 00 00       	mov    $0x0,%edx
  801bdf:	eb 03                	jmp    801be4 <strnlen+0x13>
		n++;
  801be1:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801be4:	39 c2                	cmp    %eax,%edx
  801be6:	74 08                	je     801bf0 <strnlen+0x1f>
  801be8:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801bec:	75 f3                	jne    801be1 <strnlen+0x10>
  801bee:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801bf0:	5d                   	pop    %ebp
  801bf1:	c3                   	ret    

00801bf2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
  801bf5:	53                   	push   %ebx
  801bf6:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801bfc:	89 c2                	mov    %eax,%edx
  801bfe:	83 c2 01             	add    $0x1,%edx
  801c01:	83 c1 01             	add    $0x1,%ecx
  801c04:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801c08:	88 5a ff             	mov    %bl,-0x1(%edx)
  801c0b:	84 db                	test   %bl,%bl
  801c0d:	75 ef                	jne    801bfe <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801c0f:	5b                   	pop    %ebx
  801c10:	5d                   	pop    %ebp
  801c11:	c3                   	ret    

00801c12 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801c12:	55                   	push   %ebp
  801c13:	89 e5                	mov    %esp,%ebp
  801c15:	53                   	push   %ebx
  801c16:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c19:	53                   	push   %ebx
  801c1a:	e8 9a ff ff ff       	call   801bb9 <strlen>
  801c1f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c22:	ff 75 0c             	pushl  0xc(%ebp)
  801c25:	01 d8                	add    %ebx,%eax
  801c27:	50                   	push   %eax
  801c28:	e8 c5 ff ff ff       	call   801bf2 <strcpy>
	return dst;
}
  801c2d:	89 d8                	mov    %ebx,%eax
  801c2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c32:	c9                   	leave  
  801c33:	c3                   	ret    

00801c34 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	56                   	push   %esi
  801c38:	53                   	push   %ebx
  801c39:	8b 75 08             	mov    0x8(%ebp),%esi
  801c3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c3f:	89 f3                	mov    %esi,%ebx
  801c41:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c44:	89 f2                	mov    %esi,%edx
  801c46:	eb 0f                	jmp    801c57 <strncpy+0x23>
		*dst++ = *src;
  801c48:	83 c2 01             	add    $0x1,%edx
  801c4b:	0f b6 01             	movzbl (%ecx),%eax
  801c4e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c51:	80 39 01             	cmpb   $0x1,(%ecx)
  801c54:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c57:	39 da                	cmp    %ebx,%edx
  801c59:	75 ed                	jne    801c48 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c5b:	89 f0                	mov    %esi,%eax
  801c5d:	5b                   	pop    %ebx
  801c5e:	5e                   	pop    %esi
  801c5f:	5d                   	pop    %ebp
  801c60:	c3                   	ret    

00801c61 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c61:	55                   	push   %ebp
  801c62:	89 e5                	mov    %esp,%ebp
  801c64:	56                   	push   %esi
  801c65:	53                   	push   %ebx
  801c66:	8b 75 08             	mov    0x8(%ebp),%esi
  801c69:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c6c:	8b 55 10             	mov    0x10(%ebp),%edx
  801c6f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c71:	85 d2                	test   %edx,%edx
  801c73:	74 21                	je     801c96 <strlcpy+0x35>
  801c75:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c79:	89 f2                	mov    %esi,%edx
  801c7b:	eb 09                	jmp    801c86 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c7d:	83 c2 01             	add    $0x1,%edx
  801c80:	83 c1 01             	add    $0x1,%ecx
  801c83:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c86:	39 c2                	cmp    %eax,%edx
  801c88:	74 09                	je     801c93 <strlcpy+0x32>
  801c8a:	0f b6 19             	movzbl (%ecx),%ebx
  801c8d:	84 db                	test   %bl,%bl
  801c8f:	75 ec                	jne    801c7d <strlcpy+0x1c>
  801c91:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c93:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c96:	29 f0                	sub    %esi,%eax
}
  801c98:	5b                   	pop    %ebx
  801c99:	5e                   	pop    %esi
  801c9a:	5d                   	pop    %ebp
  801c9b:	c3                   	ret    

00801c9c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c9c:	55                   	push   %ebp
  801c9d:	89 e5                	mov    %esp,%ebp
  801c9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801ca5:	eb 06                	jmp    801cad <strcmp+0x11>
		p++, q++;
  801ca7:	83 c1 01             	add    $0x1,%ecx
  801caa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801cad:	0f b6 01             	movzbl (%ecx),%eax
  801cb0:	84 c0                	test   %al,%al
  801cb2:	74 04                	je     801cb8 <strcmp+0x1c>
  801cb4:	3a 02                	cmp    (%edx),%al
  801cb6:	74 ef                	je     801ca7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801cb8:	0f b6 c0             	movzbl %al,%eax
  801cbb:	0f b6 12             	movzbl (%edx),%edx
  801cbe:	29 d0                	sub    %edx,%eax
}
  801cc0:	5d                   	pop    %ebp
  801cc1:	c3                   	ret    

00801cc2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801cc2:	55                   	push   %ebp
  801cc3:	89 e5                	mov    %esp,%ebp
  801cc5:	53                   	push   %ebx
  801cc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ccc:	89 c3                	mov    %eax,%ebx
  801cce:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801cd1:	eb 06                	jmp    801cd9 <strncmp+0x17>
		n--, p++, q++;
  801cd3:	83 c0 01             	add    $0x1,%eax
  801cd6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801cd9:	39 d8                	cmp    %ebx,%eax
  801cdb:	74 15                	je     801cf2 <strncmp+0x30>
  801cdd:	0f b6 08             	movzbl (%eax),%ecx
  801ce0:	84 c9                	test   %cl,%cl
  801ce2:	74 04                	je     801ce8 <strncmp+0x26>
  801ce4:	3a 0a                	cmp    (%edx),%cl
  801ce6:	74 eb                	je     801cd3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801ce8:	0f b6 00             	movzbl (%eax),%eax
  801ceb:	0f b6 12             	movzbl (%edx),%edx
  801cee:	29 d0                	sub    %edx,%eax
  801cf0:	eb 05                	jmp    801cf7 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801cf2:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801cf7:	5b                   	pop    %ebx
  801cf8:	5d                   	pop    %ebp
  801cf9:	c3                   	ret    

00801cfa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801cfa:	55                   	push   %ebp
  801cfb:	89 e5                	mov    %esp,%ebp
  801cfd:	8b 45 08             	mov    0x8(%ebp),%eax
  801d00:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d04:	eb 07                	jmp    801d0d <strchr+0x13>
		if (*s == c)
  801d06:	38 ca                	cmp    %cl,%dl
  801d08:	74 0f                	je     801d19 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801d0a:	83 c0 01             	add    $0x1,%eax
  801d0d:	0f b6 10             	movzbl (%eax),%edx
  801d10:	84 d2                	test   %dl,%dl
  801d12:	75 f2                	jne    801d06 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801d14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d19:	5d                   	pop    %ebp
  801d1a:	c3                   	ret    

00801d1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d25:	eb 03                	jmp    801d2a <strfind+0xf>
  801d27:	83 c0 01             	add    $0x1,%eax
  801d2a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d2d:	38 ca                	cmp    %cl,%dl
  801d2f:	74 04                	je     801d35 <strfind+0x1a>
  801d31:	84 d2                	test   %dl,%dl
  801d33:	75 f2                	jne    801d27 <strfind+0xc>
			break;
	return (char *) s;
}
  801d35:	5d                   	pop    %ebp
  801d36:	c3                   	ret    

00801d37 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d37:	55                   	push   %ebp
  801d38:	89 e5                	mov    %esp,%ebp
  801d3a:	57                   	push   %edi
  801d3b:	56                   	push   %esi
  801d3c:	53                   	push   %ebx
  801d3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d40:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d43:	85 c9                	test   %ecx,%ecx
  801d45:	74 36                	je     801d7d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d47:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d4d:	75 28                	jne    801d77 <memset+0x40>
  801d4f:	f6 c1 03             	test   $0x3,%cl
  801d52:	75 23                	jne    801d77 <memset+0x40>
		c &= 0xFF;
  801d54:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d58:	89 d3                	mov    %edx,%ebx
  801d5a:	c1 e3 08             	shl    $0x8,%ebx
  801d5d:	89 d6                	mov    %edx,%esi
  801d5f:	c1 e6 18             	shl    $0x18,%esi
  801d62:	89 d0                	mov    %edx,%eax
  801d64:	c1 e0 10             	shl    $0x10,%eax
  801d67:	09 f0                	or     %esi,%eax
  801d69:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d6b:	89 d8                	mov    %ebx,%eax
  801d6d:	09 d0                	or     %edx,%eax
  801d6f:	c1 e9 02             	shr    $0x2,%ecx
  801d72:	fc                   	cld    
  801d73:	f3 ab                	rep stos %eax,%es:(%edi)
  801d75:	eb 06                	jmp    801d7d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d77:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d7a:	fc                   	cld    
  801d7b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d7d:	89 f8                	mov    %edi,%eax
  801d7f:	5b                   	pop    %ebx
  801d80:	5e                   	pop    %esi
  801d81:	5f                   	pop    %edi
  801d82:	5d                   	pop    %ebp
  801d83:	c3                   	ret    

00801d84 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d84:	55                   	push   %ebp
  801d85:	89 e5                	mov    %esp,%ebp
  801d87:	57                   	push   %edi
  801d88:	56                   	push   %esi
  801d89:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d92:	39 c6                	cmp    %eax,%esi
  801d94:	73 35                	jae    801dcb <memmove+0x47>
  801d96:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d99:	39 d0                	cmp    %edx,%eax
  801d9b:	73 2e                	jae    801dcb <memmove+0x47>
		s += n;
		d += n;
  801d9d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801da0:	89 d6                	mov    %edx,%esi
  801da2:	09 fe                	or     %edi,%esi
  801da4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801daa:	75 13                	jne    801dbf <memmove+0x3b>
  801dac:	f6 c1 03             	test   $0x3,%cl
  801daf:	75 0e                	jne    801dbf <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801db1:	83 ef 04             	sub    $0x4,%edi
  801db4:	8d 72 fc             	lea    -0x4(%edx),%esi
  801db7:	c1 e9 02             	shr    $0x2,%ecx
  801dba:	fd                   	std    
  801dbb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801dbd:	eb 09                	jmp    801dc8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801dbf:	83 ef 01             	sub    $0x1,%edi
  801dc2:	8d 72 ff             	lea    -0x1(%edx),%esi
  801dc5:	fd                   	std    
  801dc6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801dc8:	fc                   	cld    
  801dc9:	eb 1d                	jmp    801de8 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801dcb:	89 f2                	mov    %esi,%edx
  801dcd:	09 c2                	or     %eax,%edx
  801dcf:	f6 c2 03             	test   $0x3,%dl
  801dd2:	75 0f                	jne    801de3 <memmove+0x5f>
  801dd4:	f6 c1 03             	test   $0x3,%cl
  801dd7:	75 0a                	jne    801de3 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801dd9:	c1 e9 02             	shr    $0x2,%ecx
  801ddc:	89 c7                	mov    %eax,%edi
  801dde:	fc                   	cld    
  801ddf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801de1:	eb 05                	jmp    801de8 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801de3:	89 c7                	mov    %eax,%edi
  801de5:	fc                   	cld    
  801de6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801de8:	5e                   	pop    %esi
  801de9:	5f                   	pop    %edi
  801dea:	5d                   	pop    %ebp
  801deb:	c3                   	ret    

00801dec <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801dec:	55                   	push   %ebp
  801ded:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801def:	ff 75 10             	pushl  0x10(%ebp)
  801df2:	ff 75 0c             	pushl  0xc(%ebp)
  801df5:	ff 75 08             	pushl  0x8(%ebp)
  801df8:	e8 87 ff ff ff       	call   801d84 <memmove>
}
  801dfd:	c9                   	leave  
  801dfe:	c3                   	ret    

00801dff <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801dff:	55                   	push   %ebp
  801e00:	89 e5                	mov    %esp,%ebp
  801e02:	56                   	push   %esi
  801e03:	53                   	push   %ebx
  801e04:	8b 45 08             	mov    0x8(%ebp),%eax
  801e07:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e0a:	89 c6                	mov    %eax,%esi
  801e0c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e0f:	eb 1a                	jmp    801e2b <memcmp+0x2c>
		if (*s1 != *s2)
  801e11:	0f b6 08             	movzbl (%eax),%ecx
  801e14:	0f b6 1a             	movzbl (%edx),%ebx
  801e17:	38 d9                	cmp    %bl,%cl
  801e19:	74 0a                	je     801e25 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801e1b:	0f b6 c1             	movzbl %cl,%eax
  801e1e:	0f b6 db             	movzbl %bl,%ebx
  801e21:	29 d8                	sub    %ebx,%eax
  801e23:	eb 0f                	jmp    801e34 <memcmp+0x35>
		s1++, s2++;
  801e25:	83 c0 01             	add    $0x1,%eax
  801e28:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e2b:	39 f0                	cmp    %esi,%eax
  801e2d:	75 e2                	jne    801e11 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e34:	5b                   	pop    %ebx
  801e35:	5e                   	pop    %esi
  801e36:	5d                   	pop    %ebp
  801e37:	c3                   	ret    

00801e38 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e38:	55                   	push   %ebp
  801e39:	89 e5                	mov    %esp,%ebp
  801e3b:	53                   	push   %ebx
  801e3c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e3f:	89 c1                	mov    %eax,%ecx
  801e41:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e44:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e48:	eb 0a                	jmp    801e54 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e4a:	0f b6 10             	movzbl (%eax),%edx
  801e4d:	39 da                	cmp    %ebx,%edx
  801e4f:	74 07                	je     801e58 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e51:	83 c0 01             	add    $0x1,%eax
  801e54:	39 c8                	cmp    %ecx,%eax
  801e56:	72 f2                	jb     801e4a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e58:	5b                   	pop    %ebx
  801e59:	5d                   	pop    %ebp
  801e5a:	c3                   	ret    

00801e5b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e5b:	55                   	push   %ebp
  801e5c:	89 e5                	mov    %esp,%ebp
  801e5e:	57                   	push   %edi
  801e5f:	56                   	push   %esi
  801e60:	53                   	push   %ebx
  801e61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e64:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e67:	eb 03                	jmp    801e6c <strtol+0x11>
		s++;
  801e69:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e6c:	0f b6 01             	movzbl (%ecx),%eax
  801e6f:	3c 20                	cmp    $0x20,%al
  801e71:	74 f6                	je     801e69 <strtol+0xe>
  801e73:	3c 09                	cmp    $0x9,%al
  801e75:	74 f2                	je     801e69 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e77:	3c 2b                	cmp    $0x2b,%al
  801e79:	75 0a                	jne    801e85 <strtol+0x2a>
		s++;
  801e7b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e7e:	bf 00 00 00 00       	mov    $0x0,%edi
  801e83:	eb 11                	jmp    801e96 <strtol+0x3b>
  801e85:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e8a:	3c 2d                	cmp    $0x2d,%al
  801e8c:	75 08                	jne    801e96 <strtol+0x3b>
		s++, neg = 1;
  801e8e:	83 c1 01             	add    $0x1,%ecx
  801e91:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e96:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e9c:	75 15                	jne    801eb3 <strtol+0x58>
  801e9e:	80 39 30             	cmpb   $0x30,(%ecx)
  801ea1:	75 10                	jne    801eb3 <strtol+0x58>
  801ea3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801ea7:	75 7c                	jne    801f25 <strtol+0xca>
		s += 2, base = 16;
  801ea9:	83 c1 02             	add    $0x2,%ecx
  801eac:	bb 10 00 00 00       	mov    $0x10,%ebx
  801eb1:	eb 16                	jmp    801ec9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801eb3:	85 db                	test   %ebx,%ebx
  801eb5:	75 12                	jne    801ec9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801eb7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ebc:	80 39 30             	cmpb   $0x30,(%ecx)
  801ebf:	75 08                	jne    801ec9 <strtol+0x6e>
		s++, base = 8;
  801ec1:	83 c1 01             	add    $0x1,%ecx
  801ec4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801ec9:	b8 00 00 00 00       	mov    $0x0,%eax
  801ece:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801ed1:	0f b6 11             	movzbl (%ecx),%edx
  801ed4:	8d 72 d0             	lea    -0x30(%edx),%esi
  801ed7:	89 f3                	mov    %esi,%ebx
  801ed9:	80 fb 09             	cmp    $0x9,%bl
  801edc:	77 08                	ja     801ee6 <strtol+0x8b>
			dig = *s - '0';
  801ede:	0f be d2             	movsbl %dl,%edx
  801ee1:	83 ea 30             	sub    $0x30,%edx
  801ee4:	eb 22                	jmp    801f08 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801ee6:	8d 72 9f             	lea    -0x61(%edx),%esi
  801ee9:	89 f3                	mov    %esi,%ebx
  801eeb:	80 fb 19             	cmp    $0x19,%bl
  801eee:	77 08                	ja     801ef8 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801ef0:	0f be d2             	movsbl %dl,%edx
  801ef3:	83 ea 57             	sub    $0x57,%edx
  801ef6:	eb 10                	jmp    801f08 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801ef8:	8d 72 bf             	lea    -0x41(%edx),%esi
  801efb:	89 f3                	mov    %esi,%ebx
  801efd:	80 fb 19             	cmp    $0x19,%bl
  801f00:	77 16                	ja     801f18 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801f02:	0f be d2             	movsbl %dl,%edx
  801f05:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801f08:	3b 55 10             	cmp    0x10(%ebp),%edx
  801f0b:	7d 0b                	jge    801f18 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801f0d:	83 c1 01             	add    $0x1,%ecx
  801f10:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f14:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801f16:	eb b9                	jmp    801ed1 <strtol+0x76>

	if (endptr)
  801f18:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f1c:	74 0d                	je     801f2b <strtol+0xd0>
		*endptr = (char *) s;
  801f1e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f21:	89 0e                	mov    %ecx,(%esi)
  801f23:	eb 06                	jmp    801f2b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f25:	85 db                	test   %ebx,%ebx
  801f27:	74 98                	je     801ec1 <strtol+0x66>
  801f29:	eb 9e                	jmp    801ec9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f2b:	89 c2                	mov    %eax,%edx
  801f2d:	f7 da                	neg    %edx
  801f2f:	85 ff                	test   %edi,%edi
  801f31:	0f 45 c2             	cmovne %edx,%eax
}
  801f34:	5b                   	pop    %ebx
  801f35:	5e                   	pop    %esi
  801f36:	5f                   	pop    %edi
  801f37:	5d                   	pop    %ebp
  801f38:	c3                   	ret    

00801f39 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f39:	55                   	push   %ebp
  801f3a:	89 e5                	mov    %esp,%ebp
  801f3c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801f3f:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  801f46:	75 4a                	jne    801f92 <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  801f48:	a1 08 40 80 00       	mov    0x804008,%eax
  801f4d:	8b 40 48             	mov    0x48(%eax),%eax
  801f50:	83 ec 04             	sub    $0x4,%esp
  801f53:	6a 07                	push   $0x7
  801f55:	68 00 f0 bf ee       	push   $0xeebff000
  801f5a:	50                   	push   %eax
  801f5b:	e8 10 e2 ff ff       	call   800170 <sys_page_alloc>
  801f60:	83 c4 10             	add    $0x10,%esp
  801f63:	85 c0                	test   %eax,%eax
  801f65:	79 12                	jns    801f79 <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  801f67:	50                   	push   %eax
  801f68:	68 e0 27 80 00       	push   $0x8027e0
  801f6d:	6a 21                	push   $0x21
  801f6f:	68 f8 27 80 00       	push   $0x8027f8
  801f74:	e8 9c f5 ff ff       	call   801515 <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801f79:	a1 08 40 80 00       	mov    0x804008,%eax
  801f7e:	8b 40 48             	mov    0x48(%eax),%eax
  801f81:	83 ec 08             	sub    $0x8,%esp
  801f84:	68 a0 03 80 00       	push   $0x8003a0
  801f89:	50                   	push   %eax
  801f8a:	e8 2c e3 ff ff       	call   8002bb <sys_env_set_pgfault_upcall>
  801f8f:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f92:	8b 45 08             	mov    0x8(%ebp),%eax
  801f95:	a3 00 70 80 00       	mov    %eax,0x807000
  801f9a:	c9                   	leave  
  801f9b:	c3                   	ret    

00801f9c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f9c:	55                   	push   %ebp
  801f9d:	89 e5                	mov    %esp,%ebp
  801f9f:	56                   	push   %esi
  801fa0:	53                   	push   %ebx
  801fa1:	8b 75 08             	mov    0x8(%ebp),%esi
  801fa4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fa7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801faa:	85 c0                	test   %eax,%eax
  801fac:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fb1:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801fb4:	83 ec 0c             	sub    $0xc,%esp
  801fb7:	50                   	push   %eax
  801fb8:	e8 63 e3 ff ff       	call   800320 <sys_ipc_recv>
  801fbd:	83 c4 10             	add    $0x10,%esp
  801fc0:	85 c0                	test   %eax,%eax
  801fc2:	79 16                	jns    801fda <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801fc4:	85 f6                	test   %esi,%esi
  801fc6:	74 06                	je     801fce <ipc_recv+0x32>
            *from_env_store = 0;
  801fc8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801fce:	85 db                	test   %ebx,%ebx
  801fd0:	74 2c                	je     801ffe <ipc_recv+0x62>
            *perm_store = 0;
  801fd2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801fd8:	eb 24                	jmp    801ffe <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801fda:	85 f6                	test   %esi,%esi
  801fdc:	74 0a                	je     801fe8 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801fde:	a1 08 40 80 00       	mov    0x804008,%eax
  801fe3:	8b 40 74             	mov    0x74(%eax),%eax
  801fe6:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801fe8:	85 db                	test   %ebx,%ebx
  801fea:	74 0a                	je     801ff6 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801fec:	a1 08 40 80 00       	mov    0x804008,%eax
  801ff1:	8b 40 78             	mov    0x78(%eax),%eax
  801ff4:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801ff6:	a1 08 40 80 00       	mov    0x804008,%eax
  801ffb:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801ffe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802001:	5b                   	pop    %ebx
  802002:	5e                   	pop    %esi
  802003:	5d                   	pop    %ebp
  802004:	c3                   	ret    

00802005 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802005:	55                   	push   %ebp
  802006:	89 e5                	mov    %esp,%ebp
  802008:	57                   	push   %edi
  802009:	56                   	push   %esi
  80200a:	53                   	push   %ebx
  80200b:	83 ec 0c             	sub    $0xc,%esp
  80200e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802011:	8b 75 0c             	mov    0xc(%ebp),%esi
  802014:	8b 45 10             	mov    0x10(%ebp),%eax
  802017:	85 c0                	test   %eax,%eax
  802019:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80201e:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  802021:	eb 1c                	jmp    80203f <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  802023:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802026:	74 12                	je     80203a <ipc_send+0x35>
  802028:	50                   	push   %eax
  802029:	68 06 28 80 00       	push   $0x802806
  80202e:	6a 3b                	push   $0x3b
  802030:	68 1c 28 80 00       	push   $0x80281c
  802035:	e8 db f4 ff ff       	call   801515 <_panic>
		sys_yield();
  80203a:	e8 12 e1 ff ff       	call   800151 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  80203f:	ff 75 14             	pushl  0x14(%ebp)
  802042:	53                   	push   %ebx
  802043:	56                   	push   %esi
  802044:	57                   	push   %edi
  802045:	e8 b3 e2 ff ff       	call   8002fd <sys_ipc_try_send>
  80204a:	83 c4 10             	add    $0x10,%esp
  80204d:	85 c0                	test   %eax,%eax
  80204f:	78 d2                	js     802023 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  802051:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802054:	5b                   	pop    %ebx
  802055:	5e                   	pop    %esi
  802056:	5f                   	pop    %edi
  802057:	5d                   	pop    %ebp
  802058:	c3                   	ret    

00802059 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802059:	55                   	push   %ebp
  80205a:	89 e5                	mov    %esp,%ebp
  80205c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80205f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802064:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802067:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80206d:	8b 52 50             	mov    0x50(%edx),%edx
  802070:	39 ca                	cmp    %ecx,%edx
  802072:	75 0d                	jne    802081 <ipc_find_env+0x28>
			return envs[i].env_id;
  802074:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802077:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80207c:	8b 40 48             	mov    0x48(%eax),%eax
  80207f:	eb 0f                	jmp    802090 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802081:	83 c0 01             	add    $0x1,%eax
  802084:	3d 00 04 00 00       	cmp    $0x400,%eax
  802089:	75 d9                	jne    802064 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80208b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    

00802092 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802092:	55                   	push   %ebp
  802093:	89 e5                	mov    %esp,%ebp
  802095:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802098:	89 d0                	mov    %edx,%eax
  80209a:	c1 e8 16             	shr    $0x16,%eax
  80209d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020a4:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020a9:	f6 c1 01             	test   $0x1,%cl
  8020ac:	74 1d                	je     8020cb <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020ae:	c1 ea 0c             	shr    $0xc,%edx
  8020b1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020b8:	f6 c2 01             	test   $0x1,%dl
  8020bb:	74 0e                	je     8020cb <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020bd:	c1 ea 0c             	shr    $0xc,%edx
  8020c0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020c7:	ef 
  8020c8:	0f b7 c0             	movzwl %ax,%eax
}
  8020cb:	5d                   	pop    %ebp
  8020cc:	c3                   	ret    
  8020cd:	66 90                	xchg   %ax,%ax
  8020cf:	90                   	nop

008020d0 <__udivdi3>:
  8020d0:	55                   	push   %ebp
  8020d1:	57                   	push   %edi
  8020d2:	56                   	push   %esi
  8020d3:	53                   	push   %ebx
  8020d4:	83 ec 1c             	sub    $0x1c,%esp
  8020d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020e7:	85 f6                	test   %esi,%esi
  8020e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020ed:	89 ca                	mov    %ecx,%edx
  8020ef:	89 f8                	mov    %edi,%eax
  8020f1:	75 3d                	jne    802130 <__udivdi3+0x60>
  8020f3:	39 cf                	cmp    %ecx,%edi
  8020f5:	0f 87 c5 00 00 00    	ja     8021c0 <__udivdi3+0xf0>
  8020fb:	85 ff                	test   %edi,%edi
  8020fd:	89 fd                	mov    %edi,%ebp
  8020ff:	75 0b                	jne    80210c <__udivdi3+0x3c>
  802101:	b8 01 00 00 00       	mov    $0x1,%eax
  802106:	31 d2                	xor    %edx,%edx
  802108:	f7 f7                	div    %edi
  80210a:	89 c5                	mov    %eax,%ebp
  80210c:	89 c8                	mov    %ecx,%eax
  80210e:	31 d2                	xor    %edx,%edx
  802110:	f7 f5                	div    %ebp
  802112:	89 c1                	mov    %eax,%ecx
  802114:	89 d8                	mov    %ebx,%eax
  802116:	89 cf                	mov    %ecx,%edi
  802118:	f7 f5                	div    %ebp
  80211a:	89 c3                	mov    %eax,%ebx
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
  802130:	39 ce                	cmp    %ecx,%esi
  802132:	77 74                	ja     8021a8 <__udivdi3+0xd8>
  802134:	0f bd fe             	bsr    %esi,%edi
  802137:	83 f7 1f             	xor    $0x1f,%edi
  80213a:	0f 84 98 00 00 00    	je     8021d8 <__udivdi3+0x108>
  802140:	bb 20 00 00 00       	mov    $0x20,%ebx
  802145:	89 f9                	mov    %edi,%ecx
  802147:	89 c5                	mov    %eax,%ebp
  802149:	29 fb                	sub    %edi,%ebx
  80214b:	d3 e6                	shl    %cl,%esi
  80214d:	89 d9                	mov    %ebx,%ecx
  80214f:	d3 ed                	shr    %cl,%ebp
  802151:	89 f9                	mov    %edi,%ecx
  802153:	d3 e0                	shl    %cl,%eax
  802155:	09 ee                	or     %ebp,%esi
  802157:	89 d9                	mov    %ebx,%ecx
  802159:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80215d:	89 d5                	mov    %edx,%ebp
  80215f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802163:	d3 ed                	shr    %cl,%ebp
  802165:	89 f9                	mov    %edi,%ecx
  802167:	d3 e2                	shl    %cl,%edx
  802169:	89 d9                	mov    %ebx,%ecx
  80216b:	d3 e8                	shr    %cl,%eax
  80216d:	09 c2                	or     %eax,%edx
  80216f:	89 d0                	mov    %edx,%eax
  802171:	89 ea                	mov    %ebp,%edx
  802173:	f7 f6                	div    %esi
  802175:	89 d5                	mov    %edx,%ebp
  802177:	89 c3                	mov    %eax,%ebx
  802179:	f7 64 24 0c          	mull   0xc(%esp)
  80217d:	39 d5                	cmp    %edx,%ebp
  80217f:	72 10                	jb     802191 <__udivdi3+0xc1>
  802181:	8b 74 24 08          	mov    0x8(%esp),%esi
  802185:	89 f9                	mov    %edi,%ecx
  802187:	d3 e6                	shl    %cl,%esi
  802189:	39 c6                	cmp    %eax,%esi
  80218b:	73 07                	jae    802194 <__udivdi3+0xc4>
  80218d:	39 d5                	cmp    %edx,%ebp
  80218f:	75 03                	jne    802194 <__udivdi3+0xc4>
  802191:	83 eb 01             	sub    $0x1,%ebx
  802194:	31 ff                	xor    %edi,%edi
  802196:	89 d8                	mov    %ebx,%eax
  802198:	89 fa                	mov    %edi,%edx
  80219a:	83 c4 1c             	add    $0x1c,%esp
  80219d:	5b                   	pop    %ebx
  80219e:	5e                   	pop    %esi
  80219f:	5f                   	pop    %edi
  8021a0:	5d                   	pop    %ebp
  8021a1:	c3                   	ret    
  8021a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021a8:	31 ff                	xor    %edi,%edi
  8021aa:	31 db                	xor    %ebx,%ebx
  8021ac:	89 d8                	mov    %ebx,%eax
  8021ae:	89 fa                	mov    %edi,%edx
  8021b0:	83 c4 1c             	add    $0x1c,%esp
  8021b3:	5b                   	pop    %ebx
  8021b4:	5e                   	pop    %esi
  8021b5:	5f                   	pop    %edi
  8021b6:	5d                   	pop    %ebp
  8021b7:	c3                   	ret    
  8021b8:	90                   	nop
  8021b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c0:	89 d8                	mov    %ebx,%eax
  8021c2:	f7 f7                	div    %edi
  8021c4:	31 ff                	xor    %edi,%edi
  8021c6:	89 c3                	mov    %eax,%ebx
  8021c8:	89 d8                	mov    %ebx,%eax
  8021ca:	89 fa                	mov    %edi,%edx
  8021cc:	83 c4 1c             	add    $0x1c,%esp
  8021cf:	5b                   	pop    %ebx
  8021d0:	5e                   	pop    %esi
  8021d1:	5f                   	pop    %edi
  8021d2:	5d                   	pop    %ebp
  8021d3:	c3                   	ret    
  8021d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d8:	39 ce                	cmp    %ecx,%esi
  8021da:	72 0c                	jb     8021e8 <__udivdi3+0x118>
  8021dc:	31 db                	xor    %ebx,%ebx
  8021de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021e2:	0f 87 34 ff ff ff    	ja     80211c <__udivdi3+0x4c>
  8021e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021ed:	e9 2a ff ff ff       	jmp    80211c <__udivdi3+0x4c>
  8021f2:	66 90                	xchg   %ax,%ax
  8021f4:	66 90                	xchg   %ax,%ax
  8021f6:	66 90                	xchg   %ax,%ax
  8021f8:	66 90                	xchg   %ax,%ax
  8021fa:	66 90                	xchg   %ax,%ax
  8021fc:	66 90                	xchg   %ax,%ax
  8021fe:	66 90                	xchg   %ax,%ax

00802200 <__umoddi3>:
  802200:	55                   	push   %ebp
  802201:	57                   	push   %edi
  802202:	56                   	push   %esi
  802203:	53                   	push   %ebx
  802204:	83 ec 1c             	sub    $0x1c,%esp
  802207:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80220b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80220f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802213:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802217:	85 d2                	test   %edx,%edx
  802219:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80221d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802221:	89 f3                	mov    %esi,%ebx
  802223:	89 3c 24             	mov    %edi,(%esp)
  802226:	89 74 24 04          	mov    %esi,0x4(%esp)
  80222a:	75 1c                	jne    802248 <__umoddi3+0x48>
  80222c:	39 f7                	cmp    %esi,%edi
  80222e:	76 50                	jbe    802280 <__umoddi3+0x80>
  802230:	89 c8                	mov    %ecx,%eax
  802232:	89 f2                	mov    %esi,%edx
  802234:	f7 f7                	div    %edi
  802236:	89 d0                	mov    %edx,%eax
  802238:	31 d2                	xor    %edx,%edx
  80223a:	83 c4 1c             	add    $0x1c,%esp
  80223d:	5b                   	pop    %ebx
  80223e:	5e                   	pop    %esi
  80223f:	5f                   	pop    %edi
  802240:	5d                   	pop    %ebp
  802241:	c3                   	ret    
  802242:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802248:	39 f2                	cmp    %esi,%edx
  80224a:	89 d0                	mov    %edx,%eax
  80224c:	77 52                	ja     8022a0 <__umoddi3+0xa0>
  80224e:	0f bd ea             	bsr    %edx,%ebp
  802251:	83 f5 1f             	xor    $0x1f,%ebp
  802254:	75 5a                	jne    8022b0 <__umoddi3+0xb0>
  802256:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80225a:	0f 82 e0 00 00 00    	jb     802340 <__umoddi3+0x140>
  802260:	39 0c 24             	cmp    %ecx,(%esp)
  802263:	0f 86 d7 00 00 00    	jbe    802340 <__umoddi3+0x140>
  802269:	8b 44 24 08          	mov    0x8(%esp),%eax
  80226d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802271:	83 c4 1c             	add    $0x1c,%esp
  802274:	5b                   	pop    %ebx
  802275:	5e                   	pop    %esi
  802276:	5f                   	pop    %edi
  802277:	5d                   	pop    %ebp
  802278:	c3                   	ret    
  802279:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802280:	85 ff                	test   %edi,%edi
  802282:	89 fd                	mov    %edi,%ebp
  802284:	75 0b                	jne    802291 <__umoddi3+0x91>
  802286:	b8 01 00 00 00       	mov    $0x1,%eax
  80228b:	31 d2                	xor    %edx,%edx
  80228d:	f7 f7                	div    %edi
  80228f:	89 c5                	mov    %eax,%ebp
  802291:	89 f0                	mov    %esi,%eax
  802293:	31 d2                	xor    %edx,%edx
  802295:	f7 f5                	div    %ebp
  802297:	89 c8                	mov    %ecx,%eax
  802299:	f7 f5                	div    %ebp
  80229b:	89 d0                	mov    %edx,%eax
  80229d:	eb 99                	jmp    802238 <__umoddi3+0x38>
  80229f:	90                   	nop
  8022a0:	89 c8                	mov    %ecx,%eax
  8022a2:	89 f2                	mov    %esi,%edx
  8022a4:	83 c4 1c             	add    $0x1c,%esp
  8022a7:	5b                   	pop    %ebx
  8022a8:	5e                   	pop    %esi
  8022a9:	5f                   	pop    %edi
  8022aa:	5d                   	pop    %ebp
  8022ab:	c3                   	ret    
  8022ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	8b 34 24             	mov    (%esp),%esi
  8022b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022b8:	89 e9                	mov    %ebp,%ecx
  8022ba:	29 ef                	sub    %ebp,%edi
  8022bc:	d3 e0                	shl    %cl,%eax
  8022be:	89 f9                	mov    %edi,%ecx
  8022c0:	89 f2                	mov    %esi,%edx
  8022c2:	d3 ea                	shr    %cl,%edx
  8022c4:	89 e9                	mov    %ebp,%ecx
  8022c6:	09 c2                	or     %eax,%edx
  8022c8:	89 d8                	mov    %ebx,%eax
  8022ca:	89 14 24             	mov    %edx,(%esp)
  8022cd:	89 f2                	mov    %esi,%edx
  8022cf:	d3 e2                	shl    %cl,%edx
  8022d1:	89 f9                	mov    %edi,%ecx
  8022d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022db:	d3 e8                	shr    %cl,%eax
  8022dd:	89 e9                	mov    %ebp,%ecx
  8022df:	89 c6                	mov    %eax,%esi
  8022e1:	d3 e3                	shl    %cl,%ebx
  8022e3:	89 f9                	mov    %edi,%ecx
  8022e5:	89 d0                	mov    %edx,%eax
  8022e7:	d3 e8                	shr    %cl,%eax
  8022e9:	89 e9                	mov    %ebp,%ecx
  8022eb:	09 d8                	or     %ebx,%eax
  8022ed:	89 d3                	mov    %edx,%ebx
  8022ef:	89 f2                	mov    %esi,%edx
  8022f1:	f7 34 24             	divl   (%esp)
  8022f4:	89 d6                	mov    %edx,%esi
  8022f6:	d3 e3                	shl    %cl,%ebx
  8022f8:	f7 64 24 04          	mull   0x4(%esp)
  8022fc:	39 d6                	cmp    %edx,%esi
  8022fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802302:	89 d1                	mov    %edx,%ecx
  802304:	89 c3                	mov    %eax,%ebx
  802306:	72 08                	jb     802310 <__umoddi3+0x110>
  802308:	75 11                	jne    80231b <__umoddi3+0x11b>
  80230a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80230e:	73 0b                	jae    80231b <__umoddi3+0x11b>
  802310:	2b 44 24 04          	sub    0x4(%esp),%eax
  802314:	1b 14 24             	sbb    (%esp),%edx
  802317:	89 d1                	mov    %edx,%ecx
  802319:	89 c3                	mov    %eax,%ebx
  80231b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80231f:	29 da                	sub    %ebx,%edx
  802321:	19 ce                	sbb    %ecx,%esi
  802323:	89 f9                	mov    %edi,%ecx
  802325:	89 f0                	mov    %esi,%eax
  802327:	d3 e0                	shl    %cl,%eax
  802329:	89 e9                	mov    %ebp,%ecx
  80232b:	d3 ea                	shr    %cl,%edx
  80232d:	89 e9                	mov    %ebp,%ecx
  80232f:	d3 ee                	shr    %cl,%esi
  802331:	09 d0                	or     %edx,%eax
  802333:	89 f2                	mov    %esi,%edx
  802335:	83 c4 1c             	add    $0x1c,%esp
  802338:	5b                   	pop    %ebx
  802339:	5e                   	pop    %esi
  80233a:	5f                   	pop    %edi
  80233b:	5d                   	pop    %ebp
  80233c:	c3                   	ret    
  80233d:	8d 76 00             	lea    0x0(%esi),%esi
  802340:	29 f9                	sub    %edi,%ecx
  802342:	19 d6                	sbb    %edx,%esi
  802344:	89 74 24 04          	mov    %esi,0x4(%esp)
  802348:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80234c:	e9 18 ff ff ff       	jmp    802269 <__umoddi3+0x69>
