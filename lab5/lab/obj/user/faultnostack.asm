
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
  800039:	68 61 03 80 00       	push   $0x800361
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
  800071:	a3 04 40 80 00       	mov    %eax,0x804004

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
  8000a0:	e8 ab 04 00 00       	call   800550 <close_all>
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
  800119:	68 ca 1e 80 00       	push   $0x801eca
  80011e:	6a 23                	push   $0x23
  800120:	68 e7 1e 80 00       	push   $0x801ee7
  800125:	e8 45 0f 00 00       	call   80106f <_panic>

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
  80019a:	68 ca 1e 80 00       	push   $0x801eca
  80019f:	6a 23                	push   $0x23
  8001a1:	68 e7 1e 80 00       	push   $0x801ee7
  8001a6:	e8 c4 0e 00 00       	call   80106f <_panic>

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
  8001dc:	68 ca 1e 80 00       	push   $0x801eca
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 e7 1e 80 00       	push   $0x801ee7
  8001e8:	e8 82 0e 00 00       	call   80106f <_panic>

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
  80021e:	68 ca 1e 80 00       	push   $0x801eca
  800223:	6a 23                	push   $0x23
  800225:	68 e7 1e 80 00       	push   $0x801ee7
  80022a:	e8 40 0e 00 00       	call   80106f <_panic>

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
  800260:	68 ca 1e 80 00       	push   $0x801eca
  800265:	6a 23                	push   $0x23
  800267:	68 e7 1e 80 00       	push   $0x801ee7
  80026c:	e8 fe 0d 00 00       	call   80106f <_panic>

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
  8002a2:	68 ca 1e 80 00       	push   $0x801eca
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 e7 1e 80 00       	push   $0x801ee7
  8002ae:	e8 bc 0d 00 00       	call   80106f <_panic>

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
  8002e4:	68 ca 1e 80 00       	push   $0x801eca
  8002e9:	6a 23                	push   $0x23
  8002eb:	68 e7 1e 80 00       	push   $0x801ee7
  8002f0:	e8 7a 0d 00 00       	call   80106f <_panic>

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
  800348:	68 ca 1e 80 00       	push   $0x801eca
  80034d:	6a 23                	push   $0x23
  80034f:	68 e7 1e 80 00       	push   $0x801ee7
  800354:	e8 16 0d 00 00       	call   80106f <_panic>

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

00800361 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800361:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800362:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  800367:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800369:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  80036c:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  80036f:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  800373:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  800378:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  80037c:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  80037e:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  80037f:	83 c4 04             	add    $0x4,%esp
	popfl
  800382:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800383:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  800384:	c3                   	ret    

00800385 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800388:	8b 45 08             	mov    0x8(%ebp),%eax
  80038b:	05 00 00 00 30       	add    $0x30000000,%eax
  800390:	c1 e8 0c             	shr    $0xc,%eax
}
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    

00800395 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800398:	8b 45 08             	mov    0x8(%ebp),%eax
  80039b:	05 00 00 00 30       	add    $0x30000000,%eax
  8003a0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003a5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003aa:	5d                   	pop    %ebp
  8003ab:	c3                   	ret    

008003ac <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003ac:	55                   	push   %ebp
  8003ad:	89 e5                	mov    %esp,%ebp
  8003af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003b7:	89 c2                	mov    %eax,%edx
  8003b9:	c1 ea 16             	shr    $0x16,%edx
  8003bc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003c3:	f6 c2 01             	test   $0x1,%dl
  8003c6:	74 11                	je     8003d9 <fd_alloc+0x2d>
  8003c8:	89 c2                	mov    %eax,%edx
  8003ca:	c1 ea 0c             	shr    $0xc,%edx
  8003cd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003d4:	f6 c2 01             	test   $0x1,%dl
  8003d7:	75 09                	jne    8003e2 <fd_alloc+0x36>
			*fd_store = fd;
  8003d9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003db:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e0:	eb 17                	jmp    8003f9 <fd_alloc+0x4d>
  8003e2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003e7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ec:	75 c9                	jne    8003b7 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003ee:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003f4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003f9:	5d                   	pop    %ebp
  8003fa:	c3                   	ret    

008003fb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003fb:	55                   	push   %ebp
  8003fc:	89 e5                	mov    %esp,%ebp
  8003fe:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800401:	83 f8 1f             	cmp    $0x1f,%eax
  800404:	77 36                	ja     80043c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800406:	c1 e0 0c             	shl    $0xc,%eax
  800409:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80040e:	89 c2                	mov    %eax,%edx
  800410:	c1 ea 16             	shr    $0x16,%edx
  800413:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80041a:	f6 c2 01             	test   $0x1,%dl
  80041d:	74 24                	je     800443 <fd_lookup+0x48>
  80041f:	89 c2                	mov    %eax,%edx
  800421:	c1 ea 0c             	shr    $0xc,%edx
  800424:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80042b:	f6 c2 01             	test   $0x1,%dl
  80042e:	74 1a                	je     80044a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800430:	8b 55 0c             	mov    0xc(%ebp),%edx
  800433:	89 02                	mov    %eax,(%edx)
	return 0;
  800435:	b8 00 00 00 00       	mov    $0x0,%eax
  80043a:	eb 13                	jmp    80044f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80043c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800441:	eb 0c                	jmp    80044f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800443:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800448:	eb 05                	jmp    80044f <fd_lookup+0x54>
  80044a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80044f:	5d                   	pop    %ebp
  800450:	c3                   	ret    

00800451 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800451:	55                   	push   %ebp
  800452:	89 e5                	mov    %esp,%ebp
  800454:	83 ec 08             	sub    $0x8,%esp
  800457:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80045a:	ba 74 1f 80 00       	mov    $0x801f74,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80045f:	eb 13                	jmp    800474 <dev_lookup+0x23>
  800461:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800464:	39 08                	cmp    %ecx,(%eax)
  800466:	75 0c                	jne    800474 <dev_lookup+0x23>
			*dev = devtab[i];
  800468:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80046b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80046d:	b8 00 00 00 00       	mov    $0x0,%eax
  800472:	eb 2e                	jmp    8004a2 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800474:	8b 02                	mov    (%edx),%eax
  800476:	85 c0                	test   %eax,%eax
  800478:	75 e7                	jne    800461 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80047a:	a1 04 40 80 00       	mov    0x804004,%eax
  80047f:	8b 40 48             	mov    0x48(%eax),%eax
  800482:	83 ec 04             	sub    $0x4,%esp
  800485:	51                   	push   %ecx
  800486:	50                   	push   %eax
  800487:	68 f8 1e 80 00       	push   $0x801ef8
  80048c:	e8 b7 0c 00 00       	call   801148 <cprintf>
	*dev = 0;
  800491:	8b 45 0c             	mov    0xc(%ebp),%eax
  800494:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80049a:	83 c4 10             	add    $0x10,%esp
  80049d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004a2:	c9                   	leave  
  8004a3:	c3                   	ret    

008004a4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004a4:	55                   	push   %ebp
  8004a5:	89 e5                	mov    %esp,%ebp
  8004a7:	56                   	push   %esi
  8004a8:	53                   	push   %ebx
  8004a9:	83 ec 10             	sub    $0x10,%esp
  8004ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8004af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004b5:	50                   	push   %eax
  8004b6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004bc:	c1 e8 0c             	shr    $0xc,%eax
  8004bf:	50                   	push   %eax
  8004c0:	e8 36 ff ff ff       	call   8003fb <fd_lookup>
  8004c5:	83 c4 08             	add    $0x8,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	78 05                	js     8004d1 <fd_close+0x2d>
	    || fd != fd2)
  8004cc:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004cf:	74 0c                	je     8004dd <fd_close+0x39>
		return (must_exist ? r : 0);
  8004d1:	84 db                	test   %bl,%bl
  8004d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d8:	0f 44 c2             	cmove  %edx,%eax
  8004db:	eb 41                	jmp    80051e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004e3:	50                   	push   %eax
  8004e4:	ff 36                	pushl  (%esi)
  8004e6:	e8 66 ff ff ff       	call   800451 <dev_lookup>
  8004eb:	89 c3                	mov    %eax,%ebx
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	85 c0                	test   %eax,%eax
  8004f2:	78 1a                	js     80050e <fd_close+0x6a>
		if (dev->dev_close)
  8004f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004f7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004fa:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ff:	85 c0                	test   %eax,%eax
  800501:	74 0b                	je     80050e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800503:	83 ec 0c             	sub    $0xc,%esp
  800506:	56                   	push   %esi
  800507:	ff d0                	call   *%eax
  800509:	89 c3                	mov    %eax,%ebx
  80050b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	56                   	push   %esi
  800512:	6a 00                	push   $0x0
  800514:	e8 dc fc ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800519:	83 c4 10             	add    $0x10,%esp
  80051c:	89 d8                	mov    %ebx,%eax
}
  80051e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800521:	5b                   	pop    %ebx
  800522:	5e                   	pop    %esi
  800523:	5d                   	pop    %ebp
  800524:	c3                   	ret    

00800525 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800525:	55                   	push   %ebp
  800526:	89 e5                	mov    %esp,%ebp
  800528:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80052b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80052e:	50                   	push   %eax
  80052f:	ff 75 08             	pushl  0x8(%ebp)
  800532:	e8 c4 fe ff ff       	call   8003fb <fd_lookup>
  800537:	83 c4 08             	add    $0x8,%esp
  80053a:	85 c0                	test   %eax,%eax
  80053c:	78 10                	js     80054e <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	6a 01                	push   $0x1
  800543:	ff 75 f4             	pushl  -0xc(%ebp)
  800546:	e8 59 ff ff ff       	call   8004a4 <fd_close>
  80054b:	83 c4 10             	add    $0x10,%esp
}
  80054e:	c9                   	leave  
  80054f:	c3                   	ret    

00800550 <close_all>:

void
close_all(void)
{
  800550:	55                   	push   %ebp
  800551:	89 e5                	mov    %esp,%ebp
  800553:	53                   	push   %ebx
  800554:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800557:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80055c:	83 ec 0c             	sub    $0xc,%esp
  80055f:	53                   	push   %ebx
  800560:	e8 c0 ff ff ff       	call   800525 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800565:	83 c3 01             	add    $0x1,%ebx
  800568:	83 c4 10             	add    $0x10,%esp
  80056b:	83 fb 20             	cmp    $0x20,%ebx
  80056e:	75 ec                	jne    80055c <close_all+0xc>
		close(i);
}
  800570:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800573:	c9                   	leave  
  800574:	c3                   	ret    

00800575 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800575:	55                   	push   %ebp
  800576:	89 e5                	mov    %esp,%ebp
  800578:	57                   	push   %edi
  800579:	56                   	push   %esi
  80057a:	53                   	push   %ebx
  80057b:	83 ec 2c             	sub    $0x2c,%esp
  80057e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800581:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800584:	50                   	push   %eax
  800585:	ff 75 08             	pushl  0x8(%ebp)
  800588:	e8 6e fe ff ff       	call   8003fb <fd_lookup>
  80058d:	83 c4 08             	add    $0x8,%esp
  800590:	85 c0                	test   %eax,%eax
  800592:	0f 88 c1 00 00 00    	js     800659 <dup+0xe4>
		return r;
	close(newfdnum);
  800598:	83 ec 0c             	sub    $0xc,%esp
  80059b:	56                   	push   %esi
  80059c:	e8 84 ff ff ff       	call   800525 <close>

	newfd = INDEX2FD(newfdnum);
  8005a1:	89 f3                	mov    %esi,%ebx
  8005a3:	c1 e3 0c             	shl    $0xc,%ebx
  8005a6:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005ac:	83 c4 04             	add    $0x4,%esp
  8005af:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005b2:	e8 de fd ff ff       	call   800395 <fd2data>
  8005b7:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005b9:	89 1c 24             	mov    %ebx,(%esp)
  8005bc:	e8 d4 fd ff ff       	call   800395 <fd2data>
  8005c1:	83 c4 10             	add    $0x10,%esp
  8005c4:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005c7:	89 f8                	mov    %edi,%eax
  8005c9:	c1 e8 16             	shr    $0x16,%eax
  8005cc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005d3:	a8 01                	test   $0x1,%al
  8005d5:	74 37                	je     80060e <dup+0x99>
  8005d7:	89 f8                	mov    %edi,%eax
  8005d9:	c1 e8 0c             	shr    $0xc,%eax
  8005dc:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005e3:	f6 c2 01             	test   $0x1,%dl
  8005e6:	74 26                	je     80060e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ef:	83 ec 0c             	sub    $0xc,%esp
  8005f2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f7:	50                   	push   %eax
  8005f8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005fb:	6a 00                	push   $0x0
  8005fd:	57                   	push   %edi
  8005fe:	6a 00                	push   $0x0
  800600:	e8 ae fb ff ff       	call   8001b3 <sys_page_map>
  800605:	89 c7                	mov    %eax,%edi
  800607:	83 c4 20             	add    $0x20,%esp
  80060a:	85 c0                	test   %eax,%eax
  80060c:	78 2e                	js     80063c <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800611:	89 d0                	mov    %edx,%eax
  800613:	c1 e8 0c             	shr    $0xc,%eax
  800616:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80061d:	83 ec 0c             	sub    $0xc,%esp
  800620:	25 07 0e 00 00       	and    $0xe07,%eax
  800625:	50                   	push   %eax
  800626:	53                   	push   %ebx
  800627:	6a 00                	push   $0x0
  800629:	52                   	push   %edx
  80062a:	6a 00                	push   $0x0
  80062c:	e8 82 fb ff ff       	call   8001b3 <sys_page_map>
  800631:	89 c7                	mov    %eax,%edi
  800633:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800636:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800638:	85 ff                	test   %edi,%edi
  80063a:	79 1d                	jns    800659 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	53                   	push   %ebx
  800640:	6a 00                	push   $0x0
  800642:	e8 ae fb ff ff       	call   8001f5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800647:	83 c4 08             	add    $0x8,%esp
  80064a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80064d:	6a 00                	push   $0x0
  80064f:	e8 a1 fb ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	89 f8                	mov    %edi,%eax
}
  800659:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80065c:	5b                   	pop    %ebx
  80065d:	5e                   	pop    %esi
  80065e:	5f                   	pop    %edi
  80065f:	5d                   	pop    %ebp
  800660:	c3                   	ret    

00800661 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800661:	55                   	push   %ebp
  800662:	89 e5                	mov    %esp,%ebp
  800664:	53                   	push   %ebx
  800665:	83 ec 14             	sub    $0x14,%esp
  800668:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80066b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80066e:	50                   	push   %eax
  80066f:	53                   	push   %ebx
  800670:	e8 86 fd ff ff       	call   8003fb <fd_lookup>
  800675:	83 c4 08             	add    $0x8,%esp
  800678:	89 c2                	mov    %eax,%edx
  80067a:	85 c0                	test   %eax,%eax
  80067c:	78 6d                	js     8006eb <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80067e:	83 ec 08             	sub    $0x8,%esp
  800681:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800684:	50                   	push   %eax
  800685:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800688:	ff 30                	pushl  (%eax)
  80068a:	e8 c2 fd ff ff       	call   800451 <dev_lookup>
  80068f:	83 c4 10             	add    $0x10,%esp
  800692:	85 c0                	test   %eax,%eax
  800694:	78 4c                	js     8006e2 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800696:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800699:	8b 42 08             	mov    0x8(%edx),%eax
  80069c:	83 e0 03             	and    $0x3,%eax
  80069f:	83 f8 01             	cmp    $0x1,%eax
  8006a2:	75 21                	jne    8006c5 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006a4:	a1 04 40 80 00       	mov    0x804004,%eax
  8006a9:	8b 40 48             	mov    0x48(%eax),%eax
  8006ac:	83 ec 04             	sub    $0x4,%esp
  8006af:	53                   	push   %ebx
  8006b0:	50                   	push   %eax
  8006b1:	68 39 1f 80 00       	push   $0x801f39
  8006b6:	e8 8d 0a 00 00       	call   801148 <cprintf>
		return -E_INVAL;
  8006bb:	83 c4 10             	add    $0x10,%esp
  8006be:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006c3:	eb 26                	jmp    8006eb <read+0x8a>
	}
	if (!dev->dev_read)
  8006c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c8:	8b 40 08             	mov    0x8(%eax),%eax
  8006cb:	85 c0                	test   %eax,%eax
  8006cd:	74 17                	je     8006e6 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006cf:	83 ec 04             	sub    $0x4,%esp
  8006d2:	ff 75 10             	pushl  0x10(%ebp)
  8006d5:	ff 75 0c             	pushl  0xc(%ebp)
  8006d8:	52                   	push   %edx
  8006d9:	ff d0                	call   *%eax
  8006db:	89 c2                	mov    %eax,%edx
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	eb 09                	jmp    8006eb <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006e2:	89 c2                	mov    %eax,%edx
  8006e4:	eb 05                	jmp    8006eb <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006e6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006eb:	89 d0                	mov    %edx,%eax
  8006ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f0:	c9                   	leave  
  8006f1:	c3                   	ret    

008006f2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	57                   	push   %edi
  8006f6:	56                   	push   %esi
  8006f7:	53                   	push   %ebx
  8006f8:	83 ec 0c             	sub    $0xc,%esp
  8006fb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006fe:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800701:	bb 00 00 00 00       	mov    $0x0,%ebx
  800706:	eb 21                	jmp    800729 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800708:	83 ec 04             	sub    $0x4,%esp
  80070b:	89 f0                	mov    %esi,%eax
  80070d:	29 d8                	sub    %ebx,%eax
  80070f:	50                   	push   %eax
  800710:	89 d8                	mov    %ebx,%eax
  800712:	03 45 0c             	add    0xc(%ebp),%eax
  800715:	50                   	push   %eax
  800716:	57                   	push   %edi
  800717:	e8 45 ff ff ff       	call   800661 <read>
		if (m < 0)
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	85 c0                	test   %eax,%eax
  800721:	78 10                	js     800733 <readn+0x41>
			return m;
		if (m == 0)
  800723:	85 c0                	test   %eax,%eax
  800725:	74 0a                	je     800731 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800727:	01 c3                	add    %eax,%ebx
  800729:	39 f3                	cmp    %esi,%ebx
  80072b:	72 db                	jb     800708 <readn+0x16>
  80072d:	89 d8                	mov    %ebx,%eax
  80072f:	eb 02                	jmp    800733 <readn+0x41>
  800731:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800733:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800736:	5b                   	pop    %ebx
  800737:	5e                   	pop    %esi
  800738:	5f                   	pop    %edi
  800739:	5d                   	pop    %ebp
  80073a:	c3                   	ret    

0080073b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	53                   	push   %ebx
  80073f:	83 ec 14             	sub    $0x14,%esp
  800742:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800745:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800748:	50                   	push   %eax
  800749:	53                   	push   %ebx
  80074a:	e8 ac fc ff ff       	call   8003fb <fd_lookup>
  80074f:	83 c4 08             	add    $0x8,%esp
  800752:	89 c2                	mov    %eax,%edx
  800754:	85 c0                	test   %eax,%eax
  800756:	78 68                	js     8007c0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800758:	83 ec 08             	sub    $0x8,%esp
  80075b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80075e:	50                   	push   %eax
  80075f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800762:	ff 30                	pushl  (%eax)
  800764:	e8 e8 fc ff ff       	call   800451 <dev_lookup>
  800769:	83 c4 10             	add    $0x10,%esp
  80076c:	85 c0                	test   %eax,%eax
  80076e:	78 47                	js     8007b7 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800770:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800773:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800777:	75 21                	jne    80079a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800779:	a1 04 40 80 00       	mov    0x804004,%eax
  80077e:	8b 40 48             	mov    0x48(%eax),%eax
  800781:	83 ec 04             	sub    $0x4,%esp
  800784:	53                   	push   %ebx
  800785:	50                   	push   %eax
  800786:	68 55 1f 80 00       	push   $0x801f55
  80078b:	e8 b8 09 00 00       	call   801148 <cprintf>
		return -E_INVAL;
  800790:	83 c4 10             	add    $0x10,%esp
  800793:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800798:	eb 26                	jmp    8007c0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80079a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80079d:	8b 52 0c             	mov    0xc(%edx),%edx
  8007a0:	85 d2                	test   %edx,%edx
  8007a2:	74 17                	je     8007bb <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007a4:	83 ec 04             	sub    $0x4,%esp
  8007a7:	ff 75 10             	pushl  0x10(%ebp)
  8007aa:	ff 75 0c             	pushl  0xc(%ebp)
  8007ad:	50                   	push   %eax
  8007ae:	ff d2                	call   *%edx
  8007b0:	89 c2                	mov    %eax,%edx
  8007b2:	83 c4 10             	add    $0x10,%esp
  8007b5:	eb 09                	jmp    8007c0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007b7:	89 c2                	mov    %eax,%edx
  8007b9:	eb 05                	jmp    8007c0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007bb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007c0:	89 d0                	mov    %edx,%eax
  8007c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c5:	c9                   	leave  
  8007c6:	c3                   	ret    

008007c7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007c7:	55                   	push   %ebp
  8007c8:	89 e5                	mov    %esp,%ebp
  8007ca:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007cd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007d0:	50                   	push   %eax
  8007d1:	ff 75 08             	pushl  0x8(%ebp)
  8007d4:	e8 22 fc ff ff       	call   8003fb <fd_lookup>
  8007d9:	83 c4 08             	add    $0x8,%esp
  8007dc:	85 c0                	test   %eax,%eax
  8007de:	78 0e                	js     8007ee <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    

008007f0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	53                   	push   %ebx
  8007f4:	83 ec 14             	sub    $0x14,%esp
  8007f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007fd:	50                   	push   %eax
  8007fe:	53                   	push   %ebx
  8007ff:	e8 f7 fb ff ff       	call   8003fb <fd_lookup>
  800804:	83 c4 08             	add    $0x8,%esp
  800807:	89 c2                	mov    %eax,%edx
  800809:	85 c0                	test   %eax,%eax
  80080b:	78 65                	js     800872 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80080d:	83 ec 08             	sub    $0x8,%esp
  800810:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800813:	50                   	push   %eax
  800814:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800817:	ff 30                	pushl  (%eax)
  800819:	e8 33 fc ff ff       	call   800451 <dev_lookup>
  80081e:	83 c4 10             	add    $0x10,%esp
  800821:	85 c0                	test   %eax,%eax
  800823:	78 44                	js     800869 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800825:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800828:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80082c:	75 21                	jne    80084f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80082e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800833:	8b 40 48             	mov    0x48(%eax),%eax
  800836:	83 ec 04             	sub    $0x4,%esp
  800839:	53                   	push   %ebx
  80083a:	50                   	push   %eax
  80083b:	68 18 1f 80 00       	push   $0x801f18
  800840:	e8 03 09 00 00       	call   801148 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800845:	83 c4 10             	add    $0x10,%esp
  800848:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80084d:	eb 23                	jmp    800872 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80084f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800852:	8b 52 18             	mov    0x18(%edx),%edx
  800855:	85 d2                	test   %edx,%edx
  800857:	74 14                	je     80086d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800859:	83 ec 08             	sub    $0x8,%esp
  80085c:	ff 75 0c             	pushl  0xc(%ebp)
  80085f:	50                   	push   %eax
  800860:	ff d2                	call   *%edx
  800862:	89 c2                	mov    %eax,%edx
  800864:	83 c4 10             	add    $0x10,%esp
  800867:	eb 09                	jmp    800872 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800869:	89 c2                	mov    %eax,%edx
  80086b:	eb 05                	jmp    800872 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80086d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800872:	89 d0                	mov    %edx,%eax
  800874:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800877:	c9                   	leave  
  800878:	c3                   	ret    

00800879 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	53                   	push   %ebx
  80087d:	83 ec 14             	sub    $0x14,%esp
  800880:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800883:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800886:	50                   	push   %eax
  800887:	ff 75 08             	pushl  0x8(%ebp)
  80088a:	e8 6c fb ff ff       	call   8003fb <fd_lookup>
  80088f:	83 c4 08             	add    $0x8,%esp
  800892:	89 c2                	mov    %eax,%edx
  800894:	85 c0                	test   %eax,%eax
  800896:	78 58                	js     8008f0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800898:	83 ec 08             	sub    $0x8,%esp
  80089b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80089e:	50                   	push   %eax
  80089f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a2:	ff 30                	pushl  (%eax)
  8008a4:	e8 a8 fb ff ff       	call   800451 <dev_lookup>
  8008a9:	83 c4 10             	add    $0x10,%esp
  8008ac:	85 c0                	test   %eax,%eax
  8008ae:	78 37                	js     8008e7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008b7:	74 32                	je     8008eb <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008b9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008bc:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008c3:	00 00 00 
	stat->st_isdir = 0;
  8008c6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008cd:	00 00 00 
	stat->st_dev = dev;
  8008d0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008d6:	83 ec 08             	sub    $0x8,%esp
  8008d9:	53                   	push   %ebx
  8008da:	ff 75 f0             	pushl  -0x10(%ebp)
  8008dd:	ff 50 14             	call   *0x14(%eax)
  8008e0:	89 c2                	mov    %eax,%edx
  8008e2:	83 c4 10             	add    $0x10,%esp
  8008e5:	eb 09                	jmp    8008f0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008e7:	89 c2                	mov    %eax,%edx
  8008e9:	eb 05                	jmp    8008f0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008eb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008f0:	89 d0                	mov    %edx,%eax
  8008f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f5:	c9                   	leave  
  8008f6:	c3                   	ret    

008008f7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	56                   	push   %esi
  8008fb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008fc:	83 ec 08             	sub    $0x8,%esp
  8008ff:	6a 00                	push   $0x0
  800901:	ff 75 08             	pushl  0x8(%ebp)
  800904:	e8 e3 01 00 00       	call   800aec <open>
  800909:	89 c3                	mov    %eax,%ebx
  80090b:	83 c4 10             	add    $0x10,%esp
  80090e:	85 c0                	test   %eax,%eax
  800910:	78 1b                	js     80092d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800912:	83 ec 08             	sub    $0x8,%esp
  800915:	ff 75 0c             	pushl  0xc(%ebp)
  800918:	50                   	push   %eax
  800919:	e8 5b ff ff ff       	call   800879 <fstat>
  80091e:	89 c6                	mov    %eax,%esi
	close(fd);
  800920:	89 1c 24             	mov    %ebx,(%esp)
  800923:	e8 fd fb ff ff       	call   800525 <close>
	return r;
  800928:	83 c4 10             	add    $0x10,%esp
  80092b:	89 f0                	mov    %esi,%eax
}
  80092d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800930:	5b                   	pop    %ebx
  800931:	5e                   	pop    %esi
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	56                   	push   %esi
  800938:	53                   	push   %ebx
  800939:	89 c6                	mov    %eax,%esi
  80093b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80093d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800944:	75 12                	jne    800958 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800946:	83 ec 0c             	sub    $0xc,%esp
  800949:	6a 01                	push   $0x1
  80094b:	e8 63 12 00 00       	call   801bb3 <ipc_find_env>
  800950:	a3 00 40 80 00       	mov    %eax,0x804000
  800955:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800958:	6a 07                	push   $0x7
  80095a:	68 00 50 80 00       	push   $0x805000
  80095f:	56                   	push   %esi
  800960:	ff 35 00 40 80 00    	pushl  0x804000
  800966:	e8 f4 11 00 00       	call   801b5f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80096b:	83 c4 0c             	add    $0xc,%esp
  80096e:	6a 00                	push   $0x0
  800970:	53                   	push   %ebx
  800971:	6a 00                	push   $0x0
  800973:	e8 7e 11 00 00       	call   801af6 <ipc_recv>
}
  800978:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80097b:	5b                   	pop    %ebx
  80097c:	5e                   	pop    %esi
  80097d:	5d                   	pop    %ebp
  80097e:	c3                   	ret    

0080097f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 40 0c             	mov    0xc(%eax),%eax
  80098b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800990:	8b 45 0c             	mov    0xc(%ebp),%eax
  800993:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800998:	ba 00 00 00 00       	mov    $0x0,%edx
  80099d:	b8 02 00 00 00       	mov    $0x2,%eax
  8009a2:	e8 8d ff ff ff       	call   800934 <fsipc>
}
  8009a7:	c9                   	leave  
  8009a8:	c3                   	ret    

008009a9 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bf:	b8 06 00 00 00       	mov    $0x6,%eax
  8009c4:	e8 6b ff ff ff       	call   800934 <fsipc>
}
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    

008009cb <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	53                   	push   %ebx
  8009cf:	83 ec 04             	sub    $0x4,%esp
  8009d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8009db:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e5:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ea:	e8 45 ff ff ff       	call   800934 <fsipc>
  8009ef:	85 c0                	test   %eax,%eax
  8009f1:	78 2c                	js     800a1f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009f3:	83 ec 08             	sub    $0x8,%esp
  8009f6:	68 00 50 80 00       	push   $0x805000
  8009fb:	53                   	push   %ebx
  8009fc:	e8 4b 0d 00 00       	call   80174c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a01:	a1 80 50 80 00       	mov    0x805080,%eax
  800a06:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a0c:	a1 84 50 80 00       	mov    0x805084,%eax
  800a11:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a17:	83 c4 10             	add    $0x10,%esp
  800a1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a22:	c9                   	leave  
  800a23:	c3                   	ret    

00800a24 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	83 ec 0c             	sub    $0xc,%esp
  800a2a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a2d:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a32:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a37:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3d:	8b 52 0c             	mov    0xc(%edx),%edx
  800a40:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a46:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a4b:	50                   	push   %eax
  800a4c:	ff 75 0c             	pushl  0xc(%ebp)
  800a4f:	68 08 50 80 00       	push   $0x805008
  800a54:	e8 85 0e 00 00       	call   8018de <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a59:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5e:	b8 04 00 00 00       	mov    $0x4,%eax
  800a63:	e8 cc fe ff ff       	call   800934 <fsipc>
	//panic("devfile_write not implemented");
}
  800a68:	c9                   	leave  
  800a69:	c3                   	ret    

00800a6a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	56                   	push   %esi
  800a6e:	53                   	push   %ebx
  800a6f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a72:	8b 45 08             	mov    0x8(%ebp),%eax
  800a75:	8b 40 0c             	mov    0xc(%eax),%eax
  800a78:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a7d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a83:	ba 00 00 00 00       	mov    $0x0,%edx
  800a88:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8d:	e8 a2 fe ff ff       	call   800934 <fsipc>
  800a92:	89 c3                	mov    %eax,%ebx
  800a94:	85 c0                	test   %eax,%eax
  800a96:	78 4b                	js     800ae3 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a98:	39 c6                	cmp    %eax,%esi
  800a9a:	73 16                	jae    800ab2 <devfile_read+0x48>
  800a9c:	68 84 1f 80 00       	push   $0x801f84
  800aa1:	68 8b 1f 80 00       	push   $0x801f8b
  800aa6:	6a 7c                	push   $0x7c
  800aa8:	68 a0 1f 80 00       	push   $0x801fa0
  800aad:	e8 bd 05 00 00       	call   80106f <_panic>
	assert(r <= PGSIZE);
  800ab2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ab7:	7e 16                	jle    800acf <devfile_read+0x65>
  800ab9:	68 ab 1f 80 00       	push   $0x801fab
  800abe:	68 8b 1f 80 00       	push   $0x801f8b
  800ac3:	6a 7d                	push   $0x7d
  800ac5:	68 a0 1f 80 00       	push   $0x801fa0
  800aca:	e8 a0 05 00 00       	call   80106f <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800acf:	83 ec 04             	sub    $0x4,%esp
  800ad2:	50                   	push   %eax
  800ad3:	68 00 50 80 00       	push   $0x805000
  800ad8:	ff 75 0c             	pushl  0xc(%ebp)
  800adb:	e8 fe 0d 00 00       	call   8018de <memmove>
	return r;
  800ae0:	83 c4 10             	add    $0x10,%esp
}
  800ae3:	89 d8                	mov    %ebx,%eax
  800ae5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ae8:	5b                   	pop    %ebx
  800ae9:	5e                   	pop    %esi
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800aec:	55                   	push   %ebp
  800aed:	89 e5                	mov    %esp,%ebp
  800aef:	53                   	push   %ebx
  800af0:	83 ec 20             	sub    $0x20,%esp
  800af3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800af6:	53                   	push   %ebx
  800af7:	e8 17 0c 00 00       	call   801713 <strlen>
  800afc:	83 c4 10             	add    $0x10,%esp
  800aff:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b04:	7f 67                	jg     800b6d <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b06:	83 ec 0c             	sub    $0xc,%esp
  800b09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b0c:	50                   	push   %eax
  800b0d:	e8 9a f8 ff ff       	call   8003ac <fd_alloc>
  800b12:	83 c4 10             	add    $0x10,%esp
		return r;
  800b15:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b17:	85 c0                	test   %eax,%eax
  800b19:	78 57                	js     800b72 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b1b:	83 ec 08             	sub    $0x8,%esp
  800b1e:	53                   	push   %ebx
  800b1f:	68 00 50 80 00       	push   $0x805000
  800b24:	e8 23 0c 00 00       	call   80174c <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2c:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b31:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b34:	b8 01 00 00 00       	mov    $0x1,%eax
  800b39:	e8 f6 fd ff ff       	call   800934 <fsipc>
  800b3e:	89 c3                	mov    %eax,%ebx
  800b40:	83 c4 10             	add    $0x10,%esp
  800b43:	85 c0                	test   %eax,%eax
  800b45:	79 14                	jns    800b5b <open+0x6f>
		fd_close(fd, 0);
  800b47:	83 ec 08             	sub    $0x8,%esp
  800b4a:	6a 00                	push   $0x0
  800b4c:	ff 75 f4             	pushl  -0xc(%ebp)
  800b4f:	e8 50 f9 ff ff       	call   8004a4 <fd_close>
		return r;
  800b54:	83 c4 10             	add    $0x10,%esp
  800b57:	89 da                	mov    %ebx,%edx
  800b59:	eb 17                	jmp    800b72 <open+0x86>
	}

	return fd2num(fd);
  800b5b:	83 ec 0c             	sub    $0xc,%esp
  800b5e:	ff 75 f4             	pushl  -0xc(%ebp)
  800b61:	e8 1f f8 ff ff       	call   800385 <fd2num>
  800b66:	89 c2                	mov    %eax,%edx
  800b68:	83 c4 10             	add    $0x10,%esp
  800b6b:	eb 05                	jmp    800b72 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b6d:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b72:	89 d0                	mov    %edx,%eax
  800b74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b77:	c9                   	leave  
  800b78:	c3                   	ret    

00800b79 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b79:	55                   	push   %ebp
  800b7a:	89 e5                	mov    %esp,%ebp
  800b7c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b84:	b8 08 00 00 00       	mov    $0x8,%eax
  800b89:	e8 a6 fd ff ff       	call   800934 <fsipc>
}
  800b8e:	c9                   	leave  
  800b8f:	c3                   	ret    

00800b90 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
  800b95:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b98:	83 ec 0c             	sub    $0xc,%esp
  800b9b:	ff 75 08             	pushl  0x8(%ebp)
  800b9e:	e8 f2 f7 ff ff       	call   800395 <fd2data>
  800ba3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800ba5:	83 c4 08             	add    $0x8,%esp
  800ba8:	68 b7 1f 80 00       	push   $0x801fb7
  800bad:	53                   	push   %ebx
  800bae:	e8 99 0b 00 00       	call   80174c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bb3:	8b 46 04             	mov    0x4(%esi),%eax
  800bb6:	2b 06                	sub    (%esi),%eax
  800bb8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bbe:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bc5:	00 00 00 
	stat->st_dev = &devpipe;
  800bc8:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bcf:	30 80 00 
	return 0;
}
  800bd2:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	53                   	push   %ebx
  800be2:	83 ec 0c             	sub    $0xc,%esp
  800be5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800be8:	53                   	push   %ebx
  800be9:	6a 00                	push   $0x0
  800beb:	e8 05 f6 ff ff       	call   8001f5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bf0:	89 1c 24             	mov    %ebx,(%esp)
  800bf3:	e8 9d f7 ff ff       	call   800395 <fd2data>
  800bf8:	83 c4 08             	add    $0x8,%esp
  800bfb:	50                   	push   %eax
  800bfc:	6a 00                	push   $0x0
  800bfe:	e8 f2 f5 ff ff       	call   8001f5 <sys_page_unmap>
}
  800c03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c06:	c9                   	leave  
  800c07:	c3                   	ret    

00800c08 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	57                   	push   %edi
  800c0c:	56                   	push   %esi
  800c0d:	53                   	push   %ebx
  800c0e:	83 ec 1c             	sub    $0x1c,%esp
  800c11:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c14:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c16:	a1 04 40 80 00       	mov    0x804004,%eax
  800c1b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c1e:	83 ec 0c             	sub    $0xc,%esp
  800c21:	ff 75 e0             	pushl  -0x20(%ebp)
  800c24:	e8 c3 0f 00 00       	call   801bec <pageref>
  800c29:	89 c3                	mov    %eax,%ebx
  800c2b:	89 3c 24             	mov    %edi,(%esp)
  800c2e:	e8 b9 0f 00 00       	call   801bec <pageref>
  800c33:	83 c4 10             	add    $0x10,%esp
  800c36:	39 c3                	cmp    %eax,%ebx
  800c38:	0f 94 c1             	sete   %cl
  800c3b:	0f b6 c9             	movzbl %cl,%ecx
  800c3e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c41:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c47:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c4a:	39 ce                	cmp    %ecx,%esi
  800c4c:	74 1b                	je     800c69 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c4e:	39 c3                	cmp    %eax,%ebx
  800c50:	75 c4                	jne    800c16 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c52:	8b 42 58             	mov    0x58(%edx),%eax
  800c55:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c58:	50                   	push   %eax
  800c59:	56                   	push   %esi
  800c5a:	68 be 1f 80 00       	push   $0x801fbe
  800c5f:	e8 e4 04 00 00       	call   801148 <cprintf>
  800c64:	83 c4 10             	add    $0x10,%esp
  800c67:	eb ad                	jmp    800c16 <_pipeisclosed+0xe>
	}
}
  800c69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6f:	5b                   	pop    %ebx
  800c70:	5e                   	pop    %esi
  800c71:	5f                   	pop    %edi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	57                   	push   %edi
  800c78:	56                   	push   %esi
  800c79:	53                   	push   %ebx
  800c7a:	83 ec 28             	sub    $0x28,%esp
  800c7d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c80:	56                   	push   %esi
  800c81:	e8 0f f7 ff ff       	call   800395 <fd2data>
  800c86:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c88:	83 c4 10             	add    $0x10,%esp
  800c8b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c90:	eb 4b                	jmp    800cdd <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c92:	89 da                	mov    %ebx,%edx
  800c94:	89 f0                	mov    %esi,%eax
  800c96:	e8 6d ff ff ff       	call   800c08 <_pipeisclosed>
  800c9b:	85 c0                	test   %eax,%eax
  800c9d:	75 48                	jne    800ce7 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c9f:	e8 ad f4 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800ca4:	8b 43 04             	mov    0x4(%ebx),%eax
  800ca7:	8b 0b                	mov    (%ebx),%ecx
  800ca9:	8d 51 20             	lea    0x20(%ecx),%edx
  800cac:	39 d0                	cmp    %edx,%eax
  800cae:	73 e2                	jae    800c92 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cb0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb3:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cb7:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cba:	89 c2                	mov    %eax,%edx
  800cbc:	c1 fa 1f             	sar    $0x1f,%edx
  800cbf:	89 d1                	mov    %edx,%ecx
  800cc1:	c1 e9 1b             	shr    $0x1b,%ecx
  800cc4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cc7:	83 e2 1f             	and    $0x1f,%edx
  800cca:	29 ca                	sub    %ecx,%edx
  800ccc:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cd0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cd4:	83 c0 01             	add    $0x1,%eax
  800cd7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cda:	83 c7 01             	add    $0x1,%edi
  800cdd:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ce0:	75 c2                	jne    800ca4 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ce2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce5:	eb 05                	jmp    800cec <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ce7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
  800cfa:	83 ec 18             	sub    $0x18,%esp
  800cfd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d00:	57                   	push   %edi
  800d01:	e8 8f f6 ff ff       	call   800395 <fd2data>
  800d06:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d08:	83 c4 10             	add    $0x10,%esp
  800d0b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d10:	eb 3d                	jmp    800d4f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d12:	85 db                	test   %ebx,%ebx
  800d14:	74 04                	je     800d1a <devpipe_read+0x26>
				return i;
  800d16:	89 d8                	mov    %ebx,%eax
  800d18:	eb 44                	jmp    800d5e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d1a:	89 f2                	mov    %esi,%edx
  800d1c:	89 f8                	mov    %edi,%eax
  800d1e:	e8 e5 fe ff ff       	call   800c08 <_pipeisclosed>
  800d23:	85 c0                	test   %eax,%eax
  800d25:	75 32                	jne    800d59 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d27:	e8 25 f4 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d2c:	8b 06                	mov    (%esi),%eax
  800d2e:	3b 46 04             	cmp    0x4(%esi),%eax
  800d31:	74 df                	je     800d12 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d33:	99                   	cltd   
  800d34:	c1 ea 1b             	shr    $0x1b,%edx
  800d37:	01 d0                	add    %edx,%eax
  800d39:	83 e0 1f             	and    $0x1f,%eax
  800d3c:	29 d0                	sub    %edx,%eax
  800d3e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d46:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d49:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d4c:	83 c3 01             	add    $0x1,%ebx
  800d4f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d52:	75 d8                	jne    800d2c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d54:	8b 45 10             	mov    0x10(%ebp),%eax
  800d57:	eb 05                	jmp    800d5e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d59:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d61:	5b                   	pop    %ebx
  800d62:	5e                   	pop    %esi
  800d63:	5f                   	pop    %edi
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	56                   	push   %esi
  800d6a:	53                   	push   %ebx
  800d6b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d6e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d71:	50                   	push   %eax
  800d72:	e8 35 f6 ff ff       	call   8003ac <fd_alloc>
  800d77:	83 c4 10             	add    $0x10,%esp
  800d7a:	89 c2                	mov    %eax,%edx
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	0f 88 2c 01 00 00    	js     800eb0 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d84:	83 ec 04             	sub    $0x4,%esp
  800d87:	68 07 04 00 00       	push   $0x407
  800d8c:	ff 75 f4             	pushl  -0xc(%ebp)
  800d8f:	6a 00                	push   $0x0
  800d91:	e8 da f3 ff ff       	call   800170 <sys_page_alloc>
  800d96:	83 c4 10             	add    $0x10,%esp
  800d99:	89 c2                	mov    %eax,%edx
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	0f 88 0d 01 00 00    	js     800eb0 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800da3:	83 ec 0c             	sub    $0xc,%esp
  800da6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800da9:	50                   	push   %eax
  800daa:	e8 fd f5 ff ff       	call   8003ac <fd_alloc>
  800daf:	89 c3                	mov    %eax,%ebx
  800db1:	83 c4 10             	add    $0x10,%esp
  800db4:	85 c0                	test   %eax,%eax
  800db6:	0f 88 e2 00 00 00    	js     800e9e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dbc:	83 ec 04             	sub    $0x4,%esp
  800dbf:	68 07 04 00 00       	push   $0x407
  800dc4:	ff 75 f0             	pushl  -0x10(%ebp)
  800dc7:	6a 00                	push   $0x0
  800dc9:	e8 a2 f3 ff ff       	call   800170 <sys_page_alloc>
  800dce:	89 c3                	mov    %eax,%ebx
  800dd0:	83 c4 10             	add    $0x10,%esp
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	0f 88 c3 00 00 00    	js     800e9e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800ddb:	83 ec 0c             	sub    $0xc,%esp
  800dde:	ff 75 f4             	pushl  -0xc(%ebp)
  800de1:	e8 af f5 ff ff       	call   800395 <fd2data>
  800de6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de8:	83 c4 0c             	add    $0xc,%esp
  800deb:	68 07 04 00 00       	push   $0x407
  800df0:	50                   	push   %eax
  800df1:	6a 00                	push   $0x0
  800df3:	e8 78 f3 ff ff       	call   800170 <sys_page_alloc>
  800df8:	89 c3                	mov    %eax,%ebx
  800dfa:	83 c4 10             	add    $0x10,%esp
  800dfd:	85 c0                	test   %eax,%eax
  800dff:	0f 88 89 00 00 00    	js     800e8e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e05:	83 ec 0c             	sub    $0xc,%esp
  800e08:	ff 75 f0             	pushl  -0x10(%ebp)
  800e0b:	e8 85 f5 ff ff       	call   800395 <fd2data>
  800e10:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e17:	50                   	push   %eax
  800e18:	6a 00                	push   $0x0
  800e1a:	56                   	push   %esi
  800e1b:	6a 00                	push   $0x0
  800e1d:	e8 91 f3 ff ff       	call   8001b3 <sys_page_map>
  800e22:	89 c3                	mov    %eax,%ebx
  800e24:	83 c4 20             	add    $0x20,%esp
  800e27:	85 c0                	test   %eax,%eax
  800e29:	78 55                	js     800e80 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e2b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e34:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e39:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e40:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e46:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e49:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e4e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e55:	83 ec 0c             	sub    $0xc,%esp
  800e58:	ff 75 f4             	pushl  -0xc(%ebp)
  800e5b:	e8 25 f5 ff ff       	call   800385 <fd2num>
  800e60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e63:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e65:	83 c4 04             	add    $0x4,%esp
  800e68:	ff 75 f0             	pushl  -0x10(%ebp)
  800e6b:	e8 15 f5 ff ff       	call   800385 <fd2num>
  800e70:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e73:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e76:	83 c4 10             	add    $0x10,%esp
  800e79:	ba 00 00 00 00       	mov    $0x0,%edx
  800e7e:	eb 30                	jmp    800eb0 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e80:	83 ec 08             	sub    $0x8,%esp
  800e83:	56                   	push   %esi
  800e84:	6a 00                	push   $0x0
  800e86:	e8 6a f3 ff ff       	call   8001f5 <sys_page_unmap>
  800e8b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e8e:	83 ec 08             	sub    $0x8,%esp
  800e91:	ff 75 f0             	pushl  -0x10(%ebp)
  800e94:	6a 00                	push   $0x0
  800e96:	e8 5a f3 ff ff       	call   8001f5 <sys_page_unmap>
  800e9b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e9e:	83 ec 08             	sub    $0x8,%esp
  800ea1:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea4:	6a 00                	push   $0x0
  800ea6:	e8 4a f3 ff ff       	call   8001f5 <sys_page_unmap>
  800eab:	83 c4 10             	add    $0x10,%esp
  800eae:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800eb0:	89 d0                	mov    %edx,%eax
  800eb2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eb5:	5b                   	pop    %ebx
  800eb6:	5e                   	pop    %esi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    

00800eb9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ebf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ec2:	50                   	push   %eax
  800ec3:	ff 75 08             	pushl  0x8(%ebp)
  800ec6:	e8 30 f5 ff ff       	call   8003fb <fd_lookup>
  800ecb:	83 c4 10             	add    $0x10,%esp
  800ece:	85 c0                	test   %eax,%eax
  800ed0:	78 18                	js     800eea <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ed2:	83 ec 0c             	sub    $0xc,%esp
  800ed5:	ff 75 f4             	pushl  -0xc(%ebp)
  800ed8:	e8 b8 f4 ff ff       	call   800395 <fd2data>
	return _pipeisclosed(fd, p);
  800edd:	89 c2                	mov    %eax,%edx
  800edf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ee2:	e8 21 fd ff ff       	call   800c08 <_pipeisclosed>
  800ee7:	83 c4 10             	add    $0x10,%esp
}
  800eea:	c9                   	leave  
  800eeb:	c3                   	ret    

00800eec <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eef:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef4:	5d                   	pop    %ebp
  800ef5:	c3                   	ret    

00800ef6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800efc:	68 d6 1f 80 00       	push   $0x801fd6
  800f01:	ff 75 0c             	pushl  0xc(%ebp)
  800f04:	e8 43 08 00 00       	call   80174c <strcpy>
	return 0;
}
  800f09:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0e:	c9                   	leave  
  800f0f:	c3                   	ret    

00800f10 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	57                   	push   %edi
  800f14:	56                   	push   %esi
  800f15:	53                   	push   %ebx
  800f16:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f1c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f21:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f27:	eb 2d                	jmp    800f56 <devcons_write+0x46>
		m = n - tot;
  800f29:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f2e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f31:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f36:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f39:	83 ec 04             	sub    $0x4,%esp
  800f3c:	53                   	push   %ebx
  800f3d:	03 45 0c             	add    0xc(%ebp),%eax
  800f40:	50                   	push   %eax
  800f41:	57                   	push   %edi
  800f42:	e8 97 09 00 00       	call   8018de <memmove>
		sys_cputs(buf, m);
  800f47:	83 c4 08             	add    $0x8,%esp
  800f4a:	53                   	push   %ebx
  800f4b:	57                   	push   %edi
  800f4c:	e8 63 f1 ff ff       	call   8000b4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f51:	01 de                	add    %ebx,%esi
  800f53:	83 c4 10             	add    $0x10,%esp
  800f56:	89 f0                	mov    %esi,%eax
  800f58:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f5b:	72 cc                	jb     800f29 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f60:	5b                   	pop    %ebx
  800f61:	5e                   	pop    %esi
  800f62:	5f                   	pop    %edi
  800f63:	5d                   	pop    %ebp
  800f64:	c3                   	ret    

00800f65 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	83 ec 08             	sub    $0x8,%esp
  800f6b:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f70:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f74:	74 2a                	je     800fa0 <devcons_read+0x3b>
  800f76:	eb 05                	jmp    800f7d <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f78:	e8 d4 f1 ff ff       	call   800151 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f7d:	e8 50 f1 ff ff       	call   8000d2 <sys_cgetc>
  800f82:	85 c0                	test   %eax,%eax
  800f84:	74 f2                	je     800f78 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f86:	85 c0                	test   %eax,%eax
  800f88:	78 16                	js     800fa0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f8a:	83 f8 04             	cmp    $0x4,%eax
  800f8d:	74 0c                	je     800f9b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f8f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f92:	88 02                	mov    %al,(%edx)
	return 1;
  800f94:	b8 01 00 00 00       	mov    $0x1,%eax
  800f99:	eb 05                	jmp    800fa0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f9b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fa0:	c9                   	leave  
  800fa1:	c3                   	ret    

00800fa2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fab:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fae:	6a 01                	push   $0x1
  800fb0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fb3:	50                   	push   %eax
  800fb4:	e8 fb f0 ff ff       	call   8000b4 <sys_cputs>
}
  800fb9:	83 c4 10             	add    $0x10,%esp
  800fbc:	c9                   	leave  
  800fbd:	c3                   	ret    

00800fbe <getchar>:

int
getchar(void)
{
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fc4:	6a 01                	push   $0x1
  800fc6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fc9:	50                   	push   %eax
  800fca:	6a 00                	push   $0x0
  800fcc:	e8 90 f6 ff ff       	call   800661 <read>
	if (r < 0)
  800fd1:	83 c4 10             	add    $0x10,%esp
  800fd4:	85 c0                	test   %eax,%eax
  800fd6:	78 0f                	js     800fe7 <getchar+0x29>
		return r;
	if (r < 1)
  800fd8:	85 c0                	test   %eax,%eax
  800fda:	7e 06                	jle    800fe2 <getchar+0x24>
		return -E_EOF;
	return c;
  800fdc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fe0:	eb 05                	jmp    800fe7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fe2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fe7:	c9                   	leave  
  800fe8:	c3                   	ret    

00800fe9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fe9:	55                   	push   %ebp
  800fea:	89 e5                	mov    %esp,%ebp
  800fec:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff2:	50                   	push   %eax
  800ff3:	ff 75 08             	pushl  0x8(%ebp)
  800ff6:	e8 00 f4 ff ff       	call   8003fb <fd_lookup>
  800ffb:	83 c4 10             	add    $0x10,%esp
  800ffe:	85 c0                	test   %eax,%eax
  801000:	78 11                	js     801013 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801002:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801005:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80100b:	39 10                	cmp    %edx,(%eax)
  80100d:	0f 94 c0             	sete   %al
  801010:	0f b6 c0             	movzbl %al,%eax
}
  801013:	c9                   	leave  
  801014:	c3                   	ret    

00801015 <opencons>:

int
opencons(void)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80101b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80101e:	50                   	push   %eax
  80101f:	e8 88 f3 ff ff       	call   8003ac <fd_alloc>
  801024:	83 c4 10             	add    $0x10,%esp
		return r;
  801027:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801029:	85 c0                	test   %eax,%eax
  80102b:	78 3e                	js     80106b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80102d:	83 ec 04             	sub    $0x4,%esp
  801030:	68 07 04 00 00       	push   $0x407
  801035:	ff 75 f4             	pushl  -0xc(%ebp)
  801038:	6a 00                	push   $0x0
  80103a:	e8 31 f1 ff ff       	call   800170 <sys_page_alloc>
  80103f:	83 c4 10             	add    $0x10,%esp
		return r;
  801042:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801044:	85 c0                	test   %eax,%eax
  801046:	78 23                	js     80106b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801048:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80104e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801051:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801053:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801056:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80105d:	83 ec 0c             	sub    $0xc,%esp
  801060:	50                   	push   %eax
  801061:	e8 1f f3 ff ff       	call   800385 <fd2num>
  801066:	89 c2                	mov    %eax,%edx
  801068:	83 c4 10             	add    $0x10,%esp
}
  80106b:	89 d0                	mov    %edx,%eax
  80106d:	c9                   	leave  
  80106e:	c3                   	ret    

0080106f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80106f:	55                   	push   %ebp
  801070:	89 e5                	mov    %esp,%ebp
  801072:	56                   	push   %esi
  801073:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801074:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801077:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80107d:	e8 b0 f0 ff ff       	call   800132 <sys_getenvid>
  801082:	83 ec 0c             	sub    $0xc,%esp
  801085:	ff 75 0c             	pushl  0xc(%ebp)
  801088:	ff 75 08             	pushl  0x8(%ebp)
  80108b:	56                   	push   %esi
  80108c:	50                   	push   %eax
  80108d:	68 e4 1f 80 00       	push   $0x801fe4
  801092:	e8 b1 00 00 00       	call   801148 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801097:	83 c4 18             	add    $0x18,%esp
  80109a:	53                   	push   %ebx
  80109b:	ff 75 10             	pushl  0x10(%ebp)
  80109e:	e8 54 00 00 00       	call   8010f7 <vcprintf>
	cprintf("\n");
  8010a3:	c7 04 24 cf 1f 80 00 	movl   $0x801fcf,(%esp)
  8010aa:	e8 99 00 00 00       	call   801148 <cprintf>
  8010af:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010b2:	cc                   	int3   
  8010b3:	eb fd                	jmp    8010b2 <_panic+0x43>

008010b5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
  8010b8:	53                   	push   %ebx
  8010b9:	83 ec 04             	sub    $0x4,%esp
  8010bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010bf:	8b 13                	mov    (%ebx),%edx
  8010c1:	8d 42 01             	lea    0x1(%edx),%eax
  8010c4:	89 03                	mov    %eax,(%ebx)
  8010c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010c9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010cd:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010d2:	75 1a                	jne    8010ee <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010d4:	83 ec 08             	sub    $0x8,%esp
  8010d7:	68 ff 00 00 00       	push   $0xff
  8010dc:	8d 43 08             	lea    0x8(%ebx),%eax
  8010df:	50                   	push   %eax
  8010e0:	e8 cf ef ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  8010e5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010eb:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010ee:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010f5:	c9                   	leave  
  8010f6:	c3                   	ret    

008010f7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010f7:	55                   	push   %ebp
  8010f8:	89 e5                	mov    %esp,%ebp
  8010fa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801100:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801107:	00 00 00 
	b.cnt = 0;
  80110a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801111:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801114:	ff 75 0c             	pushl  0xc(%ebp)
  801117:	ff 75 08             	pushl  0x8(%ebp)
  80111a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801120:	50                   	push   %eax
  801121:	68 b5 10 80 00       	push   $0x8010b5
  801126:	e8 1a 01 00 00       	call   801245 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80112b:	83 c4 08             	add    $0x8,%esp
  80112e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801134:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80113a:	50                   	push   %eax
  80113b:	e8 74 ef ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  801140:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801146:	c9                   	leave  
  801147:	c3                   	ret    

00801148 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
  80114b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80114e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801151:	50                   	push   %eax
  801152:	ff 75 08             	pushl  0x8(%ebp)
  801155:	e8 9d ff ff ff       	call   8010f7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80115a:	c9                   	leave  
  80115b:	c3                   	ret    

0080115c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	57                   	push   %edi
  801160:	56                   	push   %esi
  801161:	53                   	push   %ebx
  801162:	83 ec 1c             	sub    $0x1c,%esp
  801165:	89 c7                	mov    %eax,%edi
  801167:	89 d6                	mov    %edx,%esi
  801169:	8b 45 08             	mov    0x8(%ebp),%eax
  80116c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80116f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801172:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801175:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801178:	bb 00 00 00 00       	mov    $0x0,%ebx
  80117d:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801180:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801183:	39 d3                	cmp    %edx,%ebx
  801185:	72 05                	jb     80118c <printnum+0x30>
  801187:	39 45 10             	cmp    %eax,0x10(%ebp)
  80118a:	77 45                	ja     8011d1 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80118c:	83 ec 0c             	sub    $0xc,%esp
  80118f:	ff 75 18             	pushl  0x18(%ebp)
  801192:	8b 45 14             	mov    0x14(%ebp),%eax
  801195:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801198:	53                   	push   %ebx
  801199:	ff 75 10             	pushl  0x10(%ebp)
  80119c:	83 ec 08             	sub    $0x8,%esp
  80119f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8011a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8011a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8011ab:	e8 80 0a 00 00       	call   801c30 <__udivdi3>
  8011b0:	83 c4 18             	add    $0x18,%esp
  8011b3:	52                   	push   %edx
  8011b4:	50                   	push   %eax
  8011b5:	89 f2                	mov    %esi,%edx
  8011b7:	89 f8                	mov    %edi,%eax
  8011b9:	e8 9e ff ff ff       	call   80115c <printnum>
  8011be:	83 c4 20             	add    $0x20,%esp
  8011c1:	eb 18                	jmp    8011db <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011c3:	83 ec 08             	sub    $0x8,%esp
  8011c6:	56                   	push   %esi
  8011c7:	ff 75 18             	pushl  0x18(%ebp)
  8011ca:	ff d7                	call   *%edi
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	eb 03                	jmp    8011d4 <printnum+0x78>
  8011d1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011d4:	83 eb 01             	sub    $0x1,%ebx
  8011d7:	85 db                	test   %ebx,%ebx
  8011d9:	7f e8                	jg     8011c3 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011db:	83 ec 08             	sub    $0x8,%esp
  8011de:	56                   	push   %esi
  8011df:	83 ec 04             	sub    $0x4,%esp
  8011e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011e5:	ff 75 e0             	pushl  -0x20(%ebp)
  8011e8:	ff 75 dc             	pushl  -0x24(%ebp)
  8011eb:	ff 75 d8             	pushl  -0x28(%ebp)
  8011ee:	e8 6d 0b 00 00       	call   801d60 <__umoddi3>
  8011f3:	83 c4 14             	add    $0x14,%esp
  8011f6:	0f be 80 07 20 80 00 	movsbl 0x802007(%eax),%eax
  8011fd:	50                   	push   %eax
  8011fe:	ff d7                	call   *%edi
}
  801200:	83 c4 10             	add    $0x10,%esp
  801203:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801206:	5b                   	pop    %ebx
  801207:	5e                   	pop    %esi
  801208:	5f                   	pop    %edi
  801209:	5d                   	pop    %ebp
  80120a:	c3                   	ret    

0080120b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801211:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801215:	8b 10                	mov    (%eax),%edx
  801217:	3b 50 04             	cmp    0x4(%eax),%edx
  80121a:	73 0a                	jae    801226 <sprintputch+0x1b>
		*b->buf++ = ch;
  80121c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80121f:	89 08                	mov    %ecx,(%eax)
  801221:	8b 45 08             	mov    0x8(%ebp),%eax
  801224:	88 02                	mov    %al,(%edx)
}
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    

00801228 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80122e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801231:	50                   	push   %eax
  801232:	ff 75 10             	pushl  0x10(%ebp)
  801235:	ff 75 0c             	pushl  0xc(%ebp)
  801238:	ff 75 08             	pushl  0x8(%ebp)
  80123b:	e8 05 00 00 00       	call   801245 <vprintfmt>
	va_end(ap);
}
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	c9                   	leave  
  801244:	c3                   	ret    

00801245 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801245:	55                   	push   %ebp
  801246:	89 e5                	mov    %esp,%ebp
  801248:	57                   	push   %edi
  801249:	56                   	push   %esi
  80124a:	53                   	push   %ebx
  80124b:	83 ec 2c             	sub    $0x2c,%esp
  80124e:	8b 75 08             	mov    0x8(%ebp),%esi
  801251:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801254:	8b 7d 10             	mov    0x10(%ebp),%edi
  801257:	eb 12                	jmp    80126b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801259:	85 c0                	test   %eax,%eax
  80125b:	0f 84 42 04 00 00    	je     8016a3 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  801261:	83 ec 08             	sub    $0x8,%esp
  801264:	53                   	push   %ebx
  801265:	50                   	push   %eax
  801266:	ff d6                	call   *%esi
  801268:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80126b:	83 c7 01             	add    $0x1,%edi
  80126e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801272:	83 f8 25             	cmp    $0x25,%eax
  801275:	75 e2                	jne    801259 <vprintfmt+0x14>
  801277:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80127b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801282:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801289:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801290:	b9 00 00 00 00       	mov    $0x0,%ecx
  801295:	eb 07                	jmp    80129e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801297:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80129a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80129e:	8d 47 01             	lea    0x1(%edi),%eax
  8012a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012a4:	0f b6 07             	movzbl (%edi),%eax
  8012a7:	0f b6 d0             	movzbl %al,%edx
  8012aa:	83 e8 23             	sub    $0x23,%eax
  8012ad:	3c 55                	cmp    $0x55,%al
  8012af:	0f 87 d3 03 00 00    	ja     801688 <vprintfmt+0x443>
  8012b5:	0f b6 c0             	movzbl %al,%eax
  8012b8:	ff 24 85 40 21 80 00 	jmp    *0x802140(,%eax,4)
  8012bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012c2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012c6:	eb d6                	jmp    80129e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012d3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012d6:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8012da:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8012dd:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8012e0:	83 f9 09             	cmp    $0x9,%ecx
  8012e3:	77 3f                	ja     801324 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012e5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012e8:	eb e9                	jmp    8012d3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ed:	8b 00                	mov    (%eax),%eax
  8012ef:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8012f5:	8d 40 04             	lea    0x4(%eax),%eax
  8012f8:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012fe:	eb 2a                	jmp    80132a <vprintfmt+0xe5>
  801300:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801303:	85 c0                	test   %eax,%eax
  801305:	ba 00 00 00 00       	mov    $0x0,%edx
  80130a:	0f 49 d0             	cmovns %eax,%edx
  80130d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801310:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801313:	eb 89                	jmp    80129e <vprintfmt+0x59>
  801315:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801318:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80131f:	e9 7a ff ff ff       	jmp    80129e <vprintfmt+0x59>
  801324:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801327:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80132a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80132e:	0f 89 6a ff ff ff    	jns    80129e <vprintfmt+0x59>
				width = precision, precision = -1;
  801334:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801337:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80133a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801341:	e9 58 ff ff ff       	jmp    80129e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801346:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801349:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80134c:	e9 4d ff ff ff       	jmp    80129e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801351:	8b 45 14             	mov    0x14(%ebp),%eax
  801354:	8d 78 04             	lea    0x4(%eax),%edi
  801357:	83 ec 08             	sub    $0x8,%esp
  80135a:	53                   	push   %ebx
  80135b:	ff 30                	pushl  (%eax)
  80135d:	ff d6                	call   *%esi
			break;
  80135f:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801362:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801365:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801368:	e9 fe fe ff ff       	jmp    80126b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80136d:	8b 45 14             	mov    0x14(%ebp),%eax
  801370:	8d 78 04             	lea    0x4(%eax),%edi
  801373:	8b 00                	mov    (%eax),%eax
  801375:	99                   	cltd   
  801376:	31 d0                	xor    %edx,%eax
  801378:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80137a:	83 f8 0f             	cmp    $0xf,%eax
  80137d:	7f 0b                	jg     80138a <vprintfmt+0x145>
  80137f:	8b 14 85 a0 22 80 00 	mov    0x8022a0(,%eax,4),%edx
  801386:	85 d2                	test   %edx,%edx
  801388:	75 1b                	jne    8013a5 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80138a:	50                   	push   %eax
  80138b:	68 1f 20 80 00       	push   $0x80201f
  801390:	53                   	push   %ebx
  801391:	56                   	push   %esi
  801392:	e8 91 fe ff ff       	call   801228 <printfmt>
  801397:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80139a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80139d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013a0:	e9 c6 fe ff ff       	jmp    80126b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013a5:	52                   	push   %edx
  8013a6:	68 9d 1f 80 00       	push   $0x801f9d
  8013ab:	53                   	push   %ebx
  8013ac:	56                   	push   %esi
  8013ad:	e8 76 fe ff ff       	call   801228 <printfmt>
  8013b2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013b5:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013bb:	e9 ab fe ff ff       	jmp    80126b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8013c3:	83 c0 04             	add    $0x4,%eax
  8013c6:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8013c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8013cc:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013ce:	85 ff                	test   %edi,%edi
  8013d0:	b8 18 20 80 00       	mov    $0x802018,%eax
  8013d5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013d8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013dc:	0f 8e 94 00 00 00    	jle    801476 <vprintfmt+0x231>
  8013e2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013e6:	0f 84 98 00 00 00    	je     801484 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013ec:	83 ec 08             	sub    $0x8,%esp
  8013ef:	ff 75 d0             	pushl  -0x30(%ebp)
  8013f2:	57                   	push   %edi
  8013f3:	e8 33 03 00 00       	call   80172b <strnlen>
  8013f8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013fb:	29 c1                	sub    %eax,%ecx
  8013fd:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801400:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801403:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801407:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80140a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80140d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80140f:	eb 0f                	jmp    801420 <vprintfmt+0x1db>
					putch(padc, putdat);
  801411:	83 ec 08             	sub    $0x8,%esp
  801414:	53                   	push   %ebx
  801415:	ff 75 e0             	pushl  -0x20(%ebp)
  801418:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80141a:	83 ef 01             	sub    $0x1,%edi
  80141d:	83 c4 10             	add    $0x10,%esp
  801420:	85 ff                	test   %edi,%edi
  801422:	7f ed                	jg     801411 <vprintfmt+0x1cc>
  801424:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801427:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80142a:	85 c9                	test   %ecx,%ecx
  80142c:	b8 00 00 00 00       	mov    $0x0,%eax
  801431:	0f 49 c1             	cmovns %ecx,%eax
  801434:	29 c1                	sub    %eax,%ecx
  801436:	89 75 08             	mov    %esi,0x8(%ebp)
  801439:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80143c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80143f:	89 cb                	mov    %ecx,%ebx
  801441:	eb 4d                	jmp    801490 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801443:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801447:	74 1b                	je     801464 <vprintfmt+0x21f>
  801449:	0f be c0             	movsbl %al,%eax
  80144c:	83 e8 20             	sub    $0x20,%eax
  80144f:	83 f8 5e             	cmp    $0x5e,%eax
  801452:	76 10                	jbe    801464 <vprintfmt+0x21f>
					putch('?', putdat);
  801454:	83 ec 08             	sub    $0x8,%esp
  801457:	ff 75 0c             	pushl  0xc(%ebp)
  80145a:	6a 3f                	push   $0x3f
  80145c:	ff 55 08             	call   *0x8(%ebp)
  80145f:	83 c4 10             	add    $0x10,%esp
  801462:	eb 0d                	jmp    801471 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  801464:	83 ec 08             	sub    $0x8,%esp
  801467:	ff 75 0c             	pushl  0xc(%ebp)
  80146a:	52                   	push   %edx
  80146b:	ff 55 08             	call   *0x8(%ebp)
  80146e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801471:	83 eb 01             	sub    $0x1,%ebx
  801474:	eb 1a                	jmp    801490 <vprintfmt+0x24b>
  801476:	89 75 08             	mov    %esi,0x8(%ebp)
  801479:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80147c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80147f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801482:	eb 0c                	jmp    801490 <vprintfmt+0x24b>
  801484:	89 75 08             	mov    %esi,0x8(%ebp)
  801487:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80148a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80148d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801490:	83 c7 01             	add    $0x1,%edi
  801493:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801497:	0f be d0             	movsbl %al,%edx
  80149a:	85 d2                	test   %edx,%edx
  80149c:	74 23                	je     8014c1 <vprintfmt+0x27c>
  80149e:	85 f6                	test   %esi,%esi
  8014a0:	78 a1                	js     801443 <vprintfmt+0x1fe>
  8014a2:	83 ee 01             	sub    $0x1,%esi
  8014a5:	79 9c                	jns    801443 <vprintfmt+0x1fe>
  8014a7:	89 df                	mov    %ebx,%edi
  8014a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014af:	eb 18                	jmp    8014c9 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014b1:	83 ec 08             	sub    $0x8,%esp
  8014b4:	53                   	push   %ebx
  8014b5:	6a 20                	push   $0x20
  8014b7:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014b9:	83 ef 01             	sub    $0x1,%edi
  8014bc:	83 c4 10             	add    $0x10,%esp
  8014bf:	eb 08                	jmp    8014c9 <vprintfmt+0x284>
  8014c1:	89 df                	mov    %ebx,%edi
  8014c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8014c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014c9:	85 ff                	test   %edi,%edi
  8014cb:	7f e4                	jg     8014b1 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8014cd:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8014d0:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014d6:	e9 90 fd ff ff       	jmp    80126b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014db:	83 f9 01             	cmp    $0x1,%ecx
  8014de:	7e 19                	jle    8014f9 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8014e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e3:	8b 50 04             	mov    0x4(%eax),%edx
  8014e6:	8b 00                	mov    (%eax),%eax
  8014e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014eb:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f1:	8d 40 08             	lea    0x8(%eax),%eax
  8014f4:	89 45 14             	mov    %eax,0x14(%ebp)
  8014f7:	eb 38                	jmp    801531 <vprintfmt+0x2ec>
	else if (lflag)
  8014f9:	85 c9                	test   %ecx,%ecx
  8014fb:	74 1b                	je     801518 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8014fd:	8b 45 14             	mov    0x14(%ebp),%eax
  801500:	8b 00                	mov    (%eax),%eax
  801502:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801505:	89 c1                	mov    %eax,%ecx
  801507:	c1 f9 1f             	sar    $0x1f,%ecx
  80150a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80150d:	8b 45 14             	mov    0x14(%ebp),%eax
  801510:	8d 40 04             	lea    0x4(%eax),%eax
  801513:	89 45 14             	mov    %eax,0x14(%ebp)
  801516:	eb 19                	jmp    801531 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  801518:	8b 45 14             	mov    0x14(%ebp),%eax
  80151b:	8b 00                	mov    (%eax),%eax
  80151d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801520:	89 c1                	mov    %eax,%ecx
  801522:	c1 f9 1f             	sar    $0x1f,%ecx
  801525:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801528:	8b 45 14             	mov    0x14(%ebp),%eax
  80152b:	8d 40 04             	lea    0x4(%eax),%eax
  80152e:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801531:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801534:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801537:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80153c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801540:	0f 89 0e 01 00 00    	jns    801654 <vprintfmt+0x40f>
				putch('-', putdat);
  801546:	83 ec 08             	sub    $0x8,%esp
  801549:	53                   	push   %ebx
  80154a:	6a 2d                	push   $0x2d
  80154c:	ff d6                	call   *%esi
				num = -(long long) num;
  80154e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801551:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801554:	f7 da                	neg    %edx
  801556:	83 d1 00             	adc    $0x0,%ecx
  801559:	f7 d9                	neg    %ecx
  80155b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80155e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801563:	e9 ec 00 00 00       	jmp    801654 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801568:	83 f9 01             	cmp    $0x1,%ecx
  80156b:	7e 18                	jle    801585 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  80156d:	8b 45 14             	mov    0x14(%ebp),%eax
  801570:	8b 10                	mov    (%eax),%edx
  801572:	8b 48 04             	mov    0x4(%eax),%ecx
  801575:	8d 40 08             	lea    0x8(%eax),%eax
  801578:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80157b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801580:	e9 cf 00 00 00       	jmp    801654 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801585:	85 c9                	test   %ecx,%ecx
  801587:	74 1a                	je     8015a3 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  801589:	8b 45 14             	mov    0x14(%ebp),%eax
  80158c:	8b 10                	mov    (%eax),%edx
  80158e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801593:	8d 40 04             	lea    0x4(%eax),%eax
  801596:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801599:	b8 0a 00 00 00       	mov    $0xa,%eax
  80159e:	e9 b1 00 00 00       	jmp    801654 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8015a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a6:	8b 10                	mov    (%eax),%edx
  8015a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015ad:	8d 40 04             	lea    0x4(%eax),%eax
  8015b0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8015b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8015b8:	e9 97 00 00 00       	jmp    801654 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8015bd:	83 ec 08             	sub    $0x8,%esp
  8015c0:	53                   	push   %ebx
  8015c1:	6a 58                	push   $0x58
  8015c3:	ff d6                	call   *%esi
			putch('X', putdat);
  8015c5:	83 c4 08             	add    $0x8,%esp
  8015c8:	53                   	push   %ebx
  8015c9:	6a 58                	push   $0x58
  8015cb:	ff d6                	call   *%esi
			putch('X', putdat);
  8015cd:	83 c4 08             	add    $0x8,%esp
  8015d0:	53                   	push   %ebx
  8015d1:	6a 58                	push   $0x58
  8015d3:	ff d6                	call   *%esi
			break;
  8015d5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8015db:	e9 8b fc ff ff       	jmp    80126b <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8015e0:	83 ec 08             	sub    $0x8,%esp
  8015e3:	53                   	push   %ebx
  8015e4:	6a 30                	push   $0x30
  8015e6:	ff d6                	call   *%esi
			putch('x', putdat);
  8015e8:	83 c4 08             	add    $0x8,%esp
  8015eb:	53                   	push   %ebx
  8015ec:	6a 78                	push   $0x78
  8015ee:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f3:	8b 10                	mov    (%eax),%edx
  8015f5:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015fa:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015fd:	8d 40 04             	lea    0x4(%eax),%eax
  801600:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801603:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801608:	eb 4a                	jmp    801654 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80160a:	83 f9 01             	cmp    $0x1,%ecx
  80160d:	7e 15                	jle    801624 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80160f:	8b 45 14             	mov    0x14(%ebp),%eax
  801612:	8b 10                	mov    (%eax),%edx
  801614:	8b 48 04             	mov    0x4(%eax),%ecx
  801617:	8d 40 08             	lea    0x8(%eax),%eax
  80161a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80161d:	b8 10 00 00 00       	mov    $0x10,%eax
  801622:	eb 30                	jmp    801654 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801624:	85 c9                	test   %ecx,%ecx
  801626:	74 17                	je     80163f <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  801628:	8b 45 14             	mov    0x14(%ebp),%eax
  80162b:	8b 10                	mov    (%eax),%edx
  80162d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801632:	8d 40 04             	lea    0x4(%eax),%eax
  801635:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801638:	b8 10 00 00 00       	mov    $0x10,%eax
  80163d:	eb 15                	jmp    801654 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80163f:	8b 45 14             	mov    0x14(%ebp),%eax
  801642:	8b 10                	mov    (%eax),%edx
  801644:	b9 00 00 00 00       	mov    $0x0,%ecx
  801649:	8d 40 04             	lea    0x4(%eax),%eax
  80164c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80164f:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801654:	83 ec 0c             	sub    $0xc,%esp
  801657:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80165b:	57                   	push   %edi
  80165c:	ff 75 e0             	pushl  -0x20(%ebp)
  80165f:	50                   	push   %eax
  801660:	51                   	push   %ecx
  801661:	52                   	push   %edx
  801662:	89 da                	mov    %ebx,%edx
  801664:	89 f0                	mov    %esi,%eax
  801666:	e8 f1 fa ff ff       	call   80115c <printnum>
			break;
  80166b:	83 c4 20             	add    $0x20,%esp
  80166e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801671:	e9 f5 fb ff ff       	jmp    80126b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801676:	83 ec 08             	sub    $0x8,%esp
  801679:	53                   	push   %ebx
  80167a:	52                   	push   %edx
  80167b:	ff d6                	call   *%esi
			break;
  80167d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801680:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801683:	e9 e3 fb ff ff       	jmp    80126b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801688:	83 ec 08             	sub    $0x8,%esp
  80168b:	53                   	push   %ebx
  80168c:	6a 25                	push   $0x25
  80168e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801690:	83 c4 10             	add    $0x10,%esp
  801693:	eb 03                	jmp    801698 <vprintfmt+0x453>
  801695:	83 ef 01             	sub    $0x1,%edi
  801698:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80169c:	75 f7                	jne    801695 <vprintfmt+0x450>
  80169e:	e9 c8 fb ff ff       	jmp    80126b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8016a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a6:	5b                   	pop    %ebx
  8016a7:	5e                   	pop    %esi
  8016a8:	5f                   	pop    %edi
  8016a9:	5d                   	pop    %ebp
  8016aa:	c3                   	ret    

008016ab <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	83 ec 18             	sub    $0x18,%esp
  8016b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8016b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016ba:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8016be:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8016c1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8016c8:	85 c0                	test   %eax,%eax
  8016ca:	74 26                	je     8016f2 <vsnprintf+0x47>
  8016cc:	85 d2                	test   %edx,%edx
  8016ce:	7e 22                	jle    8016f2 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8016d0:	ff 75 14             	pushl  0x14(%ebp)
  8016d3:	ff 75 10             	pushl  0x10(%ebp)
  8016d6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016d9:	50                   	push   %eax
  8016da:	68 0b 12 80 00       	push   $0x80120b
  8016df:	e8 61 fb ff ff       	call   801245 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016e7:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ed:	83 c4 10             	add    $0x10,%esp
  8016f0:	eb 05                	jmp    8016f7 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016f7:	c9                   	leave  
  8016f8:	c3                   	ret    

008016f9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016f9:	55                   	push   %ebp
  8016fa:	89 e5                	mov    %esp,%ebp
  8016fc:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016ff:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801702:	50                   	push   %eax
  801703:	ff 75 10             	pushl  0x10(%ebp)
  801706:	ff 75 0c             	pushl  0xc(%ebp)
  801709:	ff 75 08             	pushl  0x8(%ebp)
  80170c:	e8 9a ff ff ff       	call   8016ab <vsnprintf>
	va_end(ap);

	return rc;
}
  801711:	c9                   	leave  
  801712:	c3                   	ret    

00801713 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801719:	b8 00 00 00 00       	mov    $0x0,%eax
  80171e:	eb 03                	jmp    801723 <strlen+0x10>
		n++;
  801720:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801723:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801727:	75 f7                	jne    801720 <strlen+0xd>
		n++;
	return n;
}
  801729:	5d                   	pop    %ebp
  80172a:	c3                   	ret    

0080172b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801731:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801734:	ba 00 00 00 00       	mov    $0x0,%edx
  801739:	eb 03                	jmp    80173e <strnlen+0x13>
		n++;
  80173b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80173e:	39 c2                	cmp    %eax,%edx
  801740:	74 08                	je     80174a <strnlen+0x1f>
  801742:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801746:	75 f3                	jne    80173b <strnlen+0x10>
  801748:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80174a:	5d                   	pop    %ebp
  80174b:	c3                   	ret    

0080174c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80174c:	55                   	push   %ebp
  80174d:	89 e5                	mov    %esp,%ebp
  80174f:	53                   	push   %ebx
  801750:	8b 45 08             	mov    0x8(%ebp),%eax
  801753:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801756:	89 c2                	mov    %eax,%edx
  801758:	83 c2 01             	add    $0x1,%edx
  80175b:	83 c1 01             	add    $0x1,%ecx
  80175e:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801762:	88 5a ff             	mov    %bl,-0x1(%edx)
  801765:	84 db                	test   %bl,%bl
  801767:	75 ef                	jne    801758 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801769:	5b                   	pop    %ebx
  80176a:	5d                   	pop    %ebp
  80176b:	c3                   	ret    

0080176c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	53                   	push   %ebx
  801770:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801773:	53                   	push   %ebx
  801774:	e8 9a ff ff ff       	call   801713 <strlen>
  801779:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80177c:	ff 75 0c             	pushl  0xc(%ebp)
  80177f:	01 d8                	add    %ebx,%eax
  801781:	50                   	push   %eax
  801782:	e8 c5 ff ff ff       	call   80174c <strcpy>
	return dst;
}
  801787:	89 d8                	mov    %ebx,%eax
  801789:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178c:	c9                   	leave  
  80178d:	c3                   	ret    

0080178e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	56                   	push   %esi
  801792:	53                   	push   %ebx
  801793:	8b 75 08             	mov    0x8(%ebp),%esi
  801796:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801799:	89 f3                	mov    %esi,%ebx
  80179b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80179e:	89 f2                	mov    %esi,%edx
  8017a0:	eb 0f                	jmp    8017b1 <strncpy+0x23>
		*dst++ = *src;
  8017a2:	83 c2 01             	add    $0x1,%edx
  8017a5:	0f b6 01             	movzbl (%ecx),%eax
  8017a8:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8017ab:	80 39 01             	cmpb   $0x1,(%ecx)
  8017ae:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8017b1:	39 da                	cmp    %ebx,%edx
  8017b3:	75 ed                	jne    8017a2 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8017b5:	89 f0                	mov    %esi,%eax
  8017b7:	5b                   	pop    %ebx
  8017b8:	5e                   	pop    %esi
  8017b9:	5d                   	pop    %ebp
  8017ba:	c3                   	ret    

008017bb <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8017bb:	55                   	push   %ebp
  8017bc:	89 e5                	mov    %esp,%ebp
  8017be:	56                   	push   %esi
  8017bf:	53                   	push   %ebx
  8017c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8017c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017c6:	8b 55 10             	mov    0x10(%ebp),%edx
  8017c9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8017cb:	85 d2                	test   %edx,%edx
  8017cd:	74 21                	je     8017f0 <strlcpy+0x35>
  8017cf:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8017d3:	89 f2                	mov    %esi,%edx
  8017d5:	eb 09                	jmp    8017e0 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017d7:	83 c2 01             	add    $0x1,%edx
  8017da:	83 c1 01             	add    $0x1,%ecx
  8017dd:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017e0:	39 c2                	cmp    %eax,%edx
  8017e2:	74 09                	je     8017ed <strlcpy+0x32>
  8017e4:	0f b6 19             	movzbl (%ecx),%ebx
  8017e7:	84 db                	test   %bl,%bl
  8017e9:	75 ec                	jne    8017d7 <strlcpy+0x1c>
  8017eb:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017ed:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017f0:	29 f0                	sub    %esi,%eax
}
  8017f2:	5b                   	pop    %ebx
  8017f3:	5e                   	pop    %esi
  8017f4:	5d                   	pop    %ebp
  8017f5:	c3                   	ret    

008017f6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017ff:	eb 06                	jmp    801807 <strcmp+0x11>
		p++, q++;
  801801:	83 c1 01             	add    $0x1,%ecx
  801804:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801807:	0f b6 01             	movzbl (%ecx),%eax
  80180a:	84 c0                	test   %al,%al
  80180c:	74 04                	je     801812 <strcmp+0x1c>
  80180e:	3a 02                	cmp    (%edx),%al
  801810:	74 ef                	je     801801 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801812:	0f b6 c0             	movzbl %al,%eax
  801815:	0f b6 12             	movzbl (%edx),%edx
  801818:	29 d0                	sub    %edx,%eax
}
  80181a:	5d                   	pop    %ebp
  80181b:	c3                   	ret    

0080181c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	53                   	push   %ebx
  801820:	8b 45 08             	mov    0x8(%ebp),%eax
  801823:	8b 55 0c             	mov    0xc(%ebp),%edx
  801826:	89 c3                	mov    %eax,%ebx
  801828:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80182b:	eb 06                	jmp    801833 <strncmp+0x17>
		n--, p++, q++;
  80182d:	83 c0 01             	add    $0x1,%eax
  801830:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801833:	39 d8                	cmp    %ebx,%eax
  801835:	74 15                	je     80184c <strncmp+0x30>
  801837:	0f b6 08             	movzbl (%eax),%ecx
  80183a:	84 c9                	test   %cl,%cl
  80183c:	74 04                	je     801842 <strncmp+0x26>
  80183e:	3a 0a                	cmp    (%edx),%cl
  801840:	74 eb                	je     80182d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801842:	0f b6 00             	movzbl (%eax),%eax
  801845:	0f b6 12             	movzbl (%edx),%edx
  801848:	29 d0                	sub    %edx,%eax
  80184a:	eb 05                	jmp    801851 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80184c:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801851:	5b                   	pop    %ebx
  801852:	5d                   	pop    %ebp
  801853:	c3                   	ret    

00801854 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801854:	55                   	push   %ebp
  801855:	89 e5                	mov    %esp,%ebp
  801857:	8b 45 08             	mov    0x8(%ebp),%eax
  80185a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80185e:	eb 07                	jmp    801867 <strchr+0x13>
		if (*s == c)
  801860:	38 ca                	cmp    %cl,%dl
  801862:	74 0f                	je     801873 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801864:	83 c0 01             	add    $0x1,%eax
  801867:	0f b6 10             	movzbl (%eax),%edx
  80186a:	84 d2                	test   %dl,%dl
  80186c:	75 f2                	jne    801860 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80186e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801873:	5d                   	pop    %ebp
  801874:	c3                   	ret    

00801875 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801875:	55                   	push   %ebp
  801876:	89 e5                	mov    %esp,%ebp
  801878:	8b 45 08             	mov    0x8(%ebp),%eax
  80187b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80187f:	eb 03                	jmp    801884 <strfind+0xf>
  801881:	83 c0 01             	add    $0x1,%eax
  801884:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801887:	38 ca                	cmp    %cl,%dl
  801889:	74 04                	je     80188f <strfind+0x1a>
  80188b:	84 d2                	test   %dl,%dl
  80188d:	75 f2                	jne    801881 <strfind+0xc>
			break;
	return (char *) s;
}
  80188f:	5d                   	pop    %ebp
  801890:	c3                   	ret    

00801891 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801891:	55                   	push   %ebp
  801892:	89 e5                	mov    %esp,%ebp
  801894:	57                   	push   %edi
  801895:	56                   	push   %esi
  801896:	53                   	push   %ebx
  801897:	8b 7d 08             	mov    0x8(%ebp),%edi
  80189a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80189d:	85 c9                	test   %ecx,%ecx
  80189f:	74 36                	je     8018d7 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8018a1:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8018a7:	75 28                	jne    8018d1 <memset+0x40>
  8018a9:	f6 c1 03             	test   $0x3,%cl
  8018ac:	75 23                	jne    8018d1 <memset+0x40>
		c &= 0xFF;
  8018ae:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8018b2:	89 d3                	mov    %edx,%ebx
  8018b4:	c1 e3 08             	shl    $0x8,%ebx
  8018b7:	89 d6                	mov    %edx,%esi
  8018b9:	c1 e6 18             	shl    $0x18,%esi
  8018bc:	89 d0                	mov    %edx,%eax
  8018be:	c1 e0 10             	shl    $0x10,%eax
  8018c1:	09 f0                	or     %esi,%eax
  8018c3:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8018c5:	89 d8                	mov    %ebx,%eax
  8018c7:	09 d0                	or     %edx,%eax
  8018c9:	c1 e9 02             	shr    $0x2,%ecx
  8018cc:	fc                   	cld    
  8018cd:	f3 ab                	rep stos %eax,%es:(%edi)
  8018cf:	eb 06                	jmp    8018d7 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8018d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018d4:	fc                   	cld    
  8018d5:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8018d7:	89 f8                	mov    %edi,%eax
  8018d9:	5b                   	pop    %ebx
  8018da:	5e                   	pop    %esi
  8018db:	5f                   	pop    %edi
  8018dc:	5d                   	pop    %ebp
  8018dd:	c3                   	ret    

008018de <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018de:	55                   	push   %ebp
  8018df:	89 e5                	mov    %esp,%ebp
  8018e1:	57                   	push   %edi
  8018e2:	56                   	push   %esi
  8018e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018e9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018ec:	39 c6                	cmp    %eax,%esi
  8018ee:	73 35                	jae    801925 <memmove+0x47>
  8018f0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018f3:	39 d0                	cmp    %edx,%eax
  8018f5:	73 2e                	jae    801925 <memmove+0x47>
		s += n;
		d += n;
  8018f7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018fa:	89 d6                	mov    %edx,%esi
  8018fc:	09 fe                	or     %edi,%esi
  8018fe:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801904:	75 13                	jne    801919 <memmove+0x3b>
  801906:	f6 c1 03             	test   $0x3,%cl
  801909:	75 0e                	jne    801919 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80190b:	83 ef 04             	sub    $0x4,%edi
  80190e:	8d 72 fc             	lea    -0x4(%edx),%esi
  801911:	c1 e9 02             	shr    $0x2,%ecx
  801914:	fd                   	std    
  801915:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801917:	eb 09                	jmp    801922 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801919:	83 ef 01             	sub    $0x1,%edi
  80191c:	8d 72 ff             	lea    -0x1(%edx),%esi
  80191f:	fd                   	std    
  801920:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801922:	fc                   	cld    
  801923:	eb 1d                	jmp    801942 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801925:	89 f2                	mov    %esi,%edx
  801927:	09 c2                	or     %eax,%edx
  801929:	f6 c2 03             	test   $0x3,%dl
  80192c:	75 0f                	jne    80193d <memmove+0x5f>
  80192e:	f6 c1 03             	test   $0x3,%cl
  801931:	75 0a                	jne    80193d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801933:	c1 e9 02             	shr    $0x2,%ecx
  801936:	89 c7                	mov    %eax,%edi
  801938:	fc                   	cld    
  801939:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80193b:	eb 05                	jmp    801942 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80193d:	89 c7                	mov    %eax,%edi
  80193f:	fc                   	cld    
  801940:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801942:	5e                   	pop    %esi
  801943:	5f                   	pop    %edi
  801944:	5d                   	pop    %ebp
  801945:	c3                   	ret    

00801946 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801946:	55                   	push   %ebp
  801947:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801949:	ff 75 10             	pushl  0x10(%ebp)
  80194c:	ff 75 0c             	pushl  0xc(%ebp)
  80194f:	ff 75 08             	pushl  0x8(%ebp)
  801952:	e8 87 ff ff ff       	call   8018de <memmove>
}
  801957:	c9                   	leave  
  801958:	c3                   	ret    

00801959 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801959:	55                   	push   %ebp
  80195a:	89 e5                	mov    %esp,%ebp
  80195c:	56                   	push   %esi
  80195d:	53                   	push   %ebx
  80195e:	8b 45 08             	mov    0x8(%ebp),%eax
  801961:	8b 55 0c             	mov    0xc(%ebp),%edx
  801964:	89 c6                	mov    %eax,%esi
  801966:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801969:	eb 1a                	jmp    801985 <memcmp+0x2c>
		if (*s1 != *s2)
  80196b:	0f b6 08             	movzbl (%eax),%ecx
  80196e:	0f b6 1a             	movzbl (%edx),%ebx
  801971:	38 d9                	cmp    %bl,%cl
  801973:	74 0a                	je     80197f <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801975:	0f b6 c1             	movzbl %cl,%eax
  801978:	0f b6 db             	movzbl %bl,%ebx
  80197b:	29 d8                	sub    %ebx,%eax
  80197d:	eb 0f                	jmp    80198e <memcmp+0x35>
		s1++, s2++;
  80197f:	83 c0 01             	add    $0x1,%eax
  801982:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801985:	39 f0                	cmp    %esi,%eax
  801987:	75 e2                	jne    80196b <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801989:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80198e:	5b                   	pop    %ebx
  80198f:	5e                   	pop    %esi
  801990:	5d                   	pop    %ebp
  801991:	c3                   	ret    

00801992 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	53                   	push   %ebx
  801996:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801999:	89 c1                	mov    %eax,%ecx
  80199b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80199e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8019a2:	eb 0a                	jmp    8019ae <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8019a4:	0f b6 10             	movzbl (%eax),%edx
  8019a7:	39 da                	cmp    %ebx,%edx
  8019a9:	74 07                	je     8019b2 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8019ab:	83 c0 01             	add    $0x1,%eax
  8019ae:	39 c8                	cmp    %ecx,%eax
  8019b0:	72 f2                	jb     8019a4 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8019b2:	5b                   	pop    %ebx
  8019b3:	5d                   	pop    %ebp
  8019b4:	c3                   	ret    

008019b5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8019b5:	55                   	push   %ebp
  8019b6:	89 e5                	mov    %esp,%ebp
  8019b8:	57                   	push   %edi
  8019b9:	56                   	push   %esi
  8019ba:	53                   	push   %ebx
  8019bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019be:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019c1:	eb 03                	jmp    8019c6 <strtol+0x11>
		s++;
  8019c3:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019c6:	0f b6 01             	movzbl (%ecx),%eax
  8019c9:	3c 20                	cmp    $0x20,%al
  8019cb:	74 f6                	je     8019c3 <strtol+0xe>
  8019cd:	3c 09                	cmp    $0x9,%al
  8019cf:	74 f2                	je     8019c3 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8019d1:	3c 2b                	cmp    $0x2b,%al
  8019d3:	75 0a                	jne    8019df <strtol+0x2a>
		s++;
  8019d5:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019d8:	bf 00 00 00 00       	mov    $0x0,%edi
  8019dd:	eb 11                	jmp    8019f0 <strtol+0x3b>
  8019df:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019e4:	3c 2d                	cmp    $0x2d,%al
  8019e6:	75 08                	jne    8019f0 <strtol+0x3b>
		s++, neg = 1;
  8019e8:	83 c1 01             	add    $0x1,%ecx
  8019eb:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019f0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019f6:	75 15                	jne    801a0d <strtol+0x58>
  8019f8:	80 39 30             	cmpb   $0x30,(%ecx)
  8019fb:	75 10                	jne    801a0d <strtol+0x58>
  8019fd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801a01:	75 7c                	jne    801a7f <strtol+0xca>
		s += 2, base = 16;
  801a03:	83 c1 02             	add    $0x2,%ecx
  801a06:	bb 10 00 00 00       	mov    $0x10,%ebx
  801a0b:	eb 16                	jmp    801a23 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801a0d:	85 db                	test   %ebx,%ebx
  801a0f:	75 12                	jne    801a23 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801a11:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a16:	80 39 30             	cmpb   $0x30,(%ecx)
  801a19:	75 08                	jne    801a23 <strtol+0x6e>
		s++, base = 8;
  801a1b:	83 c1 01             	add    $0x1,%ecx
  801a1e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801a23:	b8 00 00 00 00       	mov    $0x0,%eax
  801a28:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801a2b:	0f b6 11             	movzbl (%ecx),%edx
  801a2e:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a31:	89 f3                	mov    %esi,%ebx
  801a33:	80 fb 09             	cmp    $0x9,%bl
  801a36:	77 08                	ja     801a40 <strtol+0x8b>
			dig = *s - '0';
  801a38:	0f be d2             	movsbl %dl,%edx
  801a3b:	83 ea 30             	sub    $0x30,%edx
  801a3e:	eb 22                	jmp    801a62 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a40:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a43:	89 f3                	mov    %esi,%ebx
  801a45:	80 fb 19             	cmp    $0x19,%bl
  801a48:	77 08                	ja     801a52 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a4a:	0f be d2             	movsbl %dl,%edx
  801a4d:	83 ea 57             	sub    $0x57,%edx
  801a50:	eb 10                	jmp    801a62 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a52:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a55:	89 f3                	mov    %esi,%ebx
  801a57:	80 fb 19             	cmp    $0x19,%bl
  801a5a:	77 16                	ja     801a72 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a5c:	0f be d2             	movsbl %dl,%edx
  801a5f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a62:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a65:	7d 0b                	jge    801a72 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a67:	83 c1 01             	add    $0x1,%ecx
  801a6a:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a6e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a70:	eb b9                	jmp    801a2b <strtol+0x76>

	if (endptr)
  801a72:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a76:	74 0d                	je     801a85 <strtol+0xd0>
		*endptr = (char *) s;
  801a78:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a7b:	89 0e                	mov    %ecx,(%esi)
  801a7d:	eb 06                	jmp    801a85 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a7f:	85 db                	test   %ebx,%ebx
  801a81:	74 98                	je     801a1b <strtol+0x66>
  801a83:	eb 9e                	jmp    801a23 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a85:	89 c2                	mov    %eax,%edx
  801a87:	f7 da                	neg    %edx
  801a89:	85 ff                	test   %edi,%edi
  801a8b:	0f 45 c2             	cmovne %edx,%eax
}
  801a8e:	5b                   	pop    %ebx
  801a8f:	5e                   	pop    %esi
  801a90:	5f                   	pop    %edi
  801a91:	5d                   	pop    %ebp
  801a92:	c3                   	ret    

00801a93 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801a99:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801aa0:	75 4a                	jne    801aec <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  801aa2:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa7:	8b 40 48             	mov    0x48(%eax),%eax
  801aaa:	83 ec 04             	sub    $0x4,%esp
  801aad:	6a 07                	push   $0x7
  801aaf:	68 00 f0 bf ee       	push   $0xeebff000
  801ab4:	50                   	push   %eax
  801ab5:	e8 b6 e6 ff ff       	call   800170 <sys_page_alloc>
  801aba:	83 c4 10             	add    $0x10,%esp
  801abd:	85 c0                	test   %eax,%eax
  801abf:	79 12                	jns    801ad3 <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  801ac1:	50                   	push   %eax
  801ac2:	68 00 23 80 00       	push   $0x802300
  801ac7:	6a 21                	push   $0x21
  801ac9:	68 18 23 80 00       	push   $0x802318
  801ace:	e8 9c f5 ff ff       	call   80106f <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801ad3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad8:	8b 40 48             	mov    0x48(%eax),%eax
  801adb:	83 ec 08             	sub    $0x8,%esp
  801ade:	68 61 03 80 00       	push   $0x800361
  801ae3:	50                   	push   %eax
  801ae4:	e8 d2 e7 ff ff       	call   8002bb <sys_env_set_pgfault_upcall>
  801ae9:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801aec:	8b 45 08             	mov    0x8(%ebp),%eax
  801aef:	a3 00 60 80 00       	mov    %eax,0x806000
  801af4:	c9                   	leave  
  801af5:	c3                   	ret    

00801af6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	56                   	push   %esi
  801afa:	53                   	push   %ebx
  801afb:	8b 75 08             	mov    0x8(%ebp),%esi
  801afe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b01:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801b04:	85 c0                	test   %eax,%eax
  801b06:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b0b:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801b0e:	83 ec 0c             	sub    $0xc,%esp
  801b11:	50                   	push   %eax
  801b12:	e8 09 e8 ff ff       	call   800320 <sys_ipc_recv>
  801b17:	83 c4 10             	add    $0x10,%esp
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	79 16                	jns    801b34 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801b1e:	85 f6                	test   %esi,%esi
  801b20:	74 06                	je     801b28 <ipc_recv+0x32>
            *from_env_store = 0;
  801b22:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801b28:	85 db                	test   %ebx,%ebx
  801b2a:	74 2c                	je     801b58 <ipc_recv+0x62>
            *perm_store = 0;
  801b2c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b32:	eb 24                	jmp    801b58 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801b34:	85 f6                	test   %esi,%esi
  801b36:	74 0a                	je     801b42 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801b38:	a1 04 40 80 00       	mov    0x804004,%eax
  801b3d:	8b 40 74             	mov    0x74(%eax),%eax
  801b40:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801b42:	85 db                	test   %ebx,%ebx
  801b44:	74 0a                	je     801b50 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801b46:	a1 04 40 80 00       	mov    0x804004,%eax
  801b4b:	8b 40 78             	mov    0x78(%eax),%eax
  801b4e:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801b50:	a1 04 40 80 00       	mov    0x804004,%eax
  801b55:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801b58:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b5b:	5b                   	pop    %ebx
  801b5c:	5e                   	pop    %esi
  801b5d:	5d                   	pop    %ebp
  801b5e:	c3                   	ret    

00801b5f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b5f:	55                   	push   %ebp
  801b60:	89 e5                	mov    %esp,%ebp
  801b62:	57                   	push   %edi
  801b63:	56                   	push   %esi
  801b64:	53                   	push   %ebx
  801b65:	83 ec 0c             	sub    $0xc,%esp
  801b68:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b6b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b6e:	8b 45 10             	mov    0x10(%ebp),%eax
  801b71:	85 c0                	test   %eax,%eax
  801b73:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801b78:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801b7b:	eb 1c                	jmp    801b99 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801b7d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b80:	74 12                	je     801b94 <ipc_send+0x35>
  801b82:	50                   	push   %eax
  801b83:	68 26 23 80 00       	push   $0x802326
  801b88:	6a 3a                	push   $0x3a
  801b8a:	68 3c 23 80 00       	push   $0x80233c
  801b8f:	e8 db f4 ff ff       	call   80106f <_panic>
		sys_yield();
  801b94:	e8 b8 e5 ff ff       	call   800151 <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801b99:	ff 75 14             	pushl  0x14(%ebp)
  801b9c:	53                   	push   %ebx
  801b9d:	56                   	push   %esi
  801b9e:	57                   	push   %edi
  801b9f:	e8 59 e7 ff ff       	call   8002fd <sys_ipc_try_send>
  801ba4:	83 c4 10             	add    $0x10,%esp
  801ba7:	85 c0                	test   %eax,%eax
  801ba9:	78 d2                	js     801b7d <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801bab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bae:	5b                   	pop    %ebx
  801baf:	5e                   	pop    %esi
  801bb0:	5f                   	pop    %edi
  801bb1:	5d                   	pop    %ebp
  801bb2:	c3                   	ret    

00801bb3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bb9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bbe:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bc1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bc7:	8b 52 50             	mov    0x50(%edx),%edx
  801bca:	39 ca                	cmp    %ecx,%edx
  801bcc:	75 0d                	jne    801bdb <ipc_find_env+0x28>
			return envs[i].env_id;
  801bce:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bd1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801bd6:	8b 40 48             	mov    0x48(%eax),%eax
  801bd9:	eb 0f                	jmp    801bea <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801bdb:	83 c0 01             	add    $0x1,%eax
  801bde:	3d 00 04 00 00       	cmp    $0x400,%eax
  801be3:	75 d9                	jne    801bbe <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801be5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801bea:	5d                   	pop    %ebp
  801beb:	c3                   	ret    

00801bec <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801bec:	55                   	push   %ebp
  801bed:	89 e5                	mov    %esp,%ebp
  801bef:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bf2:	89 d0                	mov    %edx,%eax
  801bf4:	c1 e8 16             	shr    $0x16,%eax
  801bf7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801bfe:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c03:	f6 c1 01             	test   $0x1,%cl
  801c06:	74 1d                	je     801c25 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c08:	c1 ea 0c             	shr    $0xc,%edx
  801c0b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c12:	f6 c2 01             	test   $0x1,%dl
  801c15:	74 0e                	je     801c25 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c17:	c1 ea 0c             	shr    $0xc,%edx
  801c1a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c21:	ef 
  801c22:	0f b7 c0             	movzwl %ax,%eax
}
  801c25:	5d                   	pop    %ebp
  801c26:	c3                   	ret    
  801c27:	66 90                	xchg   %ax,%ax
  801c29:	66 90                	xchg   %ax,%ax
  801c2b:	66 90                	xchg   %ax,%ax
  801c2d:	66 90                	xchg   %ax,%ax
  801c2f:	90                   	nop

00801c30 <__udivdi3>:
  801c30:	55                   	push   %ebp
  801c31:	57                   	push   %edi
  801c32:	56                   	push   %esi
  801c33:	53                   	push   %ebx
  801c34:	83 ec 1c             	sub    $0x1c,%esp
  801c37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c47:	85 f6                	test   %esi,%esi
  801c49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c4d:	89 ca                	mov    %ecx,%edx
  801c4f:	89 f8                	mov    %edi,%eax
  801c51:	75 3d                	jne    801c90 <__udivdi3+0x60>
  801c53:	39 cf                	cmp    %ecx,%edi
  801c55:	0f 87 c5 00 00 00    	ja     801d20 <__udivdi3+0xf0>
  801c5b:	85 ff                	test   %edi,%edi
  801c5d:	89 fd                	mov    %edi,%ebp
  801c5f:	75 0b                	jne    801c6c <__udivdi3+0x3c>
  801c61:	b8 01 00 00 00       	mov    $0x1,%eax
  801c66:	31 d2                	xor    %edx,%edx
  801c68:	f7 f7                	div    %edi
  801c6a:	89 c5                	mov    %eax,%ebp
  801c6c:	89 c8                	mov    %ecx,%eax
  801c6e:	31 d2                	xor    %edx,%edx
  801c70:	f7 f5                	div    %ebp
  801c72:	89 c1                	mov    %eax,%ecx
  801c74:	89 d8                	mov    %ebx,%eax
  801c76:	89 cf                	mov    %ecx,%edi
  801c78:	f7 f5                	div    %ebp
  801c7a:	89 c3                	mov    %eax,%ebx
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
  801c90:	39 ce                	cmp    %ecx,%esi
  801c92:	77 74                	ja     801d08 <__udivdi3+0xd8>
  801c94:	0f bd fe             	bsr    %esi,%edi
  801c97:	83 f7 1f             	xor    $0x1f,%edi
  801c9a:	0f 84 98 00 00 00    	je     801d38 <__udivdi3+0x108>
  801ca0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801ca5:	89 f9                	mov    %edi,%ecx
  801ca7:	89 c5                	mov    %eax,%ebp
  801ca9:	29 fb                	sub    %edi,%ebx
  801cab:	d3 e6                	shl    %cl,%esi
  801cad:	89 d9                	mov    %ebx,%ecx
  801caf:	d3 ed                	shr    %cl,%ebp
  801cb1:	89 f9                	mov    %edi,%ecx
  801cb3:	d3 e0                	shl    %cl,%eax
  801cb5:	09 ee                	or     %ebp,%esi
  801cb7:	89 d9                	mov    %ebx,%ecx
  801cb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801cbd:	89 d5                	mov    %edx,%ebp
  801cbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cc3:	d3 ed                	shr    %cl,%ebp
  801cc5:	89 f9                	mov    %edi,%ecx
  801cc7:	d3 e2                	shl    %cl,%edx
  801cc9:	89 d9                	mov    %ebx,%ecx
  801ccb:	d3 e8                	shr    %cl,%eax
  801ccd:	09 c2                	or     %eax,%edx
  801ccf:	89 d0                	mov    %edx,%eax
  801cd1:	89 ea                	mov    %ebp,%edx
  801cd3:	f7 f6                	div    %esi
  801cd5:	89 d5                	mov    %edx,%ebp
  801cd7:	89 c3                	mov    %eax,%ebx
  801cd9:	f7 64 24 0c          	mull   0xc(%esp)
  801cdd:	39 d5                	cmp    %edx,%ebp
  801cdf:	72 10                	jb     801cf1 <__udivdi3+0xc1>
  801ce1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801ce5:	89 f9                	mov    %edi,%ecx
  801ce7:	d3 e6                	shl    %cl,%esi
  801ce9:	39 c6                	cmp    %eax,%esi
  801ceb:	73 07                	jae    801cf4 <__udivdi3+0xc4>
  801ced:	39 d5                	cmp    %edx,%ebp
  801cef:	75 03                	jne    801cf4 <__udivdi3+0xc4>
  801cf1:	83 eb 01             	sub    $0x1,%ebx
  801cf4:	31 ff                	xor    %edi,%edi
  801cf6:	89 d8                	mov    %ebx,%eax
  801cf8:	89 fa                	mov    %edi,%edx
  801cfa:	83 c4 1c             	add    $0x1c,%esp
  801cfd:	5b                   	pop    %ebx
  801cfe:	5e                   	pop    %esi
  801cff:	5f                   	pop    %edi
  801d00:	5d                   	pop    %ebp
  801d01:	c3                   	ret    
  801d02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d08:	31 ff                	xor    %edi,%edi
  801d0a:	31 db                	xor    %ebx,%ebx
  801d0c:	89 d8                	mov    %ebx,%eax
  801d0e:	89 fa                	mov    %edi,%edx
  801d10:	83 c4 1c             	add    $0x1c,%esp
  801d13:	5b                   	pop    %ebx
  801d14:	5e                   	pop    %esi
  801d15:	5f                   	pop    %edi
  801d16:	5d                   	pop    %ebp
  801d17:	c3                   	ret    
  801d18:	90                   	nop
  801d19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d20:	89 d8                	mov    %ebx,%eax
  801d22:	f7 f7                	div    %edi
  801d24:	31 ff                	xor    %edi,%edi
  801d26:	89 c3                	mov    %eax,%ebx
  801d28:	89 d8                	mov    %ebx,%eax
  801d2a:	89 fa                	mov    %edi,%edx
  801d2c:	83 c4 1c             	add    $0x1c,%esp
  801d2f:	5b                   	pop    %ebx
  801d30:	5e                   	pop    %esi
  801d31:	5f                   	pop    %edi
  801d32:	5d                   	pop    %ebp
  801d33:	c3                   	ret    
  801d34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d38:	39 ce                	cmp    %ecx,%esi
  801d3a:	72 0c                	jb     801d48 <__udivdi3+0x118>
  801d3c:	31 db                	xor    %ebx,%ebx
  801d3e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d42:	0f 87 34 ff ff ff    	ja     801c7c <__udivdi3+0x4c>
  801d48:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d4d:	e9 2a ff ff ff       	jmp    801c7c <__udivdi3+0x4c>
  801d52:	66 90                	xchg   %ax,%ax
  801d54:	66 90                	xchg   %ax,%ax
  801d56:	66 90                	xchg   %ax,%ax
  801d58:	66 90                	xchg   %ax,%ax
  801d5a:	66 90                	xchg   %ax,%ax
  801d5c:	66 90                	xchg   %ax,%ax
  801d5e:	66 90                	xchg   %ax,%ax

00801d60 <__umoddi3>:
  801d60:	55                   	push   %ebp
  801d61:	57                   	push   %edi
  801d62:	56                   	push   %esi
  801d63:	53                   	push   %ebx
  801d64:	83 ec 1c             	sub    $0x1c,%esp
  801d67:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d6b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d6f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d77:	85 d2                	test   %edx,%edx
  801d79:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d81:	89 f3                	mov    %esi,%ebx
  801d83:	89 3c 24             	mov    %edi,(%esp)
  801d86:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d8a:	75 1c                	jne    801da8 <__umoddi3+0x48>
  801d8c:	39 f7                	cmp    %esi,%edi
  801d8e:	76 50                	jbe    801de0 <__umoddi3+0x80>
  801d90:	89 c8                	mov    %ecx,%eax
  801d92:	89 f2                	mov    %esi,%edx
  801d94:	f7 f7                	div    %edi
  801d96:	89 d0                	mov    %edx,%eax
  801d98:	31 d2                	xor    %edx,%edx
  801d9a:	83 c4 1c             	add    $0x1c,%esp
  801d9d:	5b                   	pop    %ebx
  801d9e:	5e                   	pop    %esi
  801d9f:	5f                   	pop    %edi
  801da0:	5d                   	pop    %ebp
  801da1:	c3                   	ret    
  801da2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801da8:	39 f2                	cmp    %esi,%edx
  801daa:	89 d0                	mov    %edx,%eax
  801dac:	77 52                	ja     801e00 <__umoddi3+0xa0>
  801dae:	0f bd ea             	bsr    %edx,%ebp
  801db1:	83 f5 1f             	xor    $0x1f,%ebp
  801db4:	75 5a                	jne    801e10 <__umoddi3+0xb0>
  801db6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801dba:	0f 82 e0 00 00 00    	jb     801ea0 <__umoddi3+0x140>
  801dc0:	39 0c 24             	cmp    %ecx,(%esp)
  801dc3:	0f 86 d7 00 00 00    	jbe    801ea0 <__umoddi3+0x140>
  801dc9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dcd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801dd1:	83 c4 1c             	add    $0x1c,%esp
  801dd4:	5b                   	pop    %ebx
  801dd5:	5e                   	pop    %esi
  801dd6:	5f                   	pop    %edi
  801dd7:	5d                   	pop    %ebp
  801dd8:	c3                   	ret    
  801dd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801de0:	85 ff                	test   %edi,%edi
  801de2:	89 fd                	mov    %edi,%ebp
  801de4:	75 0b                	jne    801df1 <__umoddi3+0x91>
  801de6:	b8 01 00 00 00       	mov    $0x1,%eax
  801deb:	31 d2                	xor    %edx,%edx
  801ded:	f7 f7                	div    %edi
  801def:	89 c5                	mov    %eax,%ebp
  801df1:	89 f0                	mov    %esi,%eax
  801df3:	31 d2                	xor    %edx,%edx
  801df5:	f7 f5                	div    %ebp
  801df7:	89 c8                	mov    %ecx,%eax
  801df9:	f7 f5                	div    %ebp
  801dfb:	89 d0                	mov    %edx,%eax
  801dfd:	eb 99                	jmp    801d98 <__umoddi3+0x38>
  801dff:	90                   	nop
  801e00:	89 c8                	mov    %ecx,%eax
  801e02:	89 f2                	mov    %esi,%edx
  801e04:	83 c4 1c             	add    $0x1c,%esp
  801e07:	5b                   	pop    %ebx
  801e08:	5e                   	pop    %esi
  801e09:	5f                   	pop    %edi
  801e0a:	5d                   	pop    %ebp
  801e0b:	c3                   	ret    
  801e0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e10:	8b 34 24             	mov    (%esp),%esi
  801e13:	bf 20 00 00 00       	mov    $0x20,%edi
  801e18:	89 e9                	mov    %ebp,%ecx
  801e1a:	29 ef                	sub    %ebp,%edi
  801e1c:	d3 e0                	shl    %cl,%eax
  801e1e:	89 f9                	mov    %edi,%ecx
  801e20:	89 f2                	mov    %esi,%edx
  801e22:	d3 ea                	shr    %cl,%edx
  801e24:	89 e9                	mov    %ebp,%ecx
  801e26:	09 c2                	or     %eax,%edx
  801e28:	89 d8                	mov    %ebx,%eax
  801e2a:	89 14 24             	mov    %edx,(%esp)
  801e2d:	89 f2                	mov    %esi,%edx
  801e2f:	d3 e2                	shl    %cl,%edx
  801e31:	89 f9                	mov    %edi,%ecx
  801e33:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e37:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e3b:	d3 e8                	shr    %cl,%eax
  801e3d:	89 e9                	mov    %ebp,%ecx
  801e3f:	89 c6                	mov    %eax,%esi
  801e41:	d3 e3                	shl    %cl,%ebx
  801e43:	89 f9                	mov    %edi,%ecx
  801e45:	89 d0                	mov    %edx,%eax
  801e47:	d3 e8                	shr    %cl,%eax
  801e49:	89 e9                	mov    %ebp,%ecx
  801e4b:	09 d8                	or     %ebx,%eax
  801e4d:	89 d3                	mov    %edx,%ebx
  801e4f:	89 f2                	mov    %esi,%edx
  801e51:	f7 34 24             	divl   (%esp)
  801e54:	89 d6                	mov    %edx,%esi
  801e56:	d3 e3                	shl    %cl,%ebx
  801e58:	f7 64 24 04          	mull   0x4(%esp)
  801e5c:	39 d6                	cmp    %edx,%esi
  801e5e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e62:	89 d1                	mov    %edx,%ecx
  801e64:	89 c3                	mov    %eax,%ebx
  801e66:	72 08                	jb     801e70 <__umoddi3+0x110>
  801e68:	75 11                	jne    801e7b <__umoddi3+0x11b>
  801e6a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e6e:	73 0b                	jae    801e7b <__umoddi3+0x11b>
  801e70:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e74:	1b 14 24             	sbb    (%esp),%edx
  801e77:	89 d1                	mov    %edx,%ecx
  801e79:	89 c3                	mov    %eax,%ebx
  801e7b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e7f:	29 da                	sub    %ebx,%edx
  801e81:	19 ce                	sbb    %ecx,%esi
  801e83:	89 f9                	mov    %edi,%ecx
  801e85:	89 f0                	mov    %esi,%eax
  801e87:	d3 e0                	shl    %cl,%eax
  801e89:	89 e9                	mov    %ebp,%ecx
  801e8b:	d3 ea                	shr    %cl,%edx
  801e8d:	89 e9                	mov    %ebp,%ecx
  801e8f:	d3 ee                	shr    %cl,%esi
  801e91:	09 d0                	or     %edx,%eax
  801e93:	89 f2                	mov    %esi,%edx
  801e95:	83 c4 1c             	add    $0x1c,%esp
  801e98:	5b                   	pop    %ebx
  801e99:	5e                   	pop    %esi
  801e9a:	5f                   	pop    %edi
  801e9b:	5d                   	pop    %ebp
  801e9c:	c3                   	ret    
  801e9d:	8d 76 00             	lea    0x0(%esi),%esi
  801ea0:	29 f9                	sub    %edi,%ecx
  801ea2:	19 d6                	sbb    %edx,%esi
  801ea4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ea8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801eac:	e9 18 ff ff ff       	jmp    801dc9 <__umoddi3+0x69>
