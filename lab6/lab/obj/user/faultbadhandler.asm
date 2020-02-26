
obj/user/faultbadhandler.debug：     文件格式 elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 3a 01 00 00       	call   800181 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 ef be ad de       	push   $0xdeadbeef
  80004f:	6a 00                	push   $0x0
  800051:	e8 76 02 00 00       	call   8002cc <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800070:	e8 ce 00 00 00       	call   800143 <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 08 40 80 00       	mov    %eax,0x804008

    // save the name of the program so that panic() can use it
    if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x2d>
        binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  800092:	83 ec 08             	sub    $0x8,%esp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	e8 97 ff ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  80009c:	e8 0a 00 00 00       	call   8000ab <exit>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b1:	e8 c6 04 00 00       	call   80057c <close_all>
	sys_env_destroy(0);
  8000b6:	83 ec 0c             	sub    $0xc,%esp
  8000b9:	6a 00                	push   $0x0
  8000bb:	e8 42 00 00 00       	call   800102 <sys_env_destroy>
}
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d6:	89 c3                	mov    %eax,%ebx
  8000d8:	89 c7                	mov    %eax,%edi
  8000da:	89 c6                	mov    %eax,%esi
  8000dc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f3:	89 d1                	mov    %edx,%ecx
  8000f5:	89 d3                	mov    %edx,%ebx
  8000f7:	89 d7                	mov    %edx,%edi
  8000f9:	89 d6                	mov    %edx,%esi
  8000fb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5f                   	pop    %edi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	57                   	push   %edi
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800110:	b8 03 00 00 00       	mov    $0x3,%eax
  800115:	8b 55 08             	mov    0x8(%ebp),%edx
  800118:	89 cb                	mov    %ecx,%ebx
  80011a:	89 cf                	mov    %ecx,%edi
  80011c:	89 ce                	mov    %ecx,%esi
  80011e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800120:	85 c0                	test   %eax,%eax
  800122:	7e 17                	jle    80013b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800124:	83 ec 0c             	sub    $0xc,%esp
  800127:	50                   	push   %eax
  800128:	6a 03                	push   $0x3
  80012a:	68 0a 23 80 00       	push   $0x80230a
  80012f:	6a 23                	push   $0x23
  800131:	68 27 23 80 00       	push   $0x802327
  800136:	e8 c7 13 00 00       	call   801502 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 d3                	mov    %edx,%ebx
  800176:	89 d7                	mov    %edx,%edi
  800178:	89 d6                	mov    %edx,%esi
  80017a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018a:	be 00 00 00 00       	mov    $0x0,%esi
  80018f:	b8 04 00 00 00       	mov    $0x4,%eax
  800194:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800197:	8b 55 08             	mov    0x8(%ebp),%edx
  80019a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019d:	89 f7                	mov    %esi,%edi
  80019f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	7e 17                	jle    8001bc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a5:	83 ec 0c             	sub    $0xc,%esp
  8001a8:	50                   	push   %eax
  8001a9:	6a 04                	push   $0x4
  8001ab:	68 0a 23 80 00       	push   $0x80230a
  8001b0:	6a 23                	push   $0x23
  8001b2:	68 27 23 80 00       	push   $0x802327
  8001b7:	e8 46 13 00 00       	call   801502 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bf:	5b                   	pop    %ebx
  8001c0:	5e                   	pop    %esi
  8001c1:	5f                   	pop    %edi
  8001c2:	5d                   	pop    %ebp
  8001c3:	c3                   	ret    

008001c4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001db:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001de:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001e3:	85 c0                	test   %eax,%eax
  8001e5:	7e 17                	jle    8001fe <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	50                   	push   %eax
  8001eb:	6a 05                	push   $0x5
  8001ed:	68 0a 23 80 00       	push   $0x80230a
  8001f2:	6a 23                	push   $0x23
  8001f4:	68 27 23 80 00       	push   $0x802327
  8001f9:	e8 04 13 00 00       	call   801502 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5f                   	pop    %edi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    

00800206 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	57                   	push   %edi
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80020f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800214:	b8 06 00 00 00       	mov    $0x6,%eax
  800219:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021c:	8b 55 08             	mov    0x8(%ebp),%edx
  80021f:	89 df                	mov    %ebx,%edi
  800221:	89 de                	mov    %ebx,%esi
  800223:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800225:	85 c0                	test   %eax,%eax
  800227:	7e 17                	jle    800240 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800229:	83 ec 0c             	sub    $0xc,%esp
  80022c:	50                   	push   %eax
  80022d:	6a 06                	push   $0x6
  80022f:	68 0a 23 80 00       	push   $0x80230a
  800234:	6a 23                	push   $0x23
  800236:	68 27 23 80 00       	push   $0x802327
  80023b:	e8 c2 12 00 00       	call   801502 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5f                   	pop    %edi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800251:	bb 00 00 00 00       	mov    $0x0,%ebx
  800256:	b8 08 00 00 00       	mov    $0x8,%eax
  80025b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025e:	8b 55 08             	mov    0x8(%ebp),%edx
  800261:	89 df                	mov    %ebx,%edi
  800263:	89 de                	mov    %ebx,%esi
  800265:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800267:	85 c0                	test   %eax,%eax
  800269:	7e 17                	jle    800282 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80026b:	83 ec 0c             	sub    $0xc,%esp
  80026e:	50                   	push   %eax
  80026f:	6a 08                	push   $0x8
  800271:	68 0a 23 80 00       	push   $0x80230a
  800276:	6a 23                	push   $0x23
  800278:	68 27 23 80 00       	push   $0x802327
  80027d:	e8 80 12 00 00       	call   801502 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800282:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800285:	5b                   	pop    %ebx
  800286:	5e                   	pop    %esi
  800287:	5f                   	pop    %edi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800293:	bb 00 00 00 00       	mov    $0x0,%ebx
  800298:	b8 09 00 00 00       	mov    $0x9,%eax
  80029d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a3:	89 df                	mov    %ebx,%edi
  8002a5:	89 de                	mov    %ebx,%esi
  8002a7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002a9:	85 c0                	test   %eax,%eax
  8002ab:	7e 17                	jle    8002c4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	50                   	push   %eax
  8002b1:	6a 09                	push   $0x9
  8002b3:	68 0a 23 80 00       	push   $0x80230a
  8002b8:	6a 23                	push   $0x23
  8002ba:	68 27 23 80 00       	push   $0x802327
  8002bf:	e8 3e 12 00 00       	call   801502 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e5:	89 df                	mov    %ebx,%edi
  8002e7:	89 de                	mov    %ebx,%esi
  8002e9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	7e 17                	jle    800306 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ef:	83 ec 0c             	sub    $0xc,%esp
  8002f2:	50                   	push   %eax
  8002f3:	6a 0a                	push   $0xa
  8002f5:	68 0a 23 80 00       	push   $0x80230a
  8002fa:	6a 23                	push   $0x23
  8002fc:	68 27 23 80 00       	push   $0x802327
  800301:	e8 fc 11 00 00       	call   801502 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800306:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800314:	be 00 00 00 00       	mov    $0x0,%esi
  800319:	b8 0c 00 00 00       	mov    $0xc,%eax
  80031e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800327:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800344:	8b 55 08             	mov    0x8(%ebp),%edx
  800347:	89 cb                	mov    %ecx,%ebx
  800349:	89 cf                	mov    %ecx,%edi
  80034b:	89 ce                	mov    %ecx,%esi
  80034d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80034f:	85 c0                	test   %eax,%eax
  800351:	7e 17                	jle    80036a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	50                   	push   %eax
  800357:	6a 0d                	push   $0xd
  800359:	68 0a 23 80 00       	push   $0x80230a
  80035e:	6a 23                	push   $0x23
  800360:	68 27 23 80 00       	push   $0x802327
  800365:	e8 98 11 00 00       	call   801502 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80036a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036d:	5b                   	pop    %ebx
  80036e:	5e                   	pop    %esi
  80036f:	5f                   	pop    %edi
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	57                   	push   %edi
  800376:	56                   	push   %esi
  800377:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800378:	ba 00 00 00 00       	mov    $0x0,%edx
  80037d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800382:	89 d1                	mov    %edx,%ecx
  800384:	89 d3                	mov    %edx,%ebx
  800386:	89 d7                	mov    %edx,%edi
  800388:	89 d6                	mov    %edx,%esi
  80038a:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80038c:	5b                   	pop    %ebx
  80038d:	5e                   	pop    %esi
  80038e:	5f                   	pop    %edi
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	57                   	push   %edi
  800395:	56                   	push   %esi
  800396:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800397:	b9 00 00 00 00       	mov    $0x0,%ecx
  80039c:	b8 10 00 00 00       	mov    $0x10,%eax
  8003a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a4:	89 cb                	mov    %ecx,%ebx
  8003a6:	89 cf                	mov    %ecx,%edi
  8003a8:	89 ce                	mov    %ecx,%esi
  8003aa:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  8003ac:	5b                   	pop    %ebx
  8003ad:	5e                   	pop    %esi
  8003ae:	5f                   	pop    %edi
  8003af:	5d                   	pop    %ebp
  8003b0:	c3                   	ret    

008003b1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003b1:	55                   	push   %ebp
  8003b2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b7:	05 00 00 00 30       	add    $0x30000000,%eax
  8003bc:	c1 e8 0c             	shr    $0xc,%eax
}
  8003bf:	5d                   	pop    %ebp
  8003c0:	c3                   	ret    

008003c1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003c1:	55                   	push   %ebp
  8003c2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c7:	05 00 00 00 30       	add    $0x30000000,%eax
  8003cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003d1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003d6:	5d                   	pop    %ebp
  8003d7:	c3                   	ret    

008003d8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003de:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003e3:	89 c2                	mov    %eax,%edx
  8003e5:	c1 ea 16             	shr    $0x16,%edx
  8003e8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ef:	f6 c2 01             	test   $0x1,%dl
  8003f2:	74 11                	je     800405 <fd_alloc+0x2d>
  8003f4:	89 c2                	mov    %eax,%edx
  8003f6:	c1 ea 0c             	shr    $0xc,%edx
  8003f9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800400:	f6 c2 01             	test   $0x1,%dl
  800403:	75 09                	jne    80040e <fd_alloc+0x36>
			*fd_store = fd;
  800405:	89 01                	mov    %eax,(%ecx)
			return 0;
  800407:	b8 00 00 00 00       	mov    $0x0,%eax
  80040c:	eb 17                	jmp    800425 <fd_alloc+0x4d>
  80040e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800413:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800418:	75 c9                	jne    8003e3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80041a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800420:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800425:	5d                   	pop    %ebp
  800426:	c3                   	ret    

00800427 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80042d:	83 f8 1f             	cmp    $0x1f,%eax
  800430:	77 36                	ja     800468 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800432:	c1 e0 0c             	shl    $0xc,%eax
  800435:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80043a:	89 c2                	mov    %eax,%edx
  80043c:	c1 ea 16             	shr    $0x16,%edx
  80043f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800446:	f6 c2 01             	test   $0x1,%dl
  800449:	74 24                	je     80046f <fd_lookup+0x48>
  80044b:	89 c2                	mov    %eax,%edx
  80044d:	c1 ea 0c             	shr    $0xc,%edx
  800450:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800457:	f6 c2 01             	test   $0x1,%dl
  80045a:	74 1a                	je     800476 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80045c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80045f:	89 02                	mov    %eax,(%edx)
	return 0;
  800461:	b8 00 00 00 00       	mov    $0x0,%eax
  800466:	eb 13                	jmp    80047b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800468:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80046d:	eb 0c                	jmp    80047b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80046f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800474:	eb 05                	jmp    80047b <fd_lookup+0x54>
  800476:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80047b:	5d                   	pop    %ebp
  80047c:	c3                   	ret    

0080047d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80047d:	55                   	push   %ebp
  80047e:	89 e5                	mov    %esp,%ebp
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800486:	ba b4 23 80 00       	mov    $0x8023b4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80048b:	eb 13                	jmp    8004a0 <dev_lookup+0x23>
  80048d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800490:	39 08                	cmp    %ecx,(%eax)
  800492:	75 0c                	jne    8004a0 <dev_lookup+0x23>
			*dev = devtab[i];
  800494:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800497:	89 01                	mov    %eax,(%ecx)
			return 0;
  800499:	b8 00 00 00 00       	mov    $0x0,%eax
  80049e:	eb 2e                	jmp    8004ce <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8004a0:	8b 02                	mov    (%edx),%eax
  8004a2:	85 c0                	test   %eax,%eax
  8004a4:	75 e7                	jne    80048d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004a6:	a1 08 40 80 00       	mov    0x804008,%eax
  8004ab:	8b 40 48             	mov    0x48(%eax),%eax
  8004ae:	83 ec 04             	sub    $0x4,%esp
  8004b1:	51                   	push   %ecx
  8004b2:	50                   	push   %eax
  8004b3:	68 38 23 80 00       	push   $0x802338
  8004b8:	e8 1e 11 00 00       	call   8015db <cprintf>
	*dev = 0;
  8004bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004c6:	83 c4 10             	add    $0x10,%esp
  8004c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004ce:	c9                   	leave  
  8004cf:	c3                   	ret    

008004d0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	56                   	push   %esi
  8004d4:	53                   	push   %ebx
  8004d5:	83 ec 10             	sub    $0x10,%esp
  8004d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004e1:	50                   	push   %eax
  8004e2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004e8:	c1 e8 0c             	shr    $0xc,%eax
  8004eb:	50                   	push   %eax
  8004ec:	e8 36 ff ff ff       	call   800427 <fd_lookup>
  8004f1:	83 c4 08             	add    $0x8,%esp
  8004f4:	85 c0                	test   %eax,%eax
  8004f6:	78 05                	js     8004fd <fd_close+0x2d>
	    || fd != fd2)
  8004f8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004fb:	74 0c                	je     800509 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004fd:	84 db                	test   %bl,%bl
  8004ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800504:	0f 44 c2             	cmove  %edx,%eax
  800507:	eb 41                	jmp    80054a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800509:	83 ec 08             	sub    $0x8,%esp
  80050c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80050f:	50                   	push   %eax
  800510:	ff 36                	pushl  (%esi)
  800512:	e8 66 ff ff ff       	call   80047d <dev_lookup>
  800517:	89 c3                	mov    %eax,%ebx
  800519:	83 c4 10             	add    $0x10,%esp
  80051c:	85 c0                	test   %eax,%eax
  80051e:	78 1a                	js     80053a <fd_close+0x6a>
		if (dev->dev_close)
  800520:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800523:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800526:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80052b:	85 c0                	test   %eax,%eax
  80052d:	74 0b                	je     80053a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80052f:	83 ec 0c             	sub    $0xc,%esp
  800532:	56                   	push   %esi
  800533:	ff d0                	call   *%eax
  800535:	89 c3                	mov    %eax,%ebx
  800537:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	56                   	push   %esi
  80053e:	6a 00                	push   $0x0
  800540:	e8 c1 fc ff ff       	call   800206 <sys_page_unmap>
	return r;
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	89 d8                	mov    %ebx,%eax
}
  80054a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80054d:	5b                   	pop    %ebx
  80054e:	5e                   	pop    %esi
  80054f:	5d                   	pop    %ebp
  800550:	c3                   	ret    

00800551 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800551:	55                   	push   %ebp
  800552:	89 e5                	mov    %esp,%ebp
  800554:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800557:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80055a:	50                   	push   %eax
  80055b:	ff 75 08             	pushl  0x8(%ebp)
  80055e:	e8 c4 fe ff ff       	call   800427 <fd_lookup>
  800563:	83 c4 08             	add    $0x8,%esp
  800566:	85 c0                	test   %eax,%eax
  800568:	78 10                	js     80057a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80056a:	83 ec 08             	sub    $0x8,%esp
  80056d:	6a 01                	push   $0x1
  80056f:	ff 75 f4             	pushl  -0xc(%ebp)
  800572:	e8 59 ff ff ff       	call   8004d0 <fd_close>
  800577:	83 c4 10             	add    $0x10,%esp
}
  80057a:	c9                   	leave  
  80057b:	c3                   	ret    

0080057c <close_all>:

void
close_all(void)
{
  80057c:	55                   	push   %ebp
  80057d:	89 e5                	mov    %esp,%ebp
  80057f:	53                   	push   %ebx
  800580:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800583:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800588:	83 ec 0c             	sub    $0xc,%esp
  80058b:	53                   	push   %ebx
  80058c:	e8 c0 ff ff ff       	call   800551 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800591:	83 c3 01             	add    $0x1,%ebx
  800594:	83 c4 10             	add    $0x10,%esp
  800597:	83 fb 20             	cmp    $0x20,%ebx
  80059a:	75 ec                	jne    800588 <close_all+0xc>
		close(i);
}
  80059c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80059f:	c9                   	leave  
  8005a0:	c3                   	ret    

008005a1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005a1:	55                   	push   %ebp
  8005a2:	89 e5                	mov    %esp,%ebp
  8005a4:	57                   	push   %edi
  8005a5:	56                   	push   %esi
  8005a6:	53                   	push   %ebx
  8005a7:	83 ec 2c             	sub    $0x2c,%esp
  8005aa:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005ad:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005b0:	50                   	push   %eax
  8005b1:	ff 75 08             	pushl  0x8(%ebp)
  8005b4:	e8 6e fe ff ff       	call   800427 <fd_lookup>
  8005b9:	83 c4 08             	add    $0x8,%esp
  8005bc:	85 c0                	test   %eax,%eax
  8005be:	0f 88 c1 00 00 00    	js     800685 <dup+0xe4>
		return r;
	close(newfdnum);
  8005c4:	83 ec 0c             	sub    $0xc,%esp
  8005c7:	56                   	push   %esi
  8005c8:	e8 84 ff ff ff       	call   800551 <close>

	newfd = INDEX2FD(newfdnum);
  8005cd:	89 f3                	mov    %esi,%ebx
  8005cf:	c1 e3 0c             	shl    $0xc,%ebx
  8005d2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005d8:	83 c4 04             	add    $0x4,%esp
  8005db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005de:	e8 de fd ff ff       	call   8003c1 <fd2data>
  8005e3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005e5:	89 1c 24             	mov    %ebx,(%esp)
  8005e8:	e8 d4 fd ff ff       	call   8003c1 <fd2data>
  8005ed:	83 c4 10             	add    $0x10,%esp
  8005f0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005f3:	89 f8                	mov    %edi,%eax
  8005f5:	c1 e8 16             	shr    $0x16,%eax
  8005f8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005ff:	a8 01                	test   $0x1,%al
  800601:	74 37                	je     80063a <dup+0x99>
  800603:	89 f8                	mov    %edi,%eax
  800605:	c1 e8 0c             	shr    $0xc,%eax
  800608:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80060f:	f6 c2 01             	test   $0x1,%dl
  800612:	74 26                	je     80063a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800614:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80061b:	83 ec 0c             	sub    $0xc,%esp
  80061e:	25 07 0e 00 00       	and    $0xe07,%eax
  800623:	50                   	push   %eax
  800624:	ff 75 d4             	pushl  -0x2c(%ebp)
  800627:	6a 00                	push   $0x0
  800629:	57                   	push   %edi
  80062a:	6a 00                	push   $0x0
  80062c:	e8 93 fb ff ff       	call   8001c4 <sys_page_map>
  800631:	89 c7                	mov    %eax,%edi
  800633:	83 c4 20             	add    $0x20,%esp
  800636:	85 c0                	test   %eax,%eax
  800638:	78 2e                	js     800668 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80063a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80063d:	89 d0                	mov    %edx,%eax
  80063f:	c1 e8 0c             	shr    $0xc,%eax
  800642:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800649:	83 ec 0c             	sub    $0xc,%esp
  80064c:	25 07 0e 00 00       	and    $0xe07,%eax
  800651:	50                   	push   %eax
  800652:	53                   	push   %ebx
  800653:	6a 00                	push   $0x0
  800655:	52                   	push   %edx
  800656:	6a 00                	push   $0x0
  800658:	e8 67 fb ff ff       	call   8001c4 <sys_page_map>
  80065d:	89 c7                	mov    %eax,%edi
  80065f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800662:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800664:	85 ff                	test   %edi,%edi
  800666:	79 1d                	jns    800685 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800668:	83 ec 08             	sub    $0x8,%esp
  80066b:	53                   	push   %ebx
  80066c:	6a 00                	push   $0x0
  80066e:	e8 93 fb ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800673:	83 c4 08             	add    $0x8,%esp
  800676:	ff 75 d4             	pushl  -0x2c(%ebp)
  800679:	6a 00                	push   $0x0
  80067b:	e8 86 fb ff ff       	call   800206 <sys_page_unmap>
	return r;
  800680:	83 c4 10             	add    $0x10,%esp
  800683:	89 f8                	mov    %edi,%eax
}
  800685:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800688:	5b                   	pop    %ebx
  800689:	5e                   	pop    %esi
  80068a:	5f                   	pop    %edi
  80068b:	5d                   	pop    %ebp
  80068c:	c3                   	ret    

0080068d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80068d:	55                   	push   %ebp
  80068e:	89 e5                	mov    %esp,%ebp
  800690:	53                   	push   %ebx
  800691:	83 ec 14             	sub    $0x14,%esp
  800694:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800697:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80069a:	50                   	push   %eax
  80069b:	53                   	push   %ebx
  80069c:	e8 86 fd ff ff       	call   800427 <fd_lookup>
  8006a1:	83 c4 08             	add    $0x8,%esp
  8006a4:	89 c2                	mov    %eax,%edx
  8006a6:	85 c0                	test   %eax,%eax
  8006a8:	78 6d                	js     800717 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006aa:	83 ec 08             	sub    $0x8,%esp
  8006ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006b0:	50                   	push   %eax
  8006b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006b4:	ff 30                	pushl  (%eax)
  8006b6:	e8 c2 fd ff ff       	call   80047d <dev_lookup>
  8006bb:	83 c4 10             	add    $0x10,%esp
  8006be:	85 c0                	test   %eax,%eax
  8006c0:	78 4c                	js     80070e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006c2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006c5:	8b 42 08             	mov    0x8(%edx),%eax
  8006c8:	83 e0 03             	and    $0x3,%eax
  8006cb:	83 f8 01             	cmp    $0x1,%eax
  8006ce:	75 21                	jne    8006f1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006d0:	a1 08 40 80 00       	mov    0x804008,%eax
  8006d5:	8b 40 48             	mov    0x48(%eax),%eax
  8006d8:	83 ec 04             	sub    $0x4,%esp
  8006db:	53                   	push   %ebx
  8006dc:	50                   	push   %eax
  8006dd:	68 79 23 80 00       	push   $0x802379
  8006e2:	e8 f4 0e 00 00       	call   8015db <cprintf>
		return -E_INVAL;
  8006e7:	83 c4 10             	add    $0x10,%esp
  8006ea:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006ef:	eb 26                	jmp    800717 <read+0x8a>
	}
	if (!dev->dev_read)
  8006f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f4:	8b 40 08             	mov    0x8(%eax),%eax
  8006f7:	85 c0                	test   %eax,%eax
  8006f9:	74 17                	je     800712 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006fb:	83 ec 04             	sub    $0x4,%esp
  8006fe:	ff 75 10             	pushl  0x10(%ebp)
  800701:	ff 75 0c             	pushl  0xc(%ebp)
  800704:	52                   	push   %edx
  800705:	ff d0                	call   *%eax
  800707:	89 c2                	mov    %eax,%edx
  800709:	83 c4 10             	add    $0x10,%esp
  80070c:	eb 09                	jmp    800717 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80070e:	89 c2                	mov    %eax,%edx
  800710:	eb 05                	jmp    800717 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800712:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800717:	89 d0                	mov    %edx,%eax
  800719:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80071c:	c9                   	leave  
  80071d:	c3                   	ret    

0080071e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
  800721:	57                   	push   %edi
  800722:	56                   	push   %esi
  800723:	53                   	push   %ebx
  800724:	83 ec 0c             	sub    $0xc,%esp
  800727:	8b 7d 08             	mov    0x8(%ebp),%edi
  80072a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80072d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800732:	eb 21                	jmp    800755 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800734:	83 ec 04             	sub    $0x4,%esp
  800737:	89 f0                	mov    %esi,%eax
  800739:	29 d8                	sub    %ebx,%eax
  80073b:	50                   	push   %eax
  80073c:	89 d8                	mov    %ebx,%eax
  80073e:	03 45 0c             	add    0xc(%ebp),%eax
  800741:	50                   	push   %eax
  800742:	57                   	push   %edi
  800743:	e8 45 ff ff ff       	call   80068d <read>
		if (m < 0)
  800748:	83 c4 10             	add    $0x10,%esp
  80074b:	85 c0                	test   %eax,%eax
  80074d:	78 10                	js     80075f <readn+0x41>
			return m;
		if (m == 0)
  80074f:	85 c0                	test   %eax,%eax
  800751:	74 0a                	je     80075d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800753:	01 c3                	add    %eax,%ebx
  800755:	39 f3                	cmp    %esi,%ebx
  800757:	72 db                	jb     800734 <readn+0x16>
  800759:	89 d8                	mov    %ebx,%eax
  80075b:	eb 02                	jmp    80075f <readn+0x41>
  80075d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80075f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800762:	5b                   	pop    %ebx
  800763:	5e                   	pop    %esi
  800764:	5f                   	pop    %edi
  800765:	5d                   	pop    %ebp
  800766:	c3                   	ret    

00800767 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800767:	55                   	push   %ebp
  800768:	89 e5                	mov    %esp,%ebp
  80076a:	53                   	push   %ebx
  80076b:	83 ec 14             	sub    $0x14,%esp
  80076e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800771:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800774:	50                   	push   %eax
  800775:	53                   	push   %ebx
  800776:	e8 ac fc ff ff       	call   800427 <fd_lookup>
  80077b:	83 c4 08             	add    $0x8,%esp
  80077e:	89 c2                	mov    %eax,%edx
  800780:	85 c0                	test   %eax,%eax
  800782:	78 68                	js     8007ec <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800784:	83 ec 08             	sub    $0x8,%esp
  800787:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80078a:	50                   	push   %eax
  80078b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80078e:	ff 30                	pushl  (%eax)
  800790:	e8 e8 fc ff ff       	call   80047d <dev_lookup>
  800795:	83 c4 10             	add    $0x10,%esp
  800798:	85 c0                	test   %eax,%eax
  80079a:	78 47                	js     8007e3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80079c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80079f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007a3:	75 21                	jne    8007c6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007a5:	a1 08 40 80 00       	mov    0x804008,%eax
  8007aa:	8b 40 48             	mov    0x48(%eax),%eax
  8007ad:	83 ec 04             	sub    $0x4,%esp
  8007b0:	53                   	push   %ebx
  8007b1:	50                   	push   %eax
  8007b2:	68 95 23 80 00       	push   $0x802395
  8007b7:	e8 1f 0e 00 00       	call   8015db <cprintf>
		return -E_INVAL;
  8007bc:	83 c4 10             	add    $0x10,%esp
  8007bf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007c4:	eb 26                	jmp    8007ec <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007c9:	8b 52 0c             	mov    0xc(%edx),%edx
  8007cc:	85 d2                	test   %edx,%edx
  8007ce:	74 17                	je     8007e7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007d0:	83 ec 04             	sub    $0x4,%esp
  8007d3:	ff 75 10             	pushl  0x10(%ebp)
  8007d6:	ff 75 0c             	pushl  0xc(%ebp)
  8007d9:	50                   	push   %eax
  8007da:	ff d2                	call   *%edx
  8007dc:	89 c2                	mov    %eax,%edx
  8007de:	83 c4 10             	add    $0x10,%esp
  8007e1:	eb 09                	jmp    8007ec <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007e3:	89 c2                	mov    %eax,%edx
  8007e5:	eb 05                	jmp    8007ec <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007e7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007ec:	89 d0                	mov    %edx,%eax
  8007ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f1:	c9                   	leave  
  8007f2:	c3                   	ret    

008007f3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007f3:	55                   	push   %ebp
  8007f4:	89 e5                	mov    %esp,%ebp
  8007f6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007f9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007fc:	50                   	push   %eax
  8007fd:	ff 75 08             	pushl  0x8(%ebp)
  800800:	e8 22 fc ff ff       	call   800427 <fd_lookup>
  800805:	83 c4 08             	add    $0x8,%esp
  800808:	85 c0                	test   %eax,%eax
  80080a:	78 0e                	js     80081a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80080c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80080f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800812:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800815:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80081a:	c9                   	leave  
  80081b:	c3                   	ret    

0080081c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	53                   	push   %ebx
  800820:	83 ec 14             	sub    $0x14,%esp
  800823:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800826:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800829:	50                   	push   %eax
  80082a:	53                   	push   %ebx
  80082b:	e8 f7 fb ff ff       	call   800427 <fd_lookup>
  800830:	83 c4 08             	add    $0x8,%esp
  800833:	89 c2                	mov    %eax,%edx
  800835:	85 c0                	test   %eax,%eax
  800837:	78 65                	js     80089e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800839:	83 ec 08             	sub    $0x8,%esp
  80083c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80083f:	50                   	push   %eax
  800840:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800843:	ff 30                	pushl  (%eax)
  800845:	e8 33 fc ff ff       	call   80047d <dev_lookup>
  80084a:	83 c4 10             	add    $0x10,%esp
  80084d:	85 c0                	test   %eax,%eax
  80084f:	78 44                	js     800895 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800851:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800854:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800858:	75 21                	jne    80087b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80085a:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80085f:	8b 40 48             	mov    0x48(%eax),%eax
  800862:	83 ec 04             	sub    $0x4,%esp
  800865:	53                   	push   %ebx
  800866:	50                   	push   %eax
  800867:	68 58 23 80 00       	push   $0x802358
  80086c:	e8 6a 0d 00 00       	call   8015db <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800871:	83 c4 10             	add    $0x10,%esp
  800874:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800879:	eb 23                	jmp    80089e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80087b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80087e:	8b 52 18             	mov    0x18(%edx),%edx
  800881:	85 d2                	test   %edx,%edx
  800883:	74 14                	je     800899 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800885:	83 ec 08             	sub    $0x8,%esp
  800888:	ff 75 0c             	pushl  0xc(%ebp)
  80088b:	50                   	push   %eax
  80088c:	ff d2                	call   *%edx
  80088e:	89 c2                	mov    %eax,%edx
  800890:	83 c4 10             	add    $0x10,%esp
  800893:	eb 09                	jmp    80089e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800895:	89 c2                	mov    %eax,%edx
  800897:	eb 05                	jmp    80089e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800899:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80089e:	89 d0                	mov    %edx,%eax
  8008a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008a3:	c9                   	leave  
  8008a4:	c3                   	ret    

008008a5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	53                   	push   %ebx
  8008a9:	83 ec 14             	sub    $0x14,%esp
  8008ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008b2:	50                   	push   %eax
  8008b3:	ff 75 08             	pushl  0x8(%ebp)
  8008b6:	e8 6c fb ff ff       	call   800427 <fd_lookup>
  8008bb:	83 c4 08             	add    $0x8,%esp
  8008be:	89 c2                	mov    %eax,%edx
  8008c0:	85 c0                	test   %eax,%eax
  8008c2:	78 58                	js     80091c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008c4:	83 ec 08             	sub    $0x8,%esp
  8008c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008ca:	50                   	push   %eax
  8008cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008ce:	ff 30                	pushl  (%eax)
  8008d0:	e8 a8 fb ff ff       	call   80047d <dev_lookup>
  8008d5:	83 c4 10             	add    $0x10,%esp
  8008d8:	85 c0                	test   %eax,%eax
  8008da:	78 37                	js     800913 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008df:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008e3:	74 32                	je     800917 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008e5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008e8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008ef:	00 00 00 
	stat->st_isdir = 0;
  8008f2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008f9:	00 00 00 
	stat->st_dev = dev;
  8008fc:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800902:	83 ec 08             	sub    $0x8,%esp
  800905:	53                   	push   %ebx
  800906:	ff 75 f0             	pushl  -0x10(%ebp)
  800909:	ff 50 14             	call   *0x14(%eax)
  80090c:	89 c2                	mov    %eax,%edx
  80090e:	83 c4 10             	add    $0x10,%esp
  800911:	eb 09                	jmp    80091c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800913:	89 c2                	mov    %eax,%edx
  800915:	eb 05                	jmp    80091c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800917:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80091c:	89 d0                	mov    %edx,%eax
  80091e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800921:	c9                   	leave  
  800922:	c3                   	ret    

00800923 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	56                   	push   %esi
  800927:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800928:	83 ec 08             	sub    $0x8,%esp
  80092b:	6a 00                	push   $0x0
  80092d:	ff 75 08             	pushl  0x8(%ebp)
  800930:	e8 e3 01 00 00       	call   800b18 <open>
  800935:	89 c3                	mov    %eax,%ebx
  800937:	83 c4 10             	add    $0x10,%esp
  80093a:	85 c0                	test   %eax,%eax
  80093c:	78 1b                	js     800959 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80093e:	83 ec 08             	sub    $0x8,%esp
  800941:	ff 75 0c             	pushl  0xc(%ebp)
  800944:	50                   	push   %eax
  800945:	e8 5b ff ff ff       	call   8008a5 <fstat>
  80094a:	89 c6                	mov    %eax,%esi
	close(fd);
  80094c:	89 1c 24             	mov    %ebx,(%esp)
  80094f:	e8 fd fb ff ff       	call   800551 <close>
	return r;
  800954:	83 c4 10             	add    $0x10,%esp
  800957:	89 f0                	mov    %esi,%eax
}
  800959:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80095c:	5b                   	pop    %ebx
  80095d:	5e                   	pop    %esi
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	56                   	push   %esi
  800964:	53                   	push   %ebx
  800965:	89 c6                	mov    %eax,%esi
  800967:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800969:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800970:	75 12                	jne    800984 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800972:	83 ec 0c             	sub    $0xc,%esp
  800975:	6a 01                	push   $0x1
  800977:	e8 67 16 00 00       	call   801fe3 <ipc_find_env>
  80097c:	a3 00 40 80 00       	mov    %eax,0x804000
  800981:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800984:	6a 07                	push   $0x7
  800986:	68 00 50 80 00       	push   $0x805000
  80098b:	56                   	push   %esi
  80098c:	ff 35 00 40 80 00    	pushl  0x804000
  800992:	e8 f8 15 00 00       	call   801f8f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800997:	83 c4 0c             	add    $0xc,%esp
  80099a:	6a 00                	push   $0x0
  80099c:	53                   	push   %ebx
  80099d:	6a 00                	push   $0x0
  80099f:	e8 82 15 00 00       	call   801f26 <ipc_recv>
}
  8009a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009a7:	5b                   	pop    %ebx
  8009a8:	5e                   	pop    %esi
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bf:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c9:	b8 02 00 00 00       	mov    $0x2,%eax
  8009ce:	e8 8d ff ff ff       	call   800960 <fsipc>
}
  8009d3:	c9                   	leave  
  8009d4:	c3                   	ret    

008009d5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009db:	8b 45 08             	mov    0x8(%ebp),%eax
  8009de:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009eb:	b8 06 00 00 00       	mov    $0x6,%eax
  8009f0:	e8 6b ff ff ff       	call   800960 <fsipc>
}
  8009f5:	c9                   	leave  
  8009f6:	c3                   	ret    

008009f7 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	53                   	push   %ebx
  8009fb:	83 ec 04             	sub    $0x4,%esp
  8009fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a01:	8b 45 08             	mov    0x8(%ebp),%eax
  800a04:	8b 40 0c             	mov    0xc(%eax),%eax
  800a07:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a0c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a11:	b8 05 00 00 00       	mov    $0x5,%eax
  800a16:	e8 45 ff ff ff       	call   800960 <fsipc>
  800a1b:	85 c0                	test   %eax,%eax
  800a1d:	78 2c                	js     800a4b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a1f:	83 ec 08             	sub    $0x8,%esp
  800a22:	68 00 50 80 00       	push   $0x805000
  800a27:	53                   	push   %ebx
  800a28:	e8 b2 11 00 00       	call   801bdf <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a2d:	a1 80 50 80 00       	mov    0x805080,%eax
  800a32:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a38:	a1 84 50 80 00       	mov    0x805084,%eax
  800a3d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a43:	83 c4 10             	add    $0x10,%esp
  800a46:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a4e:	c9                   	leave  
  800a4f:	c3                   	ret    

00800a50 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	83 ec 0c             	sub    $0xc,%esp
  800a56:	8b 45 10             	mov    0x10(%ebp),%eax
  800a59:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a5e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a63:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a66:	8b 55 08             	mov    0x8(%ebp),%edx
  800a69:	8b 52 0c             	mov    0xc(%edx),%edx
  800a6c:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a72:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a77:	50                   	push   %eax
  800a78:	ff 75 0c             	pushl  0xc(%ebp)
  800a7b:	68 08 50 80 00       	push   $0x805008
  800a80:	e8 ec 12 00 00       	call   801d71 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a85:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8a:	b8 04 00 00 00       	mov    $0x4,%eax
  800a8f:	e8 cc fe ff ff       	call   800960 <fsipc>
	//panic("devfile_write not implemented");
}
  800a94:	c9                   	leave  
  800a95:	c3                   	ret    

00800a96 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	56                   	push   %esi
  800a9a:	53                   	push   %ebx
  800a9b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	8b 40 0c             	mov    0xc(%eax),%eax
  800aa4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800aa9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800aaf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab4:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab9:	e8 a2 fe ff ff       	call   800960 <fsipc>
  800abe:	89 c3                	mov    %eax,%ebx
  800ac0:	85 c0                	test   %eax,%eax
  800ac2:	78 4b                	js     800b0f <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ac4:	39 c6                	cmp    %eax,%esi
  800ac6:	73 16                	jae    800ade <devfile_read+0x48>
  800ac8:	68 c8 23 80 00       	push   $0x8023c8
  800acd:	68 cf 23 80 00       	push   $0x8023cf
  800ad2:	6a 7c                	push   $0x7c
  800ad4:	68 e4 23 80 00       	push   $0x8023e4
  800ad9:	e8 24 0a 00 00       	call   801502 <_panic>
	assert(r <= PGSIZE);
  800ade:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ae3:	7e 16                	jle    800afb <devfile_read+0x65>
  800ae5:	68 ef 23 80 00       	push   $0x8023ef
  800aea:	68 cf 23 80 00       	push   $0x8023cf
  800aef:	6a 7d                	push   $0x7d
  800af1:	68 e4 23 80 00       	push   $0x8023e4
  800af6:	e8 07 0a 00 00       	call   801502 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800afb:	83 ec 04             	sub    $0x4,%esp
  800afe:	50                   	push   %eax
  800aff:	68 00 50 80 00       	push   $0x805000
  800b04:	ff 75 0c             	pushl  0xc(%ebp)
  800b07:	e8 65 12 00 00       	call   801d71 <memmove>
	return r;
  800b0c:	83 c4 10             	add    $0x10,%esp
}
  800b0f:	89 d8                	mov    %ebx,%eax
  800b11:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b14:	5b                   	pop    %ebx
  800b15:	5e                   	pop    %esi
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	53                   	push   %ebx
  800b1c:	83 ec 20             	sub    $0x20,%esp
  800b1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b22:	53                   	push   %ebx
  800b23:	e8 7e 10 00 00       	call   801ba6 <strlen>
  800b28:	83 c4 10             	add    $0x10,%esp
  800b2b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b30:	7f 67                	jg     800b99 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b32:	83 ec 0c             	sub    $0xc,%esp
  800b35:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b38:	50                   	push   %eax
  800b39:	e8 9a f8 ff ff       	call   8003d8 <fd_alloc>
  800b3e:	83 c4 10             	add    $0x10,%esp
		return r;
  800b41:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b43:	85 c0                	test   %eax,%eax
  800b45:	78 57                	js     800b9e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b47:	83 ec 08             	sub    $0x8,%esp
  800b4a:	53                   	push   %ebx
  800b4b:	68 00 50 80 00       	push   $0x805000
  800b50:	e8 8a 10 00 00       	call   801bdf <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b58:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b5d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b60:	b8 01 00 00 00       	mov    $0x1,%eax
  800b65:	e8 f6 fd ff ff       	call   800960 <fsipc>
  800b6a:	89 c3                	mov    %eax,%ebx
  800b6c:	83 c4 10             	add    $0x10,%esp
  800b6f:	85 c0                	test   %eax,%eax
  800b71:	79 14                	jns    800b87 <open+0x6f>
		fd_close(fd, 0);
  800b73:	83 ec 08             	sub    $0x8,%esp
  800b76:	6a 00                	push   $0x0
  800b78:	ff 75 f4             	pushl  -0xc(%ebp)
  800b7b:	e8 50 f9 ff ff       	call   8004d0 <fd_close>
		return r;
  800b80:	83 c4 10             	add    $0x10,%esp
  800b83:	89 da                	mov    %ebx,%edx
  800b85:	eb 17                	jmp    800b9e <open+0x86>
	}

	return fd2num(fd);
  800b87:	83 ec 0c             	sub    $0xc,%esp
  800b8a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b8d:	e8 1f f8 ff ff       	call   8003b1 <fd2num>
  800b92:	89 c2                	mov    %eax,%edx
  800b94:	83 c4 10             	add    $0x10,%esp
  800b97:	eb 05                	jmp    800b9e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b99:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b9e:	89 d0                	mov    %edx,%eax
  800ba0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ba3:	c9                   	leave  
  800ba4:	c3                   	ret    

00800ba5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bab:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb0:	b8 08 00 00 00       	mov    $0x8,%eax
  800bb5:	e8 a6 fd ff ff       	call   800960 <fsipc>
}
  800bba:	c9                   	leave  
  800bbb:	c3                   	ret    

00800bbc <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bc2:	68 fb 23 80 00       	push   $0x8023fb
  800bc7:	ff 75 0c             	pushl  0xc(%ebp)
  800bca:	e8 10 10 00 00       	call   801bdf <strcpy>
	return 0;
}
  800bcf:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd4:	c9                   	leave  
  800bd5:	c3                   	ret    

00800bd6 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	53                   	push   %ebx
  800bda:	83 ec 10             	sub    $0x10,%esp
  800bdd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800be0:	53                   	push   %ebx
  800be1:	e8 36 14 00 00       	call   80201c <pageref>
  800be6:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800be9:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800bee:	83 f8 01             	cmp    $0x1,%eax
  800bf1:	75 10                	jne    800c03 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800bf3:	83 ec 0c             	sub    $0xc,%esp
  800bf6:	ff 73 0c             	pushl  0xc(%ebx)
  800bf9:	e8 c0 02 00 00       	call   800ebe <nsipc_close>
  800bfe:	89 c2                	mov    %eax,%edx
  800c00:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800c03:	89 d0                	mov    %edx,%eax
  800c05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c08:	c9                   	leave  
  800c09:	c3                   	ret    

00800c0a <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c10:	6a 00                	push   $0x0
  800c12:	ff 75 10             	pushl  0x10(%ebp)
  800c15:	ff 75 0c             	pushl  0xc(%ebp)
  800c18:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1b:	ff 70 0c             	pushl  0xc(%eax)
  800c1e:	e8 78 03 00 00       	call   800f9b <nsipc_send>
}
  800c23:	c9                   	leave  
  800c24:	c3                   	ret    

00800c25 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c2b:	6a 00                	push   $0x0
  800c2d:	ff 75 10             	pushl  0x10(%ebp)
  800c30:	ff 75 0c             	pushl  0xc(%ebp)
  800c33:	8b 45 08             	mov    0x8(%ebp),%eax
  800c36:	ff 70 0c             	pushl  0xc(%eax)
  800c39:	e8 f1 02 00 00       	call   800f2f <nsipc_recv>
}
  800c3e:	c9                   	leave  
  800c3f:	c3                   	ret    

00800c40 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c46:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c49:	52                   	push   %edx
  800c4a:	50                   	push   %eax
  800c4b:	e8 d7 f7 ff ff       	call   800427 <fd_lookup>
  800c50:	83 c4 10             	add    $0x10,%esp
  800c53:	85 c0                	test   %eax,%eax
  800c55:	78 17                	js     800c6e <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c5a:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c60:	39 08                	cmp    %ecx,(%eax)
  800c62:	75 05                	jne    800c69 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c64:	8b 40 0c             	mov    0xc(%eax),%eax
  800c67:	eb 05                	jmp    800c6e <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c69:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c6e:	c9                   	leave  
  800c6f:	c3                   	ret    

00800c70 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	56                   	push   %esi
  800c74:	53                   	push   %ebx
  800c75:	83 ec 1c             	sub    $0x1c,%esp
  800c78:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c7d:	50                   	push   %eax
  800c7e:	e8 55 f7 ff ff       	call   8003d8 <fd_alloc>
  800c83:	89 c3                	mov    %eax,%ebx
  800c85:	83 c4 10             	add    $0x10,%esp
  800c88:	85 c0                	test   %eax,%eax
  800c8a:	78 1b                	js     800ca7 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c8c:	83 ec 04             	sub    $0x4,%esp
  800c8f:	68 07 04 00 00       	push   $0x407
  800c94:	ff 75 f4             	pushl  -0xc(%ebp)
  800c97:	6a 00                	push   $0x0
  800c99:	e8 e3 f4 ff ff       	call   800181 <sys_page_alloc>
  800c9e:	89 c3                	mov    %eax,%ebx
  800ca0:	83 c4 10             	add    $0x10,%esp
  800ca3:	85 c0                	test   %eax,%eax
  800ca5:	79 10                	jns    800cb7 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800ca7:	83 ec 0c             	sub    $0xc,%esp
  800caa:	56                   	push   %esi
  800cab:	e8 0e 02 00 00       	call   800ebe <nsipc_close>
		return r;
  800cb0:	83 c4 10             	add    $0x10,%esp
  800cb3:	89 d8                	mov    %ebx,%eax
  800cb5:	eb 24                	jmp    800cdb <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800cb7:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cc0:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cc5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800ccc:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800ccf:	83 ec 0c             	sub    $0xc,%esp
  800cd2:	50                   	push   %eax
  800cd3:	e8 d9 f6 ff ff       	call   8003b1 <fd2num>
  800cd8:	83 c4 10             	add    $0x10,%esp
}
  800cdb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cde:	5b                   	pop    %ebx
  800cdf:	5e                   	pop    %esi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    

00800ce2 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ce8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ceb:	e8 50 ff ff ff       	call   800c40 <fd2sockid>
		return r;
  800cf0:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cf2:	85 c0                	test   %eax,%eax
  800cf4:	78 1f                	js     800d15 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cf6:	83 ec 04             	sub    $0x4,%esp
  800cf9:	ff 75 10             	pushl  0x10(%ebp)
  800cfc:	ff 75 0c             	pushl  0xc(%ebp)
  800cff:	50                   	push   %eax
  800d00:	e8 12 01 00 00       	call   800e17 <nsipc_accept>
  800d05:	83 c4 10             	add    $0x10,%esp
		return r;
  800d08:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d0a:	85 c0                	test   %eax,%eax
  800d0c:	78 07                	js     800d15 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800d0e:	e8 5d ff ff ff       	call   800c70 <alloc_sockfd>
  800d13:	89 c1                	mov    %eax,%ecx
}
  800d15:	89 c8                	mov    %ecx,%eax
  800d17:	c9                   	leave  
  800d18:	c3                   	ret    

00800d19 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d22:	e8 19 ff ff ff       	call   800c40 <fd2sockid>
  800d27:	85 c0                	test   %eax,%eax
  800d29:	78 12                	js     800d3d <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d2b:	83 ec 04             	sub    $0x4,%esp
  800d2e:	ff 75 10             	pushl  0x10(%ebp)
  800d31:	ff 75 0c             	pushl  0xc(%ebp)
  800d34:	50                   	push   %eax
  800d35:	e8 2d 01 00 00       	call   800e67 <nsipc_bind>
  800d3a:	83 c4 10             	add    $0x10,%esp
}
  800d3d:	c9                   	leave  
  800d3e:	c3                   	ret    

00800d3f <shutdown>:

int
shutdown(int s, int how)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d45:	8b 45 08             	mov    0x8(%ebp),%eax
  800d48:	e8 f3 fe ff ff       	call   800c40 <fd2sockid>
  800d4d:	85 c0                	test   %eax,%eax
  800d4f:	78 0f                	js     800d60 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d51:	83 ec 08             	sub    $0x8,%esp
  800d54:	ff 75 0c             	pushl  0xc(%ebp)
  800d57:	50                   	push   %eax
  800d58:	e8 3f 01 00 00       	call   800e9c <nsipc_shutdown>
  800d5d:	83 c4 10             	add    $0x10,%esp
}
  800d60:	c9                   	leave  
  800d61:	c3                   	ret    

00800d62 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d62:	55                   	push   %ebp
  800d63:	89 e5                	mov    %esp,%ebp
  800d65:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d68:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6b:	e8 d0 fe ff ff       	call   800c40 <fd2sockid>
  800d70:	85 c0                	test   %eax,%eax
  800d72:	78 12                	js     800d86 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d74:	83 ec 04             	sub    $0x4,%esp
  800d77:	ff 75 10             	pushl  0x10(%ebp)
  800d7a:	ff 75 0c             	pushl  0xc(%ebp)
  800d7d:	50                   	push   %eax
  800d7e:	e8 55 01 00 00       	call   800ed8 <nsipc_connect>
  800d83:	83 c4 10             	add    $0x10,%esp
}
  800d86:	c9                   	leave  
  800d87:	c3                   	ret    

00800d88 <listen>:

int
listen(int s, int backlog)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d91:	e8 aa fe ff ff       	call   800c40 <fd2sockid>
  800d96:	85 c0                	test   %eax,%eax
  800d98:	78 0f                	js     800da9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d9a:	83 ec 08             	sub    $0x8,%esp
  800d9d:	ff 75 0c             	pushl  0xc(%ebp)
  800da0:	50                   	push   %eax
  800da1:	e8 67 01 00 00       	call   800f0d <nsipc_listen>
  800da6:	83 c4 10             	add    $0x10,%esp
}
  800da9:	c9                   	leave  
  800daa:	c3                   	ret    

00800dab <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800db1:	ff 75 10             	pushl  0x10(%ebp)
  800db4:	ff 75 0c             	pushl  0xc(%ebp)
  800db7:	ff 75 08             	pushl  0x8(%ebp)
  800dba:	e8 3a 02 00 00       	call   800ff9 <nsipc_socket>
  800dbf:	83 c4 10             	add    $0x10,%esp
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	78 05                	js     800dcb <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800dc6:	e8 a5 fe ff ff       	call   800c70 <alloc_sockfd>
}
  800dcb:	c9                   	leave  
  800dcc:	c3                   	ret    

00800dcd <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	53                   	push   %ebx
  800dd1:	83 ec 04             	sub    $0x4,%esp
  800dd4:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dd6:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800ddd:	75 12                	jne    800df1 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800ddf:	83 ec 0c             	sub    $0xc,%esp
  800de2:	6a 02                	push   $0x2
  800de4:	e8 fa 11 00 00       	call   801fe3 <ipc_find_env>
  800de9:	a3 04 40 80 00       	mov    %eax,0x804004
  800dee:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800df1:	6a 07                	push   $0x7
  800df3:	68 00 60 80 00       	push   $0x806000
  800df8:	53                   	push   %ebx
  800df9:	ff 35 04 40 80 00    	pushl  0x804004
  800dff:	e8 8b 11 00 00       	call   801f8f <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e04:	83 c4 0c             	add    $0xc,%esp
  800e07:	6a 00                	push   $0x0
  800e09:	6a 00                	push   $0x0
  800e0b:	6a 00                	push   $0x0
  800e0d:	e8 14 11 00 00       	call   801f26 <ipc_recv>
}
  800e12:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e15:	c9                   	leave  
  800e16:	c3                   	ret    

00800e17 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	56                   	push   %esi
  800e1b:	53                   	push   %ebx
  800e1c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e22:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e27:	8b 06                	mov    (%esi),%eax
  800e29:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e2e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e33:	e8 95 ff ff ff       	call   800dcd <nsipc>
  800e38:	89 c3                	mov    %eax,%ebx
  800e3a:	85 c0                	test   %eax,%eax
  800e3c:	78 20                	js     800e5e <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e3e:	83 ec 04             	sub    $0x4,%esp
  800e41:	ff 35 10 60 80 00    	pushl  0x806010
  800e47:	68 00 60 80 00       	push   $0x806000
  800e4c:	ff 75 0c             	pushl  0xc(%ebp)
  800e4f:	e8 1d 0f 00 00       	call   801d71 <memmove>
		*addrlen = ret->ret_addrlen;
  800e54:	a1 10 60 80 00       	mov    0x806010,%eax
  800e59:	89 06                	mov    %eax,(%esi)
  800e5b:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e5e:	89 d8                	mov    %ebx,%eax
  800e60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e63:	5b                   	pop    %ebx
  800e64:	5e                   	pop    %esi
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    

00800e67 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	53                   	push   %ebx
  800e6b:	83 ec 08             	sub    $0x8,%esp
  800e6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e71:	8b 45 08             	mov    0x8(%ebp),%eax
  800e74:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e79:	53                   	push   %ebx
  800e7a:	ff 75 0c             	pushl  0xc(%ebp)
  800e7d:	68 04 60 80 00       	push   $0x806004
  800e82:	e8 ea 0e 00 00       	call   801d71 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e87:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e8d:	b8 02 00 00 00       	mov    $0x2,%eax
  800e92:	e8 36 ff ff ff       	call   800dcd <nsipc>
}
  800e97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e9a:	c9                   	leave  
  800e9b:	c3                   	ret    

00800e9c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800ea2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea5:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800eaa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ead:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800eb2:	b8 03 00 00 00       	mov    $0x3,%eax
  800eb7:	e8 11 ff ff ff       	call   800dcd <nsipc>
}
  800ebc:	c9                   	leave  
  800ebd:	c3                   	ret    

00800ebe <nsipc_close>:

int
nsipc_close(int s)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ec4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec7:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800ecc:	b8 04 00 00 00       	mov    $0x4,%eax
  800ed1:	e8 f7 fe ff ff       	call   800dcd <nsipc>
}
  800ed6:	c9                   	leave  
  800ed7:	c3                   	ret    

00800ed8 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	53                   	push   %ebx
  800edc:	83 ec 08             	sub    $0x8,%esp
  800edf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ee2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee5:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800eea:	53                   	push   %ebx
  800eeb:	ff 75 0c             	pushl  0xc(%ebp)
  800eee:	68 04 60 80 00       	push   $0x806004
  800ef3:	e8 79 0e 00 00       	call   801d71 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ef8:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800efe:	b8 05 00 00 00       	mov    $0x5,%eax
  800f03:	e8 c5 fe ff ff       	call   800dcd <nsipc>
}
  800f08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f0b:	c9                   	leave  
  800f0c:	c3                   	ret    

00800f0d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f13:	8b 45 08             	mov    0x8(%ebp),%eax
  800f16:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800f1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f23:	b8 06 00 00 00       	mov    $0x6,%eax
  800f28:	e8 a0 fe ff ff       	call   800dcd <nsipc>
}
  800f2d:	c9                   	leave  
  800f2e:	c3                   	ret    

00800f2f <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	56                   	push   %esi
  800f33:	53                   	push   %ebx
  800f34:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f37:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f3f:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f45:	8b 45 14             	mov    0x14(%ebp),%eax
  800f48:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f4d:	b8 07 00 00 00       	mov    $0x7,%eax
  800f52:	e8 76 fe ff ff       	call   800dcd <nsipc>
  800f57:	89 c3                	mov    %eax,%ebx
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	78 35                	js     800f92 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f5d:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f62:	7f 04                	jg     800f68 <nsipc_recv+0x39>
  800f64:	39 c6                	cmp    %eax,%esi
  800f66:	7d 16                	jge    800f7e <nsipc_recv+0x4f>
  800f68:	68 07 24 80 00       	push   $0x802407
  800f6d:	68 cf 23 80 00       	push   $0x8023cf
  800f72:	6a 62                	push   $0x62
  800f74:	68 1c 24 80 00       	push   $0x80241c
  800f79:	e8 84 05 00 00       	call   801502 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f7e:	83 ec 04             	sub    $0x4,%esp
  800f81:	50                   	push   %eax
  800f82:	68 00 60 80 00       	push   $0x806000
  800f87:	ff 75 0c             	pushl  0xc(%ebp)
  800f8a:	e8 e2 0d 00 00       	call   801d71 <memmove>
  800f8f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f92:	89 d8                	mov    %ebx,%eax
  800f94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f97:	5b                   	pop    %ebx
  800f98:	5e                   	pop    %esi
  800f99:	5d                   	pop    %ebp
  800f9a:	c3                   	ret    

00800f9b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	53                   	push   %ebx
  800f9f:	83 ec 04             	sub    $0x4,%esp
  800fa2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800fa5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa8:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800fad:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fb3:	7e 16                	jle    800fcb <nsipc_send+0x30>
  800fb5:	68 28 24 80 00       	push   $0x802428
  800fba:	68 cf 23 80 00       	push   $0x8023cf
  800fbf:	6a 6d                	push   $0x6d
  800fc1:	68 1c 24 80 00       	push   $0x80241c
  800fc6:	e8 37 05 00 00       	call   801502 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fcb:	83 ec 04             	sub    $0x4,%esp
  800fce:	53                   	push   %ebx
  800fcf:	ff 75 0c             	pushl  0xc(%ebp)
  800fd2:	68 0c 60 80 00       	push   $0x80600c
  800fd7:	e8 95 0d 00 00       	call   801d71 <memmove>
	nsipcbuf.send.req_size = size;
  800fdc:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fe2:	8b 45 14             	mov    0x14(%ebp),%eax
  800fe5:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fea:	b8 08 00 00 00       	mov    $0x8,%eax
  800fef:	e8 d9 fd ff ff       	call   800dcd <nsipc>
}
  800ff4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff7:	c9                   	leave  
  800ff8:	c3                   	ret    

00800ff9 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800ff9:	55                   	push   %ebp
  800ffa:	89 e5                	mov    %esp,%ebp
  800ffc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fff:	8b 45 08             	mov    0x8(%ebp),%eax
  801002:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801007:	8b 45 0c             	mov    0xc(%ebp),%eax
  80100a:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  80100f:	8b 45 10             	mov    0x10(%ebp),%eax
  801012:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801017:	b8 09 00 00 00       	mov    $0x9,%eax
  80101c:	e8 ac fd ff ff       	call   800dcd <nsipc>
}
  801021:	c9                   	leave  
  801022:	c3                   	ret    

00801023 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
  801026:	56                   	push   %esi
  801027:	53                   	push   %ebx
  801028:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80102b:	83 ec 0c             	sub    $0xc,%esp
  80102e:	ff 75 08             	pushl  0x8(%ebp)
  801031:	e8 8b f3 ff ff       	call   8003c1 <fd2data>
  801036:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801038:	83 c4 08             	add    $0x8,%esp
  80103b:	68 34 24 80 00       	push   $0x802434
  801040:	53                   	push   %ebx
  801041:	e8 99 0b 00 00       	call   801bdf <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801046:	8b 46 04             	mov    0x4(%esi),%eax
  801049:	2b 06                	sub    (%esi),%eax
  80104b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801051:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801058:	00 00 00 
	stat->st_dev = &devpipe;
  80105b:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801062:	30 80 00 
	return 0;
}
  801065:	b8 00 00 00 00       	mov    $0x0,%eax
  80106a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80106d:	5b                   	pop    %ebx
  80106e:	5e                   	pop    %esi
  80106f:	5d                   	pop    %ebp
  801070:	c3                   	ret    

00801071 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	53                   	push   %ebx
  801075:	83 ec 0c             	sub    $0xc,%esp
  801078:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80107b:	53                   	push   %ebx
  80107c:	6a 00                	push   $0x0
  80107e:	e8 83 f1 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801083:	89 1c 24             	mov    %ebx,(%esp)
  801086:	e8 36 f3 ff ff       	call   8003c1 <fd2data>
  80108b:	83 c4 08             	add    $0x8,%esp
  80108e:	50                   	push   %eax
  80108f:	6a 00                	push   $0x0
  801091:	e8 70 f1 ff ff       	call   800206 <sys_page_unmap>
}
  801096:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801099:	c9                   	leave  
  80109a:	c3                   	ret    

0080109b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80109b:	55                   	push   %ebp
  80109c:	89 e5                	mov    %esp,%ebp
  80109e:	57                   	push   %edi
  80109f:	56                   	push   %esi
  8010a0:	53                   	push   %ebx
  8010a1:	83 ec 1c             	sub    $0x1c,%esp
  8010a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010a7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8010a9:	a1 08 40 80 00       	mov    0x804008,%eax
  8010ae:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8010b1:	83 ec 0c             	sub    $0xc,%esp
  8010b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8010b7:	e8 60 0f 00 00       	call   80201c <pageref>
  8010bc:	89 c3                	mov    %eax,%ebx
  8010be:	89 3c 24             	mov    %edi,(%esp)
  8010c1:	e8 56 0f 00 00       	call   80201c <pageref>
  8010c6:	83 c4 10             	add    $0x10,%esp
  8010c9:	39 c3                	cmp    %eax,%ebx
  8010cb:	0f 94 c1             	sete   %cl
  8010ce:	0f b6 c9             	movzbl %cl,%ecx
  8010d1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010d4:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010da:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010dd:	39 ce                	cmp    %ecx,%esi
  8010df:	74 1b                	je     8010fc <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010e1:	39 c3                	cmp    %eax,%ebx
  8010e3:	75 c4                	jne    8010a9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010e5:	8b 42 58             	mov    0x58(%edx),%eax
  8010e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010eb:	50                   	push   %eax
  8010ec:	56                   	push   %esi
  8010ed:	68 3b 24 80 00       	push   $0x80243b
  8010f2:	e8 e4 04 00 00       	call   8015db <cprintf>
  8010f7:	83 c4 10             	add    $0x10,%esp
  8010fa:	eb ad                	jmp    8010a9 <_pipeisclosed+0xe>
	}
}
  8010fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801102:	5b                   	pop    %ebx
  801103:	5e                   	pop    %esi
  801104:	5f                   	pop    %edi
  801105:	5d                   	pop    %ebp
  801106:	c3                   	ret    

00801107 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	57                   	push   %edi
  80110b:	56                   	push   %esi
  80110c:	53                   	push   %ebx
  80110d:	83 ec 28             	sub    $0x28,%esp
  801110:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801113:	56                   	push   %esi
  801114:	e8 a8 f2 ff ff       	call   8003c1 <fd2data>
  801119:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80111b:	83 c4 10             	add    $0x10,%esp
  80111e:	bf 00 00 00 00       	mov    $0x0,%edi
  801123:	eb 4b                	jmp    801170 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801125:	89 da                	mov    %ebx,%edx
  801127:	89 f0                	mov    %esi,%eax
  801129:	e8 6d ff ff ff       	call   80109b <_pipeisclosed>
  80112e:	85 c0                	test   %eax,%eax
  801130:	75 48                	jne    80117a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801132:	e8 2b f0 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801137:	8b 43 04             	mov    0x4(%ebx),%eax
  80113a:	8b 0b                	mov    (%ebx),%ecx
  80113c:	8d 51 20             	lea    0x20(%ecx),%edx
  80113f:	39 d0                	cmp    %edx,%eax
  801141:	73 e2                	jae    801125 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801143:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801146:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80114a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80114d:	89 c2                	mov    %eax,%edx
  80114f:	c1 fa 1f             	sar    $0x1f,%edx
  801152:	89 d1                	mov    %edx,%ecx
  801154:	c1 e9 1b             	shr    $0x1b,%ecx
  801157:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80115a:	83 e2 1f             	and    $0x1f,%edx
  80115d:	29 ca                	sub    %ecx,%edx
  80115f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801163:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801167:	83 c0 01             	add    $0x1,%eax
  80116a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80116d:	83 c7 01             	add    $0x1,%edi
  801170:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801173:	75 c2                	jne    801137 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801175:	8b 45 10             	mov    0x10(%ebp),%eax
  801178:	eb 05                	jmp    80117f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80117a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80117f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801182:	5b                   	pop    %ebx
  801183:	5e                   	pop    %esi
  801184:	5f                   	pop    %edi
  801185:	5d                   	pop    %ebp
  801186:	c3                   	ret    

00801187 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	57                   	push   %edi
  80118b:	56                   	push   %esi
  80118c:	53                   	push   %ebx
  80118d:	83 ec 18             	sub    $0x18,%esp
  801190:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801193:	57                   	push   %edi
  801194:	e8 28 f2 ff ff       	call   8003c1 <fd2data>
  801199:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80119b:	83 c4 10             	add    $0x10,%esp
  80119e:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011a3:	eb 3d                	jmp    8011e2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8011a5:	85 db                	test   %ebx,%ebx
  8011a7:	74 04                	je     8011ad <devpipe_read+0x26>
				return i;
  8011a9:	89 d8                	mov    %ebx,%eax
  8011ab:	eb 44                	jmp    8011f1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8011ad:	89 f2                	mov    %esi,%edx
  8011af:	89 f8                	mov    %edi,%eax
  8011b1:	e8 e5 fe ff ff       	call   80109b <_pipeisclosed>
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	75 32                	jne    8011ec <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8011ba:	e8 a3 ef ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011bf:	8b 06                	mov    (%esi),%eax
  8011c1:	3b 46 04             	cmp    0x4(%esi),%eax
  8011c4:	74 df                	je     8011a5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011c6:	99                   	cltd   
  8011c7:	c1 ea 1b             	shr    $0x1b,%edx
  8011ca:	01 d0                	add    %edx,%eax
  8011cc:	83 e0 1f             	and    $0x1f,%eax
  8011cf:	29 d0                	sub    %edx,%eax
  8011d1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011dc:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011df:	83 c3 01             	add    $0x1,%ebx
  8011e2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011e5:	75 d8                	jne    8011bf <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8011ea:	eb 05                	jmp    8011f1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011ec:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f4:	5b                   	pop    %ebx
  8011f5:	5e                   	pop    %esi
  8011f6:	5f                   	pop    %edi
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    

008011f9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011f9:	55                   	push   %ebp
  8011fa:	89 e5                	mov    %esp,%ebp
  8011fc:	56                   	push   %esi
  8011fd:	53                   	push   %ebx
  8011fe:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801201:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801204:	50                   	push   %eax
  801205:	e8 ce f1 ff ff       	call   8003d8 <fd_alloc>
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	89 c2                	mov    %eax,%edx
  80120f:	85 c0                	test   %eax,%eax
  801211:	0f 88 2c 01 00 00    	js     801343 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801217:	83 ec 04             	sub    $0x4,%esp
  80121a:	68 07 04 00 00       	push   $0x407
  80121f:	ff 75 f4             	pushl  -0xc(%ebp)
  801222:	6a 00                	push   $0x0
  801224:	e8 58 ef ff ff       	call   800181 <sys_page_alloc>
  801229:	83 c4 10             	add    $0x10,%esp
  80122c:	89 c2                	mov    %eax,%edx
  80122e:	85 c0                	test   %eax,%eax
  801230:	0f 88 0d 01 00 00    	js     801343 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801236:	83 ec 0c             	sub    $0xc,%esp
  801239:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80123c:	50                   	push   %eax
  80123d:	e8 96 f1 ff ff       	call   8003d8 <fd_alloc>
  801242:	89 c3                	mov    %eax,%ebx
  801244:	83 c4 10             	add    $0x10,%esp
  801247:	85 c0                	test   %eax,%eax
  801249:	0f 88 e2 00 00 00    	js     801331 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80124f:	83 ec 04             	sub    $0x4,%esp
  801252:	68 07 04 00 00       	push   $0x407
  801257:	ff 75 f0             	pushl  -0x10(%ebp)
  80125a:	6a 00                	push   $0x0
  80125c:	e8 20 ef ff ff       	call   800181 <sys_page_alloc>
  801261:	89 c3                	mov    %eax,%ebx
  801263:	83 c4 10             	add    $0x10,%esp
  801266:	85 c0                	test   %eax,%eax
  801268:	0f 88 c3 00 00 00    	js     801331 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80126e:	83 ec 0c             	sub    $0xc,%esp
  801271:	ff 75 f4             	pushl  -0xc(%ebp)
  801274:	e8 48 f1 ff ff       	call   8003c1 <fd2data>
  801279:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80127b:	83 c4 0c             	add    $0xc,%esp
  80127e:	68 07 04 00 00       	push   $0x407
  801283:	50                   	push   %eax
  801284:	6a 00                	push   $0x0
  801286:	e8 f6 ee ff ff       	call   800181 <sys_page_alloc>
  80128b:	89 c3                	mov    %eax,%ebx
  80128d:	83 c4 10             	add    $0x10,%esp
  801290:	85 c0                	test   %eax,%eax
  801292:	0f 88 89 00 00 00    	js     801321 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801298:	83 ec 0c             	sub    $0xc,%esp
  80129b:	ff 75 f0             	pushl  -0x10(%ebp)
  80129e:	e8 1e f1 ff ff       	call   8003c1 <fd2data>
  8012a3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012aa:	50                   	push   %eax
  8012ab:	6a 00                	push   $0x0
  8012ad:	56                   	push   %esi
  8012ae:	6a 00                	push   $0x0
  8012b0:	e8 0f ef ff ff       	call   8001c4 <sys_page_map>
  8012b5:	89 c3                	mov    %eax,%ebx
  8012b7:	83 c4 20             	add    $0x20,%esp
  8012ba:	85 c0                	test   %eax,%eax
  8012bc:	78 55                	js     801313 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012be:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012cc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012d3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012dc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012e8:	83 ec 0c             	sub    $0xc,%esp
  8012eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8012ee:	e8 be f0 ff ff       	call   8003b1 <fd2num>
  8012f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012f8:	83 c4 04             	add    $0x4,%esp
  8012fb:	ff 75 f0             	pushl  -0x10(%ebp)
  8012fe:	e8 ae f0 ff ff       	call   8003b1 <fd2num>
  801303:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801306:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801309:	83 c4 10             	add    $0x10,%esp
  80130c:	ba 00 00 00 00       	mov    $0x0,%edx
  801311:	eb 30                	jmp    801343 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801313:	83 ec 08             	sub    $0x8,%esp
  801316:	56                   	push   %esi
  801317:	6a 00                	push   $0x0
  801319:	e8 e8 ee ff ff       	call   800206 <sys_page_unmap>
  80131e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801321:	83 ec 08             	sub    $0x8,%esp
  801324:	ff 75 f0             	pushl  -0x10(%ebp)
  801327:	6a 00                	push   $0x0
  801329:	e8 d8 ee ff ff       	call   800206 <sys_page_unmap>
  80132e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801331:	83 ec 08             	sub    $0x8,%esp
  801334:	ff 75 f4             	pushl  -0xc(%ebp)
  801337:	6a 00                	push   $0x0
  801339:	e8 c8 ee ff ff       	call   800206 <sys_page_unmap>
  80133e:	83 c4 10             	add    $0x10,%esp
  801341:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801343:	89 d0                	mov    %edx,%eax
  801345:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801348:	5b                   	pop    %ebx
  801349:	5e                   	pop    %esi
  80134a:	5d                   	pop    %ebp
  80134b:	c3                   	ret    

0080134c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80134c:	55                   	push   %ebp
  80134d:	89 e5                	mov    %esp,%ebp
  80134f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801352:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801355:	50                   	push   %eax
  801356:	ff 75 08             	pushl  0x8(%ebp)
  801359:	e8 c9 f0 ff ff       	call   800427 <fd_lookup>
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	85 c0                	test   %eax,%eax
  801363:	78 18                	js     80137d <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801365:	83 ec 0c             	sub    $0xc,%esp
  801368:	ff 75 f4             	pushl  -0xc(%ebp)
  80136b:	e8 51 f0 ff ff       	call   8003c1 <fd2data>
	return _pipeisclosed(fd, p);
  801370:	89 c2                	mov    %eax,%edx
  801372:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801375:	e8 21 fd ff ff       	call   80109b <_pipeisclosed>
  80137a:	83 c4 10             	add    $0x10,%esp
}
  80137d:	c9                   	leave  
  80137e:	c3                   	ret    

0080137f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801382:	b8 00 00 00 00       	mov    $0x0,%eax
  801387:	5d                   	pop    %ebp
  801388:	c3                   	ret    

00801389 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801389:	55                   	push   %ebp
  80138a:	89 e5                	mov    %esp,%ebp
  80138c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80138f:	68 53 24 80 00       	push   $0x802453
  801394:	ff 75 0c             	pushl  0xc(%ebp)
  801397:	e8 43 08 00 00       	call   801bdf <strcpy>
	return 0;
}
  80139c:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a1:	c9                   	leave  
  8013a2:	c3                   	ret    

008013a3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	57                   	push   %edi
  8013a7:	56                   	push   %esi
  8013a8:	53                   	push   %ebx
  8013a9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013af:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013b4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013ba:	eb 2d                	jmp    8013e9 <devcons_write+0x46>
		m = n - tot;
  8013bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013bf:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013c1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013c4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013c9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013cc:	83 ec 04             	sub    $0x4,%esp
  8013cf:	53                   	push   %ebx
  8013d0:	03 45 0c             	add    0xc(%ebp),%eax
  8013d3:	50                   	push   %eax
  8013d4:	57                   	push   %edi
  8013d5:	e8 97 09 00 00       	call   801d71 <memmove>
		sys_cputs(buf, m);
  8013da:	83 c4 08             	add    $0x8,%esp
  8013dd:	53                   	push   %ebx
  8013de:	57                   	push   %edi
  8013df:	e8 e1 ec ff ff       	call   8000c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013e4:	01 de                	add    %ebx,%esi
  8013e6:	83 c4 10             	add    $0x10,%esp
  8013e9:	89 f0                	mov    %esi,%eax
  8013eb:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013ee:	72 cc                	jb     8013bc <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013f3:	5b                   	pop    %ebx
  8013f4:	5e                   	pop    %esi
  8013f5:	5f                   	pop    %edi
  8013f6:	5d                   	pop    %ebp
  8013f7:	c3                   	ret    

008013f8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
  8013fb:	83 ec 08             	sub    $0x8,%esp
  8013fe:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801403:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801407:	74 2a                	je     801433 <devcons_read+0x3b>
  801409:	eb 05                	jmp    801410 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80140b:	e8 52 ed ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801410:	e8 ce ec ff ff       	call   8000e3 <sys_cgetc>
  801415:	85 c0                	test   %eax,%eax
  801417:	74 f2                	je     80140b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801419:	85 c0                	test   %eax,%eax
  80141b:	78 16                	js     801433 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80141d:	83 f8 04             	cmp    $0x4,%eax
  801420:	74 0c                	je     80142e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801422:	8b 55 0c             	mov    0xc(%ebp),%edx
  801425:	88 02                	mov    %al,(%edx)
	return 1;
  801427:	b8 01 00 00 00       	mov    $0x1,%eax
  80142c:	eb 05                	jmp    801433 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80142e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801433:	c9                   	leave  
  801434:	c3                   	ret    

00801435 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801435:	55                   	push   %ebp
  801436:	89 e5                	mov    %esp,%ebp
  801438:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80143b:	8b 45 08             	mov    0x8(%ebp),%eax
  80143e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801441:	6a 01                	push   $0x1
  801443:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801446:	50                   	push   %eax
  801447:	e8 79 ec ff ff       	call   8000c5 <sys_cputs>
}
  80144c:	83 c4 10             	add    $0x10,%esp
  80144f:	c9                   	leave  
  801450:	c3                   	ret    

00801451 <getchar>:

int
getchar(void)
{
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801457:	6a 01                	push   $0x1
  801459:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80145c:	50                   	push   %eax
  80145d:	6a 00                	push   $0x0
  80145f:	e8 29 f2 ff ff       	call   80068d <read>
	if (r < 0)
  801464:	83 c4 10             	add    $0x10,%esp
  801467:	85 c0                	test   %eax,%eax
  801469:	78 0f                	js     80147a <getchar+0x29>
		return r;
	if (r < 1)
  80146b:	85 c0                	test   %eax,%eax
  80146d:	7e 06                	jle    801475 <getchar+0x24>
		return -E_EOF;
	return c;
  80146f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801473:	eb 05                	jmp    80147a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801475:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80147a:	c9                   	leave  
  80147b:	c3                   	ret    

0080147c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801482:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801485:	50                   	push   %eax
  801486:	ff 75 08             	pushl  0x8(%ebp)
  801489:	e8 99 ef ff ff       	call   800427 <fd_lookup>
  80148e:	83 c4 10             	add    $0x10,%esp
  801491:	85 c0                	test   %eax,%eax
  801493:	78 11                	js     8014a6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801495:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801498:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80149e:	39 10                	cmp    %edx,(%eax)
  8014a0:	0f 94 c0             	sete   %al
  8014a3:	0f b6 c0             	movzbl %al,%eax
}
  8014a6:	c9                   	leave  
  8014a7:	c3                   	ret    

008014a8 <opencons>:

int
opencons(void)
{
  8014a8:	55                   	push   %ebp
  8014a9:	89 e5                	mov    %esp,%ebp
  8014ab:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b1:	50                   	push   %eax
  8014b2:	e8 21 ef ff ff       	call   8003d8 <fd_alloc>
  8014b7:	83 c4 10             	add    $0x10,%esp
		return r;
  8014ba:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8014bc:	85 c0                	test   %eax,%eax
  8014be:	78 3e                	js     8014fe <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014c0:	83 ec 04             	sub    $0x4,%esp
  8014c3:	68 07 04 00 00       	push   $0x407
  8014c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8014cb:	6a 00                	push   $0x0
  8014cd:	e8 af ec ff ff       	call   800181 <sys_page_alloc>
  8014d2:	83 c4 10             	add    $0x10,%esp
		return r;
  8014d5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014d7:	85 c0                	test   %eax,%eax
  8014d9:	78 23                	js     8014fe <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014db:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014f0:	83 ec 0c             	sub    $0xc,%esp
  8014f3:	50                   	push   %eax
  8014f4:	e8 b8 ee ff ff       	call   8003b1 <fd2num>
  8014f9:	89 c2                	mov    %eax,%edx
  8014fb:	83 c4 10             	add    $0x10,%esp
}
  8014fe:	89 d0                	mov    %edx,%eax
  801500:	c9                   	leave  
  801501:	c3                   	ret    

00801502 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801502:	55                   	push   %ebp
  801503:	89 e5                	mov    %esp,%ebp
  801505:	56                   	push   %esi
  801506:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801507:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80150a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801510:	e8 2e ec ff ff       	call   800143 <sys_getenvid>
  801515:	83 ec 0c             	sub    $0xc,%esp
  801518:	ff 75 0c             	pushl  0xc(%ebp)
  80151b:	ff 75 08             	pushl  0x8(%ebp)
  80151e:	56                   	push   %esi
  80151f:	50                   	push   %eax
  801520:	68 60 24 80 00       	push   $0x802460
  801525:	e8 b1 00 00 00       	call   8015db <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80152a:	83 c4 18             	add    $0x18,%esp
  80152d:	53                   	push   %ebx
  80152e:	ff 75 10             	pushl  0x10(%ebp)
  801531:	e8 54 00 00 00       	call   80158a <vcprintf>
	cprintf("\n");
  801536:	c7 04 24 4c 24 80 00 	movl   $0x80244c,(%esp)
  80153d:	e8 99 00 00 00       	call   8015db <cprintf>
  801542:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801545:	cc                   	int3   
  801546:	eb fd                	jmp    801545 <_panic+0x43>

00801548 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801548:	55                   	push   %ebp
  801549:	89 e5                	mov    %esp,%ebp
  80154b:	53                   	push   %ebx
  80154c:	83 ec 04             	sub    $0x4,%esp
  80154f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801552:	8b 13                	mov    (%ebx),%edx
  801554:	8d 42 01             	lea    0x1(%edx),%eax
  801557:	89 03                	mov    %eax,(%ebx)
  801559:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80155c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801560:	3d ff 00 00 00       	cmp    $0xff,%eax
  801565:	75 1a                	jne    801581 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801567:	83 ec 08             	sub    $0x8,%esp
  80156a:	68 ff 00 00 00       	push   $0xff
  80156f:	8d 43 08             	lea    0x8(%ebx),%eax
  801572:	50                   	push   %eax
  801573:	e8 4d eb ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  801578:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80157e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801581:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801585:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801588:	c9                   	leave  
  801589:	c3                   	ret    

0080158a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80158a:	55                   	push   %ebp
  80158b:	89 e5                	mov    %esp,%ebp
  80158d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801593:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80159a:	00 00 00 
	b.cnt = 0;
  80159d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8015a4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015a7:	ff 75 0c             	pushl  0xc(%ebp)
  8015aa:	ff 75 08             	pushl  0x8(%ebp)
  8015ad:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015b3:	50                   	push   %eax
  8015b4:	68 48 15 80 00       	push   $0x801548
  8015b9:	e8 1a 01 00 00       	call   8016d8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015be:	83 c4 08             	add    $0x8,%esp
  8015c1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015c7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015cd:	50                   	push   %eax
  8015ce:	e8 f2 ea ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  8015d3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015d9:	c9                   	leave  
  8015da:	c3                   	ret    

008015db <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015e1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015e4:	50                   	push   %eax
  8015e5:	ff 75 08             	pushl  0x8(%ebp)
  8015e8:	e8 9d ff ff ff       	call   80158a <vcprintf>
	va_end(ap);

	return cnt;
}
  8015ed:	c9                   	leave  
  8015ee:	c3                   	ret    

008015ef <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015ef:	55                   	push   %ebp
  8015f0:	89 e5                	mov    %esp,%ebp
  8015f2:	57                   	push   %edi
  8015f3:	56                   	push   %esi
  8015f4:	53                   	push   %ebx
  8015f5:	83 ec 1c             	sub    $0x1c,%esp
  8015f8:	89 c7                	mov    %eax,%edi
  8015fa:	89 d6                	mov    %edx,%esi
  8015fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801602:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801605:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801608:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80160b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801610:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801613:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801616:	39 d3                	cmp    %edx,%ebx
  801618:	72 05                	jb     80161f <printnum+0x30>
  80161a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80161d:	77 45                	ja     801664 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80161f:	83 ec 0c             	sub    $0xc,%esp
  801622:	ff 75 18             	pushl  0x18(%ebp)
  801625:	8b 45 14             	mov    0x14(%ebp),%eax
  801628:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80162b:	53                   	push   %ebx
  80162c:	ff 75 10             	pushl  0x10(%ebp)
  80162f:	83 ec 08             	sub    $0x8,%esp
  801632:	ff 75 e4             	pushl  -0x1c(%ebp)
  801635:	ff 75 e0             	pushl  -0x20(%ebp)
  801638:	ff 75 dc             	pushl  -0x24(%ebp)
  80163b:	ff 75 d8             	pushl  -0x28(%ebp)
  80163e:	e8 1d 0a 00 00       	call   802060 <__udivdi3>
  801643:	83 c4 18             	add    $0x18,%esp
  801646:	52                   	push   %edx
  801647:	50                   	push   %eax
  801648:	89 f2                	mov    %esi,%edx
  80164a:	89 f8                	mov    %edi,%eax
  80164c:	e8 9e ff ff ff       	call   8015ef <printnum>
  801651:	83 c4 20             	add    $0x20,%esp
  801654:	eb 18                	jmp    80166e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801656:	83 ec 08             	sub    $0x8,%esp
  801659:	56                   	push   %esi
  80165a:	ff 75 18             	pushl  0x18(%ebp)
  80165d:	ff d7                	call   *%edi
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	eb 03                	jmp    801667 <printnum+0x78>
  801664:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801667:	83 eb 01             	sub    $0x1,%ebx
  80166a:	85 db                	test   %ebx,%ebx
  80166c:	7f e8                	jg     801656 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80166e:	83 ec 08             	sub    $0x8,%esp
  801671:	56                   	push   %esi
  801672:	83 ec 04             	sub    $0x4,%esp
  801675:	ff 75 e4             	pushl  -0x1c(%ebp)
  801678:	ff 75 e0             	pushl  -0x20(%ebp)
  80167b:	ff 75 dc             	pushl  -0x24(%ebp)
  80167e:	ff 75 d8             	pushl  -0x28(%ebp)
  801681:	e8 0a 0b 00 00       	call   802190 <__umoddi3>
  801686:	83 c4 14             	add    $0x14,%esp
  801689:	0f be 80 83 24 80 00 	movsbl 0x802483(%eax),%eax
  801690:	50                   	push   %eax
  801691:	ff d7                	call   *%edi
}
  801693:	83 c4 10             	add    $0x10,%esp
  801696:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801699:	5b                   	pop    %ebx
  80169a:	5e                   	pop    %esi
  80169b:	5f                   	pop    %edi
  80169c:	5d                   	pop    %ebp
  80169d:	c3                   	ret    

0080169e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80169e:	55                   	push   %ebp
  80169f:	89 e5                	mov    %esp,%ebp
  8016a1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8016a4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8016a8:	8b 10                	mov    (%eax),%edx
  8016aa:	3b 50 04             	cmp    0x4(%eax),%edx
  8016ad:	73 0a                	jae    8016b9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8016af:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016b2:	89 08                	mov    %ecx,(%eax)
  8016b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b7:	88 02                	mov    %al,(%edx)
}
  8016b9:	5d                   	pop    %ebp
  8016ba:	c3                   	ret    

008016bb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016c1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016c4:	50                   	push   %eax
  8016c5:	ff 75 10             	pushl  0x10(%ebp)
  8016c8:	ff 75 0c             	pushl  0xc(%ebp)
  8016cb:	ff 75 08             	pushl  0x8(%ebp)
  8016ce:	e8 05 00 00 00       	call   8016d8 <vprintfmt>
	va_end(ap);
}
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	c9                   	leave  
  8016d7:	c3                   	ret    

008016d8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016d8:	55                   	push   %ebp
  8016d9:	89 e5                	mov    %esp,%ebp
  8016db:	57                   	push   %edi
  8016dc:	56                   	push   %esi
  8016dd:	53                   	push   %ebx
  8016de:	83 ec 2c             	sub    $0x2c,%esp
  8016e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8016e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016e7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016ea:	eb 12                	jmp    8016fe <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	0f 84 42 04 00 00    	je     801b36 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8016f4:	83 ec 08             	sub    $0x8,%esp
  8016f7:	53                   	push   %ebx
  8016f8:	50                   	push   %eax
  8016f9:	ff d6                	call   *%esi
  8016fb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016fe:	83 c7 01             	add    $0x1,%edi
  801701:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801705:	83 f8 25             	cmp    $0x25,%eax
  801708:	75 e2                	jne    8016ec <vprintfmt+0x14>
  80170a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80170e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801715:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80171c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801723:	b9 00 00 00 00       	mov    $0x0,%ecx
  801728:	eb 07                	jmp    801731 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80172a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80172d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801731:	8d 47 01             	lea    0x1(%edi),%eax
  801734:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801737:	0f b6 07             	movzbl (%edi),%eax
  80173a:	0f b6 d0             	movzbl %al,%edx
  80173d:	83 e8 23             	sub    $0x23,%eax
  801740:	3c 55                	cmp    $0x55,%al
  801742:	0f 87 d3 03 00 00    	ja     801b1b <vprintfmt+0x443>
  801748:	0f b6 c0             	movzbl %al,%eax
  80174b:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  801752:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801755:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801759:	eb d6                	jmp    801731 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80175b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80175e:	b8 00 00 00 00       	mov    $0x0,%eax
  801763:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801766:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801769:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80176d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801770:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801773:	83 f9 09             	cmp    $0x9,%ecx
  801776:	77 3f                	ja     8017b7 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801778:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80177b:	eb e9                	jmp    801766 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80177d:	8b 45 14             	mov    0x14(%ebp),%eax
  801780:	8b 00                	mov    (%eax),%eax
  801782:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801785:	8b 45 14             	mov    0x14(%ebp),%eax
  801788:	8d 40 04             	lea    0x4(%eax),%eax
  80178b:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80178e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801791:	eb 2a                	jmp    8017bd <vprintfmt+0xe5>
  801793:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801796:	85 c0                	test   %eax,%eax
  801798:	ba 00 00 00 00       	mov    $0x0,%edx
  80179d:	0f 49 d0             	cmovns %eax,%edx
  8017a0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017a6:	eb 89                	jmp    801731 <vprintfmt+0x59>
  8017a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8017ab:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8017b2:	e9 7a ff ff ff       	jmp    801731 <vprintfmt+0x59>
  8017b7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8017ba:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8017bd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017c1:	0f 89 6a ff ff ff    	jns    801731 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017c7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017cd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017d4:	e9 58 ff ff ff       	jmp    801731 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017d9:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017df:	e9 4d ff ff ff       	jmp    801731 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8017e7:	8d 78 04             	lea    0x4(%eax),%edi
  8017ea:	83 ec 08             	sub    $0x8,%esp
  8017ed:	53                   	push   %ebx
  8017ee:	ff 30                	pushl  (%eax)
  8017f0:	ff d6                	call   *%esi
			break;
  8017f2:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017f5:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8017fb:	e9 fe fe ff ff       	jmp    8016fe <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801800:	8b 45 14             	mov    0x14(%ebp),%eax
  801803:	8d 78 04             	lea    0x4(%eax),%edi
  801806:	8b 00                	mov    (%eax),%eax
  801808:	99                   	cltd   
  801809:	31 d0                	xor    %edx,%eax
  80180b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80180d:	83 f8 0f             	cmp    $0xf,%eax
  801810:	7f 0b                	jg     80181d <vprintfmt+0x145>
  801812:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  801819:	85 d2                	test   %edx,%edx
  80181b:	75 1b                	jne    801838 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80181d:	50                   	push   %eax
  80181e:	68 9b 24 80 00       	push   $0x80249b
  801823:	53                   	push   %ebx
  801824:	56                   	push   %esi
  801825:	e8 91 fe ff ff       	call   8016bb <printfmt>
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
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801833:	e9 c6 fe ff ff       	jmp    8016fe <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801838:	52                   	push   %edx
  801839:	68 e1 23 80 00       	push   $0x8023e1
  80183e:	53                   	push   %ebx
  80183f:	56                   	push   %esi
  801840:	e8 76 fe ff ff       	call   8016bb <printfmt>
  801845:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801848:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80184b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80184e:	e9 ab fe ff ff       	jmp    8016fe <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801853:	8b 45 14             	mov    0x14(%ebp),%eax
  801856:	83 c0 04             	add    $0x4,%eax
  801859:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80185c:	8b 45 14             	mov    0x14(%ebp),%eax
  80185f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801861:	85 ff                	test   %edi,%edi
  801863:	b8 94 24 80 00       	mov    $0x802494,%eax
  801868:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80186b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80186f:	0f 8e 94 00 00 00    	jle    801909 <vprintfmt+0x231>
  801875:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801879:	0f 84 98 00 00 00    	je     801917 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  80187f:	83 ec 08             	sub    $0x8,%esp
  801882:	ff 75 d0             	pushl  -0x30(%ebp)
  801885:	57                   	push   %edi
  801886:	e8 33 03 00 00       	call   801bbe <strnlen>
  80188b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80188e:	29 c1                	sub    %eax,%ecx
  801890:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801893:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801896:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80189a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80189d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8018a0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018a2:	eb 0f                	jmp    8018b3 <vprintfmt+0x1db>
					putch(padc, putdat);
  8018a4:	83 ec 08             	sub    $0x8,%esp
  8018a7:	53                   	push   %ebx
  8018a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8018ab:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8018ad:	83 ef 01             	sub    $0x1,%edi
  8018b0:	83 c4 10             	add    $0x10,%esp
  8018b3:	85 ff                	test   %edi,%edi
  8018b5:	7f ed                	jg     8018a4 <vprintfmt+0x1cc>
  8018b7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8018ba:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8018bd:	85 c9                	test   %ecx,%ecx
  8018bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c4:	0f 49 c1             	cmovns %ecx,%eax
  8018c7:	29 c1                	sub    %eax,%ecx
  8018c9:	89 75 08             	mov    %esi,0x8(%ebp)
  8018cc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018cf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018d2:	89 cb                	mov    %ecx,%ebx
  8018d4:	eb 4d                	jmp    801923 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018d6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018da:	74 1b                	je     8018f7 <vprintfmt+0x21f>
  8018dc:	0f be c0             	movsbl %al,%eax
  8018df:	83 e8 20             	sub    $0x20,%eax
  8018e2:	83 f8 5e             	cmp    $0x5e,%eax
  8018e5:	76 10                	jbe    8018f7 <vprintfmt+0x21f>
					putch('?', putdat);
  8018e7:	83 ec 08             	sub    $0x8,%esp
  8018ea:	ff 75 0c             	pushl  0xc(%ebp)
  8018ed:	6a 3f                	push   $0x3f
  8018ef:	ff 55 08             	call   *0x8(%ebp)
  8018f2:	83 c4 10             	add    $0x10,%esp
  8018f5:	eb 0d                	jmp    801904 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8018f7:	83 ec 08             	sub    $0x8,%esp
  8018fa:	ff 75 0c             	pushl  0xc(%ebp)
  8018fd:	52                   	push   %edx
  8018fe:	ff 55 08             	call   *0x8(%ebp)
  801901:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801904:	83 eb 01             	sub    $0x1,%ebx
  801907:	eb 1a                	jmp    801923 <vprintfmt+0x24b>
  801909:	89 75 08             	mov    %esi,0x8(%ebp)
  80190c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80190f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801912:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801915:	eb 0c                	jmp    801923 <vprintfmt+0x24b>
  801917:	89 75 08             	mov    %esi,0x8(%ebp)
  80191a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80191d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801920:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801923:	83 c7 01             	add    $0x1,%edi
  801926:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80192a:	0f be d0             	movsbl %al,%edx
  80192d:	85 d2                	test   %edx,%edx
  80192f:	74 23                	je     801954 <vprintfmt+0x27c>
  801931:	85 f6                	test   %esi,%esi
  801933:	78 a1                	js     8018d6 <vprintfmt+0x1fe>
  801935:	83 ee 01             	sub    $0x1,%esi
  801938:	79 9c                	jns    8018d6 <vprintfmt+0x1fe>
  80193a:	89 df                	mov    %ebx,%edi
  80193c:	8b 75 08             	mov    0x8(%ebp),%esi
  80193f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801942:	eb 18                	jmp    80195c <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801944:	83 ec 08             	sub    $0x8,%esp
  801947:	53                   	push   %ebx
  801948:	6a 20                	push   $0x20
  80194a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80194c:	83 ef 01             	sub    $0x1,%edi
  80194f:	83 c4 10             	add    $0x10,%esp
  801952:	eb 08                	jmp    80195c <vprintfmt+0x284>
  801954:	89 df                	mov    %ebx,%edi
  801956:	8b 75 08             	mov    0x8(%ebp),%esi
  801959:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80195c:	85 ff                	test   %edi,%edi
  80195e:	7f e4                	jg     801944 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801960:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801963:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801966:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801969:	e9 90 fd ff ff       	jmp    8016fe <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80196e:	83 f9 01             	cmp    $0x1,%ecx
  801971:	7e 19                	jle    80198c <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  801973:	8b 45 14             	mov    0x14(%ebp),%eax
  801976:	8b 50 04             	mov    0x4(%eax),%edx
  801979:	8b 00                	mov    (%eax),%eax
  80197b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80197e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801981:	8b 45 14             	mov    0x14(%ebp),%eax
  801984:	8d 40 08             	lea    0x8(%eax),%eax
  801987:	89 45 14             	mov    %eax,0x14(%ebp)
  80198a:	eb 38                	jmp    8019c4 <vprintfmt+0x2ec>
	else if (lflag)
  80198c:	85 c9                	test   %ecx,%ecx
  80198e:	74 1b                	je     8019ab <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  801990:	8b 45 14             	mov    0x14(%ebp),%eax
  801993:	8b 00                	mov    (%eax),%eax
  801995:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801998:	89 c1                	mov    %eax,%ecx
  80199a:	c1 f9 1f             	sar    $0x1f,%ecx
  80199d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a3:	8d 40 04             	lea    0x4(%eax),%eax
  8019a6:	89 45 14             	mov    %eax,0x14(%ebp)
  8019a9:	eb 19                	jmp    8019c4 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8019ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ae:	8b 00                	mov    (%eax),%eax
  8019b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8019b3:	89 c1                	mov    %eax,%ecx
  8019b5:	c1 f9 1f             	sar    $0x1f,%ecx
  8019b8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8019bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8019be:	8d 40 04             	lea    0x4(%eax),%eax
  8019c1:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019c4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8019c7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019ca:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019cf:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019d3:	0f 89 0e 01 00 00    	jns    801ae7 <vprintfmt+0x40f>
				putch('-', putdat);
  8019d9:	83 ec 08             	sub    $0x8,%esp
  8019dc:	53                   	push   %ebx
  8019dd:	6a 2d                	push   $0x2d
  8019df:	ff d6                	call   *%esi
				num = -(long long) num;
  8019e1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8019e4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8019e7:	f7 da                	neg    %edx
  8019e9:	83 d1 00             	adc    $0x0,%ecx
  8019ec:	f7 d9                	neg    %ecx
  8019ee:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019f1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8019f6:	e9 ec 00 00 00       	jmp    801ae7 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8019fb:	83 f9 01             	cmp    $0x1,%ecx
  8019fe:	7e 18                	jle    801a18 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  801a00:	8b 45 14             	mov    0x14(%ebp),%eax
  801a03:	8b 10                	mov    (%eax),%edx
  801a05:	8b 48 04             	mov    0x4(%eax),%ecx
  801a08:	8d 40 08             	lea    0x8(%eax),%eax
  801a0b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801a0e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a13:	e9 cf 00 00 00       	jmp    801ae7 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801a18:	85 c9                	test   %ecx,%ecx
  801a1a:	74 1a                	je     801a36 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  801a1c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a1f:	8b 10                	mov    (%eax),%edx
  801a21:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a26:	8d 40 04             	lea    0x4(%eax),%eax
  801a29:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801a2c:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a31:	e9 b1 00 00 00       	jmp    801ae7 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801a36:	8b 45 14             	mov    0x14(%ebp),%eax
  801a39:	8b 10                	mov    (%eax),%edx
  801a3b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a40:	8d 40 04             	lea    0x4(%eax),%eax
  801a43:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801a46:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a4b:	e9 97 00 00 00       	jmp    801ae7 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801a50:	83 ec 08             	sub    $0x8,%esp
  801a53:	53                   	push   %ebx
  801a54:	6a 58                	push   $0x58
  801a56:	ff d6                	call   *%esi
			putch('X', putdat);
  801a58:	83 c4 08             	add    $0x8,%esp
  801a5b:	53                   	push   %ebx
  801a5c:	6a 58                	push   $0x58
  801a5e:	ff d6                	call   *%esi
			putch('X', putdat);
  801a60:	83 c4 08             	add    $0x8,%esp
  801a63:	53                   	push   %ebx
  801a64:	6a 58                	push   $0x58
  801a66:	ff d6                	call   *%esi
			break;
  801a68:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a6b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  801a6e:	e9 8b fc ff ff       	jmp    8016fe <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  801a73:	83 ec 08             	sub    $0x8,%esp
  801a76:	53                   	push   %ebx
  801a77:	6a 30                	push   $0x30
  801a79:	ff d6                	call   *%esi
			putch('x', putdat);
  801a7b:	83 c4 08             	add    $0x8,%esp
  801a7e:	53                   	push   %ebx
  801a7f:	6a 78                	push   $0x78
  801a81:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a83:	8b 45 14             	mov    0x14(%ebp),%eax
  801a86:	8b 10                	mov    (%eax),%edx
  801a88:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a8d:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a90:	8d 40 04             	lea    0x4(%eax),%eax
  801a93:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a96:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801a9b:	eb 4a                	jmp    801ae7 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a9d:	83 f9 01             	cmp    $0x1,%ecx
  801aa0:	7e 15                	jle    801ab7 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  801aa2:	8b 45 14             	mov    0x14(%ebp),%eax
  801aa5:	8b 10                	mov    (%eax),%edx
  801aa7:	8b 48 04             	mov    0x4(%eax),%ecx
  801aaa:	8d 40 08             	lea    0x8(%eax),%eax
  801aad:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801ab0:	b8 10 00 00 00       	mov    $0x10,%eax
  801ab5:	eb 30                	jmp    801ae7 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801ab7:	85 c9                	test   %ecx,%ecx
  801ab9:	74 17                	je     801ad2 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
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
  801ad0:	eb 15                	jmp    801ae7 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801ad2:	8b 45 14             	mov    0x14(%ebp),%eax
  801ad5:	8b 10                	mov    (%eax),%edx
  801ad7:	b9 00 00 00 00       	mov    $0x0,%ecx
  801adc:	8d 40 04             	lea    0x4(%eax),%eax
  801adf:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801ae2:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801ae7:	83 ec 0c             	sub    $0xc,%esp
  801aea:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801aee:	57                   	push   %edi
  801aef:	ff 75 e0             	pushl  -0x20(%ebp)
  801af2:	50                   	push   %eax
  801af3:	51                   	push   %ecx
  801af4:	52                   	push   %edx
  801af5:	89 da                	mov    %ebx,%edx
  801af7:	89 f0                	mov    %esi,%eax
  801af9:	e8 f1 fa ff ff       	call   8015ef <printnum>
			break;
  801afe:	83 c4 20             	add    $0x20,%esp
  801b01:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801b04:	e9 f5 fb ff ff       	jmp    8016fe <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801b09:	83 ec 08             	sub    $0x8,%esp
  801b0c:	53                   	push   %ebx
  801b0d:	52                   	push   %edx
  801b0e:	ff d6                	call   *%esi
			break;
  801b10:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801b13:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801b16:	e9 e3 fb ff ff       	jmp    8016fe <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801b1b:	83 ec 08             	sub    $0x8,%esp
  801b1e:	53                   	push   %ebx
  801b1f:	6a 25                	push   $0x25
  801b21:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b23:	83 c4 10             	add    $0x10,%esp
  801b26:	eb 03                	jmp    801b2b <vprintfmt+0x453>
  801b28:	83 ef 01             	sub    $0x1,%edi
  801b2b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b2f:	75 f7                	jne    801b28 <vprintfmt+0x450>
  801b31:	e9 c8 fb ff ff       	jmp    8016fe <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b39:	5b                   	pop    %ebx
  801b3a:	5e                   	pop    %esi
  801b3b:	5f                   	pop    %edi
  801b3c:	5d                   	pop    %ebp
  801b3d:	c3                   	ret    

00801b3e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	83 ec 18             	sub    $0x18,%esp
  801b44:	8b 45 08             	mov    0x8(%ebp),%eax
  801b47:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b4a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b4d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b51:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b54:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b5b:	85 c0                	test   %eax,%eax
  801b5d:	74 26                	je     801b85 <vsnprintf+0x47>
  801b5f:	85 d2                	test   %edx,%edx
  801b61:	7e 22                	jle    801b85 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b63:	ff 75 14             	pushl  0x14(%ebp)
  801b66:	ff 75 10             	pushl  0x10(%ebp)
  801b69:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b6c:	50                   	push   %eax
  801b6d:	68 9e 16 80 00       	push   $0x80169e
  801b72:	e8 61 fb ff ff       	call   8016d8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b77:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b7a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b80:	83 c4 10             	add    $0x10,%esp
  801b83:	eb 05                	jmp    801b8a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b85:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b8a:	c9                   	leave  
  801b8b:	c3                   	ret    

00801b8c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b8c:	55                   	push   %ebp
  801b8d:	89 e5                	mov    %esp,%ebp
  801b8f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b92:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b95:	50                   	push   %eax
  801b96:	ff 75 10             	pushl  0x10(%ebp)
  801b99:	ff 75 0c             	pushl  0xc(%ebp)
  801b9c:	ff 75 08             	pushl  0x8(%ebp)
  801b9f:	e8 9a ff ff ff       	call   801b3e <vsnprintf>
	va_end(ap);

	return rc;
}
  801ba4:	c9                   	leave  
  801ba5:	c3                   	ret    

00801ba6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801ba6:	55                   	push   %ebp
  801ba7:	89 e5                	mov    %esp,%ebp
  801ba9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801bac:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb1:	eb 03                	jmp    801bb6 <strlen+0x10>
		n++;
  801bb3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801bb6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801bba:	75 f7                	jne    801bb3 <strlen+0xd>
		n++;
	return n;
}
  801bbc:	5d                   	pop    %ebp
  801bbd:	c3                   	ret    

00801bbe <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801bbe:	55                   	push   %ebp
  801bbf:	89 e5                	mov    %esp,%ebp
  801bc1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bc4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bc7:	ba 00 00 00 00       	mov    $0x0,%edx
  801bcc:	eb 03                	jmp    801bd1 <strnlen+0x13>
		n++;
  801bce:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bd1:	39 c2                	cmp    %eax,%edx
  801bd3:	74 08                	je     801bdd <strnlen+0x1f>
  801bd5:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801bd9:	75 f3                	jne    801bce <strnlen+0x10>
  801bdb:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    

00801bdf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	53                   	push   %ebx
  801be3:	8b 45 08             	mov    0x8(%ebp),%eax
  801be6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801be9:	89 c2                	mov    %eax,%edx
  801beb:	83 c2 01             	add    $0x1,%edx
  801bee:	83 c1 01             	add    $0x1,%ecx
  801bf1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801bf5:	88 5a ff             	mov    %bl,-0x1(%edx)
  801bf8:	84 db                	test   %bl,%bl
  801bfa:	75 ef                	jne    801beb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801bfc:	5b                   	pop    %ebx
  801bfd:	5d                   	pop    %ebp
  801bfe:	c3                   	ret    

00801bff <strcat>:

char *
strcat(char *dst, const char *src)
{
  801bff:	55                   	push   %ebp
  801c00:	89 e5                	mov    %esp,%ebp
  801c02:	53                   	push   %ebx
  801c03:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801c06:	53                   	push   %ebx
  801c07:	e8 9a ff ff ff       	call   801ba6 <strlen>
  801c0c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801c0f:	ff 75 0c             	pushl  0xc(%ebp)
  801c12:	01 d8                	add    %ebx,%eax
  801c14:	50                   	push   %eax
  801c15:	e8 c5 ff ff ff       	call   801bdf <strcpy>
	return dst;
}
  801c1a:	89 d8                	mov    %ebx,%eax
  801c1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c1f:	c9                   	leave  
  801c20:	c3                   	ret    

00801c21 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c21:	55                   	push   %ebp
  801c22:	89 e5                	mov    %esp,%ebp
  801c24:	56                   	push   %esi
  801c25:	53                   	push   %ebx
  801c26:	8b 75 08             	mov    0x8(%ebp),%esi
  801c29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c2c:	89 f3                	mov    %esi,%ebx
  801c2e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c31:	89 f2                	mov    %esi,%edx
  801c33:	eb 0f                	jmp    801c44 <strncpy+0x23>
		*dst++ = *src;
  801c35:	83 c2 01             	add    $0x1,%edx
  801c38:	0f b6 01             	movzbl (%ecx),%eax
  801c3b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c3e:	80 39 01             	cmpb   $0x1,(%ecx)
  801c41:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c44:	39 da                	cmp    %ebx,%edx
  801c46:	75 ed                	jne    801c35 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c48:	89 f0                	mov    %esi,%eax
  801c4a:	5b                   	pop    %ebx
  801c4b:	5e                   	pop    %esi
  801c4c:	5d                   	pop    %ebp
  801c4d:	c3                   	ret    

00801c4e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c4e:	55                   	push   %ebp
  801c4f:	89 e5                	mov    %esp,%ebp
  801c51:	56                   	push   %esi
  801c52:	53                   	push   %ebx
  801c53:	8b 75 08             	mov    0x8(%ebp),%esi
  801c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c59:	8b 55 10             	mov    0x10(%ebp),%edx
  801c5c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c5e:	85 d2                	test   %edx,%edx
  801c60:	74 21                	je     801c83 <strlcpy+0x35>
  801c62:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c66:	89 f2                	mov    %esi,%edx
  801c68:	eb 09                	jmp    801c73 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c6a:	83 c2 01             	add    $0x1,%edx
  801c6d:	83 c1 01             	add    $0x1,%ecx
  801c70:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c73:	39 c2                	cmp    %eax,%edx
  801c75:	74 09                	je     801c80 <strlcpy+0x32>
  801c77:	0f b6 19             	movzbl (%ecx),%ebx
  801c7a:	84 db                	test   %bl,%bl
  801c7c:	75 ec                	jne    801c6a <strlcpy+0x1c>
  801c7e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c80:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c83:	29 f0                	sub    %esi,%eax
}
  801c85:	5b                   	pop    %ebx
  801c86:	5e                   	pop    %esi
  801c87:	5d                   	pop    %ebp
  801c88:	c3                   	ret    

00801c89 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c89:	55                   	push   %ebp
  801c8a:	89 e5                	mov    %esp,%ebp
  801c8c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c8f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c92:	eb 06                	jmp    801c9a <strcmp+0x11>
		p++, q++;
  801c94:	83 c1 01             	add    $0x1,%ecx
  801c97:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c9a:	0f b6 01             	movzbl (%ecx),%eax
  801c9d:	84 c0                	test   %al,%al
  801c9f:	74 04                	je     801ca5 <strcmp+0x1c>
  801ca1:	3a 02                	cmp    (%edx),%al
  801ca3:	74 ef                	je     801c94 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801ca5:	0f b6 c0             	movzbl %al,%eax
  801ca8:	0f b6 12             	movzbl (%edx),%edx
  801cab:	29 d0                	sub    %edx,%eax
}
  801cad:	5d                   	pop    %ebp
  801cae:	c3                   	ret    

00801caf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801caf:	55                   	push   %ebp
  801cb0:	89 e5                	mov    %esp,%ebp
  801cb2:	53                   	push   %ebx
  801cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cb9:	89 c3                	mov    %eax,%ebx
  801cbb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801cbe:	eb 06                	jmp    801cc6 <strncmp+0x17>
		n--, p++, q++;
  801cc0:	83 c0 01             	add    $0x1,%eax
  801cc3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801cc6:	39 d8                	cmp    %ebx,%eax
  801cc8:	74 15                	je     801cdf <strncmp+0x30>
  801cca:	0f b6 08             	movzbl (%eax),%ecx
  801ccd:	84 c9                	test   %cl,%cl
  801ccf:	74 04                	je     801cd5 <strncmp+0x26>
  801cd1:	3a 0a                	cmp    (%edx),%cl
  801cd3:	74 eb                	je     801cc0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801cd5:	0f b6 00             	movzbl (%eax),%eax
  801cd8:	0f b6 12             	movzbl (%edx),%edx
  801cdb:	29 d0                	sub    %edx,%eax
  801cdd:	eb 05                	jmp    801ce4 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801cdf:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801ce4:	5b                   	pop    %ebx
  801ce5:	5d                   	pop    %ebp
  801ce6:	c3                   	ret    

00801ce7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801ce7:	55                   	push   %ebp
  801ce8:	89 e5                	mov    %esp,%ebp
  801cea:	8b 45 08             	mov    0x8(%ebp),%eax
  801ced:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cf1:	eb 07                	jmp    801cfa <strchr+0x13>
		if (*s == c)
  801cf3:	38 ca                	cmp    %cl,%dl
  801cf5:	74 0f                	je     801d06 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801cf7:	83 c0 01             	add    $0x1,%eax
  801cfa:	0f b6 10             	movzbl (%eax),%edx
  801cfd:	84 d2                	test   %dl,%dl
  801cff:	75 f2                	jne    801cf3 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801d01:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d06:	5d                   	pop    %ebp
  801d07:	c3                   	ret    

00801d08 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801d08:	55                   	push   %ebp
  801d09:	89 e5                	mov    %esp,%ebp
  801d0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801d12:	eb 03                	jmp    801d17 <strfind+0xf>
  801d14:	83 c0 01             	add    $0x1,%eax
  801d17:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801d1a:	38 ca                	cmp    %cl,%dl
  801d1c:	74 04                	je     801d22 <strfind+0x1a>
  801d1e:	84 d2                	test   %dl,%dl
  801d20:	75 f2                	jne    801d14 <strfind+0xc>
			break;
	return (char *) s;
}
  801d22:	5d                   	pop    %ebp
  801d23:	c3                   	ret    

00801d24 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d24:	55                   	push   %ebp
  801d25:	89 e5                	mov    %esp,%ebp
  801d27:	57                   	push   %edi
  801d28:	56                   	push   %esi
  801d29:	53                   	push   %ebx
  801d2a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d2d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d30:	85 c9                	test   %ecx,%ecx
  801d32:	74 36                	je     801d6a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d34:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d3a:	75 28                	jne    801d64 <memset+0x40>
  801d3c:	f6 c1 03             	test   $0x3,%cl
  801d3f:	75 23                	jne    801d64 <memset+0x40>
		c &= 0xFF;
  801d41:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d45:	89 d3                	mov    %edx,%ebx
  801d47:	c1 e3 08             	shl    $0x8,%ebx
  801d4a:	89 d6                	mov    %edx,%esi
  801d4c:	c1 e6 18             	shl    $0x18,%esi
  801d4f:	89 d0                	mov    %edx,%eax
  801d51:	c1 e0 10             	shl    $0x10,%eax
  801d54:	09 f0                	or     %esi,%eax
  801d56:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d58:	89 d8                	mov    %ebx,%eax
  801d5a:	09 d0                	or     %edx,%eax
  801d5c:	c1 e9 02             	shr    $0x2,%ecx
  801d5f:	fc                   	cld    
  801d60:	f3 ab                	rep stos %eax,%es:(%edi)
  801d62:	eb 06                	jmp    801d6a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d67:	fc                   	cld    
  801d68:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d6a:	89 f8                	mov    %edi,%eax
  801d6c:	5b                   	pop    %ebx
  801d6d:	5e                   	pop    %esi
  801d6e:	5f                   	pop    %edi
  801d6f:	5d                   	pop    %ebp
  801d70:	c3                   	ret    

00801d71 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d71:	55                   	push   %ebp
  801d72:	89 e5                	mov    %esp,%ebp
  801d74:	57                   	push   %edi
  801d75:	56                   	push   %esi
  801d76:	8b 45 08             	mov    0x8(%ebp),%eax
  801d79:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d7c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d7f:	39 c6                	cmp    %eax,%esi
  801d81:	73 35                	jae    801db8 <memmove+0x47>
  801d83:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d86:	39 d0                	cmp    %edx,%eax
  801d88:	73 2e                	jae    801db8 <memmove+0x47>
		s += n;
		d += n;
  801d8a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d8d:	89 d6                	mov    %edx,%esi
  801d8f:	09 fe                	or     %edi,%esi
  801d91:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d97:	75 13                	jne    801dac <memmove+0x3b>
  801d99:	f6 c1 03             	test   $0x3,%cl
  801d9c:	75 0e                	jne    801dac <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d9e:	83 ef 04             	sub    $0x4,%edi
  801da1:	8d 72 fc             	lea    -0x4(%edx),%esi
  801da4:	c1 e9 02             	shr    $0x2,%ecx
  801da7:	fd                   	std    
  801da8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801daa:	eb 09                	jmp    801db5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801dac:	83 ef 01             	sub    $0x1,%edi
  801daf:	8d 72 ff             	lea    -0x1(%edx),%esi
  801db2:	fd                   	std    
  801db3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801db5:	fc                   	cld    
  801db6:	eb 1d                	jmp    801dd5 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801db8:	89 f2                	mov    %esi,%edx
  801dba:	09 c2                	or     %eax,%edx
  801dbc:	f6 c2 03             	test   $0x3,%dl
  801dbf:	75 0f                	jne    801dd0 <memmove+0x5f>
  801dc1:	f6 c1 03             	test   $0x3,%cl
  801dc4:	75 0a                	jne    801dd0 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801dc6:	c1 e9 02             	shr    $0x2,%ecx
  801dc9:	89 c7                	mov    %eax,%edi
  801dcb:	fc                   	cld    
  801dcc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801dce:	eb 05                	jmp    801dd5 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801dd0:	89 c7                	mov    %eax,%edi
  801dd2:	fc                   	cld    
  801dd3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801dd5:	5e                   	pop    %esi
  801dd6:	5f                   	pop    %edi
  801dd7:	5d                   	pop    %ebp
  801dd8:	c3                   	ret    

00801dd9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801dd9:	55                   	push   %ebp
  801dda:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801ddc:	ff 75 10             	pushl  0x10(%ebp)
  801ddf:	ff 75 0c             	pushl  0xc(%ebp)
  801de2:	ff 75 08             	pushl  0x8(%ebp)
  801de5:	e8 87 ff ff ff       	call   801d71 <memmove>
}
  801dea:	c9                   	leave  
  801deb:	c3                   	ret    

00801dec <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801dec:	55                   	push   %ebp
  801ded:	89 e5                	mov    %esp,%ebp
  801def:	56                   	push   %esi
  801df0:	53                   	push   %ebx
  801df1:	8b 45 08             	mov    0x8(%ebp),%eax
  801df4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801df7:	89 c6                	mov    %eax,%esi
  801df9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dfc:	eb 1a                	jmp    801e18 <memcmp+0x2c>
		if (*s1 != *s2)
  801dfe:	0f b6 08             	movzbl (%eax),%ecx
  801e01:	0f b6 1a             	movzbl (%edx),%ebx
  801e04:	38 d9                	cmp    %bl,%cl
  801e06:	74 0a                	je     801e12 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801e08:	0f b6 c1             	movzbl %cl,%eax
  801e0b:	0f b6 db             	movzbl %bl,%ebx
  801e0e:	29 d8                	sub    %ebx,%eax
  801e10:	eb 0f                	jmp    801e21 <memcmp+0x35>
		s1++, s2++;
  801e12:	83 c0 01             	add    $0x1,%eax
  801e15:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801e18:	39 f0                	cmp    %esi,%eax
  801e1a:	75 e2                	jne    801dfe <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801e1c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e21:	5b                   	pop    %ebx
  801e22:	5e                   	pop    %esi
  801e23:	5d                   	pop    %ebp
  801e24:	c3                   	ret    

00801e25 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e25:	55                   	push   %ebp
  801e26:	89 e5                	mov    %esp,%ebp
  801e28:	53                   	push   %ebx
  801e29:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e2c:	89 c1                	mov    %eax,%ecx
  801e2e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e31:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e35:	eb 0a                	jmp    801e41 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e37:	0f b6 10             	movzbl (%eax),%edx
  801e3a:	39 da                	cmp    %ebx,%edx
  801e3c:	74 07                	je     801e45 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e3e:	83 c0 01             	add    $0x1,%eax
  801e41:	39 c8                	cmp    %ecx,%eax
  801e43:	72 f2                	jb     801e37 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e45:	5b                   	pop    %ebx
  801e46:	5d                   	pop    %ebp
  801e47:	c3                   	ret    

00801e48 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e48:	55                   	push   %ebp
  801e49:	89 e5                	mov    %esp,%ebp
  801e4b:	57                   	push   %edi
  801e4c:	56                   	push   %esi
  801e4d:	53                   	push   %ebx
  801e4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e51:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e54:	eb 03                	jmp    801e59 <strtol+0x11>
		s++;
  801e56:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e59:	0f b6 01             	movzbl (%ecx),%eax
  801e5c:	3c 20                	cmp    $0x20,%al
  801e5e:	74 f6                	je     801e56 <strtol+0xe>
  801e60:	3c 09                	cmp    $0x9,%al
  801e62:	74 f2                	je     801e56 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e64:	3c 2b                	cmp    $0x2b,%al
  801e66:	75 0a                	jne    801e72 <strtol+0x2a>
		s++;
  801e68:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e6b:	bf 00 00 00 00       	mov    $0x0,%edi
  801e70:	eb 11                	jmp    801e83 <strtol+0x3b>
  801e72:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e77:	3c 2d                	cmp    $0x2d,%al
  801e79:	75 08                	jne    801e83 <strtol+0x3b>
		s++, neg = 1;
  801e7b:	83 c1 01             	add    $0x1,%ecx
  801e7e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e83:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e89:	75 15                	jne    801ea0 <strtol+0x58>
  801e8b:	80 39 30             	cmpb   $0x30,(%ecx)
  801e8e:	75 10                	jne    801ea0 <strtol+0x58>
  801e90:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e94:	75 7c                	jne    801f12 <strtol+0xca>
		s += 2, base = 16;
  801e96:	83 c1 02             	add    $0x2,%ecx
  801e99:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e9e:	eb 16                	jmp    801eb6 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801ea0:	85 db                	test   %ebx,%ebx
  801ea2:	75 12                	jne    801eb6 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801ea4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ea9:	80 39 30             	cmpb   $0x30,(%ecx)
  801eac:	75 08                	jne    801eb6 <strtol+0x6e>
		s++, base = 8;
  801eae:	83 c1 01             	add    $0x1,%ecx
  801eb1:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801eb6:	b8 00 00 00 00       	mov    $0x0,%eax
  801ebb:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801ebe:	0f b6 11             	movzbl (%ecx),%edx
  801ec1:	8d 72 d0             	lea    -0x30(%edx),%esi
  801ec4:	89 f3                	mov    %esi,%ebx
  801ec6:	80 fb 09             	cmp    $0x9,%bl
  801ec9:	77 08                	ja     801ed3 <strtol+0x8b>
			dig = *s - '0';
  801ecb:	0f be d2             	movsbl %dl,%edx
  801ece:	83 ea 30             	sub    $0x30,%edx
  801ed1:	eb 22                	jmp    801ef5 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801ed3:	8d 72 9f             	lea    -0x61(%edx),%esi
  801ed6:	89 f3                	mov    %esi,%ebx
  801ed8:	80 fb 19             	cmp    $0x19,%bl
  801edb:	77 08                	ja     801ee5 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801edd:	0f be d2             	movsbl %dl,%edx
  801ee0:	83 ea 57             	sub    $0x57,%edx
  801ee3:	eb 10                	jmp    801ef5 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801ee5:	8d 72 bf             	lea    -0x41(%edx),%esi
  801ee8:	89 f3                	mov    %esi,%ebx
  801eea:	80 fb 19             	cmp    $0x19,%bl
  801eed:	77 16                	ja     801f05 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801eef:	0f be d2             	movsbl %dl,%edx
  801ef2:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801ef5:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ef8:	7d 0b                	jge    801f05 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801efa:	83 c1 01             	add    $0x1,%ecx
  801efd:	0f af 45 10          	imul   0x10(%ebp),%eax
  801f01:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801f03:	eb b9                	jmp    801ebe <strtol+0x76>

	if (endptr)
  801f05:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801f09:	74 0d                	je     801f18 <strtol+0xd0>
		*endptr = (char *) s;
  801f0b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f0e:	89 0e                	mov    %ecx,(%esi)
  801f10:	eb 06                	jmp    801f18 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801f12:	85 db                	test   %ebx,%ebx
  801f14:	74 98                	je     801eae <strtol+0x66>
  801f16:	eb 9e                	jmp    801eb6 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801f18:	89 c2                	mov    %eax,%edx
  801f1a:	f7 da                	neg    %edx
  801f1c:	85 ff                	test   %edi,%edi
  801f1e:	0f 45 c2             	cmovne %edx,%eax
}
  801f21:	5b                   	pop    %ebx
  801f22:	5e                   	pop    %esi
  801f23:	5f                   	pop    %edi
  801f24:	5d                   	pop    %ebp
  801f25:	c3                   	ret    

00801f26 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f26:	55                   	push   %ebp
  801f27:	89 e5                	mov    %esp,%ebp
  801f29:	56                   	push   %esi
  801f2a:	53                   	push   %ebx
  801f2b:	8b 75 08             	mov    0x8(%ebp),%esi
  801f2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f31:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801f34:	85 c0                	test   %eax,%eax
  801f36:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f3b:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801f3e:	83 ec 0c             	sub    $0xc,%esp
  801f41:	50                   	push   %eax
  801f42:	e8 ea e3 ff ff       	call   800331 <sys_ipc_recv>
  801f47:	83 c4 10             	add    $0x10,%esp
  801f4a:	85 c0                	test   %eax,%eax
  801f4c:	79 16                	jns    801f64 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801f4e:	85 f6                	test   %esi,%esi
  801f50:	74 06                	je     801f58 <ipc_recv+0x32>
            *from_env_store = 0;
  801f52:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801f58:	85 db                	test   %ebx,%ebx
  801f5a:	74 2c                	je     801f88 <ipc_recv+0x62>
            *perm_store = 0;
  801f5c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f62:	eb 24                	jmp    801f88 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801f64:	85 f6                	test   %esi,%esi
  801f66:	74 0a                	je     801f72 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801f68:	a1 08 40 80 00       	mov    0x804008,%eax
  801f6d:	8b 40 74             	mov    0x74(%eax),%eax
  801f70:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801f72:	85 db                	test   %ebx,%ebx
  801f74:	74 0a                	je     801f80 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801f76:	a1 08 40 80 00       	mov    0x804008,%eax
  801f7b:	8b 40 78             	mov    0x78(%eax),%eax
  801f7e:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801f80:	a1 08 40 80 00       	mov    0x804008,%eax
  801f85:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801f88:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f8b:	5b                   	pop    %ebx
  801f8c:	5e                   	pop    %esi
  801f8d:	5d                   	pop    %ebp
  801f8e:	c3                   	ret    

00801f8f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f8f:	55                   	push   %ebp
  801f90:	89 e5                	mov    %esp,%ebp
  801f92:	57                   	push   %edi
  801f93:	56                   	push   %esi
  801f94:	53                   	push   %ebx
  801f95:	83 ec 0c             	sub    $0xc,%esp
  801f98:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f9b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f9e:	8b 45 10             	mov    0x10(%ebp),%eax
  801fa1:	85 c0                	test   %eax,%eax
  801fa3:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801fa8:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801fab:	eb 1c                	jmp    801fc9 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801fad:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fb0:	74 12                	je     801fc4 <ipc_send+0x35>
  801fb2:	50                   	push   %eax
  801fb3:	68 80 27 80 00       	push   $0x802780
  801fb8:	6a 3b                	push   $0x3b
  801fba:	68 96 27 80 00       	push   $0x802796
  801fbf:	e8 3e f5 ff ff       	call   801502 <_panic>
		sys_yield();
  801fc4:	e8 99 e1 ff ff       	call   800162 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801fc9:	ff 75 14             	pushl  0x14(%ebp)
  801fcc:	53                   	push   %ebx
  801fcd:	56                   	push   %esi
  801fce:	57                   	push   %edi
  801fcf:	e8 3a e3 ff ff       	call   80030e <sys_ipc_try_send>
  801fd4:	83 c4 10             	add    $0x10,%esp
  801fd7:	85 c0                	test   %eax,%eax
  801fd9:	78 d2                	js     801fad <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801fdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fde:	5b                   	pop    %ebx
  801fdf:	5e                   	pop    %esi
  801fe0:	5f                   	pop    %edi
  801fe1:	5d                   	pop    %ebp
  801fe2:	c3                   	ret    

00801fe3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fe3:	55                   	push   %ebp
  801fe4:	89 e5                	mov    %esp,%ebp
  801fe6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fe9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fee:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ff1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ff7:	8b 52 50             	mov    0x50(%edx),%edx
  801ffa:	39 ca                	cmp    %ecx,%edx
  801ffc:	75 0d                	jne    80200b <ipc_find_env+0x28>
			return envs[i].env_id;
  801ffe:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802001:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802006:	8b 40 48             	mov    0x48(%eax),%eax
  802009:	eb 0f                	jmp    80201a <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80200b:	83 c0 01             	add    $0x1,%eax
  80200e:	3d 00 04 00 00       	cmp    $0x400,%eax
  802013:	75 d9                	jne    801fee <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802015:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80201a:	5d                   	pop    %ebp
  80201b:	c3                   	ret    

0080201c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80201c:	55                   	push   %ebp
  80201d:	89 e5                	mov    %esp,%ebp
  80201f:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802022:	89 d0                	mov    %edx,%eax
  802024:	c1 e8 16             	shr    $0x16,%eax
  802027:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80202e:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802033:	f6 c1 01             	test   $0x1,%cl
  802036:	74 1d                	je     802055 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802038:	c1 ea 0c             	shr    $0xc,%edx
  80203b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802042:	f6 c2 01             	test   $0x1,%dl
  802045:	74 0e                	je     802055 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802047:	c1 ea 0c             	shr    $0xc,%edx
  80204a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802051:	ef 
  802052:	0f b7 c0             	movzwl %ax,%eax
}
  802055:	5d                   	pop    %ebp
  802056:	c3                   	ret    
  802057:	66 90                	xchg   %ax,%ax
  802059:	66 90                	xchg   %ax,%ax
  80205b:	66 90                	xchg   %ax,%ax
  80205d:	66 90                	xchg   %ax,%ax
  80205f:	90                   	nop

00802060 <__udivdi3>:
  802060:	55                   	push   %ebp
  802061:	57                   	push   %edi
  802062:	56                   	push   %esi
  802063:	53                   	push   %ebx
  802064:	83 ec 1c             	sub    $0x1c,%esp
  802067:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80206b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80206f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802073:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802077:	85 f6                	test   %esi,%esi
  802079:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80207d:	89 ca                	mov    %ecx,%edx
  80207f:	89 f8                	mov    %edi,%eax
  802081:	75 3d                	jne    8020c0 <__udivdi3+0x60>
  802083:	39 cf                	cmp    %ecx,%edi
  802085:	0f 87 c5 00 00 00    	ja     802150 <__udivdi3+0xf0>
  80208b:	85 ff                	test   %edi,%edi
  80208d:	89 fd                	mov    %edi,%ebp
  80208f:	75 0b                	jne    80209c <__udivdi3+0x3c>
  802091:	b8 01 00 00 00       	mov    $0x1,%eax
  802096:	31 d2                	xor    %edx,%edx
  802098:	f7 f7                	div    %edi
  80209a:	89 c5                	mov    %eax,%ebp
  80209c:	89 c8                	mov    %ecx,%eax
  80209e:	31 d2                	xor    %edx,%edx
  8020a0:	f7 f5                	div    %ebp
  8020a2:	89 c1                	mov    %eax,%ecx
  8020a4:	89 d8                	mov    %ebx,%eax
  8020a6:	89 cf                	mov    %ecx,%edi
  8020a8:	f7 f5                	div    %ebp
  8020aa:	89 c3                	mov    %eax,%ebx
  8020ac:	89 d8                	mov    %ebx,%eax
  8020ae:	89 fa                	mov    %edi,%edx
  8020b0:	83 c4 1c             	add    $0x1c,%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    
  8020b8:	90                   	nop
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	39 ce                	cmp    %ecx,%esi
  8020c2:	77 74                	ja     802138 <__udivdi3+0xd8>
  8020c4:	0f bd fe             	bsr    %esi,%edi
  8020c7:	83 f7 1f             	xor    $0x1f,%edi
  8020ca:	0f 84 98 00 00 00    	je     802168 <__udivdi3+0x108>
  8020d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	89 c5                	mov    %eax,%ebp
  8020d9:	29 fb                	sub    %edi,%ebx
  8020db:	d3 e6                	shl    %cl,%esi
  8020dd:	89 d9                	mov    %ebx,%ecx
  8020df:	d3 ed                	shr    %cl,%ebp
  8020e1:	89 f9                	mov    %edi,%ecx
  8020e3:	d3 e0                	shl    %cl,%eax
  8020e5:	09 ee                	or     %ebp,%esi
  8020e7:	89 d9                	mov    %ebx,%ecx
  8020e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ed:	89 d5                	mov    %edx,%ebp
  8020ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020f3:	d3 ed                	shr    %cl,%ebp
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	d3 e2                	shl    %cl,%edx
  8020f9:	89 d9                	mov    %ebx,%ecx
  8020fb:	d3 e8                	shr    %cl,%eax
  8020fd:	09 c2                	or     %eax,%edx
  8020ff:	89 d0                	mov    %edx,%eax
  802101:	89 ea                	mov    %ebp,%edx
  802103:	f7 f6                	div    %esi
  802105:	89 d5                	mov    %edx,%ebp
  802107:	89 c3                	mov    %eax,%ebx
  802109:	f7 64 24 0c          	mull   0xc(%esp)
  80210d:	39 d5                	cmp    %edx,%ebp
  80210f:	72 10                	jb     802121 <__udivdi3+0xc1>
  802111:	8b 74 24 08          	mov    0x8(%esp),%esi
  802115:	89 f9                	mov    %edi,%ecx
  802117:	d3 e6                	shl    %cl,%esi
  802119:	39 c6                	cmp    %eax,%esi
  80211b:	73 07                	jae    802124 <__udivdi3+0xc4>
  80211d:	39 d5                	cmp    %edx,%ebp
  80211f:	75 03                	jne    802124 <__udivdi3+0xc4>
  802121:	83 eb 01             	sub    $0x1,%ebx
  802124:	31 ff                	xor    %edi,%edi
  802126:	89 d8                	mov    %ebx,%eax
  802128:	89 fa                	mov    %edi,%edx
  80212a:	83 c4 1c             	add    $0x1c,%esp
  80212d:	5b                   	pop    %ebx
  80212e:	5e                   	pop    %esi
  80212f:	5f                   	pop    %edi
  802130:	5d                   	pop    %ebp
  802131:	c3                   	ret    
  802132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802138:	31 ff                	xor    %edi,%edi
  80213a:	31 db                	xor    %ebx,%ebx
  80213c:	89 d8                	mov    %ebx,%eax
  80213e:	89 fa                	mov    %edi,%edx
  802140:	83 c4 1c             	add    $0x1c,%esp
  802143:	5b                   	pop    %ebx
  802144:	5e                   	pop    %esi
  802145:	5f                   	pop    %edi
  802146:	5d                   	pop    %ebp
  802147:	c3                   	ret    
  802148:	90                   	nop
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	89 d8                	mov    %ebx,%eax
  802152:	f7 f7                	div    %edi
  802154:	31 ff                	xor    %edi,%edi
  802156:	89 c3                	mov    %eax,%ebx
  802158:	89 d8                	mov    %ebx,%eax
  80215a:	89 fa                	mov    %edi,%edx
  80215c:	83 c4 1c             	add    $0x1c,%esp
  80215f:	5b                   	pop    %ebx
  802160:	5e                   	pop    %esi
  802161:	5f                   	pop    %edi
  802162:	5d                   	pop    %ebp
  802163:	c3                   	ret    
  802164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802168:	39 ce                	cmp    %ecx,%esi
  80216a:	72 0c                	jb     802178 <__udivdi3+0x118>
  80216c:	31 db                	xor    %ebx,%ebx
  80216e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802172:	0f 87 34 ff ff ff    	ja     8020ac <__udivdi3+0x4c>
  802178:	bb 01 00 00 00       	mov    $0x1,%ebx
  80217d:	e9 2a ff ff ff       	jmp    8020ac <__udivdi3+0x4c>
  802182:	66 90                	xchg   %ax,%ax
  802184:	66 90                	xchg   %ax,%ax
  802186:	66 90                	xchg   %ax,%ax
  802188:	66 90                	xchg   %ax,%ax
  80218a:	66 90                	xchg   %ax,%ax
  80218c:	66 90                	xchg   %ax,%ax
  80218e:	66 90                	xchg   %ax,%ax

00802190 <__umoddi3>:
  802190:	55                   	push   %ebp
  802191:	57                   	push   %edi
  802192:	56                   	push   %esi
  802193:	53                   	push   %ebx
  802194:	83 ec 1c             	sub    $0x1c,%esp
  802197:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80219b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80219f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021a7:	85 d2                	test   %edx,%edx
  8021a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021b1:	89 f3                	mov    %esi,%ebx
  8021b3:	89 3c 24             	mov    %edi,(%esp)
  8021b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ba:	75 1c                	jne    8021d8 <__umoddi3+0x48>
  8021bc:	39 f7                	cmp    %esi,%edi
  8021be:	76 50                	jbe    802210 <__umoddi3+0x80>
  8021c0:	89 c8                	mov    %ecx,%eax
  8021c2:	89 f2                	mov    %esi,%edx
  8021c4:	f7 f7                	div    %edi
  8021c6:	89 d0                	mov    %edx,%eax
  8021c8:	31 d2                	xor    %edx,%edx
  8021ca:	83 c4 1c             	add    $0x1c,%esp
  8021cd:	5b                   	pop    %ebx
  8021ce:	5e                   	pop    %esi
  8021cf:	5f                   	pop    %edi
  8021d0:	5d                   	pop    %ebp
  8021d1:	c3                   	ret    
  8021d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021d8:	39 f2                	cmp    %esi,%edx
  8021da:	89 d0                	mov    %edx,%eax
  8021dc:	77 52                	ja     802230 <__umoddi3+0xa0>
  8021de:	0f bd ea             	bsr    %edx,%ebp
  8021e1:	83 f5 1f             	xor    $0x1f,%ebp
  8021e4:	75 5a                	jne    802240 <__umoddi3+0xb0>
  8021e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021ea:	0f 82 e0 00 00 00    	jb     8022d0 <__umoddi3+0x140>
  8021f0:	39 0c 24             	cmp    %ecx,(%esp)
  8021f3:	0f 86 d7 00 00 00    	jbe    8022d0 <__umoddi3+0x140>
  8021f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802201:	83 c4 1c             	add    $0x1c,%esp
  802204:	5b                   	pop    %ebx
  802205:	5e                   	pop    %esi
  802206:	5f                   	pop    %edi
  802207:	5d                   	pop    %ebp
  802208:	c3                   	ret    
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	85 ff                	test   %edi,%edi
  802212:	89 fd                	mov    %edi,%ebp
  802214:	75 0b                	jne    802221 <__umoddi3+0x91>
  802216:	b8 01 00 00 00       	mov    $0x1,%eax
  80221b:	31 d2                	xor    %edx,%edx
  80221d:	f7 f7                	div    %edi
  80221f:	89 c5                	mov    %eax,%ebp
  802221:	89 f0                	mov    %esi,%eax
  802223:	31 d2                	xor    %edx,%edx
  802225:	f7 f5                	div    %ebp
  802227:	89 c8                	mov    %ecx,%eax
  802229:	f7 f5                	div    %ebp
  80222b:	89 d0                	mov    %edx,%eax
  80222d:	eb 99                	jmp    8021c8 <__umoddi3+0x38>
  80222f:	90                   	nop
  802230:	89 c8                	mov    %ecx,%eax
  802232:	89 f2                	mov    %esi,%edx
  802234:	83 c4 1c             	add    $0x1c,%esp
  802237:	5b                   	pop    %ebx
  802238:	5e                   	pop    %esi
  802239:	5f                   	pop    %edi
  80223a:	5d                   	pop    %ebp
  80223b:	c3                   	ret    
  80223c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802240:	8b 34 24             	mov    (%esp),%esi
  802243:	bf 20 00 00 00       	mov    $0x20,%edi
  802248:	89 e9                	mov    %ebp,%ecx
  80224a:	29 ef                	sub    %ebp,%edi
  80224c:	d3 e0                	shl    %cl,%eax
  80224e:	89 f9                	mov    %edi,%ecx
  802250:	89 f2                	mov    %esi,%edx
  802252:	d3 ea                	shr    %cl,%edx
  802254:	89 e9                	mov    %ebp,%ecx
  802256:	09 c2                	or     %eax,%edx
  802258:	89 d8                	mov    %ebx,%eax
  80225a:	89 14 24             	mov    %edx,(%esp)
  80225d:	89 f2                	mov    %esi,%edx
  80225f:	d3 e2                	shl    %cl,%edx
  802261:	89 f9                	mov    %edi,%ecx
  802263:	89 54 24 04          	mov    %edx,0x4(%esp)
  802267:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80226b:	d3 e8                	shr    %cl,%eax
  80226d:	89 e9                	mov    %ebp,%ecx
  80226f:	89 c6                	mov    %eax,%esi
  802271:	d3 e3                	shl    %cl,%ebx
  802273:	89 f9                	mov    %edi,%ecx
  802275:	89 d0                	mov    %edx,%eax
  802277:	d3 e8                	shr    %cl,%eax
  802279:	89 e9                	mov    %ebp,%ecx
  80227b:	09 d8                	or     %ebx,%eax
  80227d:	89 d3                	mov    %edx,%ebx
  80227f:	89 f2                	mov    %esi,%edx
  802281:	f7 34 24             	divl   (%esp)
  802284:	89 d6                	mov    %edx,%esi
  802286:	d3 e3                	shl    %cl,%ebx
  802288:	f7 64 24 04          	mull   0x4(%esp)
  80228c:	39 d6                	cmp    %edx,%esi
  80228e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802292:	89 d1                	mov    %edx,%ecx
  802294:	89 c3                	mov    %eax,%ebx
  802296:	72 08                	jb     8022a0 <__umoddi3+0x110>
  802298:	75 11                	jne    8022ab <__umoddi3+0x11b>
  80229a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80229e:	73 0b                	jae    8022ab <__umoddi3+0x11b>
  8022a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022a4:	1b 14 24             	sbb    (%esp),%edx
  8022a7:	89 d1                	mov    %edx,%ecx
  8022a9:	89 c3                	mov    %eax,%ebx
  8022ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022af:	29 da                	sub    %ebx,%edx
  8022b1:	19 ce                	sbb    %ecx,%esi
  8022b3:	89 f9                	mov    %edi,%ecx
  8022b5:	89 f0                	mov    %esi,%eax
  8022b7:	d3 e0                	shl    %cl,%eax
  8022b9:	89 e9                	mov    %ebp,%ecx
  8022bb:	d3 ea                	shr    %cl,%edx
  8022bd:	89 e9                	mov    %ebp,%ecx
  8022bf:	d3 ee                	shr    %cl,%esi
  8022c1:	09 d0                	or     %edx,%eax
  8022c3:	89 f2                	mov    %esi,%edx
  8022c5:	83 c4 1c             	add    $0x1c,%esp
  8022c8:	5b                   	pop    %ebx
  8022c9:	5e                   	pop    %esi
  8022ca:	5f                   	pop    %edi
  8022cb:	5d                   	pop    %ebp
  8022cc:	c3                   	ret    
  8022cd:	8d 76 00             	lea    0x0(%esi),%esi
  8022d0:	29 f9                	sub    %edi,%ecx
  8022d2:	19 d6                	sbb    %edx,%esi
  8022d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022dc:	e9 18 ff ff ff       	jmp    8021f9 <__umoddi3+0x69>
