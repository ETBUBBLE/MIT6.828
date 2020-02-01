
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
  800082:	a3 04 40 80 00       	mov    %eax,0x804004

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
  8000b1:	e8 87 04 00 00       	call   80053d <close_all>
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
  80012a:	68 6a 1e 80 00       	push   $0x801e6a
  80012f:	6a 23                	push   $0x23
  800131:	68 87 1e 80 00       	push   $0x801e87
  800136:	e8 21 0f 00 00       	call   80105c <_panic>

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
  8001ab:	68 6a 1e 80 00       	push   $0x801e6a
  8001b0:	6a 23                	push   $0x23
  8001b2:	68 87 1e 80 00       	push   $0x801e87
  8001b7:	e8 a0 0e 00 00       	call   80105c <_panic>

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
  8001ed:	68 6a 1e 80 00       	push   $0x801e6a
  8001f2:	6a 23                	push   $0x23
  8001f4:	68 87 1e 80 00       	push   $0x801e87
  8001f9:	e8 5e 0e 00 00       	call   80105c <_panic>

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
  80022f:	68 6a 1e 80 00       	push   $0x801e6a
  800234:	6a 23                	push   $0x23
  800236:	68 87 1e 80 00       	push   $0x801e87
  80023b:	e8 1c 0e 00 00       	call   80105c <_panic>

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
  800271:	68 6a 1e 80 00       	push   $0x801e6a
  800276:	6a 23                	push   $0x23
  800278:	68 87 1e 80 00       	push   $0x801e87
  80027d:	e8 da 0d 00 00       	call   80105c <_panic>

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
  8002b3:	68 6a 1e 80 00       	push   $0x801e6a
  8002b8:	6a 23                	push   $0x23
  8002ba:	68 87 1e 80 00       	push   $0x801e87
  8002bf:	e8 98 0d 00 00       	call   80105c <_panic>

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
  8002f5:	68 6a 1e 80 00       	push   $0x801e6a
  8002fa:	6a 23                	push   $0x23
  8002fc:	68 87 1e 80 00       	push   $0x801e87
  800301:	e8 56 0d 00 00       	call   80105c <_panic>

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
  800359:	68 6a 1e 80 00       	push   $0x801e6a
  80035e:	6a 23                	push   $0x23
  800360:	68 87 1e 80 00       	push   $0x801e87
  800365:	e8 f2 0c 00 00       	call   80105c <_panic>

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

00800372 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800375:	8b 45 08             	mov    0x8(%ebp),%eax
  800378:	05 00 00 00 30       	add    $0x30000000,%eax
  80037d:	c1 e8 0c             	shr    $0xc,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800385:	8b 45 08             	mov    0x8(%ebp),%eax
  800388:	05 00 00 00 30       	add    $0x30000000,%eax
  80038d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800392:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800397:	5d                   	pop    %ebp
  800398:	c3                   	ret    

00800399 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a4:	89 c2                	mov    %eax,%edx
  8003a6:	c1 ea 16             	shr    $0x16,%edx
  8003a9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b0:	f6 c2 01             	test   $0x1,%dl
  8003b3:	74 11                	je     8003c6 <fd_alloc+0x2d>
  8003b5:	89 c2                	mov    %eax,%edx
  8003b7:	c1 ea 0c             	shr    $0xc,%edx
  8003ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c1:	f6 c2 01             	test   $0x1,%dl
  8003c4:	75 09                	jne    8003cf <fd_alloc+0x36>
			*fd_store = fd;
  8003c6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003cd:	eb 17                	jmp    8003e6 <fd_alloc+0x4d>
  8003cf:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003d4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003d9:	75 c9                	jne    8003a4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003db:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003e1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003e6:	5d                   	pop    %ebp
  8003e7:	c3                   	ret    

008003e8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003ee:	83 f8 1f             	cmp    $0x1f,%eax
  8003f1:	77 36                	ja     800429 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003f3:	c1 e0 0c             	shl    $0xc,%eax
  8003f6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003fb:	89 c2                	mov    %eax,%edx
  8003fd:	c1 ea 16             	shr    $0x16,%edx
  800400:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800407:	f6 c2 01             	test   $0x1,%dl
  80040a:	74 24                	je     800430 <fd_lookup+0x48>
  80040c:	89 c2                	mov    %eax,%edx
  80040e:	c1 ea 0c             	shr    $0xc,%edx
  800411:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800418:	f6 c2 01             	test   $0x1,%dl
  80041b:	74 1a                	je     800437 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80041d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800420:	89 02                	mov    %eax,(%edx)
	return 0;
  800422:	b8 00 00 00 00       	mov    $0x0,%eax
  800427:	eb 13                	jmp    80043c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800429:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80042e:	eb 0c                	jmp    80043c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800430:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800435:	eb 05                	jmp    80043c <fd_lookup+0x54>
  800437:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80043c:	5d                   	pop    %ebp
  80043d:	c3                   	ret    

0080043e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800447:	ba 14 1f 80 00       	mov    $0x801f14,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80044c:	eb 13                	jmp    800461 <dev_lookup+0x23>
  80044e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800451:	39 08                	cmp    %ecx,(%eax)
  800453:	75 0c                	jne    800461 <dev_lookup+0x23>
			*dev = devtab[i];
  800455:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800458:	89 01                	mov    %eax,(%ecx)
			return 0;
  80045a:	b8 00 00 00 00       	mov    $0x0,%eax
  80045f:	eb 2e                	jmp    80048f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800461:	8b 02                	mov    (%edx),%eax
  800463:	85 c0                	test   %eax,%eax
  800465:	75 e7                	jne    80044e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800467:	a1 04 40 80 00       	mov    0x804004,%eax
  80046c:	8b 40 48             	mov    0x48(%eax),%eax
  80046f:	83 ec 04             	sub    $0x4,%esp
  800472:	51                   	push   %ecx
  800473:	50                   	push   %eax
  800474:	68 98 1e 80 00       	push   $0x801e98
  800479:	e8 b7 0c 00 00       	call   801135 <cprintf>
	*dev = 0;
  80047e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800481:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800487:	83 c4 10             	add    $0x10,%esp
  80048a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80048f:	c9                   	leave  
  800490:	c3                   	ret    

00800491 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800491:	55                   	push   %ebp
  800492:	89 e5                	mov    %esp,%ebp
  800494:	56                   	push   %esi
  800495:	53                   	push   %ebx
  800496:	83 ec 10             	sub    $0x10,%esp
  800499:	8b 75 08             	mov    0x8(%ebp),%esi
  80049c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80049f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004a2:	50                   	push   %eax
  8004a3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004a9:	c1 e8 0c             	shr    $0xc,%eax
  8004ac:	50                   	push   %eax
  8004ad:	e8 36 ff ff ff       	call   8003e8 <fd_lookup>
  8004b2:	83 c4 08             	add    $0x8,%esp
  8004b5:	85 c0                	test   %eax,%eax
  8004b7:	78 05                	js     8004be <fd_close+0x2d>
	    || fd != fd2)
  8004b9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004bc:	74 0c                	je     8004ca <fd_close+0x39>
		return (must_exist ? r : 0);
  8004be:	84 db                	test   %bl,%bl
  8004c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c5:	0f 44 c2             	cmove  %edx,%eax
  8004c8:	eb 41                	jmp    80050b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004d0:	50                   	push   %eax
  8004d1:	ff 36                	pushl  (%esi)
  8004d3:	e8 66 ff ff ff       	call   80043e <dev_lookup>
  8004d8:	89 c3                	mov    %eax,%ebx
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	85 c0                	test   %eax,%eax
  8004df:	78 1a                	js     8004fb <fd_close+0x6a>
		if (dev->dev_close)
  8004e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004e4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004e7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ec:	85 c0                	test   %eax,%eax
  8004ee:	74 0b                	je     8004fb <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004f0:	83 ec 0c             	sub    $0xc,%esp
  8004f3:	56                   	push   %esi
  8004f4:	ff d0                	call   *%eax
  8004f6:	89 c3                	mov    %eax,%ebx
  8004f8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	56                   	push   %esi
  8004ff:	6a 00                	push   $0x0
  800501:	e8 00 fd ff ff       	call   800206 <sys_page_unmap>
	return r;
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	89 d8                	mov    %ebx,%eax
}
  80050b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80050e:	5b                   	pop    %ebx
  80050f:	5e                   	pop    %esi
  800510:	5d                   	pop    %ebp
  800511:	c3                   	ret    

00800512 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800518:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80051b:	50                   	push   %eax
  80051c:	ff 75 08             	pushl  0x8(%ebp)
  80051f:	e8 c4 fe ff ff       	call   8003e8 <fd_lookup>
  800524:	83 c4 08             	add    $0x8,%esp
  800527:	85 c0                	test   %eax,%eax
  800529:	78 10                	js     80053b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	6a 01                	push   $0x1
  800530:	ff 75 f4             	pushl  -0xc(%ebp)
  800533:	e8 59 ff ff ff       	call   800491 <fd_close>
  800538:	83 c4 10             	add    $0x10,%esp
}
  80053b:	c9                   	leave  
  80053c:	c3                   	ret    

0080053d <close_all>:

void
close_all(void)
{
  80053d:	55                   	push   %ebp
  80053e:	89 e5                	mov    %esp,%ebp
  800540:	53                   	push   %ebx
  800541:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800544:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800549:	83 ec 0c             	sub    $0xc,%esp
  80054c:	53                   	push   %ebx
  80054d:	e8 c0 ff ff ff       	call   800512 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800552:	83 c3 01             	add    $0x1,%ebx
  800555:	83 c4 10             	add    $0x10,%esp
  800558:	83 fb 20             	cmp    $0x20,%ebx
  80055b:	75 ec                	jne    800549 <close_all+0xc>
		close(i);
}
  80055d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800560:	c9                   	leave  
  800561:	c3                   	ret    

00800562 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800562:	55                   	push   %ebp
  800563:	89 e5                	mov    %esp,%ebp
  800565:	57                   	push   %edi
  800566:	56                   	push   %esi
  800567:	53                   	push   %ebx
  800568:	83 ec 2c             	sub    $0x2c,%esp
  80056b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80056e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800571:	50                   	push   %eax
  800572:	ff 75 08             	pushl  0x8(%ebp)
  800575:	e8 6e fe ff ff       	call   8003e8 <fd_lookup>
  80057a:	83 c4 08             	add    $0x8,%esp
  80057d:	85 c0                	test   %eax,%eax
  80057f:	0f 88 c1 00 00 00    	js     800646 <dup+0xe4>
		return r;
	close(newfdnum);
  800585:	83 ec 0c             	sub    $0xc,%esp
  800588:	56                   	push   %esi
  800589:	e8 84 ff ff ff       	call   800512 <close>

	newfd = INDEX2FD(newfdnum);
  80058e:	89 f3                	mov    %esi,%ebx
  800590:	c1 e3 0c             	shl    $0xc,%ebx
  800593:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800599:	83 c4 04             	add    $0x4,%esp
  80059c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80059f:	e8 de fd ff ff       	call   800382 <fd2data>
  8005a4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005a6:	89 1c 24             	mov    %ebx,(%esp)
  8005a9:	e8 d4 fd ff ff       	call   800382 <fd2data>
  8005ae:	83 c4 10             	add    $0x10,%esp
  8005b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005b4:	89 f8                	mov    %edi,%eax
  8005b6:	c1 e8 16             	shr    $0x16,%eax
  8005b9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005c0:	a8 01                	test   $0x1,%al
  8005c2:	74 37                	je     8005fb <dup+0x99>
  8005c4:	89 f8                	mov    %edi,%eax
  8005c6:	c1 e8 0c             	shr    $0xc,%eax
  8005c9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005d0:	f6 c2 01             	test   $0x1,%dl
  8005d3:	74 26                	je     8005fb <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005dc:	83 ec 0c             	sub    $0xc,%esp
  8005df:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e4:	50                   	push   %eax
  8005e5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005e8:	6a 00                	push   $0x0
  8005ea:	57                   	push   %edi
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 d2 fb ff ff       	call   8001c4 <sys_page_map>
  8005f2:	89 c7                	mov    %eax,%edi
  8005f4:	83 c4 20             	add    $0x20,%esp
  8005f7:	85 c0                	test   %eax,%eax
  8005f9:	78 2e                	js     800629 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fe:	89 d0                	mov    %edx,%eax
  800600:	c1 e8 0c             	shr    $0xc,%eax
  800603:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060a:	83 ec 0c             	sub    $0xc,%esp
  80060d:	25 07 0e 00 00       	and    $0xe07,%eax
  800612:	50                   	push   %eax
  800613:	53                   	push   %ebx
  800614:	6a 00                	push   $0x0
  800616:	52                   	push   %edx
  800617:	6a 00                	push   $0x0
  800619:	e8 a6 fb ff ff       	call   8001c4 <sys_page_map>
  80061e:	89 c7                	mov    %eax,%edi
  800620:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800623:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800625:	85 ff                	test   %edi,%edi
  800627:	79 1d                	jns    800646 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	53                   	push   %ebx
  80062d:	6a 00                	push   $0x0
  80062f:	e8 d2 fb ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800634:	83 c4 08             	add    $0x8,%esp
  800637:	ff 75 d4             	pushl  -0x2c(%ebp)
  80063a:	6a 00                	push   $0x0
  80063c:	e8 c5 fb ff ff       	call   800206 <sys_page_unmap>
	return r;
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	89 f8                	mov    %edi,%eax
}
  800646:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800649:	5b                   	pop    %ebx
  80064a:	5e                   	pop    %esi
  80064b:	5f                   	pop    %edi
  80064c:	5d                   	pop    %ebp
  80064d:	c3                   	ret    

0080064e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80064e:	55                   	push   %ebp
  80064f:	89 e5                	mov    %esp,%ebp
  800651:	53                   	push   %ebx
  800652:	83 ec 14             	sub    $0x14,%esp
  800655:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800658:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80065b:	50                   	push   %eax
  80065c:	53                   	push   %ebx
  80065d:	e8 86 fd ff ff       	call   8003e8 <fd_lookup>
  800662:	83 c4 08             	add    $0x8,%esp
  800665:	89 c2                	mov    %eax,%edx
  800667:	85 c0                	test   %eax,%eax
  800669:	78 6d                	js     8006d8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800671:	50                   	push   %eax
  800672:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800675:	ff 30                	pushl  (%eax)
  800677:	e8 c2 fd ff ff       	call   80043e <dev_lookup>
  80067c:	83 c4 10             	add    $0x10,%esp
  80067f:	85 c0                	test   %eax,%eax
  800681:	78 4c                	js     8006cf <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800683:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800686:	8b 42 08             	mov    0x8(%edx),%eax
  800689:	83 e0 03             	and    $0x3,%eax
  80068c:	83 f8 01             	cmp    $0x1,%eax
  80068f:	75 21                	jne    8006b2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800691:	a1 04 40 80 00       	mov    0x804004,%eax
  800696:	8b 40 48             	mov    0x48(%eax),%eax
  800699:	83 ec 04             	sub    $0x4,%esp
  80069c:	53                   	push   %ebx
  80069d:	50                   	push   %eax
  80069e:	68 d9 1e 80 00       	push   $0x801ed9
  8006a3:	e8 8d 0a 00 00       	call   801135 <cprintf>
		return -E_INVAL;
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006b0:	eb 26                	jmp    8006d8 <read+0x8a>
	}
	if (!dev->dev_read)
  8006b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b5:	8b 40 08             	mov    0x8(%eax),%eax
  8006b8:	85 c0                	test   %eax,%eax
  8006ba:	74 17                	je     8006d3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006bc:	83 ec 04             	sub    $0x4,%esp
  8006bf:	ff 75 10             	pushl  0x10(%ebp)
  8006c2:	ff 75 0c             	pushl  0xc(%ebp)
  8006c5:	52                   	push   %edx
  8006c6:	ff d0                	call   *%eax
  8006c8:	89 c2                	mov    %eax,%edx
  8006ca:	83 c4 10             	add    $0x10,%esp
  8006cd:	eb 09                	jmp    8006d8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006cf:	89 c2                	mov    %eax,%edx
  8006d1:	eb 05                	jmp    8006d8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006d3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006d8:	89 d0                	mov    %edx,%eax
  8006da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006dd:	c9                   	leave  
  8006de:	c3                   	ret    

008006df <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	57                   	push   %edi
  8006e3:	56                   	push   %esi
  8006e4:	53                   	push   %ebx
  8006e5:	83 ec 0c             	sub    $0xc,%esp
  8006e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006eb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f3:	eb 21                	jmp    800716 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f5:	83 ec 04             	sub    $0x4,%esp
  8006f8:	89 f0                	mov    %esi,%eax
  8006fa:	29 d8                	sub    %ebx,%eax
  8006fc:	50                   	push   %eax
  8006fd:	89 d8                	mov    %ebx,%eax
  8006ff:	03 45 0c             	add    0xc(%ebp),%eax
  800702:	50                   	push   %eax
  800703:	57                   	push   %edi
  800704:	e8 45 ff ff ff       	call   80064e <read>
		if (m < 0)
  800709:	83 c4 10             	add    $0x10,%esp
  80070c:	85 c0                	test   %eax,%eax
  80070e:	78 10                	js     800720 <readn+0x41>
			return m;
		if (m == 0)
  800710:	85 c0                	test   %eax,%eax
  800712:	74 0a                	je     80071e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800714:	01 c3                	add    %eax,%ebx
  800716:	39 f3                	cmp    %esi,%ebx
  800718:	72 db                	jb     8006f5 <readn+0x16>
  80071a:	89 d8                	mov    %ebx,%eax
  80071c:	eb 02                	jmp    800720 <readn+0x41>
  80071e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800720:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800723:	5b                   	pop    %ebx
  800724:	5e                   	pop    %esi
  800725:	5f                   	pop    %edi
  800726:	5d                   	pop    %ebp
  800727:	c3                   	ret    

00800728 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	53                   	push   %ebx
  80072c:	83 ec 14             	sub    $0x14,%esp
  80072f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800732:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800735:	50                   	push   %eax
  800736:	53                   	push   %ebx
  800737:	e8 ac fc ff ff       	call   8003e8 <fd_lookup>
  80073c:	83 c4 08             	add    $0x8,%esp
  80073f:	89 c2                	mov    %eax,%edx
  800741:	85 c0                	test   %eax,%eax
  800743:	78 68                	js     8007ad <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80074b:	50                   	push   %eax
  80074c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074f:	ff 30                	pushl  (%eax)
  800751:	e8 e8 fc ff ff       	call   80043e <dev_lookup>
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	85 c0                	test   %eax,%eax
  80075b:	78 47                	js     8007a4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80075d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800760:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800764:	75 21                	jne    800787 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800766:	a1 04 40 80 00       	mov    0x804004,%eax
  80076b:	8b 40 48             	mov    0x48(%eax),%eax
  80076e:	83 ec 04             	sub    $0x4,%esp
  800771:	53                   	push   %ebx
  800772:	50                   	push   %eax
  800773:	68 f5 1e 80 00       	push   $0x801ef5
  800778:	e8 b8 09 00 00       	call   801135 <cprintf>
		return -E_INVAL;
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800785:	eb 26                	jmp    8007ad <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800787:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80078a:	8b 52 0c             	mov    0xc(%edx),%edx
  80078d:	85 d2                	test   %edx,%edx
  80078f:	74 17                	je     8007a8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800791:	83 ec 04             	sub    $0x4,%esp
  800794:	ff 75 10             	pushl  0x10(%ebp)
  800797:	ff 75 0c             	pushl  0xc(%ebp)
  80079a:	50                   	push   %eax
  80079b:	ff d2                	call   *%edx
  80079d:	89 c2                	mov    %eax,%edx
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	eb 09                	jmp    8007ad <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a4:	89 c2                	mov    %eax,%edx
  8007a6:	eb 05                	jmp    8007ad <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007ad:	89 d0                	mov    %edx,%eax
  8007af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ba:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007bd:	50                   	push   %eax
  8007be:	ff 75 08             	pushl  0x8(%ebp)
  8007c1:	e8 22 fc ff ff       	call   8003e8 <fd_lookup>
  8007c6:	83 c4 08             	add    $0x8,%esp
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	78 0e                	js     8007db <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    

008007dd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	53                   	push   %ebx
  8007e1:	83 ec 14             	sub    $0x14,%esp
  8007e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ea:	50                   	push   %eax
  8007eb:	53                   	push   %ebx
  8007ec:	e8 f7 fb ff ff       	call   8003e8 <fd_lookup>
  8007f1:	83 c4 08             	add    $0x8,%esp
  8007f4:	89 c2                	mov    %eax,%edx
  8007f6:	85 c0                	test   %eax,%eax
  8007f8:	78 65                	js     80085f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800800:	50                   	push   %eax
  800801:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800804:	ff 30                	pushl  (%eax)
  800806:	e8 33 fc ff ff       	call   80043e <dev_lookup>
  80080b:	83 c4 10             	add    $0x10,%esp
  80080e:	85 c0                	test   %eax,%eax
  800810:	78 44                	js     800856 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800812:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800815:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800819:	75 21                	jne    80083c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80081b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800820:	8b 40 48             	mov    0x48(%eax),%eax
  800823:	83 ec 04             	sub    $0x4,%esp
  800826:	53                   	push   %ebx
  800827:	50                   	push   %eax
  800828:	68 b8 1e 80 00       	push   $0x801eb8
  80082d:	e8 03 09 00 00       	call   801135 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800832:	83 c4 10             	add    $0x10,%esp
  800835:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80083a:	eb 23                	jmp    80085f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80083c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80083f:	8b 52 18             	mov    0x18(%edx),%edx
  800842:	85 d2                	test   %edx,%edx
  800844:	74 14                	je     80085a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800846:	83 ec 08             	sub    $0x8,%esp
  800849:	ff 75 0c             	pushl  0xc(%ebp)
  80084c:	50                   	push   %eax
  80084d:	ff d2                	call   *%edx
  80084f:	89 c2                	mov    %eax,%edx
  800851:	83 c4 10             	add    $0x10,%esp
  800854:	eb 09                	jmp    80085f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800856:	89 c2                	mov    %eax,%edx
  800858:	eb 05                	jmp    80085f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80085a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80085f:	89 d0                	mov    %edx,%eax
  800861:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800864:	c9                   	leave  
  800865:	c3                   	ret    

00800866 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	53                   	push   %ebx
  80086a:	83 ec 14             	sub    $0x14,%esp
  80086d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800870:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800873:	50                   	push   %eax
  800874:	ff 75 08             	pushl  0x8(%ebp)
  800877:	e8 6c fb ff ff       	call   8003e8 <fd_lookup>
  80087c:	83 c4 08             	add    $0x8,%esp
  80087f:	89 c2                	mov    %eax,%edx
  800881:	85 c0                	test   %eax,%eax
  800883:	78 58                	js     8008dd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800885:	83 ec 08             	sub    $0x8,%esp
  800888:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80088b:	50                   	push   %eax
  80088c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088f:	ff 30                	pushl  (%eax)
  800891:	e8 a8 fb ff ff       	call   80043e <dev_lookup>
  800896:	83 c4 10             	add    $0x10,%esp
  800899:	85 c0                	test   %eax,%eax
  80089b:	78 37                	js     8008d4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80089d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008a4:	74 32                	je     8008d8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008a6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008a9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008b0:	00 00 00 
	stat->st_isdir = 0;
  8008b3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ba:	00 00 00 
	stat->st_dev = dev;
  8008bd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008c3:	83 ec 08             	sub    $0x8,%esp
  8008c6:	53                   	push   %ebx
  8008c7:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ca:	ff 50 14             	call   *0x14(%eax)
  8008cd:	89 c2                	mov    %eax,%edx
  8008cf:	83 c4 10             	add    $0x10,%esp
  8008d2:	eb 09                	jmp    8008dd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d4:	89 c2                	mov    %eax,%edx
  8008d6:	eb 05                	jmp    8008dd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008d8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008dd:	89 d0                	mov    %edx,%eax
  8008df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008e9:	83 ec 08             	sub    $0x8,%esp
  8008ec:	6a 00                	push   $0x0
  8008ee:	ff 75 08             	pushl  0x8(%ebp)
  8008f1:	e8 e3 01 00 00       	call   800ad9 <open>
  8008f6:	89 c3                	mov    %eax,%ebx
  8008f8:	83 c4 10             	add    $0x10,%esp
  8008fb:	85 c0                	test   %eax,%eax
  8008fd:	78 1b                	js     80091a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008ff:	83 ec 08             	sub    $0x8,%esp
  800902:	ff 75 0c             	pushl  0xc(%ebp)
  800905:	50                   	push   %eax
  800906:	e8 5b ff ff ff       	call   800866 <fstat>
  80090b:	89 c6                	mov    %eax,%esi
	close(fd);
  80090d:	89 1c 24             	mov    %ebx,(%esp)
  800910:	e8 fd fb ff ff       	call   800512 <close>
	return r;
  800915:	83 c4 10             	add    $0x10,%esp
  800918:	89 f0                	mov    %esi,%eax
}
  80091a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80091d:	5b                   	pop    %ebx
  80091e:	5e                   	pop    %esi
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	56                   	push   %esi
  800925:	53                   	push   %ebx
  800926:	89 c6                	mov    %eax,%esi
  800928:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80092a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800931:	75 12                	jne    800945 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800933:	83 ec 0c             	sub    $0xc,%esp
  800936:	6a 01                	push   $0x1
  800938:	e8 00 12 00 00       	call   801b3d <ipc_find_env>
  80093d:	a3 00 40 80 00       	mov    %eax,0x804000
  800942:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800945:	6a 07                	push   $0x7
  800947:	68 00 50 80 00       	push   $0x805000
  80094c:	56                   	push   %esi
  80094d:	ff 35 00 40 80 00    	pushl  0x804000
  800953:	e8 91 11 00 00       	call   801ae9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800958:	83 c4 0c             	add    $0xc,%esp
  80095b:	6a 00                	push   $0x0
  80095d:	53                   	push   %ebx
  80095e:	6a 00                	push   $0x0
  800960:	e8 1b 11 00 00       	call   801a80 <ipc_recv>
}
  800965:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	8b 40 0c             	mov    0xc(%eax),%eax
  800978:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80097d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800980:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800985:	ba 00 00 00 00       	mov    $0x0,%edx
  80098a:	b8 02 00 00 00       	mov    $0x2,%eax
  80098f:	e8 8d ff ff ff       	call   800921 <fsipc>
}
  800994:	c9                   	leave  
  800995:	c3                   	ret    

00800996 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ac:	b8 06 00 00 00       	mov    $0x6,%eax
  8009b1:	e8 6b ff ff ff       	call   800921 <fsipc>
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	53                   	push   %ebx
  8009bc:	83 ec 04             	sub    $0x4,%esp
  8009bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8009d7:	e8 45 ff ff ff       	call   800921 <fsipc>
  8009dc:	85 c0                	test   %eax,%eax
  8009de:	78 2c                	js     800a0c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009e0:	83 ec 08             	sub    $0x8,%esp
  8009e3:	68 00 50 80 00       	push   $0x805000
  8009e8:	53                   	push   %ebx
  8009e9:	e8 4b 0d 00 00       	call   801739 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009ee:	a1 80 50 80 00       	mov    0x805080,%eax
  8009f3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009f9:	a1 84 50 80 00       	mov    0x805084,%eax
  8009fe:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a04:	83 c4 10             	add    $0x10,%esp
  800a07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0f:	c9                   	leave  
  800a10:	c3                   	ret    

00800a11 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	83 ec 0c             	sub    $0xc,%esp
  800a17:	8b 45 10             	mov    0x10(%ebp),%eax
  800a1a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a1f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a24:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a27:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2a:	8b 52 0c             	mov    0xc(%edx),%edx
  800a2d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a33:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a38:	50                   	push   %eax
  800a39:	ff 75 0c             	pushl  0xc(%ebp)
  800a3c:	68 08 50 80 00       	push   $0x805008
  800a41:	e8 85 0e 00 00       	call   8018cb <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a46:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4b:	b8 04 00 00 00       	mov    $0x4,%eax
  800a50:	e8 cc fe ff ff       	call   800921 <fsipc>
	//panic("devfile_write not implemented");
}
  800a55:	c9                   	leave  
  800a56:	c3                   	ret    

00800a57 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	56                   	push   %esi
  800a5b:	53                   	push   %ebx
  800a5c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a62:	8b 40 0c             	mov    0xc(%eax),%eax
  800a65:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a6a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a70:	ba 00 00 00 00       	mov    $0x0,%edx
  800a75:	b8 03 00 00 00       	mov    $0x3,%eax
  800a7a:	e8 a2 fe ff ff       	call   800921 <fsipc>
  800a7f:	89 c3                	mov    %eax,%ebx
  800a81:	85 c0                	test   %eax,%eax
  800a83:	78 4b                	js     800ad0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a85:	39 c6                	cmp    %eax,%esi
  800a87:	73 16                	jae    800a9f <devfile_read+0x48>
  800a89:	68 24 1f 80 00       	push   $0x801f24
  800a8e:	68 2b 1f 80 00       	push   $0x801f2b
  800a93:	6a 7c                	push   $0x7c
  800a95:	68 40 1f 80 00       	push   $0x801f40
  800a9a:	e8 bd 05 00 00       	call   80105c <_panic>
	assert(r <= PGSIZE);
  800a9f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aa4:	7e 16                	jle    800abc <devfile_read+0x65>
  800aa6:	68 4b 1f 80 00       	push   $0x801f4b
  800aab:	68 2b 1f 80 00       	push   $0x801f2b
  800ab0:	6a 7d                	push   $0x7d
  800ab2:	68 40 1f 80 00       	push   $0x801f40
  800ab7:	e8 a0 05 00 00       	call   80105c <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800abc:	83 ec 04             	sub    $0x4,%esp
  800abf:	50                   	push   %eax
  800ac0:	68 00 50 80 00       	push   $0x805000
  800ac5:	ff 75 0c             	pushl  0xc(%ebp)
  800ac8:	e8 fe 0d 00 00       	call   8018cb <memmove>
	return r;
  800acd:	83 c4 10             	add    $0x10,%esp
}
  800ad0:	89 d8                	mov    %ebx,%eax
  800ad2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ad5:	5b                   	pop    %ebx
  800ad6:	5e                   	pop    %esi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	53                   	push   %ebx
  800add:	83 ec 20             	sub    $0x20,%esp
  800ae0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ae3:	53                   	push   %ebx
  800ae4:	e8 17 0c 00 00       	call   801700 <strlen>
  800ae9:	83 c4 10             	add    $0x10,%esp
  800aec:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800af1:	7f 67                	jg     800b5a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800af3:	83 ec 0c             	sub    $0xc,%esp
  800af6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800af9:	50                   	push   %eax
  800afa:	e8 9a f8 ff ff       	call   800399 <fd_alloc>
  800aff:	83 c4 10             	add    $0x10,%esp
		return r;
  800b02:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b04:	85 c0                	test   %eax,%eax
  800b06:	78 57                	js     800b5f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b08:	83 ec 08             	sub    $0x8,%esp
  800b0b:	53                   	push   %ebx
  800b0c:	68 00 50 80 00       	push   $0x805000
  800b11:	e8 23 0c 00 00       	call   801739 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b16:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b19:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b21:	b8 01 00 00 00       	mov    $0x1,%eax
  800b26:	e8 f6 fd ff ff       	call   800921 <fsipc>
  800b2b:	89 c3                	mov    %eax,%ebx
  800b2d:	83 c4 10             	add    $0x10,%esp
  800b30:	85 c0                	test   %eax,%eax
  800b32:	79 14                	jns    800b48 <open+0x6f>
		fd_close(fd, 0);
  800b34:	83 ec 08             	sub    $0x8,%esp
  800b37:	6a 00                	push   $0x0
  800b39:	ff 75 f4             	pushl  -0xc(%ebp)
  800b3c:	e8 50 f9 ff ff       	call   800491 <fd_close>
		return r;
  800b41:	83 c4 10             	add    $0x10,%esp
  800b44:	89 da                	mov    %ebx,%edx
  800b46:	eb 17                	jmp    800b5f <open+0x86>
	}

	return fd2num(fd);
  800b48:	83 ec 0c             	sub    $0xc,%esp
  800b4b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b4e:	e8 1f f8 ff ff       	call   800372 <fd2num>
  800b53:	89 c2                	mov    %eax,%edx
  800b55:	83 c4 10             	add    $0x10,%esp
  800b58:	eb 05                	jmp    800b5f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b5a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b5f:	89 d0                	mov    %edx,%eax
  800b61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b64:	c9                   	leave  
  800b65:	c3                   	ret    

00800b66 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b71:	b8 08 00 00 00       	mov    $0x8,%eax
  800b76:	e8 a6 fd ff ff       	call   800921 <fsipc>
}
  800b7b:	c9                   	leave  
  800b7c:	c3                   	ret    

00800b7d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b85:	83 ec 0c             	sub    $0xc,%esp
  800b88:	ff 75 08             	pushl  0x8(%ebp)
  800b8b:	e8 f2 f7 ff ff       	call   800382 <fd2data>
  800b90:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b92:	83 c4 08             	add    $0x8,%esp
  800b95:	68 57 1f 80 00       	push   $0x801f57
  800b9a:	53                   	push   %ebx
  800b9b:	e8 99 0b 00 00       	call   801739 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ba0:	8b 46 04             	mov    0x4(%esi),%eax
  800ba3:	2b 06                	sub    (%esi),%eax
  800ba5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bab:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bb2:	00 00 00 
	stat->st_dev = &devpipe;
  800bb5:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bbc:	30 80 00 
	return 0;
}
  800bbf:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bc7:	5b                   	pop    %ebx
  800bc8:	5e                   	pop    %esi
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	53                   	push   %ebx
  800bcf:	83 ec 0c             	sub    $0xc,%esp
  800bd2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bd5:	53                   	push   %ebx
  800bd6:	6a 00                	push   $0x0
  800bd8:	e8 29 f6 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bdd:	89 1c 24             	mov    %ebx,(%esp)
  800be0:	e8 9d f7 ff ff       	call   800382 <fd2data>
  800be5:	83 c4 08             	add    $0x8,%esp
  800be8:	50                   	push   %eax
  800be9:	6a 00                	push   $0x0
  800beb:	e8 16 f6 ff ff       	call   800206 <sys_page_unmap>
}
  800bf0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf3:	c9                   	leave  
  800bf4:	c3                   	ret    

00800bf5 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	83 ec 1c             	sub    $0x1c,%esp
  800bfe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c01:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c03:	a1 04 40 80 00       	mov    0x804004,%eax
  800c08:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c0b:	83 ec 0c             	sub    $0xc,%esp
  800c0e:	ff 75 e0             	pushl  -0x20(%ebp)
  800c11:	e8 60 0f 00 00       	call   801b76 <pageref>
  800c16:	89 c3                	mov    %eax,%ebx
  800c18:	89 3c 24             	mov    %edi,(%esp)
  800c1b:	e8 56 0f 00 00       	call   801b76 <pageref>
  800c20:	83 c4 10             	add    $0x10,%esp
  800c23:	39 c3                	cmp    %eax,%ebx
  800c25:	0f 94 c1             	sete   %cl
  800c28:	0f b6 c9             	movzbl %cl,%ecx
  800c2b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c2e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c34:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c37:	39 ce                	cmp    %ecx,%esi
  800c39:	74 1b                	je     800c56 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c3b:	39 c3                	cmp    %eax,%ebx
  800c3d:	75 c4                	jne    800c03 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c3f:	8b 42 58             	mov    0x58(%edx),%eax
  800c42:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c45:	50                   	push   %eax
  800c46:	56                   	push   %esi
  800c47:	68 5e 1f 80 00       	push   $0x801f5e
  800c4c:	e8 e4 04 00 00       	call   801135 <cprintf>
  800c51:	83 c4 10             	add    $0x10,%esp
  800c54:	eb ad                	jmp    800c03 <_pipeisclosed+0xe>
	}
}
  800c56:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 28             	sub    $0x28,%esp
  800c6a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c6d:	56                   	push   %esi
  800c6e:	e8 0f f7 ff ff       	call   800382 <fd2data>
  800c73:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c75:	83 c4 10             	add    $0x10,%esp
  800c78:	bf 00 00 00 00       	mov    $0x0,%edi
  800c7d:	eb 4b                	jmp    800cca <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c7f:	89 da                	mov    %ebx,%edx
  800c81:	89 f0                	mov    %esi,%eax
  800c83:	e8 6d ff ff ff       	call   800bf5 <_pipeisclosed>
  800c88:	85 c0                	test   %eax,%eax
  800c8a:	75 48                	jne    800cd4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c8c:	e8 d1 f4 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c91:	8b 43 04             	mov    0x4(%ebx),%eax
  800c94:	8b 0b                	mov    (%ebx),%ecx
  800c96:	8d 51 20             	lea    0x20(%ecx),%edx
  800c99:	39 d0                	cmp    %edx,%eax
  800c9b:	73 e2                	jae    800c7f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800ca4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ca7:	89 c2                	mov    %eax,%edx
  800ca9:	c1 fa 1f             	sar    $0x1f,%edx
  800cac:	89 d1                	mov    %edx,%ecx
  800cae:	c1 e9 1b             	shr    $0x1b,%ecx
  800cb1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cb4:	83 e2 1f             	and    $0x1f,%edx
  800cb7:	29 ca                	sub    %ecx,%edx
  800cb9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cbd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cc1:	83 c0 01             	add    $0x1,%eax
  800cc4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cc7:	83 c7 01             	add    $0x1,%edi
  800cca:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ccd:	75 c2                	jne    800c91 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ccf:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd2:	eb 05                	jmp    800cd9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cd4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5f                   	pop    %edi
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	57                   	push   %edi
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
  800ce7:	83 ec 18             	sub    $0x18,%esp
  800cea:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ced:	57                   	push   %edi
  800cee:	e8 8f f6 ff ff       	call   800382 <fd2data>
  800cf3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf5:	83 c4 10             	add    $0x10,%esp
  800cf8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfd:	eb 3d                	jmp    800d3c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cff:	85 db                	test   %ebx,%ebx
  800d01:	74 04                	je     800d07 <devpipe_read+0x26>
				return i;
  800d03:	89 d8                	mov    %ebx,%eax
  800d05:	eb 44                	jmp    800d4b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d07:	89 f2                	mov    %esi,%edx
  800d09:	89 f8                	mov    %edi,%eax
  800d0b:	e8 e5 fe ff ff       	call   800bf5 <_pipeisclosed>
  800d10:	85 c0                	test   %eax,%eax
  800d12:	75 32                	jne    800d46 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d14:	e8 49 f4 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d19:	8b 06                	mov    (%esi),%eax
  800d1b:	3b 46 04             	cmp    0x4(%esi),%eax
  800d1e:	74 df                	je     800cff <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d20:	99                   	cltd   
  800d21:	c1 ea 1b             	shr    $0x1b,%edx
  800d24:	01 d0                	add    %edx,%eax
  800d26:	83 e0 1f             	and    $0x1f,%eax
  800d29:	29 d0                	sub    %edx,%eax
  800d2b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d36:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d39:	83 c3 01             	add    $0x1,%ebx
  800d3c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d3f:	75 d8                	jne    800d19 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d41:	8b 45 10             	mov    0x10(%ebp),%eax
  800d44:	eb 05                	jmp    800d4b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d46:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	56                   	push   %esi
  800d57:	53                   	push   %ebx
  800d58:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d5e:	50                   	push   %eax
  800d5f:	e8 35 f6 ff ff       	call   800399 <fd_alloc>
  800d64:	83 c4 10             	add    $0x10,%esp
  800d67:	89 c2                	mov    %eax,%edx
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	0f 88 2c 01 00 00    	js     800e9d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d71:	83 ec 04             	sub    $0x4,%esp
  800d74:	68 07 04 00 00       	push   $0x407
  800d79:	ff 75 f4             	pushl  -0xc(%ebp)
  800d7c:	6a 00                	push   $0x0
  800d7e:	e8 fe f3 ff ff       	call   800181 <sys_page_alloc>
  800d83:	83 c4 10             	add    $0x10,%esp
  800d86:	89 c2                	mov    %eax,%edx
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	0f 88 0d 01 00 00    	js     800e9d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d90:	83 ec 0c             	sub    $0xc,%esp
  800d93:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d96:	50                   	push   %eax
  800d97:	e8 fd f5 ff ff       	call   800399 <fd_alloc>
  800d9c:	89 c3                	mov    %eax,%ebx
  800d9e:	83 c4 10             	add    $0x10,%esp
  800da1:	85 c0                	test   %eax,%eax
  800da3:	0f 88 e2 00 00 00    	js     800e8b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da9:	83 ec 04             	sub    $0x4,%esp
  800dac:	68 07 04 00 00       	push   $0x407
  800db1:	ff 75 f0             	pushl  -0x10(%ebp)
  800db4:	6a 00                	push   $0x0
  800db6:	e8 c6 f3 ff ff       	call   800181 <sys_page_alloc>
  800dbb:	89 c3                	mov    %eax,%ebx
  800dbd:	83 c4 10             	add    $0x10,%esp
  800dc0:	85 c0                	test   %eax,%eax
  800dc2:	0f 88 c3 00 00 00    	js     800e8b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dc8:	83 ec 0c             	sub    $0xc,%esp
  800dcb:	ff 75 f4             	pushl  -0xc(%ebp)
  800dce:	e8 af f5 ff ff       	call   800382 <fd2data>
  800dd3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd5:	83 c4 0c             	add    $0xc,%esp
  800dd8:	68 07 04 00 00       	push   $0x407
  800ddd:	50                   	push   %eax
  800dde:	6a 00                	push   $0x0
  800de0:	e8 9c f3 ff ff       	call   800181 <sys_page_alloc>
  800de5:	89 c3                	mov    %eax,%ebx
  800de7:	83 c4 10             	add    $0x10,%esp
  800dea:	85 c0                	test   %eax,%eax
  800dec:	0f 88 89 00 00 00    	js     800e7b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df2:	83 ec 0c             	sub    $0xc,%esp
  800df5:	ff 75 f0             	pushl  -0x10(%ebp)
  800df8:	e8 85 f5 ff ff       	call   800382 <fd2data>
  800dfd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e04:	50                   	push   %eax
  800e05:	6a 00                	push   $0x0
  800e07:	56                   	push   %esi
  800e08:	6a 00                	push   $0x0
  800e0a:	e8 b5 f3 ff ff       	call   8001c4 <sys_page_map>
  800e0f:	89 c3                	mov    %eax,%ebx
  800e11:	83 c4 20             	add    $0x20,%esp
  800e14:	85 c0                	test   %eax,%eax
  800e16:	78 55                	js     800e6d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e18:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e21:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e26:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e2d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e36:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e38:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e3b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e42:	83 ec 0c             	sub    $0xc,%esp
  800e45:	ff 75 f4             	pushl  -0xc(%ebp)
  800e48:	e8 25 f5 ff ff       	call   800372 <fd2num>
  800e4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e50:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e52:	83 c4 04             	add    $0x4,%esp
  800e55:	ff 75 f0             	pushl  -0x10(%ebp)
  800e58:	e8 15 f5 ff ff       	call   800372 <fd2num>
  800e5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e60:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e63:	83 c4 10             	add    $0x10,%esp
  800e66:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6b:	eb 30                	jmp    800e9d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e6d:	83 ec 08             	sub    $0x8,%esp
  800e70:	56                   	push   %esi
  800e71:	6a 00                	push   $0x0
  800e73:	e8 8e f3 ff ff       	call   800206 <sys_page_unmap>
  800e78:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e7b:	83 ec 08             	sub    $0x8,%esp
  800e7e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e81:	6a 00                	push   $0x0
  800e83:	e8 7e f3 ff ff       	call   800206 <sys_page_unmap>
  800e88:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e8b:	83 ec 08             	sub    $0x8,%esp
  800e8e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e91:	6a 00                	push   $0x0
  800e93:	e8 6e f3 ff ff       	call   800206 <sys_page_unmap>
  800e98:	83 c4 10             	add    $0x10,%esp
  800e9b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e9d:	89 d0                	mov    %edx,%eax
  800e9f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eaf:	50                   	push   %eax
  800eb0:	ff 75 08             	pushl  0x8(%ebp)
  800eb3:	e8 30 f5 ff ff       	call   8003e8 <fd_lookup>
  800eb8:	83 c4 10             	add    $0x10,%esp
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	78 18                	js     800ed7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ebf:	83 ec 0c             	sub    $0xc,%esp
  800ec2:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec5:	e8 b8 f4 ff ff       	call   800382 <fd2data>
	return _pipeisclosed(fd, p);
  800eca:	89 c2                	mov    %eax,%edx
  800ecc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ecf:	e8 21 fd ff ff       	call   800bf5 <_pipeisclosed>
  800ed4:	83 c4 10             	add    $0x10,%esp
}
  800ed7:	c9                   	leave  
  800ed8:	c3                   	ret    

00800ed9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800edc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee1:	5d                   	pop    %ebp
  800ee2:	c3                   	ret    

00800ee3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ee9:	68 76 1f 80 00       	push   $0x801f76
  800eee:	ff 75 0c             	pushl  0xc(%ebp)
  800ef1:	e8 43 08 00 00       	call   801739 <strcpy>
	return 0;
}
  800ef6:	b8 00 00 00 00       	mov    $0x0,%eax
  800efb:	c9                   	leave  
  800efc:	c3                   	ret    

00800efd <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	57                   	push   %edi
  800f01:	56                   	push   %esi
  800f02:	53                   	push   %ebx
  800f03:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f09:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f0e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f14:	eb 2d                	jmp    800f43 <devcons_write+0x46>
		m = n - tot;
  800f16:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f19:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f1b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f1e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f23:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f26:	83 ec 04             	sub    $0x4,%esp
  800f29:	53                   	push   %ebx
  800f2a:	03 45 0c             	add    0xc(%ebp),%eax
  800f2d:	50                   	push   %eax
  800f2e:	57                   	push   %edi
  800f2f:	e8 97 09 00 00       	call   8018cb <memmove>
		sys_cputs(buf, m);
  800f34:	83 c4 08             	add    $0x8,%esp
  800f37:	53                   	push   %ebx
  800f38:	57                   	push   %edi
  800f39:	e8 87 f1 ff ff       	call   8000c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f3e:	01 de                	add    %ebx,%esi
  800f40:	83 c4 10             	add    $0x10,%esp
  800f43:	89 f0                	mov    %esi,%eax
  800f45:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f48:	72 cc                	jb     800f16 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f4d:	5b                   	pop    %ebx
  800f4e:	5e                   	pop    %esi
  800f4f:	5f                   	pop    %edi
  800f50:	5d                   	pop    %ebp
  800f51:	c3                   	ret    

00800f52 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f52:	55                   	push   %ebp
  800f53:	89 e5                	mov    %esp,%ebp
  800f55:	83 ec 08             	sub    $0x8,%esp
  800f58:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f5d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f61:	74 2a                	je     800f8d <devcons_read+0x3b>
  800f63:	eb 05                	jmp    800f6a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f65:	e8 f8 f1 ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f6a:	e8 74 f1 ff ff       	call   8000e3 <sys_cgetc>
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	74 f2                	je     800f65 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f73:	85 c0                	test   %eax,%eax
  800f75:	78 16                	js     800f8d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f77:	83 f8 04             	cmp    $0x4,%eax
  800f7a:	74 0c                	je     800f88 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f7f:	88 02                	mov    %al,(%edx)
	return 1;
  800f81:	b8 01 00 00 00       	mov    $0x1,%eax
  800f86:	eb 05                	jmp    800f8d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f88:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f8d:	c9                   	leave  
  800f8e:	c3                   	ret    

00800f8f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  800f8f:	55                   	push   %ebp
  800f90:	89 e5                	mov    %esp,%ebp
  800f92:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f95:	8b 45 08             	mov    0x8(%ebp),%eax
  800f98:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f9b:	6a 01                	push   $0x1
  800f9d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fa0:	50                   	push   %eax
  800fa1:	e8 1f f1 ff ff       	call   8000c5 <sys_cputs>
}
  800fa6:	83 c4 10             	add    $0x10,%esp
  800fa9:	c9                   	leave  
  800faa:	c3                   	ret    

00800fab <getchar>:

int
getchar(void)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fb1:	6a 01                	push   $0x1
  800fb3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fb6:	50                   	push   %eax
  800fb7:	6a 00                	push   $0x0
  800fb9:	e8 90 f6 ff ff       	call   80064e <read>
	if (r < 0)
  800fbe:	83 c4 10             	add    $0x10,%esp
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	78 0f                	js     800fd4 <getchar+0x29>
		return r;
	if (r < 1)
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	7e 06                	jle    800fcf <getchar+0x24>
		return -E_EOF;
	return c;
  800fc9:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fcd:	eb 05                	jmp    800fd4 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fcf:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fd4:	c9                   	leave  
  800fd5:	c3                   	ret    

00800fd6 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdf:	50                   	push   %eax
  800fe0:	ff 75 08             	pushl  0x8(%ebp)
  800fe3:	e8 00 f4 ff ff       	call   8003e8 <fd_lookup>
  800fe8:	83 c4 10             	add    $0x10,%esp
  800feb:	85 c0                	test   %eax,%eax
  800fed:	78 11                	js     801000 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ff8:	39 10                	cmp    %edx,(%eax)
  800ffa:	0f 94 c0             	sete   %al
  800ffd:	0f b6 c0             	movzbl %al,%eax
}
  801000:	c9                   	leave  
  801001:	c3                   	ret    

00801002 <opencons>:

int
opencons(void)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801008:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80100b:	50                   	push   %eax
  80100c:	e8 88 f3 ff ff       	call   800399 <fd_alloc>
  801011:	83 c4 10             	add    $0x10,%esp
		return r;
  801014:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801016:	85 c0                	test   %eax,%eax
  801018:	78 3e                	js     801058 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80101a:	83 ec 04             	sub    $0x4,%esp
  80101d:	68 07 04 00 00       	push   $0x407
  801022:	ff 75 f4             	pushl  -0xc(%ebp)
  801025:	6a 00                	push   $0x0
  801027:	e8 55 f1 ff ff       	call   800181 <sys_page_alloc>
  80102c:	83 c4 10             	add    $0x10,%esp
		return r;
  80102f:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801031:	85 c0                	test   %eax,%eax
  801033:	78 23                	js     801058 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801035:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80103b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80103e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801040:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801043:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80104a:	83 ec 0c             	sub    $0xc,%esp
  80104d:	50                   	push   %eax
  80104e:	e8 1f f3 ff ff       	call   800372 <fd2num>
  801053:	89 c2                	mov    %eax,%edx
  801055:	83 c4 10             	add    $0x10,%esp
}
  801058:	89 d0                	mov    %edx,%eax
  80105a:	c9                   	leave  
  80105b:	c3                   	ret    

0080105c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	56                   	push   %esi
  801060:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801061:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801064:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80106a:	e8 d4 f0 ff ff       	call   800143 <sys_getenvid>
  80106f:	83 ec 0c             	sub    $0xc,%esp
  801072:	ff 75 0c             	pushl  0xc(%ebp)
  801075:	ff 75 08             	pushl  0x8(%ebp)
  801078:	56                   	push   %esi
  801079:	50                   	push   %eax
  80107a:	68 84 1f 80 00       	push   $0x801f84
  80107f:	e8 b1 00 00 00       	call   801135 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801084:	83 c4 18             	add    $0x18,%esp
  801087:	53                   	push   %ebx
  801088:	ff 75 10             	pushl  0x10(%ebp)
  80108b:	e8 54 00 00 00       	call   8010e4 <vcprintf>
	cprintf("\n");
  801090:	c7 04 24 6f 1f 80 00 	movl   $0x801f6f,(%esp)
  801097:	e8 99 00 00 00       	call   801135 <cprintf>
  80109c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80109f:	cc                   	int3   
  8010a0:	eb fd                	jmp    80109f <_panic+0x43>

008010a2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	53                   	push   %ebx
  8010a6:	83 ec 04             	sub    $0x4,%esp
  8010a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010ac:	8b 13                	mov    (%ebx),%edx
  8010ae:	8d 42 01             	lea    0x1(%edx),%eax
  8010b1:	89 03                	mov    %eax,(%ebx)
  8010b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010b6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010ba:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010bf:	75 1a                	jne    8010db <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010c1:	83 ec 08             	sub    $0x8,%esp
  8010c4:	68 ff 00 00 00       	push   $0xff
  8010c9:	8d 43 08             	lea    0x8(%ebx),%eax
  8010cc:	50                   	push   %eax
  8010cd:	e8 f3 ef ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  8010d2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010d8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010db:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e2:	c9                   	leave  
  8010e3:	c3                   	ret    

008010e4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010ed:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010f4:	00 00 00 
	b.cnt = 0;
  8010f7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010fe:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801101:	ff 75 0c             	pushl  0xc(%ebp)
  801104:	ff 75 08             	pushl  0x8(%ebp)
  801107:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80110d:	50                   	push   %eax
  80110e:	68 a2 10 80 00       	push   $0x8010a2
  801113:	e8 1a 01 00 00       	call   801232 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801118:	83 c4 08             	add    $0x8,%esp
  80111b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801121:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801127:	50                   	push   %eax
  801128:	e8 98 ef ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  80112d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801133:	c9                   	leave  
  801134:	c3                   	ret    

00801135 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80113b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80113e:	50                   	push   %eax
  80113f:	ff 75 08             	pushl  0x8(%ebp)
  801142:	e8 9d ff ff ff       	call   8010e4 <vcprintf>
	va_end(ap);

	return cnt;
}
  801147:	c9                   	leave  
  801148:	c3                   	ret    

00801149 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
  80114c:	57                   	push   %edi
  80114d:	56                   	push   %esi
  80114e:	53                   	push   %ebx
  80114f:	83 ec 1c             	sub    $0x1c,%esp
  801152:	89 c7                	mov    %eax,%edi
  801154:	89 d6                	mov    %edx,%esi
  801156:	8b 45 08             	mov    0x8(%ebp),%eax
  801159:	8b 55 0c             	mov    0xc(%ebp),%edx
  80115c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80115f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801162:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801165:	bb 00 00 00 00       	mov    $0x0,%ebx
  80116a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80116d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801170:	39 d3                	cmp    %edx,%ebx
  801172:	72 05                	jb     801179 <printnum+0x30>
  801174:	39 45 10             	cmp    %eax,0x10(%ebp)
  801177:	77 45                	ja     8011be <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801179:	83 ec 0c             	sub    $0xc,%esp
  80117c:	ff 75 18             	pushl  0x18(%ebp)
  80117f:	8b 45 14             	mov    0x14(%ebp),%eax
  801182:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801185:	53                   	push   %ebx
  801186:	ff 75 10             	pushl  0x10(%ebp)
  801189:	83 ec 08             	sub    $0x8,%esp
  80118c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80118f:	ff 75 e0             	pushl  -0x20(%ebp)
  801192:	ff 75 dc             	pushl  -0x24(%ebp)
  801195:	ff 75 d8             	pushl  -0x28(%ebp)
  801198:	e8 23 0a 00 00       	call   801bc0 <__udivdi3>
  80119d:	83 c4 18             	add    $0x18,%esp
  8011a0:	52                   	push   %edx
  8011a1:	50                   	push   %eax
  8011a2:	89 f2                	mov    %esi,%edx
  8011a4:	89 f8                	mov    %edi,%eax
  8011a6:	e8 9e ff ff ff       	call   801149 <printnum>
  8011ab:	83 c4 20             	add    $0x20,%esp
  8011ae:	eb 18                	jmp    8011c8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011b0:	83 ec 08             	sub    $0x8,%esp
  8011b3:	56                   	push   %esi
  8011b4:	ff 75 18             	pushl  0x18(%ebp)
  8011b7:	ff d7                	call   *%edi
  8011b9:	83 c4 10             	add    $0x10,%esp
  8011bc:	eb 03                	jmp    8011c1 <printnum+0x78>
  8011be:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011c1:	83 eb 01             	sub    $0x1,%ebx
  8011c4:	85 db                	test   %ebx,%ebx
  8011c6:	7f e8                	jg     8011b0 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011c8:	83 ec 08             	sub    $0x8,%esp
  8011cb:	56                   	push   %esi
  8011cc:	83 ec 04             	sub    $0x4,%esp
  8011cf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d2:	ff 75 e0             	pushl  -0x20(%ebp)
  8011d5:	ff 75 dc             	pushl  -0x24(%ebp)
  8011d8:	ff 75 d8             	pushl  -0x28(%ebp)
  8011db:	e8 10 0b 00 00       	call   801cf0 <__umoddi3>
  8011e0:	83 c4 14             	add    $0x14,%esp
  8011e3:	0f be 80 a7 1f 80 00 	movsbl 0x801fa7(%eax),%eax
  8011ea:	50                   	push   %eax
  8011eb:	ff d7                	call   *%edi
}
  8011ed:	83 c4 10             	add    $0x10,%esp
  8011f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f3:	5b                   	pop    %ebx
  8011f4:	5e                   	pop    %esi
  8011f5:	5f                   	pop    %edi
  8011f6:	5d                   	pop    %ebp
  8011f7:	c3                   	ret    

008011f8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011fe:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801202:	8b 10                	mov    (%eax),%edx
  801204:	3b 50 04             	cmp    0x4(%eax),%edx
  801207:	73 0a                	jae    801213 <sprintputch+0x1b>
		*b->buf++ = ch;
  801209:	8d 4a 01             	lea    0x1(%edx),%ecx
  80120c:	89 08                	mov    %ecx,(%eax)
  80120e:	8b 45 08             	mov    0x8(%ebp),%eax
  801211:	88 02                	mov    %al,(%edx)
}
  801213:	5d                   	pop    %ebp
  801214:	c3                   	ret    

00801215 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
  801218:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80121b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80121e:	50                   	push   %eax
  80121f:	ff 75 10             	pushl  0x10(%ebp)
  801222:	ff 75 0c             	pushl  0xc(%ebp)
  801225:	ff 75 08             	pushl  0x8(%ebp)
  801228:	e8 05 00 00 00       	call   801232 <vprintfmt>
	va_end(ap);
}
  80122d:	83 c4 10             	add    $0x10,%esp
  801230:	c9                   	leave  
  801231:	c3                   	ret    

00801232 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801232:	55                   	push   %ebp
  801233:	89 e5                	mov    %esp,%ebp
  801235:	57                   	push   %edi
  801236:	56                   	push   %esi
  801237:	53                   	push   %ebx
  801238:	83 ec 2c             	sub    $0x2c,%esp
  80123b:	8b 75 08             	mov    0x8(%ebp),%esi
  80123e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801241:	8b 7d 10             	mov    0x10(%ebp),%edi
  801244:	eb 12                	jmp    801258 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801246:	85 c0                	test   %eax,%eax
  801248:	0f 84 42 04 00 00    	je     801690 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80124e:	83 ec 08             	sub    $0x8,%esp
  801251:	53                   	push   %ebx
  801252:	50                   	push   %eax
  801253:	ff d6                	call   *%esi
  801255:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801258:	83 c7 01             	add    $0x1,%edi
  80125b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80125f:	83 f8 25             	cmp    $0x25,%eax
  801262:	75 e2                	jne    801246 <vprintfmt+0x14>
  801264:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801268:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80126f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801276:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80127d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801282:	eb 07                	jmp    80128b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801284:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801287:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80128b:	8d 47 01             	lea    0x1(%edi),%eax
  80128e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801291:	0f b6 07             	movzbl (%edi),%eax
  801294:	0f b6 d0             	movzbl %al,%edx
  801297:	83 e8 23             	sub    $0x23,%eax
  80129a:	3c 55                	cmp    $0x55,%al
  80129c:	0f 87 d3 03 00 00    	ja     801675 <vprintfmt+0x443>
  8012a2:	0f b6 c0             	movzbl %al,%eax
  8012a5:	ff 24 85 e0 20 80 00 	jmp    *0x8020e0(,%eax,4)
  8012ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012af:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012b3:	eb d6                	jmp    80128b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012bd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012c0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012c3:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8012c7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8012ca:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8012cd:	83 f9 09             	cmp    $0x9,%ecx
  8012d0:	77 3f                	ja     801311 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012d2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012d5:	eb e9                	jmp    8012c0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8012da:	8b 00                	mov    (%eax),%eax
  8012dc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012df:	8b 45 14             	mov    0x14(%ebp),%eax
  8012e2:	8d 40 04             	lea    0x4(%eax),%eax
  8012e5:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012eb:	eb 2a                	jmp    801317 <vprintfmt+0xe5>
  8012ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012f0:	85 c0                	test   %eax,%eax
  8012f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f7:	0f 49 d0             	cmovns %eax,%edx
  8012fa:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801300:	eb 89                	jmp    80128b <vprintfmt+0x59>
  801302:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801305:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80130c:	e9 7a ff ff ff       	jmp    80128b <vprintfmt+0x59>
  801311:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801314:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801317:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80131b:	0f 89 6a ff ff ff    	jns    80128b <vprintfmt+0x59>
				width = precision, precision = -1;
  801321:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801324:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801327:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80132e:	e9 58 ff ff ff       	jmp    80128b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801333:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801336:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801339:	e9 4d ff ff ff       	jmp    80128b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80133e:	8b 45 14             	mov    0x14(%ebp),%eax
  801341:	8d 78 04             	lea    0x4(%eax),%edi
  801344:	83 ec 08             	sub    $0x8,%esp
  801347:	53                   	push   %ebx
  801348:	ff 30                	pushl  (%eax)
  80134a:	ff d6                	call   *%esi
			break;
  80134c:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80134f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801352:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801355:	e9 fe fe ff ff       	jmp    801258 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80135a:	8b 45 14             	mov    0x14(%ebp),%eax
  80135d:	8d 78 04             	lea    0x4(%eax),%edi
  801360:	8b 00                	mov    (%eax),%eax
  801362:	99                   	cltd   
  801363:	31 d0                	xor    %edx,%eax
  801365:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801367:	83 f8 0f             	cmp    $0xf,%eax
  80136a:	7f 0b                	jg     801377 <vprintfmt+0x145>
  80136c:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  801373:	85 d2                	test   %edx,%edx
  801375:	75 1b                	jne    801392 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  801377:	50                   	push   %eax
  801378:	68 bf 1f 80 00       	push   $0x801fbf
  80137d:	53                   	push   %ebx
  80137e:	56                   	push   %esi
  80137f:	e8 91 fe ff ff       	call   801215 <printfmt>
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
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80138d:	e9 c6 fe ff ff       	jmp    801258 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801392:	52                   	push   %edx
  801393:	68 3d 1f 80 00       	push   $0x801f3d
  801398:	53                   	push   %ebx
  801399:	56                   	push   %esi
  80139a:	e8 76 fe ff ff       	call   801215 <printfmt>
  80139f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8013a2:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013a8:	e9 ab fe ff ff       	jmp    801258 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b0:	83 c0 04             	add    $0x4,%eax
  8013b3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8013b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013bb:	85 ff                	test   %edi,%edi
  8013bd:	b8 b8 1f 80 00       	mov    $0x801fb8,%eax
  8013c2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013c9:	0f 8e 94 00 00 00    	jle    801463 <vprintfmt+0x231>
  8013cf:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013d3:	0f 84 98 00 00 00    	je     801471 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013d9:	83 ec 08             	sub    $0x8,%esp
  8013dc:	ff 75 d0             	pushl  -0x30(%ebp)
  8013df:	57                   	push   %edi
  8013e0:	e8 33 03 00 00       	call   801718 <strnlen>
  8013e5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013e8:	29 c1                	sub    %eax,%ecx
  8013ea:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013ed:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013f0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013f7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013fa:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013fc:	eb 0f                	jmp    80140d <vprintfmt+0x1db>
					putch(padc, putdat);
  8013fe:	83 ec 08             	sub    $0x8,%esp
  801401:	53                   	push   %ebx
  801402:	ff 75 e0             	pushl  -0x20(%ebp)
  801405:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801407:	83 ef 01             	sub    $0x1,%edi
  80140a:	83 c4 10             	add    $0x10,%esp
  80140d:	85 ff                	test   %edi,%edi
  80140f:	7f ed                	jg     8013fe <vprintfmt+0x1cc>
  801411:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801414:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  801417:	85 c9                	test   %ecx,%ecx
  801419:	b8 00 00 00 00       	mov    $0x0,%eax
  80141e:	0f 49 c1             	cmovns %ecx,%eax
  801421:	29 c1                	sub    %eax,%ecx
  801423:	89 75 08             	mov    %esi,0x8(%ebp)
  801426:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801429:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80142c:	89 cb                	mov    %ecx,%ebx
  80142e:	eb 4d                	jmp    80147d <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801430:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801434:	74 1b                	je     801451 <vprintfmt+0x21f>
  801436:	0f be c0             	movsbl %al,%eax
  801439:	83 e8 20             	sub    $0x20,%eax
  80143c:	83 f8 5e             	cmp    $0x5e,%eax
  80143f:	76 10                	jbe    801451 <vprintfmt+0x21f>
					putch('?', putdat);
  801441:	83 ec 08             	sub    $0x8,%esp
  801444:	ff 75 0c             	pushl  0xc(%ebp)
  801447:	6a 3f                	push   $0x3f
  801449:	ff 55 08             	call   *0x8(%ebp)
  80144c:	83 c4 10             	add    $0x10,%esp
  80144f:	eb 0d                	jmp    80145e <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  801451:	83 ec 08             	sub    $0x8,%esp
  801454:	ff 75 0c             	pushl  0xc(%ebp)
  801457:	52                   	push   %edx
  801458:	ff 55 08             	call   *0x8(%ebp)
  80145b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80145e:	83 eb 01             	sub    $0x1,%ebx
  801461:	eb 1a                	jmp    80147d <vprintfmt+0x24b>
  801463:	89 75 08             	mov    %esi,0x8(%ebp)
  801466:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801469:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80146c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80146f:	eb 0c                	jmp    80147d <vprintfmt+0x24b>
  801471:	89 75 08             	mov    %esi,0x8(%ebp)
  801474:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801477:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80147a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80147d:	83 c7 01             	add    $0x1,%edi
  801480:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801484:	0f be d0             	movsbl %al,%edx
  801487:	85 d2                	test   %edx,%edx
  801489:	74 23                	je     8014ae <vprintfmt+0x27c>
  80148b:	85 f6                	test   %esi,%esi
  80148d:	78 a1                	js     801430 <vprintfmt+0x1fe>
  80148f:	83 ee 01             	sub    $0x1,%esi
  801492:	79 9c                	jns    801430 <vprintfmt+0x1fe>
  801494:	89 df                	mov    %ebx,%edi
  801496:	8b 75 08             	mov    0x8(%ebp),%esi
  801499:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80149c:	eb 18                	jmp    8014b6 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80149e:	83 ec 08             	sub    $0x8,%esp
  8014a1:	53                   	push   %ebx
  8014a2:	6a 20                	push   $0x20
  8014a4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014a6:	83 ef 01             	sub    $0x1,%edi
  8014a9:	83 c4 10             	add    $0x10,%esp
  8014ac:	eb 08                	jmp    8014b6 <vprintfmt+0x284>
  8014ae:	89 df                	mov    %ebx,%edi
  8014b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8014b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014b6:	85 ff                	test   %edi,%edi
  8014b8:	7f e4                	jg     80149e <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8014ba:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8014bd:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014c3:	e9 90 fd ff ff       	jmp    801258 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014c8:	83 f9 01             	cmp    $0x1,%ecx
  8014cb:	7e 19                	jle    8014e6 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8014cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d0:	8b 50 04             	mov    0x4(%eax),%edx
  8014d3:	8b 00                	mov    (%eax),%eax
  8014d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014d8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014db:	8b 45 14             	mov    0x14(%ebp),%eax
  8014de:	8d 40 08             	lea    0x8(%eax),%eax
  8014e1:	89 45 14             	mov    %eax,0x14(%ebp)
  8014e4:	eb 38                	jmp    80151e <vprintfmt+0x2ec>
	else if (lflag)
  8014e6:	85 c9                	test   %ecx,%ecx
  8014e8:	74 1b                	je     801505 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8014ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ed:	8b 00                	mov    (%eax),%eax
  8014ef:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f2:	89 c1                	mov    %eax,%ecx
  8014f4:	c1 f9 1f             	sar    $0x1f,%ecx
  8014f7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8014fd:	8d 40 04             	lea    0x4(%eax),%eax
  801500:	89 45 14             	mov    %eax,0x14(%ebp)
  801503:	eb 19                	jmp    80151e <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  801505:	8b 45 14             	mov    0x14(%ebp),%eax
  801508:	8b 00                	mov    (%eax),%eax
  80150a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80150d:	89 c1                	mov    %eax,%ecx
  80150f:	c1 f9 1f             	sar    $0x1f,%ecx
  801512:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801515:	8b 45 14             	mov    0x14(%ebp),%eax
  801518:	8d 40 04             	lea    0x4(%eax),%eax
  80151b:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80151e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801521:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801524:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801529:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80152d:	0f 89 0e 01 00 00    	jns    801641 <vprintfmt+0x40f>
				putch('-', putdat);
  801533:	83 ec 08             	sub    $0x8,%esp
  801536:	53                   	push   %ebx
  801537:	6a 2d                	push   $0x2d
  801539:	ff d6                	call   *%esi
				num = -(long long) num;
  80153b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80153e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801541:	f7 da                	neg    %edx
  801543:	83 d1 00             	adc    $0x0,%ecx
  801546:	f7 d9                	neg    %ecx
  801548:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80154b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801550:	e9 ec 00 00 00       	jmp    801641 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801555:	83 f9 01             	cmp    $0x1,%ecx
  801558:	7e 18                	jle    801572 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  80155a:	8b 45 14             	mov    0x14(%ebp),%eax
  80155d:	8b 10                	mov    (%eax),%edx
  80155f:	8b 48 04             	mov    0x4(%eax),%ecx
  801562:	8d 40 08             	lea    0x8(%eax),%eax
  801565:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801568:	b8 0a 00 00 00       	mov    $0xa,%eax
  80156d:	e9 cf 00 00 00       	jmp    801641 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801572:	85 c9                	test   %ecx,%ecx
  801574:	74 1a                	je     801590 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  801576:	8b 45 14             	mov    0x14(%ebp),%eax
  801579:	8b 10                	mov    (%eax),%edx
  80157b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801580:	8d 40 04             	lea    0x4(%eax),%eax
  801583:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801586:	b8 0a 00 00 00       	mov    $0xa,%eax
  80158b:	e9 b1 00 00 00       	jmp    801641 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801590:	8b 45 14             	mov    0x14(%ebp),%eax
  801593:	8b 10                	mov    (%eax),%edx
  801595:	b9 00 00 00 00       	mov    $0x0,%ecx
  80159a:	8d 40 04             	lea    0x4(%eax),%eax
  80159d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8015a0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8015a5:	e9 97 00 00 00       	jmp    801641 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8015aa:	83 ec 08             	sub    $0x8,%esp
  8015ad:	53                   	push   %ebx
  8015ae:	6a 58                	push   $0x58
  8015b0:	ff d6                	call   *%esi
			putch('X', putdat);
  8015b2:	83 c4 08             	add    $0x8,%esp
  8015b5:	53                   	push   %ebx
  8015b6:	6a 58                	push   $0x58
  8015b8:	ff d6                	call   *%esi
			putch('X', putdat);
  8015ba:	83 c4 08             	add    $0x8,%esp
  8015bd:	53                   	push   %ebx
  8015be:	6a 58                	push   $0x58
  8015c0:	ff d6                	call   *%esi
			break;
  8015c2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8015c8:	e9 8b fc ff ff       	jmp    801258 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8015cd:	83 ec 08             	sub    $0x8,%esp
  8015d0:	53                   	push   %ebx
  8015d1:	6a 30                	push   $0x30
  8015d3:	ff d6                	call   *%esi
			putch('x', putdat);
  8015d5:	83 c4 08             	add    $0x8,%esp
  8015d8:	53                   	push   %ebx
  8015d9:	6a 78                	push   $0x78
  8015db:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e0:	8b 10                	mov    (%eax),%edx
  8015e2:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015e7:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015ea:	8d 40 04             	lea    0x4(%eax),%eax
  8015ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015f0:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015f5:	eb 4a                	jmp    801641 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015f7:	83 f9 01             	cmp    $0x1,%ecx
  8015fa:	7e 15                	jle    801611 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8015fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ff:	8b 10                	mov    (%eax),%edx
  801601:	8b 48 04             	mov    0x4(%eax),%ecx
  801604:	8d 40 08             	lea    0x8(%eax),%eax
  801607:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80160a:	b8 10 00 00 00       	mov    $0x10,%eax
  80160f:	eb 30                	jmp    801641 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801611:	85 c9                	test   %ecx,%ecx
  801613:	74 17                	je     80162c <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
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
  80162a:	eb 15                	jmp    801641 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80162c:	8b 45 14             	mov    0x14(%ebp),%eax
  80162f:	8b 10                	mov    (%eax),%edx
  801631:	b9 00 00 00 00       	mov    $0x0,%ecx
  801636:	8d 40 04             	lea    0x4(%eax),%eax
  801639:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80163c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801641:	83 ec 0c             	sub    $0xc,%esp
  801644:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801648:	57                   	push   %edi
  801649:	ff 75 e0             	pushl  -0x20(%ebp)
  80164c:	50                   	push   %eax
  80164d:	51                   	push   %ecx
  80164e:	52                   	push   %edx
  80164f:	89 da                	mov    %ebx,%edx
  801651:	89 f0                	mov    %esi,%eax
  801653:	e8 f1 fa ff ff       	call   801149 <printnum>
			break;
  801658:	83 c4 20             	add    $0x20,%esp
  80165b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80165e:	e9 f5 fb ff ff       	jmp    801258 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801663:	83 ec 08             	sub    $0x8,%esp
  801666:	53                   	push   %ebx
  801667:	52                   	push   %edx
  801668:	ff d6                	call   *%esi
			break;
  80166a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80166d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801670:	e9 e3 fb ff ff       	jmp    801258 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801675:	83 ec 08             	sub    $0x8,%esp
  801678:	53                   	push   %ebx
  801679:	6a 25                	push   $0x25
  80167b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80167d:	83 c4 10             	add    $0x10,%esp
  801680:	eb 03                	jmp    801685 <vprintfmt+0x453>
  801682:	83 ef 01             	sub    $0x1,%edi
  801685:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801689:	75 f7                	jne    801682 <vprintfmt+0x450>
  80168b:	e9 c8 fb ff ff       	jmp    801258 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801690:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801693:	5b                   	pop    %ebx
  801694:	5e                   	pop    %esi
  801695:	5f                   	pop    %edi
  801696:	5d                   	pop    %ebp
  801697:	c3                   	ret    

00801698 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	83 ec 18             	sub    $0x18,%esp
  80169e:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8016a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8016a7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8016ab:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8016ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8016b5:	85 c0                	test   %eax,%eax
  8016b7:	74 26                	je     8016df <vsnprintf+0x47>
  8016b9:	85 d2                	test   %edx,%edx
  8016bb:	7e 22                	jle    8016df <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8016bd:	ff 75 14             	pushl  0x14(%ebp)
  8016c0:	ff 75 10             	pushl  0x10(%ebp)
  8016c3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016c6:	50                   	push   %eax
  8016c7:	68 f8 11 80 00       	push   $0x8011f8
  8016cc:	e8 61 fb ff ff       	call   801232 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016d4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	eb 05                	jmp    8016e4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016e4:	c9                   	leave  
  8016e5:	c3                   	ret    

008016e6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016ec:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016ef:	50                   	push   %eax
  8016f0:	ff 75 10             	pushl  0x10(%ebp)
  8016f3:	ff 75 0c             	pushl  0xc(%ebp)
  8016f6:	ff 75 08             	pushl  0x8(%ebp)
  8016f9:	e8 9a ff ff ff       	call   801698 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016fe:	c9                   	leave  
  8016ff:	c3                   	ret    

00801700 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801700:	55                   	push   %ebp
  801701:	89 e5                	mov    %esp,%ebp
  801703:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801706:	b8 00 00 00 00       	mov    $0x0,%eax
  80170b:	eb 03                	jmp    801710 <strlen+0x10>
		n++;
  80170d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801710:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801714:	75 f7                	jne    80170d <strlen+0xd>
		n++;
	return n;
}
  801716:	5d                   	pop    %ebp
  801717:	c3                   	ret    

00801718 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80171e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801721:	ba 00 00 00 00       	mov    $0x0,%edx
  801726:	eb 03                	jmp    80172b <strnlen+0x13>
		n++;
  801728:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80172b:	39 c2                	cmp    %eax,%edx
  80172d:	74 08                	je     801737 <strnlen+0x1f>
  80172f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801733:	75 f3                	jne    801728 <strnlen+0x10>
  801735:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801737:	5d                   	pop    %ebp
  801738:	c3                   	ret    

00801739 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801739:	55                   	push   %ebp
  80173a:	89 e5                	mov    %esp,%ebp
  80173c:	53                   	push   %ebx
  80173d:	8b 45 08             	mov    0x8(%ebp),%eax
  801740:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801743:	89 c2                	mov    %eax,%edx
  801745:	83 c2 01             	add    $0x1,%edx
  801748:	83 c1 01             	add    $0x1,%ecx
  80174b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80174f:	88 5a ff             	mov    %bl,-0x1(%edx)
  801752:	84 db                	test   %bl,%bl
  801754:	75 ef                	jne    801745 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801756:	5b                   	pop    %ebx
  801757:	5d                   	pop    %ebp
  801758:	c3                   	ret    

00801759 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801759:	55                   	push   %ebp
  80175a:	89 e5                	mov    %esp,%ebp
  80175c:	53                   	push   %ebx
  80175d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801760:	53                   	push   %ebx
  801761:	e8 9a ff ff ff       	call   801700 <strlen>
  801766:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801769:	ff 75 0c             	pushl  0xc(%ebp)
  80176c:	01 d8                	add    %ebx,%eax
  80176e:	50                   	push   %eax
  80176f:	e8 c5 ff ff ff       	call   801739 <strcpy>
	return dst;
}
  801774:	89 d8                	mov    %ebx,%eax
  801776:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801779:	c9                   	leave  
  80177a:	c3                   	ret    

0080177b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80177b:	55                   	push   %ebp
  80177c:	89 e5                	mov    %esp,%ebp
  80177e:	56                   	push   %esi
  80177f:	53                   	push   %ebx
  801780:	8b 75 08             	mov    0x8(%ebp),%esi
  801783:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801786:	89 f3                	mov    %esi,%ebx
  801788:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80178b:	89 f2                	mov    %esi,%edx
  80178d:	eb 0f                	jmp    80179e <strncpy+0x23>
		*dst++ = *src;
  80178f:	83 c2 01             	add    $0x1,%edx
  801792:	0f b6 01             	movzbl (%ecx),%eax
  801795:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801798:	80 39 01             	cmpb   $0x1,(%ecx)
  80179b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80179e:	39 da                	cmp    %ebx,%edx
  8017a0:	75 ed                	jne    80178f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8017a2:	89 f0                	mov    %esi,%eax
  8017a4:	5b                   	pop    %ebx
  8017a5:	5e                   	pop    %esi
  8017a6:	5d                   	pop    %ebp
  8017a7:	c3                   	ret    

008017a8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8017a8:	55                   	push   %ebp
  8017a9:	89 e5                	mov    %esp,%ebp
  8017ab:	56                   	push   %esi
  8017ac:	53                   	push   %ebx
  8017ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8017b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017b3:	8b 55 10             	mov    0x10(%ebp),%edx
  8017b6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8017b8:	85 d2                	test   %edx,%edx
  8017ba:	74 21                	je     8017dd <strlcpy+0x35>
  8017bc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8017c0:	89 f2                	mov    %esi,%edx
  8017c2:	eb 09                	jmp    8017cd <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017c4:	83 c2 01             	add    $0x1,%edx
  8017c7:	83 c1 01             	add    $0x1,%ecx
  8017ca:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017cd:	39 c2                	cmp    %eax,%edx
  8017cf:	74 09                	je     8017da <strlcpy+0x32>
  8017d1:	0f b6 19             	movzbl (%ecx),%ebx
  8017d4:	84 db                	test   %bl,%bl
  8017d6:	75 ec                	jne    8017c4 <strlcpy+0x1c>
  8017d8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017da:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017dd:	29 f0                	sub    %esi,%eax
}
  8017df:	5b                   	pop    %ebx
  8017e0:	5e                   	pop    %esi
  8017e1:	5d                   	pop    %ebp
  8017e2:	c3                   	ret    

008017e3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017e3:	55                   	push   %ebp
  8017e4:	89 e5                	mov    %esp,%ebp
  8017e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017ec:	eb 06                	jmp    8017f4 <strcmp+0x11>
		p++, q++;
  8017ee:	83 c1 01             	add    $0x1,%ecx
  8017f1:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017f4:	0f b6 01             	movzbl (%ecx),%eax
  8017f7:	84 c0                	test   %al,%al
  8017f9:	74 04                	je     8017ff <strcmp+0x1c>
  8017fb:	3a 02                	cmp    (%edx),%al
  8017fd:	74 ef                	je     8017ee <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ff:	0f b6 c0             	movzbl %al,%eax
  801802:	0f b6 12             	movzbl (%edx),%edx
  801805:	29 d0                	sub    %edx,%eax
}
  801807:	5d                   	pop    %ebp
  801808:	c3                   	ret    

00801809 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801809:	55                   	push   %ebp
  80180a:	89 e5                	mov    %esp,%ebp
  80180c:	53                   	push   %ebx
  80180d:	8b 45 08             	mov    0x8(%ebp),%eax
  801810:	8b 55 0c             	mov    0xc(%ebp),%edx
  801813:	89 c3                	mov    %eax,%ebx
  801815:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801818:	eb 06                	jmp    801820 <strncmp+0x17>
		n--, p++, q++;
  80181a:	83 c0 01             	add    $0x1,%eax
  80181d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801820:	39 d8                	cmp    %ebx,%eax
  801822:	74 15                	je     801839 <strncmp+0x30>
  801824:	0f b6 08             	movzbl (%eax),%ecx
  801827:	84 c9                	test   %cl,%cl
  801829:	74 04                	je     80182f <strncmp+0x26>
  80182b:	3a 0a                	cmp    (%edx),%cl
  80182d:	74 eb                	je     80181a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80182f:	0f b6 00             	movzbl (%eax),%eax
  801832:	0f b6 12             	movzbl (%edx),%edx
  801835:	29 d0                	sub    %edx,%eax
  801837:	eb 05                	jmp    80183e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801839:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80183e:	5b                   	pop    %ebx
  80183f:	5d                   	pop    %ebp
  801840:	c3                   	ret    

00801841 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801841:	55                   	push   %ebp
  801842:	89 e5                	mov    %esp,%ebp
  801844:	8b 45 08             	mov    0x8(%ebp),%eax
  801847:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80184b:	eb 07                	jmp    801854 <strchr+0x13>
		if (*s == c)
  80184d:	38 ca                	cmp    %cl,%dl
  80184f:	74 0f                	je     801860 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801851:	83 c0 01             	add    $0x1,%eax
  801854:	0f b6 10             	movzbl (%eax),%edx
  801857:	84 d2                	test   %dl,%dl
  801859:	75 f2                	jne    80184d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80185b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801860:	5d                   	pop    %ebp
  801861:	c3                   	ret    

00801862 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801862:	55                   	push   %ebp
  801863:	89 e5                	mov    %esp,%ebp
  801865:	8b 45 08             	mov    0x8(%ebp),%eax
  801868:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80186c:	eb 03                	jmp    801871 <strfind+0xf>
  80186e:	83 c0 01             	add    $0x1,%eax
  801871:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801874:	38 ca                	cmp    %cl,%dl
  801876:	74 04                	je     80187c <strfind+0x1a>
  801878:	84 d2                	test   %dl,%dl
  80187a:	75 f2                	jne    80186e <strfind+0xc>
			break;
	return (char *) s;
}
  80187c:	5d                   	pop    %ebp
  80187d:	c3                   	ret    

0080187e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	57                   	push   %edi
  801882:	56                   	push   %esi
  801883:	53                   	push   %ebx
  801884:	8b 7d 08             	mov    0x8(%ebp),%edi
  801887:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80188a:	85 c9                	test   %ecx,%ecx
  80188c:	74 36                	je     8018c4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80188e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801894:	75 28                	jne    8018be <memset+0x40>
  801896:	f6 c1 03             	test   $0x3,%cl
  801899:	75 23                	jne    8018be <memset+0x40>
		c &= 0xFF;
  80189b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80189f:	89 d3                	mov    %edx,%ebx
  8018a1:	c1 e3 08             	shl    $0x8,%ebx
  8018a4:	89 d6                	mov    %edx,%esi
  8018a6:	c1 e6 18             	shl    $0x18,%esi
  8018a9:	89 d0                	mov    %edx,%eax
  8018ab:	c1 e0 10             	shl    $0x10,%eax
  8018ae:	09 f0                	or     %esi,%eax
  8018b0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8018b2:	89 d8                	mov    %ebx,%eax
  8018b4:	09 d0                	or     %edx,%eax
  8018b6:	c1 e9 02             	shr    $0x2,%ecx
  8018b9:	fc                   	cld    
  8018ba:	f3 ab                	rep stos %eax,%es:(%edi)
  8018bc:	eb 06                	jmp    8018c4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8018be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c1:	fc                   	cld    
  8018c2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8018c4:	89 f8                	mov    %edi,%eax
  8018c6:	5b                   	pop    %ebx
  8018c7:	5e                   	pop    %esi
  8018c8:	5f                   	pop    %edi
  8018c9:	5d                   	pop    %ebp
  8018ca:	c3                   	ret    

008018cb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
  8018ce:	57                   	push   %edi
  8018cf:	56                   	push   %esi
  8018d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018d6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018d9:	39 c6                	cmp    %eax,%esi
  8018db:	73 35                	jae    801912 <memmove+0x47>
  8018dd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018e0:	39 d0                	cmp    %edx,%eax
  8018e2:	73 2e                	jae    801912 <memmove+0x47>
		s += n;
		d += n;
  8018e4:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018e7:	89 d6                	mov    %edx,%esi
  8018e9:	09 fe                	or     %edi,%esi
  8018eb:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018f1:	75 13                	jne    801906 <memmove+0x3b>
  8018f3:	f6 c1 03             	test   $0x3,%cl
  8018f6:	75 0e                	jne    801906 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018f8:	83 ef 04             	sub    $0x4,%edi
  8018fb:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018fe:	c1 e9 02             	shr    $0x2,%ecx
  801901:	fd                   	std    
  801902:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801904:	eb 09                	jmp    80190f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801906:	83 ef 01             	sub    $0x1,%edi
  801909:	8d 72 ff             	lea    -0x1(%edx),%esi
  80190c:	fd                   	std    
  80190d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80190f:	fc                   	cld    
  801910:	eb 1d                	jmp    80192f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801912:	89 f2                	mov    %esi,%edx
  801914:	09 c2                	or     %eax,%edx
  801916:	f6 c2 03             	test   $0x3,%dl
  801919:	75 0f                	jne    80192a <memmove+0x5f>
  80191b:	f6 c1 03             	test   $0x3,%cl
  80191e:	75 0a                	jne    80192a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801920:	c1 e9 02             	shr    $0x2,%ecx
  801923:	89 c7                	mov    %eax,%edi
  801925:	fc                   	cld    
  801926:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801928:	eb 05                	jmp    80192f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80192a:	89 c7                	mov    %eax,%edi
  80192c:	fc                   	cld    
  80192d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80192f:	5e                   	pop    %esi
  801930:	5f                   	pop    %edi
  801931:	5d                   	pop    %ebp
  801932:	c3                   	ret    

00801933 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801933:	55                   	push   %ebp
  801934:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801936:	ff 75 10             	pushl  0x10(%ebp)
  801939:	ff 75 0c             	pushl  0xc(%ebp)
  80193c:	ff 75 08             	pushl  0x8(%ebp)
  80193f:	e8 87 ff ff ff       	call   8018cb <memmove>
}
  801944:	c9                   	leave  
  801945:	c3                   	ret    

00801946 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801946:	55                   	push   %ebp
  801947:	89 e5                	mov    %esp,%ebp
  801949:	56                   	push   %esi
  80194a:	53                   	push   %ebx
  80194b:	8b 45 08             	mov    0x8(%ebp),%eax
  80194e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801951:	89 c6                	mov    %eax,%esi
  801953:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801956:	eb 1a                	jmp    801972 <memcmp+0x2c>
		if (*s1 != *s2)
  801958:	0f b6 08             	movzbl (%eax),%ecx
  80195b:	0f b6 1a             	movzbl (%edx),%ebx
  80195e:	38 d9                	cmp    %bl,%cl
  801960:	74 0a                	je     80196c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801962:	0f b6 c1             	movzbl %cl,%eax
  801965:	0f b6 db             	movzbl %bl,%ebx
  801968:	29 d8                	sub    %ebx,%eax
  80196a:	eb 0f                	jmp    80197b <memcmp+0x35>
		s1++, s2++;
  80196c:	83 c0 01             	add    $0x1,%eax
  80196f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801972:	39 f0                	cmp    %esi,%eax
  801974:	75 e2                	jne    801958 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801976:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80197b:	5b                   	pop    %ebx
  80197c:	5e                   	pop    %esi
  80197d:	5d                   	pop    %ebp
  80197e:	c3                   	ret    

0080197f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
  801982:	53                   	push   %ebx
  801983:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801986:	89 c1                	mov    %eax,%ecx
  801988:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80198b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80198f:	eb 0a                	jmp    80199b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801991:	0f b6 10             	movzbl (%eax),%edx
  801994:	39 da                	cmp    %ebx,%edx
  801996:	74 07                	je     80199f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801998:	83 c0 01             	add    $0x1,%eax
  80199b:	39 c8                	cmp    %ecx,%eax
  80199d:	72 f2                	jb     801991 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80199f:	5b                   	pop    %ebx
  8019a0:	5d                   	pop    %ebp
  8019a1:	c3                   	ret    

008019a2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	57                   	push   %edi
  8019a6:	56                   	push   %esi
  8019a7:	53                   	push   %ebx
  8019a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019ae:	eb 03                	jmp    8019b3 <strtol+0x11>
		s++;
  8019b0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8019b3:	0f b6 01             	movzbl (%ecx),%eax
  8019b6:	3c 20                	cmp    $0x20,%al
  8019b8:	74 f6                	je     8019b0 <strtol+0xe>
  8019ba:	3c 09                	cmp    $0x9,%al
  8019bc:	74 f2                	je     8019b0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8019be:	3c 2b                	cmp    $0x2b,%al
  8019c0:	75 0a                	jne    8019cc <strtol+0x2a>
		s++;
  8019c2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019c5:	bf 00 00 00 00       	mov    $0x0,%edi
  8019ca:	eb 11                	jmp    8019dd <strtol+0x3b>
  8019cc:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019d1:	3c 2d                	cmp    $0x2d,%al
  8019d3:	75 08                	jne    8019dd <strtol+0x3b>
		s++, neg = 1;
  8019d5:	83 c1 01             	add    $0x1,%ecx
  8019d8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019dd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019e3:	75 15                	jne    8019fa <strtol+0x58>
  8019e5:	80 39 30             	cmpb   $0x30,(%ecx)
  8019e8:	75 10                	jne    8019fa <strtol+0x58>
  8019ea:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019ee:	75 7c                	jne    801a6c <strtol+0xca>
		s += 2, base = 16;
  8019f0:	83 c1 02             	add    $0x2,%ecx
  8019f3:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019f8:	eb 16                	jmp    801a10 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019fa:	85 db                	test   %ebx,%ebx
  8019fc:	75 12                	jne    801a10 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019fe:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a03:	80 39 30             	cmpb   $0x30,(%ecx)
  801a06:	75 08                	jne    801a10 <strtol+0x6e>
		s++, base = 8;
  801a08:	83 c1 01             	add    $0x1,%ecx
  801a0b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801a10:	b8 00 00 00 00       	mov    $0x0,%eax
  801a15:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801a18:	0f b6 11             	movzbl (%ecx),%edx
  801a1b:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a1e:	89 f3                	mov    %esi,%ebx
  801a20:	80 fb 09             	cmp    $0x9,%bl
  801a23:	77 08                	ja     801a2d <strtol+0x8b>
			dig = *s - '0';
  801a25:	0f be d2             	movsbl %dl,%edx
  801a28:	83 ea 30             	sub    $0x30,%edx
  801a2b:	eb 22                	jmp    801a4f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a2d:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a30:	89 f3                	mov    %esi,%ebx
  801a32:	80 fb 19             	cmp    $0x19,%bl
  801a35:	77 08                	ja     801a3f <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a37:	0f be d2             	movsbl %dl,%edx
  801a3a:	83 ea 57             	sub    $0x57,%edx
  801a3d:	eb 10                	jmp    801a4f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a3f:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a42:	89 f3                	mov    %esi,%ebx
  801a44:	80 fb 19             	cmp    $0x19,%bl
  801a47:	77 16                	ja     801a5f <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a49:	0f be d2             	movsbl %dl,%edx
  801a4c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a4f:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a52:	7d 0b                	jge    801a5f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a54:	83 c1 01             	add    $0x1,%ecx
  801a57:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a5b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a5d:	eb b9                	jmp    801a18 <strtol+0x76>

	if (endptr)
  801a5f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a63:	74 0d                	je     801a72 <strtol+0xd0>
		*endptr = (char *) s;
  801a65:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a68:	89 0e                	mov    %ecx,(%esi)
  801a6a:	eb 06                	jmp    801a72 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a6c:	85 db                	test   %ebx,%ebx
  801a6e:	74 98                	je     801a08 <strtol+0x66>
  801a70:	eb 9e                	jmp    801a10 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a72:	89 c2                	mov    %eax,%edx
  801a74:	f7 da                	neg    %edx
  801a76:	85 ff                	test   %edi,%edi
  801a78:	0f 45 c2             	cmovne %edx,%eax
}
  801a7b:	5b                   	pop    %ebx
  801a7c:	5e                   	pop    %esi
  801a7d:	5f                   	pop    %edi
  801a7e:	5d                   	pop    %ebp
  801a7f:	c3                   	ret    

00801a80 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	56                   	push   %esi
  801a84:	53                   	push   %ebx
  801a85:	8b 75 08             	mov    0x8(%ebp),%esi
  801a88:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a95:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801a98:	83 ec 0c             	sub    $0xc,%esp
  801a9b:	50                   	push   %eax
  801a9c:	e8 90 e8 ff ff       	call   800331 <sys_ipc_recv>
  801aa1:	83 c4 10             	add    $0x10,%esp
  801aa4:	85 c0                	test   %eax,%eax
  801aa6:	79 16                	jns    801abe <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801aa8:	85 f6                	test   %esi,%esi
  801aaa:	74 06                	je     801ab2 <ipc_recv+0x32>
            *from_env_store = 0;
  801aac:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801ab2:	85 db                	test   %ebx,%ebx
  801ab4:	74 2c                	je     801ae2 <ipc_recv+0x62>
            *perm_store = 0;
  801ab6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801abc:	eb 24                	jmp    801ae2 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801abe:	85 f6                	test   %esi,%esi
  801ac0:	74 0a                	je     801acc <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801ac2:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac7:	8b 40 74             	mov    0x74(%eax),%eax
  801aca:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801acc:	85 db                	test   %ebx,%ebx
  801ace:	74 0a                	je     801ada <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801ad0:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad5:	8b 40 78             	mov    0x78(%eax),%eax
  801ad8:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801ada:	a1 04 40 80 00       	mov    0x804004,%eax
  801adf:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801ae2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae5:	5b                   	pop    %ebx
  801ae6:	5e                   	pop    %esi
  801ae7:	5d                   	pop    %ebp
  801ae8:	c3                   	ret    

00801ae9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ae9:	55                   	push   %ebp
  801aea:	89 e5                	mov    %esp,%ebp
  801aec:	57                   	push   %edi
  801aed:	56                   	push   %esi
  801aee:	53                   	push   %ebx
  801aef:	83 ec 0c             	sub    $0xc,%esp
  801af2:	8b 7d 08             	mov    0x8(%ebp),%edi
  801af5:	8b 75 0c             	mov    0xc(%ebp),%esi
  801af8:	8b 45 10             	mov    0x10(%ebp),%eax
  801afb:	85 c0                	test   %eax,%eax
  801afd:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801b02:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801b05:	eb 1c                	jmp    801b23 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801b07:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b0a:	74 12                	je     801b1e <ipc_send+0x35>
  801b0c:	50                   	push   %eax
  801b0d:	68 a0 22 80 00       	push   $0x8022a0
  801b12:	6a 3a                	push   $0x3a
  801b14:	68 b6 22 80 00       	push   $0x8022b6
  801b19:	e8 3e f5 ff ff       	call   80105c <_panic>
		sys_yield();
  801b1e:	e8 3f e6 ff ff       	call   800162 <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801b23:	ff 75 14             	pushl  0x14(%ebp)
  801b26:	53                   	push   %ebx
  801b27:	56                   	push   %esi
  801b28:	57                   	push   %edi
  801b29:	e8 e0 e7 ff ff       	call   80030e <sys_ipc_try_send>
  801b2e:	83 c4 10             	add    $0x10,%esp
  801b31:	85 c0                	test   %eax,%eax
  801b33:	78 d2                	js     801b07 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801b35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b38:	5b                   	pop    %ebx
  801b39:	5e                   	pop    %esi
  801b3a:	5f                   	pop    %edi
  801b3b:	5d                   	pop    %ebp
  801b3c:	c3                   	ret    

00801b3d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b3d:	55                   	push   %ebp
  801b3e:	89 e5                	mov    %esp,%ebp
  801b40:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b43:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b48:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b4b:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b51:	8b 52 50             	mov    0x50(%edx),%edx
  801b54:	39 ca                	cmp    %ecx,%edx
  801b56:	75 0d                	jne    801b65 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b58:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b5b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b60:	8b 40 48             	mov    0x48(%eax),%eax
  801b63:	eb 0f                	jmp    801b74 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b65:	83 c0 01             	add    $0x1,%eax
  801b68:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b6d:	75 d9                	jne    801b48 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b74:	5d                   	pop    %ebp
  801b75:	c3                   	ret    

00801b76 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b76:	55                   	push   %ebp
  801b77:	89 e5                	mov    %esp,%ebp
  801b79:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b7c:	89 d0                	mov    %edx,%eax
  801b7e:	c1 e8 16             	shr    $0x16,%eax
  801b81:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b88:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b8d:	f6 c1 01             	test   $0x1,%cl
  801b90:	74 1d                	je     801baf <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b92:	c1 ea 0c             	shr    $0xc,%edx
  801b95:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b9c:	f6 c2 01             	test   $0x1,%dl
  801b9f:	74 0e                	je     801baf <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ba1:	c1 ea 0c             	shr    $0xc,%edx
  801ba4:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bab:	ef 
  801bac:	0f b7 c0             	movzwl %ax,%eax
}
  801baf:	5d                   	pop    %ebp
  801bb0:	c3                   	ret    
  801bb1:	66 90                	xchg   %ax,%ax
  801bb3:	66 90                	xchg   %ax,%ax
  801bb5:	66 90                	xchg   %ax,%ax
  801bb7:	66 90                	xchg   %ax,%ax
  801bb9:	66 90                	xchg   %ax,%ax
  801bbb:	66 90                	xchg   %ax,%ax
  801bbd:	66 90                	xchg   %ax,%ax
  801bbf:	90                   	nop

00801bc0 <__udivdi3>:
  801bc0:	55                   	push   %ebp
  801bc1:	57                   	push   %edi
  801bc2:	56                   	push   %esi
  801bc3:	53                   	push   %ebx
  801bc4:	83 ec 1c             	sub    $0x1c,%esp
  801bc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bd7:	85 f6                	test   %esi,%esi
  801bd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bdd:	89 ca                	mov    %ecx,%edx
  801bdf:	89 f8                	mov    %edi,%eax
  801be1:	75 3d                	jne    801c20 <__udivdi3+0x60>
  801be3:	39 cf                	cmp    %ecx,%edi
  801be5:	0f 87 c5 00 00 00    	ja     801cb0 <__udivdi3+0xf0>
  801beb:	85 ff                	test   %edi,%edi
  801bed:	89 fd                	mov    %edi,%ebp
  801bef:	75 0b                	jne    801bfc <__udivdi3+0x3c>
  801bf1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bf6:	31 d2                	xor    %edx,%edx
  801bf8:	f7 f7                	div    %edi
  801bfa:	89 c5                	mov    %eax,%ebp
  801bfc:	89 c8                	mov    %ecx,%eax
  801bfe:	31 d2                	xor    %edx,%edx
  801c00:	f7 f5                	div    %ebp
  801c02:	89 c1                	mov    %eax,%ecx
  801c04:	89 d8                	mov    %ebx,%eax
  801c06:	89 cf                	mov    %ecx,%edi
  801c08:	f7 f5                	div    %ebp
  801c0a:	89 c3                	mov    %eax,%ebx
  801c0c:	89 d8                	mov    %ebx,%eax
  801c0e:	89 fa                	mov    %edi,%edx
  801c10:	83 c4 1c             	add    $0x1c,%esp
  801c13:	5b                   	pop    %ebx
  801c14:	5e                   	pop    %esi
  801c15:	5f                   	pop    %edi
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    
  801c18:	90                   	nop
  801c19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c20:	39 ce                	cmp    %ecx,%esi
  801c22:	77 74                	ja     801c98 <__udivdi3+0xd8>
  801c24:	0f bd fe             	bsr    %esi,%edi
  801c27:	83 f7 1f             	xor    $0x1f,%edi
  801c2a:	0f 84 98 00 00 00    	je     801cc8 <__udivdi3+0x108>
  801c30:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c35:	89 f9                	mov    %edi,%ecx
  801c37:	89 c5                	mov    %eax,%ebp
  801c39:	29 fb                	sub    %edi,%ebx
  801c3b:	d3 e6                	shl    %cl,%esi
  801c3d:	89 d9                	mov    %ebx,%ecx
  801c3f:	d3 ed                	shr    %cl,%ebp
  801c41:	89 f9                	mov    %edi,%ecx
  801c43:	d3 e0                	shl    %cl,%eax
  801c45:	09 ee                	or     %ebp,%esi
  801c47:	89 d9                	mov    %ebx,%ecx
  801c49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c4d:	89 d5                	mov    %edx,%ebp
  801c4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c53:	d3 ed                	shr    %cl,%ebp
  801c55:	89 f9                	mov    %edi,%ecx
  801c57:	d3 e2                	shl    %cl,%edx
  801c59:	89 d9                	mov    %ebx,%ecx
  801c5b:	d3 e8                	shr    %cl,%eax
  801c5d:	09 c2                	or     %eax,%edx
  801c5f:	89 d0                	mov    %edx,%eax
  801c61:	89 ea                	mov    %ebp,%edx
  801c63:	f7 f6                	div    %esi
  801c65:	89 d5                	mov    %edx,%ebp
  801c67:	89 c3                	mov    %eax,%ebx
  801c69:	f7 64 24 0c          	mull   0xc(%esp)
  801c6d:	39 d5                	cmp    %edx,%ebp
  801c6f:	72 10                	jb     801c81 <__udivdi3+0xc1>
  801c71:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c75:	89 f9                	mov    %edi,%ecx
  801c77:	d3 e6                	shl    %cl,%esi
  801c79:	39 c6                	cmp    %eax,%esi
  801c7b:	73 07                	jae    801c84 <__udivdi3+0xc4>
  801c7d:	39 d5                	cmp    %edx,%ebp
  801c7f:	75 03                	jne    801c84 <__udivdi3+0xc4>
  801c81:	83 eb 01             	sub    $0x1,%ebx
  801c84:	31 ff                	xor    %edi,%edi
  801c86:	89 d8                	mov    %ebx,%eax
  801c88:	89 fa                	mov    %edi,%edx
  801c8a:	83 c4 1c             	add    $0x1c,%esp
  801c8d:	5b                   	pop    %ebx
  801c8e:	5e                   	pop    %esi
  801c8f:	5f                   	pop    %edi
  801c90:	5d                   	pop    %ebp
  801c91:	c3                   	ret    
  801c92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c98:	31 ff                	xor    %edi,%edi
  801c9a:	31 db                	xor    %ebx,%ebx
  801c9c:	89 d8                	mov    %ebx,%eax
  801c9e:	89 fa                	mov    %edi,%edx
  801ca0:	83 c4 1c             	add    $0x1c,%esp
  801ca3:	5b                   	pop    %ebx
  801ca4:	5e                   	pop    %esi
  801ca5:	5f                   	pop    %edi
  801ca6:	5d                   	pop    %ebp
  801ca7:	c3                   	ret    
  801ca8:	90                   	nop
  801ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cb0:	89 d8                	mov    %ebx,%eax
  801cb2:	f7 f7                	div    %edi
  801cb4:	31 ff                	xor    %edi,%edi
  801cb6:	89 c3                	mov    %eax,%ebx
  801cb8:	89 d8                	mov    %ebx,%eax
  801cba:	89 fa                	mov    %edi,%edx
  801cbc:	83 c4 1c             	add    $0x1c,%esp
  801cbf:	5b                   	pop    %ebx
  801cc0:	5e                   	pop    %esi
  801cc1:	5f                   	pop    %edi
  801cc2:	5d                   	pop    %ebp
  801cc3:	c3                   	ret    
  801cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cc8:	39 ce                	cmp    %ecx,%esi
  801cca:	72 0c                	jb     801cd8 <__udivdi3+0x118>
  801ccc:	31 db                	xor    %ebx,%ebx
  801cce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cd2:	0f 87 34 ff ff ff    	ja     801c0c <__udivdi3+0x4c>
  801cd8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cdd:	e9 2a ff ff ff       	jmp    801c0c <__udivdi3+0x4c>
  801ce2:	66 90                	xchg   %ax,%ax
  801ce4:	66 90                	xchg   %ax,%ax
  801ce6:	66 90                	xchg   %ax,%ax
  801ce8:	66 90                	xchg   %ax,%ax
  801cea:	66 90                	xchg   %ax,%ax
  801cec:	66 90                	xchg   %ax,%ax
  801cee:	66 90                	xchg   %ax,%ax

00801cf0 <__umoddi3>:
  801cf0:	55                   	push   %ebp
  801cf1:	57                   	push   %edi
  801cf2:	56                   	push   %esi
  801cf3:	53                   	push   %ebx
  801cf4:	83 ec 1c             	sub    $0x1c,%esp
  801cf7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cfb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cff:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d07:	85 d2                	test   %edx,%edx
  801d09:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d11:	89 f3                	mov    %esi,%ebx
  801d13:	89 3c 24             	mov    %edi,(%esp)
  801d16:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d1a:	75 1c                	jne    801d38 <__umoddi3+0x48>
  801d1c:	39 f7                	cmp    %esi,%edi
  801d1e:	76 50                	jbe    801d70 <__umoddi3+0x80>
  801d20:	89 c8                	mov    %ecx,%eax
  801d22:	89 f2                	mov    %esi,%edx
  801d24:	f7 f7                	div    %edi
  801d26:	89 d0                	mov    %edx,%eax
  801d28:	31 d2                	xor    %edx,%edx
  801d2a:	83 c4 1c             	add    $0x1c,%esp
  801d2d:	5b                   	pop    %ebx
  801d2e:	5e                   	pop    %esi
  801d2f:	5f                   	pop    %edi
  801d30:	5d                   	pop    %ebp
  801d31:	c3                   	ret    
  801d32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d38:	39 f2                	cmp    %esi,%edx
  801d3a:	89 d0                	mov    %edx,%eax
  801d3c:	77 52                	ja     801d90 <__umoddi3+0xa0>
  801d3e:	0f bd ea             	bsr    %edx,%ebp
  801d41:	83 f5 1f             	xor    $0x1f,%ebp
  801d44:	75 5a                	jne    801da0 <__umoddi3+0xb0>
  801d46:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d4a:	0f 82 e0 00 00 00    	jb     801e30 <__umoddi3+0x140>
  801d50:	39 0c 24             	cmp    %ecx,(%esp)
  801d53:	0f 86 d7 00 00 00    	jbe    801e30 <__umoddi3+0x140>
  801d59:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d5d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d61:	83 c4 1c             	add    $0x1c,%esp
  801d64:	5b                   	pop    %ebx
  801d65:	5e                   	pop    %esi
  801d66:	5f                   	pop    %edi
  801d67:	5d                   	pop    %ebp
  801d68:	c3                   	ret    
  801d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d70:	85 ff                	test   %edi,%edi
  801d72:	89 fd                	mov    %edi,%ebp
  801d74:	75 0b                	jne    801d81 <__umoddi3+0x91>
  801d76:	b8 01 00 00 00       	mov    $0x1,%eax
  801d7b:	31 d2                	xor    %edx,%edx
  801d7d:	f7 f7                	div    %edi
  801d7f:	89 c5                	mov    %eax,%ebp
  801d81:	89 f0                	mov    %esi,%eax
  801d83:	31 d2                	xor    %edx,%edx
  801d85:	f7 f5                	div    %ebp
  801d87:	89 c8                	mov    %ecx,%eax
  801d89:	f7 f5                	div    %ebp
  801d8b:	89 d0                	mov    %edx,%eax
  801d8d:	eb 99                	jmp    801d28 <__umoddi3+0x38>
  801d8f:	90                   	nop
  801d90:	89 c8                	mov    %ecx,%eax
  801d92:	89 f2                	mov    %esi,%edx
  801d94:	83 c4 1c             	add    $0x1c,%esp
  801d97:	5b                   	pop    %ebx
  801d98:	5e                   	pop    %esi
  801d99:	5f                   	pop    %edi
  801d9a:	5d                   	pop    %ebp
  801d9b:	c3                   	ret    
  801d9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801da0:	8b 34 24             	mov    (%esp),%esi
  801da3:	bf 20 00 00 00       	mov    $0x20,%edi
  801da8:	89 e9                	mov    %ebp,%ecx
  801daa:	29 ef                	sub    %ebp,%edi
  801dac:	d3 e0                	shl    %cl,%eax
  801dae:	89 f9                	mov    %edi,%ecx
  801db0:	89 f2                	mov    %esi,%edx
  801db2:	d3 ea                	shr    %cl,%edx
  801db4:	89 e9                	mov    %ebp,%ecx
  801db6:	09 c2                	or     %eax,%edx
  801db8:	89 d8                	mov    %ebx,%eax
  801dba:	89 14 24             	mov    %edx,(%esp)
  801dbd:	89 f2                	mov    %esi,%edx
  801dbf:	d3 e2                	shl    %cl,%edx
  801dc1:	89 f9                	mov    %edi,%ecx
  801dc3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dc7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dcb:	d3 e8                	shr    %cl,%eax
  801dcd:	89 e9                	mov    %ebp,%ecx
  801dcf:	89 c6                	mov    %eax,%esi
  801dd1:	d3 e3                	shl    %cl,%ebx
  801dd3:	89 f9                	mov    %edi,%ecx
  801dd5:	89 d0                	mov    %edx,%eax
  801dd7:	d3 e8                	shr    %cl,%eax
  801dd9:	89 e9                	mov    %ebp,%ecx
  801ddb:	09 d8                	or     %ebx,%eax
  801ddd:	89 d3                	mov    %edx,%ebx
  801ddf:	89 f2                	mov    %esi,%edx
  801de1:	f7 34 24             	divl   (%esp)
  801de4:	89 d6                	mov    %edx,%esi
  801de6:	d3 e3                	shl    %cl,%ebx
  801de8:	f7 64 24 04          	mull   0x4(%esp)
  801dec:	39 d6                	cmp    %edx,%esi
  801dee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801df2:	89 d1                	mov    %edx,%ecx
  801df4:	89 c3                	mov    %eax,%ebx
  801df6:	72 08                	jb     801e00 <__umoddi3+0x110>
  801df8:	75 11                	jne    801e0b <__umoddi3+0x11b>
  801dfa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dfe:	73 0b                	jae    801e0b <__umoddi3+0x11b>
  801e00:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e04:	1b 14 24             	sbb    (%esp),%edx
  801e07:	89 d1                	mov    %edx,%ecx
  801e09:	89 c3                	mov    %eax,%ebx
  801e0b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e0f:	29 da                	sub    %ebx,%edx
  801e11:	19 ce                	sbb    %ecx,%esi
  801e13:	89 f9                	mov    %edi,%ecx
  801e15:	89 f0                	mov    %esi,%eax
  801e17:	d3 e0                	shl    %cl,%eax
  801e19:	89 e9                	mov    %ebp,%ecx
  801e1b:	d3 ea                	shr    %cl,%edx
  801e1d:	89 e9                	mov    %ebp,%ecx
  801e1f:	d3 ee                	shr    %cl,%esi
  801e21:	09 d0                	or     %edx,%eax
  801e23:	89 f2                	mov    %esi,%edx
  801e25:	83 c4 1c             	add    $0x1c,%esp
  801e28:	5b                   	pop    %ebx
  801e29:	5e                   	pop    %esi
  801e2a:	5f                   	pop    %edi
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    
  801e2d:	8d 76 00             	lea    0x0(%esi),%esi
  801e30:	29 f9                	sub    %edi,%ecx
  801e32:	19 d6                	sbb    %edx,%esi
  801e34:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e38:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e3c:	e9 18 ff ff ff       	jmp    801d59 <__umoddi3+0x69>
