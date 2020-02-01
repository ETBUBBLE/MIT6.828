
obj/user/faultwritekernel.debug：     文件格式 elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0xf0100000 = 0;
  800036:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  80004d:	e8 ce 00 00 00       	call   800120 <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 04 40 80 00       	mov    %eax,0x804004

    // save the name of the program so that panic() can use it
    if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x2d>
        binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
}
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008e:	e8 87 04 00 00       	call   80051a <close_all>
	sys_env_destroy(0);
  800093:	83 ec 0c             	sub    $0xc,%esp
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7e 17                	jle    800118 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 2a 1e 80 00       	push   $0x801e2a
  80010c:	6a 23                	push   $0x23
  80010e:	68 47 1e 80 00       	push   $0x801e47
  800113:	e8 21 0f 00 00       	call   801039 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5f                   	pop    %edi
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_yield>:

void
sys_yield(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
  800164:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800167:	be 00 00 00 00       	mov    $0x0,%esi
  80016c:	b8 04 00 00 00       	mov    $0x4,%eax
  800171:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017a:	89 f7                	mov    %esi,%edi
  80017c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80017e:	85 c0                	test   %eax,%eax
  800180:	7e 17                	jle    800199 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	50                   	push   %eax
  800186:	6a 04                	push   $0x4
  800188:	68 2a 1e 80 00       	push   $0x801e2a
  80018d:	6a 23                	push   $0x23
  80018f:	68 47 1e 80 00       	push   $0x801e47
  800194:	e8 a0 0e 00 00       	call   801039 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8001af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001be:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	7e 17                	jle    8001db <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	50                   	push   %eax
  8001c8:	6a 05                	push   $0x5
  8001ca:	68 2a 1e 80 00       	push   $0x801e2a
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 47 1e 80 00       	push   $0x801e47
  8001d6:	e8 5e 0e 00 00       	call   801039 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5e                   	pop    %esi
  8001e0:	5f                   	pop    %edi
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fc:	89 df                	mov    %ebx,%edi
  8001fe:	89 de                	mov    %ebx,%esi
  800200:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7e 17                	jle    80021d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	50                   	push   %eax
  80020a:	6a 06                	push   $0x6
  80020c:	68 2a 1e 80 00       	push   $0x801e2a
  800211:	6a 23                	push   $0x23
  800213:	68 47 1e 80 00       	push   $0x801e47
  800218:	e8 1c 0e 00 00       	call   801039 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800220:	5b                   	pop    %ebx
  800221:	5e                   	pop    %esi
  800222:	5f                   	pop    %edi
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	b8 08 00 00 00       	mov    $0x8,%eax
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7e 17                	jle    80025f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	50                   	push   %eax
  80024c:	6a 08                	push   $0x8
  80024e:	68 2a 1e 80 00       	push   $0x801e2a
  800253:	6a 23                	push   $0x23
  800255:	68 47 1e 80 00       	push   $0x801e47
  80025a:	e8 da 0d 00 00       	call   801039 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5f                   	pop    %edi
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	b8 09 00 00 00       	mov    $0x9,%eax
  80027a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7e 17                	jle    8002a1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 09                	push   $0x9
  800290:	68 2a 1e 80 00       	push   $0x801e2a
  800295:	6a 23                	push   $0x23
  800297:	68 47 1e 80 00       	push   $0x801e47
  80029c:	e8 98 0d 00 00       	call   801039 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5e                   	pop    %esi
  8002a6:	5f                   	pop    %edi
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c2:	89 df                	mov    %ebx,%edi
  8002c4:	89 de                	mov    %ebx,%esi
  8002c6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	7e 17                	jle    8002e3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cc:	83 ec 0c             	sub    $0xc,%esp
  8002cf:	50                   	push   %eax
  8002d0:	6a 0a                	push   $0xa
  8002d2:	68 2a 1e 80 00       	push   $0x801e2a
  8002d7:	6a 23                	push   $0x23
  8002d9:	68 47 1e 80 00       	push   $0x801e47
  8002de:	e8 56 0d 00 00       	call   801039 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e6:	5b                   	pop    %ebx
  8002e7:	5e                   	pop    %esi
  8002e8:	5f                   	pop    %edi
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f1:	be 00 00 00 00       	mov    $0x0,%esi
  8002f6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800301:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800304:	8b 7d 14             	mov    0x14(%ebp),%edi
  800307:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800317:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	89 cb                	mov    %ecx,%ebx
  800326:	89 cf                	mov    %ecx,%edi
  800328:	89 ce                	mov    %ecx,%esi
  80032a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80032c:	85 c0                	test   %eax,%eax
  80032e:	7e 17                	jle    800347 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	50                   	push   %eax
  800334:	6a 0d                	push   $0xd
  800336:	68 2a 1e 80 00       	push   $0x801e2a
  80033b:	6a 23                	push   $0x23
  80033d:	68 47 1e 80 00       	push   $0x801e47
  800342:	e8 f2 0c 00 00       	call   801039 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800352:	8b 45 08             	mov    0x8(%ebp),%eax
  800355:	05 00 00 00 30       	add    $0x30000000,%eax
  80035a:	c1 e8 0c             	shr    $0xc,%eax
}
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    

0080035f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800362:	8b 45 08             	mov    0x8(%ebp),%eax
  800365:	05 00 00 00 30       	add    $0x30000000,%eax
  80036a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80036f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800381:	89 c2                	mov    %eax,%edx
  800383:	c1 ea 16             	shr    $0x16,%edx
  800386:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80038d:	f6 c2 01             	test   $0x1,%dl
  800390:	74 11                	je     8003a3 <fd_alloc+0x2d>
  800392:	89 c2                	mov    %eax,%edx
  800394:	c1 ea 0c             	shr    $0xc,%edx
  800397:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80039e:	f6 c2 01             	test   $0x1,%dl
  8003a1:	75 09                	jne    8003ac <fd_alloc+0x36>
			*fd_store = fd;
  8003a3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003aa:	eb 17                	jmp    8003c3 <fd_alloc+0x4d>
  8003ac:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b6:	75 c9                	jne    800381 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003be:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    

008003c5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003cb:	83 f8 1f             	cmp    $0x1f,%eax
  8003ce:	77 36                	ja     800406 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d0:	c1 e0 0c             	shl    $0xc,%eax
  8003d3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d8:	89 c2                	mov    %eax,%edx
  8003da:	c1 ea 16             	shr    $0x16,%edx
  8003dd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e4:	f6 c2 01             	test   $0x1,%dl
  8003e7:	74 24                	je     80040d <fd_lookup+0x48>
  8003e9:	89 c2                	mov    %eax,%edx
  8003eb:	c1 ea 0c             	shr    $0xc,%edx
  8003ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f5:	f6 c2 01             	test   $0x1,%dl
  8003f8:	74 1a                	je     800414 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fd:	89 02                	mov    %eax,(%edx)
	return 0;
  8003ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800404:	eb 13                	jmp    800419 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800406:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040b:	eb 0c                	jmp    800419 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800412:	eb 05                	jmp    800419 <fd_lookup+0x54>
  800414:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800419:	5d                   	pop    %ebp
  80041a:	c3                   	ret    

0080041b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80041b:	55                   	push   %ebp
  80041c:	89 e5                	mov    %esp,%ebp
  80041e:	83 ec 08             	sub    $0x8,%esp
  800421:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800424:	ba d4 1e 80 00       	mov    $0x801ed4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800429:	eb 13                	jmp    80043e <dev_lookup+0x23>
  80042b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80042e:	39 08                	cmp    %ecx,(%eax)
  800430:	75 0c                	jne    80043e <dev_lookup+0x23>
			*dev = devtab[i];
  800432:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800435:	89 01                	mov    %eax,(%ecx)
			return 0;
  800437:	b8 00 00 00 00       	mov    $0x0,%eax
  80043c:	eb 2e                	jmp    80046c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80043e:	8b 02                	mov    (%edx),%eax
  800440:	85 c0                	test   %eax,%eax
  800442:	75 e7                	jne    80042b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800444:	a1 04 40 80 00       	mov    0x804004,%eax
  800449:	8b 40 48             	mov    0x48(%eax),%eax
  80044c:	83 ec 04             	sub    $0x4,%esp
  80044f:	51                   	push   %ecx
  800450:	50                   	push   %eax
  800451:	68 58 1e 80 00       	push   $0x801e58
  800456:	e8 b7 0c 00 00       	call   801112 <cprintf>
	*dev = 0;
  80045b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800464:	83 c4 10             	add    $0x10,%esp
  800467:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80046c:	c9                   	leave  
  80046d:	c3                   	ret    

0080046e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	56                   	push   %esi
  800472:	53                   	push   %ebx
  800473:	83 ec 10             	sub    $0x10,%esp
  800476:	8b 75 08             	mov    0x8(%ebp),%esi
  800479:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80047c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80047f:	50                   	push   %eax
  800480:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800486:	c1 e8 0c             	shr    $0xc,%eax
  800489:	50                   	push   %eax
  80048a:	e8 36 ff ff ff       	call   8003c5 <fd_lookup>
  80048f:	83 c4 08             	add    $0x8,%esp
  800492:	85 c0                	test   %eax,%eax
  800494:	78 05                	js     80049b <fd_close+0x2d>
	    || fd != fd2)
  800496:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800499:	74 0c                	je     8004a7 <fd_close+0x39>
		return (must_exist ? r : 0);
  80049b:	84 db                	test   %bl,%bl
  80049d:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a2:	0f 44 c2             	cmove  %edx,%eax
  8004a5:	eb 41                	jmp    8004e8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004ad:	50                   	push   %eax
  8004ae:	ff 36                	pushl  (%esi)
  8004b0:	e8 66 ff ff ff       	call   80041b <dev_lookup>
  8004b5:	89 c3                	mov    %eax,%ebx
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	85 c0                	test   %eax,%eax
  8004bc:	78 1a                	js     8004d8 <fd_close+0x6a>
		if (dev->dev_close)
  8004be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004c4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c9:	85 c0                	test   %eax,%eax
  8004cb:	74 0b                	je     8004d8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004cd:	83 ec 0c             	sub    $0xc,%esp
  8004d0:	56                   	push   %esi
  8004d1:	ff d0                	call   *%eax
  8004d3:	89 c3                	mov    %eax,%ebx
  8004d5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	56                   	push   %esi
  8004dc:	6a 00                	push   $0x0
  8004de:	e8 00 fd ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	89 d8                	mov    %ebx,%eax
}
  8004e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004eb:	5b                   	pop    %ebx
  8004ec:	5e                   	pop    %esi
  8004ed:	5d                   	pop    %ebp
  8004ee:	c3                   	ret    

008004ef <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004ef:	55                   	push   %ebp
  8004f0:	89 e5                	mov    %esp,%ebp
  8004f2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f8:	50                   	push   %eax
  8004f9:	ff 75 08             	pushl  0x8(%ebp)
  8004fc:	e8 c4 fe ff ff       	call   8003c5 <fd_lookup>
  800501:	83 c4 08             	add    $0x8,%esp
  800504:	85 c0                	test   %eax,%eax
  800506:	78 10                	js     800518 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	6a 01                	push   $0x1
  80050d:	ff 75 f4             	pushl  -0xc(%ebp)
  800510:	e8 59 ff ff ff       	call   80046e <fd_close>
  800515:	83 c4 10             	add    $0x10,%esp
}
  800518:	c9                   	leave  
  800519:	c3                   	ret    

0080051a <close_all>:

void
close_all(void)
{
  80051a:	55                   	push   %ebp
  80051b:	89 e5                	mov    %esp,%ebp
  80051d:	53                   	push   %ebx
  80051e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800521:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800526:	83 ec 0c             	sub    $0xc,%esp
  800529:	53                   	push   %ebx
  80052a:	e8 c0 ff ff ff       	call   8004ef <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80052f:	83 c3 01             	add    $0x1,%ebx
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	83 fb 20             	cmp    $0x20,%ebx
  800538:	75 ec                	jne    800526 <close_all+0xc>
		close(i);
}
  80053a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80053d:	c9                   	leave  
  80053e:	c3                   	ret    

0080053f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80053f:	55                   	push   %ebp
  800540:	89 e5                	mov    %esp,%ebp
  800542:	57                   	push   %edi
  800543:	56                   	push   %esi
  800544:	53                   	push   %ebx
  800545:	83 ec 2c             	sub    $0x2c,%esp
  800548:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80054b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80054e:	50                   	push   %eax
  80054f:	ff 75 08             	pushl  0x8(%ebp)
  800552:	e8 6e fe ff ff       	call   8003c5 <fd_lookup>
  800557:	83 c4 08             	add    $0x8,%esp
  80055a:	85 c0                	test   %eax,%eax
  80055c:	0f 88 c1 00 00 00    	js     800623 <dup+0xe4>
		return r;
	close(newfdnum);
  800562:	83 ec 0c             	sub    $0xc,%esp
  800565:	56                   	push   %esi
  800566:	e8 84 ff ff ff       	call   8004ef <close>

	newfd = INDEX2FD(newfdnum);
  80056b:	89 f3                	mov    %esi,%ebx
  80056d:	c1 e3 0c             	shl    $0xc,%ebx
  800570:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800576:	83 c4 04             	add    $0x4,%esp
  800579:	ff 75 e4             	pushl  -0x1c(%ebp)
  80057c:	e8 de fd ff ff       	call   80035f <fd2data>
  800581:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800583:	89 1c 24             	mov    %ebx,(%esp)
  800586:	e8 d4 fd ff ff       	call   80035f <fd2data>
  80058b:	83 c4 10             	add    $0x10,%esp
  80058e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800591:	89 f8                	mov    %edi,%eax
  800593:	c1 e8 16             	shr    $0x16,%eax
  800596:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80059d:	a8 01                	test   $0x1,%al
  80059f:	74 37                	je     8005d8 <dup+0x99>
  8005a1:	89 f8                	mov    %edi,%eax
  8005a3:	c1 e8 0c             	shr    $0xc,%eax
  8005a6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005ad:	f6 c2 01             	test   $0x1,%dl
  8005b0:	74 26                	je     8005d8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b9:	83 ec 0c             	sub    $0xc,%esp
  8005bc:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c1:	50                   	push   %eax
  8005c2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005c5:	6a 00                	push   $0x0
  8005c7:	57                   	push   %edi
  8005c8:	6a 00                	push   $0x0
  8005ca:	e8 d2 fb ff ff       	call   8001a1 <sys_page_map>
  8005cf:	89 c7                	mov    %eax,%edi
  8005d1:	83 c4 20             	add    $0x20,%esp
  8005d4:	85 c0                	test   %eax,%eax
  8005d6:	78 2e                	js     800606 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005db:	89 d0                	mov    %edx,%eax
  8005dd:	c1 e8 0c             	shr    $0xc,%eax
  8005e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e7:	83 ec 0c             	sub    $0xc,%esp
  8005ea:	25 07 0e 00 00       	and    $0xe07,%eax
  8005ef:	50                   	push   %eax
  8005f0:	53                   	push   %ebx
  8005f1:	6a 00                	push   $0x0
  8005f3:	52                   	push   %edx
  8005f4:	6a 00                	push   $0x0
  8005f6:	e8 a6 fb ff ff       	call   8001a1 <sys_page_map>
  8005fb:	89 c7                	mov    %eax,%edi
  8005fd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800600:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800602:	85 ff                	test   %edi,%edi
  800604:	79 1d                	jns    800623 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	6a 00                	push   $0x0
  80060c:	e8 d2 fb ff ff       	call   8001e3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800611:	83 c4 08             	add    $0x8,%esp
  800614:	ff 75 d4             	pushl  -0x2c(%ebp)
  800617:	6a 00                	push   $0x0
  800619:	e8 c5 fb ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  80061e:	83 c4 10             	add    $0x10,%esp
  800621:	89 f8                	mov    %edi,%eax
}
  800623:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800626:	5b                   	pop    %ebx
  800627:	5e                   	pop    %esi
  800628:	5f                   	pop    %edi
  800629:	5d                   	pop    %ebp
  80062a:	c3                   	ret    

0080062b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80062b:	55                   	push   %ebp
  80062c:	89 e5                	mov    %esp,%ebp
  80062e:	53                   	push   %ebx
  80062f:	83 ec 14             	sub    $0x14,%esp
  800632:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800635:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800638:	50                   	push   %eax
  800639:	53                   	push   %ebx
  80063a:	e8 86 fd ff ff       	call   8003c5 <fd_lookup>
  80063f:	83 c4 08             	add    $0x8,%esp
  800642:	89 c2                	mov    %eax,%edx
  800644:	85 c0                	test   %eax,%eax
  800646:	78 6d                	js     8006b5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80064e:	50                   	push   %eax
  80064f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800652:	ff 30                	pushl  (%eax)
  800654:	e8 c2 fd ff ff       	call   80041b <dev_lookup>
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	85 c0                	test   %eax,%eax
  80065e:	78 4c                	js     8006ac <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800660:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800663:	8b 42 08             	mov    0x8(%edx),%eax
  800666:	83 e0 03             	and    $0x3,%eax
  800669:	83 f8 01             	cmp    $0x1,%eax
  80066c:	75 21                	jne    80068f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80066e:	a1 04 40 80 00       	mov    0x804004,%eax
  800673:	8b 40 48             	mov    0x48(%eax),%eax
  800676:	83 ec 04             	sub    $0x4,%esp
  800679:	53                   	push   %ebx
  80067a:	50                   	push   %eax
  80067b:	68 99 1e 80 00       	push   $0x801e99
  800680:	e8 8d 0a 00 00       	call   801112 <cprintf>
		return -E_INVAL;
  800685:	83 c4 10             	add    $0x10,%esp
  800688:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80068d:	eb 26                	jmp    8006b5 <read+0x8a>
	}
	if (!dev->dev_read)
  80068f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800692:	8b 40 08             	mov    0x8(%eax),%eax
  800695:	85 c0                	test   %eax,%eax
  800697:	74 17                	je     8006b0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800699:	83 ec 04             	sub    $0x4,%esp
  80069c:	ff 75 10             	pushl  0x10(%ebp)
  80069f:	ff 75 0c             	pushl  0xc(%ebp)
  8006a2:	52                   	push   %edx
  8006a3:	ff d0                	call   *%eax
  8006a5:	89 c2                	mov    %eax,%edx
  8006a7:	83 c4 10             	add    $0x10,%esp
  8006aa:	eb 09                	jmp    8006b5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006ac:	89 c2                	mov    %eax,%edx
  8006ae:	eb 05                	jmp    8006b5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006b5:	89 d0                	mov    %edx,%eax
  8006b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006ba:	c9                   	leave  
  8006bb:	c3                   	ret    

008006bc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006bc:	55                   	push   %ebp
  8006bd:	89 e5                	mov    %esp,%ebp
  8006bf:	57                   	push   %edi
  8006c0:	56                   	push   %esi
  8006c1:	53                   	push   %ebx
  8006c2:	83 ec 0c             	sub    $0xc,%esp
  8006c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d0:	eb 21                	jmp    8006f3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d2:	83 ec 04             	sub    $0x4,%esp
  8006d5:	89 f0                	mov    %esi,%eax
  8006d7:	29 d8                	sub    %ebx,%eax
  8006d9:	50                   	push   %eax
  8006da:	89 d8                	mov    %ebx,%eax
  8006dc:	03 45 0c             	add    0xc(%ebp),%eax
  8006df:	50                   	push   %eax
  8006e0:	57                   	push   %edi
  8006e1:	e8 45 ff ff ff       	call   80062b <read>
		if (m < 0)
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	78 10                	js     8006fd <readn+0x41>
			return m;
		if (m == 0)
  8006ed:	85 c0                	test   %eax,%eax
  8006ef:	74 0a                	je     8006fb <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f1:	01 c3                	add    %eax,%ebx
  8006f3:	39 f3                	cmp    %esi,%ebx
  8006f5:	72 db                	jb     8006d2 <readn+0x16>
  8006f7:	89 d8                	mov    %ebx,%eax
  8006f9:	eb 02                	jmp    8006fd <readn+0x41>
  8006fb:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800700:	5b                   	pop    %ebx
  800701:	5e                   	pop    %esi
  800702:	5f                   	pop    %edi
  800703:	5d                   	pop    %ebp
  800704:	c3                   	ret    

00800705 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	53                   	push   %ebx
  800709:	83 ec 14             	sub    $0x14,%esp
  80070c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80070f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800712:	50                   	push   %eax
  800713:	53                   	push   %ebx
  800714:	e8 ac fc ff ff       	call   8003c5 <fd_lookup>
  800719:	83 c4 08             	add    $0x8,%esp
  80071c:	89 c2                	mov    %eax,%edx
  80071e:	85 c0                	test   %eax,%eax
  800720:	78 68                	js     80078a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800722:	83 ec 08             	sub    $0x8,%esp
  800725:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800728:	50                   	push   %eax
  800729:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072c:	ff 30                	pushl  (%eax)
  80072e:	e8 e8 fc ff ff       	call   80041b <dev_lookup>
  800733:	83 c4 10             	add    $0x10,%esp
  800736:	85 c0                	test   %eax,%eax
  800738:	78 47                	js     800781 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800741:	75 21                	jne    800764 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800743:	a1 04 40 80 00       	mov    0x804004,%eax
  800748:	8b 40 48             	mov    0x48(%eax),%eax
  80074b:	83 ec 04             	sub    $0x4,%esp
  80074e:	53                   	push   %ebx
  80074f:	50                   	push   %eax
  800750:	68 b5 1e 80 00       	push   $0x801eb5
  800755:	e8 b8 09 00 00       	call   801112 <cprintf>
		return -E_INVAL;
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800762:	eb 26                	jmp    80078a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800764:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800767:	8b 52 0c             	mov    0xc(%edx),%edx
  80076a:	85 d2                	test   %edx,%edx
  80076c:	74 17                	je     800785 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80076e:	83 ec 04             	sub    $0x4,%esp
  800771:	ff 75 10             	pushl  0x10(%ebp)
  800774:	ff 75 0c             	pushl  0xc(%ebp)
  800777:	50                   	push   %eax
  800778:	ff d2                	call   *%edx
  80077a:	89 c2                	mov    %eax,%edx
  80077c:	83 c4 10             	add    $0x10,%esp
  80077f:	eb 09                	jmp    80078a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800781:	89 c2                	mov    %eax,%edx
  800783:	eb 05                	jmp    80078a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800785:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80078a:	89 d0                	mov    %edx,%eax
  80078c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078f:	c9                   	leave  
  800790:	c3                   	ret    

00800791 <seek>:

int
seek(int fdnum, off_t offset)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800797:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80079a:	50                   	push   %eax
  80079b:	ff 75 08             	pushl  0x8(%ebp)
  80079e:	e8 22 fc ff ff       	call   8003c5 <fd_lookup>
  8007a3:	83 c4 08             	add    $0x8,%esp
  8007a6:	85 c0                	test   %eax,%eax
  8007a8:	78 0e                	js     8007b8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b8:	c9                   	leave  
  8007b9:	c3                   	ret    

008007ba <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	53                   	push   %ebx
  8007be:	83 ec 14             	sub    $0x14,%esp
  8007c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c7:	50                   	push   %eax
  8007c8:	53                   	push   %ebx
  8007c9:	e8 f7 fb ff ff       	call   8003c5 <fd_lookup>
  8007ce:	83 c4 08             	add    $0x8,%esp
  8007d1:	89 c2                	mov    %eax,%edx
  8007d3:	85 c0                	test   %eax,%eax
  8007d5:	78 65                	js     80083c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d7:	83 ec 08             	sub    $0x8,%esp
  8007da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007dd:	50                   	push   %eax
  8007de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e1:	ff 30                	pushl  (%eax)
  8007e3:	e8 33 fc ff ff       	call   80041b <dev_lookup>
  8007e8:	83 c4 10             	add    $0x10,%esp
  8007eb:	85 c0                	test   %eax,%eax
  8007ed:	78 44                	js     800833 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f6:	75 21                	jne    800819 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f8:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007fd:	8b 40 48             	mov    0x48(%eax),%eax
  800800:	83 ec 04             	sub    $0x4,%esp
  800803:	53                   	push   %ebx
  800804:	50                   	push   %eax
  800805:	68 78 1e 80 00       	push   $0x801e78
  80080a:	e8 03 09 00 00       	call   801112 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80080f:	83 c4 10             	add    $0x10,%esp
  800812:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800817:	eb 23                	jmp    80083c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800819:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80081c:	8b 52 18             	mov    0x18(%edx),%edx
  80081f:	85 d2                	test   %edx,%edx
  800821:	74 14                	je     800837 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800823:	83 ec 08             	sub    $0x8,%esp
  800826:	ff 75 0c             	pushl  0xc(%ebp)
  800829:	50                   	push   %eax
  80082a:	ff d2                	call   *%edx
  80082c:	89 c2                	mov    %eax,%edx
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	eb 09                	jmp    80083c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800833:	89 c2                	mov    %eax,%edx
  800835:	eb 05                	jmp    80083c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800837:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80083c:	89 d0                	mov    %edx,%eax
  80083e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800841:	c9                   	leave  
  800842:	c3                   	ret    

00800843 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	53                   	push   %ebx
  800847:	83 ec 14             	sub    $0x14,%esp
  80084a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80084d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800850:	50                   	push   %eax
  800851:	ff 75 08             	pushl  0x8(%ebp)
  800854:	e8 6c fb ff ff       	call   8003c5 <fd_lookup>
  800859:	83 c4 08             	add    $0x8,%esp
  80085c:	89 c2                	mov    %eax,%edx
  80085e:	85 c0                	test   %eax,%eax
  800860:	78 58                	js     8008ba <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800862:	83 ec 08             	sub    $0x8,%esp
  800865:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800868:	50                   	push   %eax
  800869:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80086c:	ff 30                	pushl  (%eax)
  80086e:	e8 a8 fb ff ff       	call   80041b <dev_lookup>
  800873:	83 c4 10             	add    $0x10,%esp
  800876:	85 c0                	test   %eax,%eax
  800878:	78 37                	js     8008b1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80087a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800881:	74 32                	je     8008b5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800883:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800886:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80088d:	00 00 00 
	stat->st_isdir = 0;
  800890:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800897:	00 00 00 
	stat->st_dev = dev;
  80089a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a0:	83 ec 08             	sub    $0x8,%esp
  8008a3:	53                   	push   %ebx
  8008a4:	ff 75 f0             	pushl  -0x10(%ebp)
  8008a7:	ff 50 14             	call   *0x14(%eax)
  8008aa:	89 c2                	mov    %eax,%edx
  8008ac:	83 c4 10             	add    $0x10,%esp
  8008af:	eb 09                	jmp    8008ba <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b1:	89 c2                	mov    %eax,%edx
  8008b3:	eb 05                	jmp    8008ba <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008ba:	89 d0                	mov    %edx,%eax
  8008bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bf:	c9                   	leave  
  8008c0:	c3                   	ret    

008008c1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	56                   	push   %esi
  8008c5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008c6:	83 ec 08             	sub    $0x8,%esp
  8008c9:	6a 00                	push   $0x0
  8008cb:	ff 75 08             	pushl  0x8(%ebp)
  8008ce:	e8 e3 01 00 00       	call   800ab6 <open>
  8008d3:	89 c3                	mov    %eax,%ebx
  8008d5:	83 c4 10             	add    $0x10,%esp
  8008d8:	85 c0                	test   %eax,%eax
  8008da:	78 1b                	js     8008f7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008dc:	83 ec 08             	sub    $0x8,%esp
  8008df:	ff 75 0c             	pushl  0xc(%ebp)
  8008e2:	50                   	push   %eax
  8008e3:	e8 5b ff ff ff       	call   800843 <fstat>
  8008e8:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ea:	89 1c 24             	mov    %ebx,(%esp)
  8008ed:	e8 fd fb ff ff       	call   8004ef <close>
	return r;
  8008f2:	83 c4 10             	add    $0x10,%esp
  8008f5:	89 f0                	mov    %esi,%eax
}
  8008f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008fa:	5b                   	pop    %ebx
  8008fb:	5e                   	pop    %esi
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	56                   	push   %esi
  800902:	53                   	push   %ebx
  800903:	89 c6                	mov    %eax,%esi
  800905:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800907:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80090e:	75 12                	jne    800922 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800910:	83 ec 0c             	sub    $0xc,%esp
  800913:	6a 01                	push   $0x1
  800915:	e8 00 12 00 00       	call   801b1a <ipc_find_env>
  80091a:	a3 00 40 80 00       	mov    %eax,0x804000
  80091f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800922:	6a 07                	push   $0x7
  800924:	68 00 50 80 00       	push   $0x805000
  800929:	56                   	push   %esi
  80092a:	ff 35 00 40 80 00    	pushl  0x804000
  800930:	e8 91 11 00 00       	call   801ac6 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800935:	83 c4 0c             	add    $0xc,%esp
  800938:	6a 00                	push   $0x0
  80093a:	53                   	push   %ebx
  80093b:	6a 00                	push   $0x0
  80093d:	e8 1b 11 00 00       	call   801a5d <ipc_recv>
}
  800942:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800945:	5b                   	pop    %ebx
  800946:	5e                   	pop    %esi
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	8b 40 0c             	mov    0xc(%eax),%eax
  800955:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80095a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800962:	ba 00 00 00 00       	mov    $0x0,%edx
  800967:	b8 02 00 00 00       	mov    $0x2,%eax
  80096c:	e8 8d ff ff ff       	call   8008fe <fsipc>
}
  800971:	c9                   	leave  
  800972:	c3                   	ret    

00800973 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 40 0c             	mov    0xc(%eax),%eax
  80097f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800984:	ba 00 00 00 00       	mov    $0x0,%edx
  800989:	b8 06 00 00 00       	mov    $0x6,%eax
  80098e:	e8 6b ff ff ff       	call   8008fe <fsipc>
}
  800993:	c9                   	leave  
  800994:	c3                   	ret    

00800995 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	53                   	push   %ebx
  800999:	83 ec 04             	sub    $0x4,%esp
  80099c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8009af:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b4:	e8 45 ff ff ff       	call   8008fe <fsipc>
  8009b9:	85 c0                	test   %eax,%eax
  8009bb:	78 2c                	js     8009e9 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009bd:	83 ec 08             	sub    $0x8,%esp
  8009c0:	68 00 50 80 00       	push   $0x805000
  8009c5:	53                   	push   %ebx
  8009c6:	e8 4b 0d 00 00       	call   801716 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009cb:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009d6:	a1 84 50 80 00       	mov    0x805084,%eax
  8009db:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e1:	83 c4 10             	add    $0x10,%esp
  8009e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ec:	c9                   	leave  
  8009ed:	c3                   	ret    

008009ee <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	83 ec 0c             	sub    $0xc,%esp
  8009f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f7:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009fc:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a01:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a04:	8b 55 08             	mov    0x8(%ebp),%edx
  800a07:	8b 52 0c             	mov    0xc(%edx),%edx
  800a0a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a10:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a15:	50                   	push   %eax
  800a16:	ff 75 0c             	pushl  0xc(%ebp)
  800a19:	68 08 50 80 00       	push   $0x805008
  800a1e:	e8 85 0e 00 00       	call   8018a8 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a23:	ba 00 00 00 00       	mov    $0x0,%edx
  800a28:	b8 04 00 00 00       	mov    $0x4,%eax
  800a2d:	e8 cc fe ff ff       	call   8008fe <fsipc>
	//panic("devfile_write not implemented");
}
  800a32:	c9                   	leave  
  800a33:	c3                   	ret    

00800a34 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a34:	55                   	push   %ebp
  800a35:	89 e5                	mov    %esp,%ebp
  800a37:	56                   	push   %esi
  800a38:	53                   	push   %ebx
  800a39:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a42:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a47:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a52:	b8 03 00 00 00       	mov    $0x3,%eax
  800a57:	e8 a2 fe ff ff       	call   8008fe <fsipc>
  800a5c:	89 c3                	mov    %eax,%ebx
  800a5e:	85 c0                	test   %eax,%eax
  800a60:	78 4b                	js     800aad <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a62:	39 c6                	cmp    %eax,%esi
  800a64:	73 16                	jae    800a7c <devfile_read+0x48>
  800a66:	68 e4 1e 80 00       	push   $0x801ee4
  800a6b:	68 eb 1e 80 00       	push   $0x801eeb
  800a70:	6a 7c                	push   $0x7c
  800a72:	68 00 1f 80 00       	push   $0x801f00
  800a77:	e8 bd 05 00 00       	call   801039 <_panic>
	assert(r <= PGSIZE);
  800a7c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a81:	7e 16                	jle    800a99 <devfile_read+0x65>
  800a83:	68 0b 1f 80 00       	push   $0x801f0b
  800a88:	68 eb 1e 80 00       	push   $0x801eeb
  800a8d:	6a 7d                	push   $0x7d
  800a8f:	68 00 1f 80 00       	push   $0x801f00
  800a94:	e8 a0 05 00 00       	call   801039 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a99:	83 ec 04             	sub    $0x4,%esp
  800a9c:	50                   	push   %eax
  800a9d:	68 00 50 80 00       	push   $0x805000
  800aa2:	ff 75 0c             	pushl  0xc(%ebp)
  800aa5:	e8 fe 0d 00 00       	call   8018a8 <memmove>
	return r;
  800aaa:	83 c4 10             	add    $0x10,%esp
}
  800aad:	89 d8                	mov    %ebx,%eax
  800aaf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ab2:	5b                   	pop    %ebx
  800ab3:	5e                   	pop    %esi
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	53                   	push   %ebx
  800aba:	83 ec 20             	sub    $0x20,%esp
  800abd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ac0:	53                   	push   %ebx
  800ac1:	e8 17 0c 00 00       	call   8016dd <strlen>
  800ac6:	83 c4 10             	add    $0x10,%esp
  800ac9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ace:	7f 67                	jg     800b37 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ad0:	83 ec 0c             	sub    $0xc,%esp
  800ad3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ad6:	50                   	push   %eax
  800ad7:	e8 9a f8 ff ff       	call   800376 <fd_alloc>
  800adc:	83 c4 10             	add    $0x10,%esp
		return r;
  800adf:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ae1:	85 c0                	test   %eax,%eax
  800ae3:	78 57                	js     800b3c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ae5:	83 ec 08             	sub    $0x8,%esp
  800ae8:	53                   	push   %ebx
  800ae9:	68 00 50 80 00       	push   $0x805000
  800aee:	e8 23 0c 00 00       	call   801716 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800af3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800afb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800afe:	b8 01 00 00 00       	mov    $0x1,%eax
  800b03:	e8 f6 fd ff ff       	call   8008fe <fsipc>
  800b08:	89 c3                	mov    %eax,%ebx
  800b0a:	83 c4 10             	add    $0x10,%esp
  800b0d:	85 c0                	test   %eax,%eax
  800b0f:	79 14                	jns    800b25 <open+0x6f>
		fd_close(fd, 0);
  800b11:	83 ec 08             	sub    $0x8,%esp
  800b14:	6a 00                	push   $0x0
  800b16:	ff 75 f4             	pushl  -0xc(%ebp)
  800b19:	e8 50 f9 ff ff       	call   80046e <fd_close>
		return r;
  800b1e:	83 c4 10             	add    $0x10,%esp
  800b21:	89 da                	mov    %ebx,%edx
  800b23:	eb 17                	jmp    800b3c <open+0x86>
	}

	return fd2num(fd);
  800b25:	83 ec 0c             	sub    $0xc,%esp
  800b28:	ff 75 f4             	pushl  -0xc(%ebp)
  800b2b:	e8 1f f8 ff ff       	call   80034f <fd2num>
  800b30:	89 c2                	mov    %eax,%edx
  800b32:	83 c4 10             	add    $0x10,%esp
  800b35:	eb 05                	jmp    800b3c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b37:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b3c:	89 d0                	mov    %edx,%eax
  800b3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b41:	c9                   	leave  
  800b42:	c3                   	ret    

00800b43 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b49:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4e:	b8 08 00 00 00       	mov    $0x8,%eax
  800b53:	e8 a6 fd ff ff       	call   8008fe <fsipc>
}
  800b58:	c9                   	leave  
  800b59:	c3                   	ret    

00800b5a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	56                   	push   %esi
  800b5e:	53                   	push   %ebx
  800b5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b62:	83 ec 0c             	sub    $0xc,%esp
  800b65:	ff 75 08             	pushl  0x8(%ebp)
  800b68:	e8 f2 f7 ff ff       	call   80035f <fd2data>
  800b6d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b6f:	83 c4 08             	add    $0x8,%esp
  800b72:	68 17 1f 80 00       	push   $0x801f17
  800b77:	53                   	push   %ebx
  800b78:	e8 99 0b 00 00       	call   801716 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b7d:	8b 46 04             	mov    0x4(%esi),%eax
  800b80:	2b 06                	sub    (%esi),%eax
  800b82:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b88:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b8f:	00 00 00 
	stat->st_dev = &devpipe;
  800b92:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b99:	30 80 00 
	return 0;
}
  800b9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ba4:	5b                   	pop    %ebx
  800ba5:	5e                   	pop    %esi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	53                   	push   %ebx
  800bac:	83 ec 0c             	sub    $0xc,%esp
  800baf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bb2:	53                   	push   %ebx
  800bb3:	6a 00                	push   $0x0
  800bb5:	e8 29 f6 ff ff       	call   8001e3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bba:	89 1c 24             	mov    %ebx,(%esp)
  800bbd:	e8 9d f7 ff ff       	call   80035f <fd2data>
  800bc2:	83 c4 08             	add    $0x8,%esp
  800bc5:	50                   	push   %eax
  800bc6:	6a 00                	push   $0x0
  800bc8:	e8 16 f6 ff ff       	call   8001e3 <sys_page_unmap>
}
  800bcd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bd0:	c9                   	leave  
  800bd1:	c3                   	ret    

00800bd2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
  800bd8:	83 ec 1c             	sub    $0x1c,%esp
  800bdb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bde:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800be0:	a1 04 40 80 00       	mov    0x804004,%eax
  800be5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800be8:	83 ec 0c             	sub    $0xc,%esp
  800beb:	ff 75 e0             	pushl  -0x20(%ebp)
  800bee:	e8 60 0f 00 00       	call   801b53 <pageref>
  800bf3:	89 c3                	mov    %eax,%ebx
  800bf5:	89 3c 24             	mov    %edi,(%esp)
  800bf8:	e8 56 0f 00 00       	call   801b53 <pageref>
  800bfd:	83 c4 10             	add    $0x10,%esp
  800c00:	39 c3                	cmp    %eax,%ebx
  800c02:	0f 94 c1             	sete   %cl
  800c05:	0f b6 c9             	movzbl %cl,%ecx
  800c08:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c0b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c11:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c14:	39 ce                	cmp    %ecx,%esi
  800c16:	74 1b                	je     800c33 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c18:	39 c3                	cmp    %eax,%ebx
  800c1a:	75 c4                	jne    800be0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c1c:	8b 42 58             	mov    0x58(%edx),%eax
  800c1f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c22:	50                   	push   %eax
  800c23:	56                   	push   %esi
  800c24:	68 1e 1f 80 00       	push   $0x801f1e
  800c29:	e8 e4 04 00 00       	call   801112 <cprintf>
  800c2e:	83 c4 10             	add    $0x10,%esp
  800c31:	eb ad                	jmp    800be0 <_pipeisclosed+0xe>
	}
}
  800c33:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 28             	sub    $0x28,%esp
  800c47:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c4a:	56                   	push   %esi
  800c4b:	e8 0f f7 ff ff       	call   80035f <fd2data>
  800c50:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c52:	83 c4 10             	add    $0x10,%esp
  800c55:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5a:	eb 4b                	jmp    800ca7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c5c:	89 da                	mov    %ebx,%edx
  800c5e:	89 f0                	mov    %esi,%eax
  800c60:	e8 6d ff ff ff       	call   800bd2 <_pipeisclosed>
  800c65:	85 c0                	test   %eax,%eax
  800c67:	75 48                	jne    800cb1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c69:	e8 d1 f4 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c6e:	8b 43 04             	mov    0x4(%ebx),%eax
  800c71:	8b 0b                	mov    (%ebx),%ecx
  800c73:	8d 51 20             	lea    0x20(%ecx),%edx
  800c76:	39 d0                	cmp    %edx,%eax
  800c78:	73 e2                	jae    800c5c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c81:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c84:	89 c2                	mov    %eax,%edx
  800c86:	c1 fa 1f             	sar    $0x1f,%edx
  800c89:	89 d1                	mov    %edx,%ecx
  800c8b:	c1 e9 1b             	shr    $0x1b,%ecx
  800c8e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c91:	83 e2 1f             	and    $0x1f,%edx
  800c94:	29 ca                	sub    %ecx,%edx
  800c96:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c9a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c9e:	83 c0 01             	add    $0x1,%eax
  800ca1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ca4:	83 c7 01             	add    $0x1,%edi
  800ca7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800caa:	75 c2                	jne    800c6e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cac:	8b 45 10             	mov    0x10(%ebp),%eax
  800caf:	eb 05                	jmp    800cb6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cb1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    

00800cbe <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	57                   	push   %edi
  800cc2:	56                   	push   %esi
  800cc3:	53                   	push   %ebx
  800cc4:	83 ec 18             	sub    $0x18,%esp
  800cc7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cca:	57                   	push   %edi
  800ccb:	e8 8f f6 ff ff       	call   80035f <fd2data>
  800cd0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cd2:	83 c4 10             	add    $0x10,%esp
  800cd5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cda:	eb 3d                	jmp    800d19 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cdc:	85 db                	test   %ebx,%ebx
  800cde:	74 04                	je     800ce4 <devpipe_read+0x26>
				return i;
  800ce0:	89 d8                	mov    %ebx,%eax
  800ce2:	eb 44                	jmp    800d28 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800ce4:	89 f2                	mov    %esi,%edx
  800ce6:	89 f8                	mov    %edi,%eax
  800ce8:	e8 e5 fe ff ff       	call   800bd2 <_pipeisclosed>
  800ced:	85 c0                	test   %eax,%eax
  800cef:	75 32                	jne    800d23 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cf1:	e8 49 f4 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cf6:	8b 06                	mov    (%esi),%eax
  800cf8:	3b 46 04             	cmp    0x4(%esi),%eax
  800cfb:	74 df                	je     800cdc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cfd:	99                   	cltd   
  800cfe:	c1 ea 1b             	shr    $0x1b,%edx
  800d01:	01 d0                	add    %edx,%eax
  800d03:	83 e0 1f             	and    $0x1f,%eax
  800d06:	29 d0                	sub    %edx,%eax
  800d08:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d10:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d13:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d16:	83 c3 01             	add    $0x1,%ebx
  800d19:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d1c:	75 d8                	jne    800cf6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d1e:	8b 45 10             	mov    0x10(%ebp),%eax
  800d21:	eb 05                	jmp    800d28 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d23:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2b:	5b                   	pop    %ebx
  800d2c:	5e                   	pop    %esi
  800d2d:	5f                   	pop    %edi
  800d2e:	5d                   	pop    %ebp
  800d2f:	c3                   	ret    

00800d30 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d30:	55                   	push   %ebp
  800d31:	89 e5                	mov    %esp,%ebp
  800d33:	56                   	push   %esi
  800d34:	53                   	push   %ebx
  800d35:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d3b:	50                   	push   %eax
  800d3c:	e8 35 f6 ff ff       	call   800376 <fd_alloc>
  800d41:	83 c4 10             	add    $0x10,%esp
  800d44:	89 c2                	mov    %eax,%edx
  800d46:	85 c0                	test   %eax,%eax
  800d48:	0f 88 2c 01 00 00    	js     800e7a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d4e:	83 ec 04             	sub    $0x4,%esp
  800d51:	68 07 04 00 00       	push   $0x407
  800d56:	ff 75 f4             	pushl  -0xc(%ebp)
  800d59:	6a 00                	push   $0x0
  800d5b:	e8 fe f3 ff ff       	call   80015e <sys_page_alloc>
  800d60:	83 c4 10             	add    $0x10,%esp
  800d63:	89 c2                	mov    %eax,%edx
  800d65:	85 c0                	test   %eax,%eax
  800d67:	0f 88 0d 01 00 00    	js     800e7a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d6d:	83 ec 0c             	sub    $0xc,%esp
  800d70:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d73:	50                   	push   %eax
  800d74:	e8 fd f5 ff ff       	call   800376 <fd_alloc>
  800d79:	89 c3                	mov    %eax,%ebx
  800d7b:	83 c4 10             	add    $0x10,%esp
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	0f 88 e2 00 00 00    	js     800e68 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d86:	83 ec 04             	sub    $0x4,%esp
  800d89:	68 07 04 00 00       	push   $0x407
  800d8e:	ff 75 f0             	pushl  -0x10(%ebp)
  800d91:	6a 00                	push   $0x0
  800d93:	e8 c6 f3 ff ff       	call   80015e <sys_page_alloc>
  800d98:	89 c3                	mov    %eax,%ebx
  800d9a:	83 c4 10             	add    $0x10,%esp
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	0f 88 c3 00 00 00    	js     800e68 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800da5:	83 ec 0c             	sub    $0xc,%esp
  800da8:	ff 75 f4             	pushl  -0xc(%ebp)
  800dab:	e8 af f5 ff ff       	call   80035f <fd2data>
  800db0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db2:	83 c4 0c             	add    $0xc,%esp
  800db5:	68 07 04 00 00       	push   $0x407
  800dba:	50                   	push   %eax
  800dbb:	6a 00                	push   $0x0
  800dbd:	e8 9c f3 ff ff       	call   80015e <sys_page_alloc>
  800dc2:	89 c3                	mov    %eax,%ebx
  800dc4:	83 c4 10             	add    $0x10,%esp
  800dc7:	85 c0                	test   %eax,%eax
  800dc9:	0f 88 89 00 00 00    	js     800e58 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dcf:	83 ec 0c             	sub    $0xc,%esp
  800dd2:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd5:	e8 85 f5 ff ff       	call   80035f <fd2data>
  800dda:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800de1:	50                   	push   %eax
  800de2:	6a 00                	push   $0x0
  800de4:	56                   	push   %esi
  800de5:	6a 00                	push   $0x0
  800de7:	e8 b5 f3 ff ff       	call   8001a1 <sys_page_map>
  800dec:	89 c3                	mov    %eax,%ebx
  800dee:	83 c4 20             	add    $0x20,%esp
  800df1:	85 c0                	test   %eax,%eax
  800df3:	78 55                	js     800e4a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800df5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800dfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dfe:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e03:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e0a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e10:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e13:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e18:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e1f:	83 ec 0c             	sub    $0xc,%esp
  800e22:	ff 75 f4             	pushl  -0xc(%ebp)
  800e25:	e8 25 f5 ff ff       	call   80034f <fd2num>
  800e2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e2f:	83 c4 04             	add    $0x4,%esp
  800e32:	ff 75 f0             	pushl  -0x10(%ebp)
  800e35:	e8 15 f5 ff ff       	call   80034f <fd2num>
  800e3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e40:	83 c4 10             	add    $0x10,%esp
  800e43:	ba 00 00 00 00       	mov    $0x0,%edx
  800e48:	eb 30                	jmp    800e7a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e4a:	83 ec 08             	sub    $0x8,%esp
  800e4d:	56                   	push   %esi
  800e4e:	6a 00                	push   $0x0
  800e50:	e8 8e f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e55:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e58:	83 ec 08             	sub    $0x8,%esp
  800e5b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e5e:	6a 00                	push   $0x0
  800e60:	e8 7e f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e65:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e68:	83 ec 08             	sub    $0x8,%esp
  800e6b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e6e:	6a 00                	push   $0x0
  800e70:	e8 6e f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e75:	83 c4 10             	add    $0x10,%esp
  800e78:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e7a:	89 d0                	mov    %edx,%eax
  800e7c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e7f:	5b                   	pop    %ebx
  800e80:	5e                   	pop    %esi
  800e81:	5d                   	pop    %ebp
  800e82:	c3                   	ret    

00800e83 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e8c:	50                   	push   %eax
  800e8d:	ff 75 08             	pushl  0x8(%ebp)
  800e90:	e8 30 f5 ff ff       	call   8003c5 <fd_lookup>
  800e95:	83 c4 10             	add    $0x10,%esp
  800e98:	85 c0                	test   %eax,%eax
  800e9a:	78 18                	js     800eb4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e9c:	83 ec 0c             	sub    $0xc,%esp
  800e9f:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea2:	e8 b8 f4 ff ff       	call   80035f <fd2data>
	return _pipeisclosed(fd, p);
  800ea7:	89 c2                	mov    %eax,%edx
  800ea9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eac:	e8 21 fd ff ff       	call   800bd2 <_pipeisclosed>
  800eb1:	83 c4 10             	add    $0x10,%esp
}
  800eb4:	c9                   	leave  
  800eb5:	c3                   	ret    

00800eb6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eb9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebe:	5d                   	pop    %ebp
  800ebf:	c3                   	ret    

00800ec0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
  800ec3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ec6:	68 36 1f 80 00       	push   $0x801f36
  800ecb:	ff 75 0c             	pushl  0xc(%ebp)
  800ece:	e8 43 08 00 00       	call   801716 <strcpy>
	return 0;
}
  800ed3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed8:	c9                   	leave  
  800ed9:	c3                   	ret    

00800eda <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	57                   	push   %edi
  800ede:	56                   	push   %esi
  800edf:	53                   	push   %ebx
  800ee0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ee6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800eeb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef1:	eb 2d                	jmp    800f20 <devcons_write+0x46>
		m = n - tot;
  800ef3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ef8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800efb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f00:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f03:	83 ec 04             	sub    $0x4,%esp
  800f06:	53                   	push   %ebx
  800f07:	03 45 0c             	add    0xc(%ebp),%eax
  800f0a:	50                   	push   %eax
  800f0b:	57                   	push   %edi
  800f0c:	e8 97 09 00 00       	call   8018a8 <memmove>
		sys_cputs(buf, m);
  800f11:	83 c4 08             	add    $0x8,%esp
  800f14:	53                   	push   %ebx
  800f15:	57                   	push   %edi
  800f16:	e8 87 f1 ff ff       	call   8000a2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f1b:	01 de                	add    %ebx,%esi
  800f1d:	83 c4 10             	add    $0x10,%esp
  800f20:	89 f0                	mov    %esi,%eax
  800f22:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f25:	72 cc                	jb     800ef3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f27:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2a:	5b                   	pop    %ebx
  800f2b:	5e                   	pop    %esi
  800f2c:	5f                   	pop    %edi
  800f2d:	5d                   	pop    %ebp
  800f2e:	c3                   	ret    

00800f2f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	83 ec 08             	sub    $0x8,%esp
  800f35:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f3a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f3e:	74 2a                	je     800f6a <devcons_read+0x3b>
  800f40:	eb 05                	jmp    800f47 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f42:	e8 f8 f1 ff ff       	call   80013f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f47:	e8 74 f1 ff ff       	call   8000c0 <sys_cgetc>
  800f4c:	85 c0                	test   %eax,%eax
  800f4e:	74 f2                	je     800f42 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f50:	85 c0                	test   %eax,%eax
  800f52:	78 16                	js     800f6a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f54:	83 f8 04             	cmp    $0x4,%eax
  800f57:	74 0c                	je     800f65 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f5c:	88 02                	mov    %al,(%edx)
	return 1;
  800f5e:	b8 01 00 00 00       	mov    $0x1,%eax
  800f63:	eb 05                	jmp    800f6a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f65:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f6a:	c9                   	leave  
  800f6b:	c3                   	ret    

00800f6c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f72:	8b 45 08             	mov    0x8(%ebp),%eax
  800f75:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f78:	6a 01                	push   $0x1
  800f7a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f7d:	50                   	push   %eax
  800f7e:	e8 1f f1 ff ff       	call   8000a2 <sys_cputs>
}
  800f83:	83 c4 10             	add    $0x10,%esp
  800f86:	c9                   	leave  
  800f87:	c3                   	ret    

00800f88 <getchar>:

int
getchar(void)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f8e:	6a 01                	push   $0x1
  800f90:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f93:	50                   	push   %eax
  800f94:	6a 00                	push   $0x0
  800f96:	e8 90 f6 ff ff       	call   80062b <read>
	if (r < 0)
  800f9b:	83 c4 10             	add    $0x10,%esp
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	78 0f                	js     800fb1 <getchar+0x29>
		return r;
	if (r < 1)
  800fa2:	85 c0                	test   %eax,%eax
  800fa4:	7e 06                	jle    800fac <getchar+0x24>
		return -E_EOF;
	return c;
  800fa6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800faa:	eb 05                	jmp    800fb1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fac:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fb1:	c9                   	leave  
  800fb2:	c3                   	ret    

00800fb3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fbc:	50                   	push   %eax
  800fbd:	ff 75 08             	pushl  0x8(%ebp)
  800fc0:	e8 00 f4 ff ff       	call   8003c5 <fd_lookup>
  800fc5:	83 c4 10             	add    $0x10,%esp
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	78 11                	js     800fdd <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fcf:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fd5:	39 10                	cmp    %edx,(%eax)
  800fd7:	0f 94 c0             	sete   %al
  800fda:	0f b6 c0             	movzbl %al,%eax
}
  800fdd:	c9                   	leave  
  800fde:	c3                   	ret    

00800fdf <opencons>:

int
opencons(void)
{
  800fdf:	55                   	push   %ebp
  800fe0:	89 e5                	mov    %esp,%ebp
  800fe2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fe5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe8:	50                   	push   %eax
  800fe9:	e8 88 f3 ff ff       	call   800376 <fd_alloc>
  800fee:	83 c4 10             	add    $0x10,%esp
		return r;
  800ff1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800ff3:	85 c0                	test   %eax,%eax
  800ff5:	78 3e                	js     801035 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800ff7:	83 ec 04             	sub    $0x4,%esp
  800ffa:	68 07 04 00 00       	push   $0x407
  800fff:	ff 75 f4             	pushl  -0xc(%ebp)
  801002:	6a 00                	push   $0x0
  801004:	e8 55 f1 ff ff       	call   80015e <sys_page_alloc>
  801009:	83 c4 10             	add    $0x10,%esp
		return r;
  80100c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80100e:	85 c0                	test   %eax,%eax
  801010:	78 23                	js     801035 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801012:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801018:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80101d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801020:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801027:	83 ec 0c             	sub    $0xc,%esp
  80102a:	50                   	push   %eax
  80102b:	e8 1f f3 ff ff       	call   80034f <fd2num>
  801030:	89 c2                	mov    %eax,%edx
  801032:	83 c4 10             	add    $0x10,%esp
}
  801035:	89 d0                	mov    %edx,%eax
  801037:	c9                   	leave  
  801038:	c3                   	ret    

00801039 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	56                   	push   %esi
  80103d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80103e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801041:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801047:	e8 d4 f0 ff ff       	call   800120 <sys_getenvid>
  80104c:	83 ec 0c             	sub    $0xc,%esp
  80104f:	ff 75 0c             	pushl  0xc(%ebp)
  801052:	ff 75 08             	pushl  0x8(%ebp)
  801055:	56                   	push   %esi
  801056:	50                   	push   %eax
  801057:	68 44 1f 80 00       	push   $0x801f44
  80105c:	e8 b1 00 00 00       	call   801112 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801061:	83 c4 18             	add    $0x18,%esp
  801064:	53                   	push   %ebx
  801065:	ff 75 10             	pushl  0x10(%ebp)
  801068:	e8 54 00 00 00       	call   8010c1 <vcprintf>
	cprintf("\n");
  80106d:	c7 04 24 2f 1f 80 00 	movl   $0x801f2f,(%esp)
  801074:	e8 99 00 00 00       	call   801112 <cprintf>
  801079:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80107c:	cc                   	int3   
  80107d:	eb fd                	jmp    80107c <_panic+0x43>

0080107f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	53                   	push   %ebx
  801083:	83 ec 04             	sub    $0x4,%esp
  801086:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801089:	8b 13                	mov    (%ebx),%edx
  80108b:	8d 42 01             	lea    0x1(%edx),%eax
  80108e:	89 03                	mov    %eax,(%ebx)
  801090:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801093:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801097:	3d ff 00 00 00       	cmp    $0xff,%eax
  80109c:	75 1a                	jne    8010b8 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80109e:	83 ec 08             	sub    $0x8,%esp
  8010a1:	68 ff 00 00 00       	push   $0xff
  8010a6:	8d 43 08             	lea    0x8(%ebx),%eax
  8010a9:	50                   	push   %eax
  8010aa:	e8 f3 ef ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  8010af:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010b5:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010b8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010bf:	c9                   	leave  
  8010c0:	c3                   	ret    

008010c1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010c1:	55                   	push   %ebp
  8010c2:	89 e5                	mov    %esp,%ebp
  8010c4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010ca:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010d1:	00 00 00 
	b.cnt = 0;
  8010d4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010db:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010de:	ff 75 0c             	pushl  0xc(%ebp)
  8010e1:	ff 75 08             	pushl  0x8(%ebp)
  8010e4:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010ea:	50                   	push   %eax
  8010eb:	68 7f 10 80 00       	push   $0x80107f
  8010f0:	e8 1a 01 00 00       	call   80120f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010f5:	83 c4 08             	add    $0x8,%esp
  8010f8:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010fe:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801104:	50                   	push   %eax
  801105:	e8 98 ef ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  80110a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801110:	c9                   	leave  
  801111:	c3                   	ret    

00801112 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801112:	55                   	push   %ebp
  801113:	89 e5                	mov    %esp,%ebp
  801115:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801118:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80111b:	50                   	push   %eax
  80111c:	ff 75 08             	pushl  0x8(%ebp)
  80111f:	e8 9d ff ff ff       	call   8010c1 <vcprintf>
	va_end(ap);

	return cnt;
}
  801124:	c9                   	leave  
  801125:	c3                   	ret    

00801126 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801126:	55                   	push   %ebp
  801127:	89 e5                	mov    %esp,%ebp
  801129:	57                   	push   %edi
  80112a:	56                   	push   %esi
  80112b:	53                   	push   %ebx
  80112c:	83 ec 1c             	sub    $0x1c,%esp
  80112f:	89 c7                	mov    %eax,%edi
  801131:	89 d6                	mov    %edx,%esi
  801133:	8b 45 08             	mov    0x8(%ebp),%eax
  801136:	8b 55 0c             	mov    0xc(%ebp),%edx
  801139:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80113c:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80113f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801142:	bb 00 00 00 00       	mov    $0x0,%ebx
  801147:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80114a:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80114d:	39 d3                	cmp    %edx,%ebx
  80114f:	72 05                	jb     801156 <printnum+0x30>
  801151:	39 45 10             	cmp    %eax,0x10(%ebp)
  801154:	77 45                	ja     80119b <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801156:	83 ec 0c             	sub    $0xc,%esp
  801159:	ff 75 18             	pushl  0x18(%ebp)
  80115c:	8b 45 14             	mov    0x14(%ebp),%eax
  80115f:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801162:	53                   	push   %ebx
  801163:	ff 75 10             	pushl  0x10(%ebp)
  801166:	83 ec 08             	sub    $0x8,%esp
  801169:	ff 75 e4             	pushl  -0x1c(%ebp)
  80116c:	ff 75 e0             	pushl  -0x20(%ebp)
  80116f:	ff 75 dc             	pushl  -0x24(%ebp)
  801172:	ff 75 d8             	pushl  -0x28(%ebp)
  801175:	e8 16 0a 00 00       	call   801b90 <__udivdi3>
  80117a:	83 c4 18             	add    $0x18,%esp
  80117d:	52                   	push   %edx
  80117e:	50                   	push   %eax
  80117f:	89 f2                	mov    %esi,%edx
  801181:	89 f8                	mov    %edi,%eax
  801183:	e8 9e ff ff ff       	call   801126 <printnum>
  801188:	83 c4 20             	add    $0x20,%esp
  80118b:	eb 18                	jmp    8011a5 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80118d:	83 ec 08             	sub    $0x8,%esp
  801190:	56                   	push   %esi
  801191:	ff 75 18             	pushl  0x18(%ebp)
  801194:	ff d7                	call   *%edi
  801196:	83 c4 10             	add    $0x10,%esp
  801199:	eb 03                	jmp    80119e <printnum+0x78>
  80119b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80119e:	83 eb 01             	sub    $0x1,%ebx
  8011a1:	85 db                	test   %ebx,%ebx
  8011a3:	7f e8                	jg     80118d <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011a5:	83 ec 08             	sub    $0x8,%esp
  8011a8:	56                   	push   %esi
  8011a9:	83 ec 04             	sub    $0x4,%esp
  8011ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011af:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b2:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b5:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b8:	e8 03 0b 00 00       	call   801cc0 <__umoddi3>
  8011bd:	83 c4 14             	add    $0x14,%esp
  8011c0:	0f be 80 67 1f 80 00 	movsbl 0x801f67(%eax),%eax
  8011c7:	50                   	push   %eax
  8011c8:	ff d7                	call   *%edi
}
  8011ca:	83 c4 10             	add    $0x10,%esp
  8011cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d0:	5b                   	pop    %ebx
  8011d1:	5e                   	pop    %esi
  8011d2:	5f                   	pop    %edi
  8011d3:	5d                   	pop    %ebp
  8011d4:	c3                   	ret    

008011d5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011db:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011df:	8b 10                	mov    (%eax),%edx
  8011e1:	3b 50 04             	cmp    0x4(%eax),%edx
  8011e4:	73 0a                	jae    8011f0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011e6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011e9:	89 08                	mov    %ecx,(%eax)
  8011eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ee:	88 02                	mov    %al,(%edx)
}
  8011f0:	5d                   	pop    %ebp
  8011f1:	c3                   	ret    

008011f2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011f8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011fb:	50                   	push   %eax
  8011fc:	ff 75 10             	pushl  0x10(%ebp)
  8011ff:	ff 75 0c             	pushl  0xc(%ebp)
  801202:	ff 75 08             	pushl  0x8(%ebp)
  801205:	e8 05 00 00 00       	call   80120f <vprintfmt>
	va_end(ap);
}
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	c9                   	leave  
  80120e:	c3                   	ret    

0080120f <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80120f:	55                   	push   %ebp
  801210:	89 e5                	mov    %esp,%ebp
  801212:	57                   	push   %edi
  801213:	56                   	push   %esi
  801214:	53                   	push   %ebx
  801215:	83 ec 2c             	sub    $0x2c,%esp
  801218:	8b 75 08             	mov    0x8(%ebp),%esi
  80121b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80121e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801221:	eb 12                	jmp    801235 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801223:	85 c0                	test   %eax,%eax
  801225:	0f 84 42 04 00 00    	je     80166d <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80122b:	83 ec 08             	sub    $0x8,%esp
  80122e:	53                   	push   %ebx
  80122f:	50                   	push   %eax
  801230:	ff d6                	call   *%esi
  801232:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801235:	83 c7 01             	add    $0x1,%edi
  801238:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80123c:	83 f8 25             	cmp    $0x25,%eax
  80123f:	75 e2                	jne    801223 <vprintfmt+0x14>
  801241:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801245:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80124c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801253:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80125a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80125f:	eb 07                	jmp    801268 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801261:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801264:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801268:	8d 47 01             	lea    0x1(%edi),%eax
  80126b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80126e:	0f b6 07             	movzbl (%edi),%eax
  801271:	0f b6 d0             	movzbl %al,%edx
  801274:	83 e8 23             	sub    $0x23,%eax
  801277:	3c 55                	cmp    $0x55,%al
  801279:	0f 87 d3 03 00 00    	ja     801652 <vprintfmt+0x443>
  80127f:	0f b6 c0             	movzbl %al,%eax
  801282:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  801289:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80128c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801290:	eb d6                	jmp    801268 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801292:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801295:	b8 00 00 00 00       	mov    $0x0,%eax
  80129a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80129d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012a0:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8012a4:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8012a7:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8012aa:	83 f9 09             	cmp    $0x9,%ecx
  8012ad:	77 3f                	ja     8012ee <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012af:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012b2:	eb e9                	jmp    80129d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8012b7:	8b 00                	mov    (%eax),%eax
  8012b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8012bf:	8d 40 04             	lea    0x4(%eax),%eax
  8012c2:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012c8:	eb 2a                	jmp    8012f4 <vprintfmt+0xe5>
  8012ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012cd:	85 c0                	test   %eax,%eax
  8012cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d4:	0f 49 d0             	cmovns %eax,%edx
  8012d7:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012dd:	eb 89                	jmp    801268 <vprintfmt+0x59>
  8012df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012e2:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012e9:	e9 7a ff ff ff       	jmp    801268 <vprintfmt+0x59>
  8012ee:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012f1:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8012f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012f8:	0f 89 6a ff ff ff    	jns    801268 <vprintfmt+0x59>
				width = precision, precision = -1;
  8012fe:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801301:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801304:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80130b:	e9 58 ff ff ff       	jmp    801268 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801310:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801313:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801316:	e9 4d ff ff ff       	jmp    801268 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80131b:	8b 45 14             	mov    0x14(%ebp),%eax
  80131e:	8d 78 04             	lea    0x4(%eax),%edi
  801321:	83 ec 08             	sub    $0x8,%esp
  801324:	53                   	push   %ebx
  801325:	ff 30                	pushl  (%eax)
  801327:	ff d6                	call   *%esi
			break;
  801329:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80132c:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80132f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801332:	e9 fe fe ff ff       	jmp    801235 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801337:	8b 45 14             	mov    0x14(%ebp),%eax
  80133a:	8d 78 04             	lea    0x4(%eax),%edi
  80133d:	8b 00                	mov    (%eax),%eax
  80133f:	99                   	cltd   
  801340:	31 d0                	xor    %edx,%eax
  801342:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801344:	83 f8 0f             	cmp    $0xf,%eax
  801347:	7f 0b                	jg     801354 <vprintfmt+0x145>
  801349:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  801350:	85 d2                	test   %edx,%edx
  801352:	75 1b                	jne    80136f <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  801354:	50                   	push   %eax
  801355:	68 7f 1f 80 00       	push   $0x801f7f
  80135a:	53                   	push   %ebx
  80135b:	56                   	push   %esi
  80135c:	e8 91 fe ff ff       	call   8011f2 <printfmt>
  801361:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801364:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80136a:	e9 c6 fe ff ff       	jmp    801235 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80136f:	52                   	push   %edx
  801370:	68 fd 1e 80 00       	push   $0x801efd
  801375:	53                   	push   %ebx
  801376:	56                   	push   %esi
  801377:	e8 76 fe ff ff       	call   8011f2 <printfmt>
  80137c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80137f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801382:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801385:	e9 ab fe ff ff       	jmp    801235 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80138a:	8b 45 14             	mov    0x14(%ebp),%eax
  80138d:	83 c0 04             	add    $0x4,%eax
  801390:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801393:	8b 45 14             	mov    0x14(%ebp),%eax
  801396:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801398:	85 ff                	test   %edi,%edi
  80139a:	b8 78 1f 80 00       	mov    $0x801f78,%eax
  80139f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013a6:	0f 8e 94 00 00 00    	jle    801440 <vprintfmt+0x231>
  8013ac:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013b0:	0f 84 98 00 00 00    	je     80144e <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013b6:	83 ec 08             	sub    $0x8,%esp
  8013b9:	ff 75 d0             	pushl  -0x30(%ebp)
  8013bc:	57                   	push   %edi
  8013bd:	e8 33 03 00 00       	call   8016f5 <strnlen>
  8013c2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013c5:	29 c1                	sub    %eax,%ecx
  8013c7:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013ca:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013cd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013d4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013d7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013d9:	eb 0f                	jmp    8013ea <vprintfmt+0x1db>
					putch(padc, putdat);
  8013db:	83 ec 08             	sub    $0x8,%esp
  8013de:	53                   	push   %ebx
  8013df:	ff 75 e0             	pushl  -0x20(%ebp)
  8013e2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e4:	83 ef 01             	sub    $0x1,%edi
  8013e7:	83 c4 10             	add    $0x10,%esp
  8013ea:	85 ff                	test   %edi,%edi
  8013ec:	7f ed                	jg     8013db <vprintfmt+0x1cc>
  8013ee:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013f1:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013f4:	85 c9                	test   %ecx,%ecx
  8013f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8013fb:	0f 49 c1             	cmovns %ecx,%eax
  8013fe:	29 c1                	sub    %eax,%ecx
  801400:	89 75 08             	mov    %esi,0x8(%ebp)
  801403:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801406:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801409:	89 cb                	mov    %ecx,%ebx
  80140b:	eb 4d                	jmp    80145a <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80140d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801411:	74 1b                	je     80142e <vprintfmt+0x21f>
  801413:	0f be c0             	movsbl %al,%eax
  801416:	83 e8 20             	sub    $0x20,%eax
  801419:	83 f8 5e             	cmp    $0x5e,%eax
  80141c:	76 10                	jbe    80142e <vprintfmt+0x21f>
					putch('?', putdat);
  80141e:	83 ec 08             	sub    $0x8,%esp
  801421:	ff 75 0c             	pushl  0xc(%ebp)
  801424:	6a 3f                	push   $0x3f
  801426:	ff 55 08             	call   *0x8(%ebp)
  801429:	83 c4 10             	add    $0x10,%esp
  80142c:	eb 0d                	jmp    80143b <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80142e:	83 ec 08             	sub    $0x8,%esp
  801431:	ff 75 0c             	pushl  0xc(%ebp)
  801434:	52                   	push   %edx
  801435:	ff 55 08             	call   *0x8(%ebp)
  801438:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80143b:	83 eb 01             	sub    $0x1,%ebx
  80143e:	eb 1a                	jmp    80145a <vprintfmt+0x24b>
  801440:	89 75 08             	mov    %esi,0x8(%ebp)
  801443:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801446:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801449:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80144c:	eb 0c                	jmp    80145a <vprintfmt+0x24b>
  80144e:	89 75 08             	mov    %esi,0x8(%ebp)
  801451:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801454:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801457:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80145a:	83 c7 01             	add    $0x1,%edi
  80145d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801461:	0f be d0             	movsbl %al,%edx
  801464:	85 d2                	test   %edx,%edx
  801466:	74 23                	je     80148b <vprintfmt+0x27c>
  801468:	85 f6                	test   %esi,%esi
  80146a:	78 a1                	js     80140d <vprintfmt+0x1fe>
  80146c:	83 ee 01             	sub    $0x1,%esi
  80146f:	79 9c                	jns    80140d <vprintfmt+0x1fe>
  801471:	89 df                	mov    %ebx,%edi
  801473:	8b 75 08             	mov    0x8(%ebp),%esi
  801476:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801479:	eb 18                	jmp    801493 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80147b:	83 ec 08             	sub    $0x8,%esp
  80147e:	53                   	push   %ebx
  80147f:	6a 20                	push   $0x20
  801481:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801483:	83 ef 01             	sub    $0x1,%edi
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	eb 08                	jmp    801493 <vprintfmt+0x284>
  80148b:	89 df                	mov    %ebx,%edi
  80148d:	8b 75 08             	mov    0x8(%ebp),%esi
  801490:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801493:	85 ff                	test   %edi,%edi
  801495:	7f e4                	jg     80147b <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801497:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80149a:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80149d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014a0:	e9 90 fd ff ff       	jmp    801235 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014a5:	83 f9 01             	cmp    $0x1,%ecx
  8014a8:	7e 19                	jle    8014c3 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8014aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ad:	8b 50 04             	mov    0x4(%eax),%edx
  8014b0:	8b 00                	mov    (%eax),%eax
  8014b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014b5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8014bb:	8d 40 08             	lea    0x8(%eax),%eax
  8014be:	89 45 14             	mov    %eax,0x14(%ebp)
  8014c1:	eb 38                	jmp    8014fb <vprintfmt+0x2ec>
	else if (lflag)
  8014c3:	85 c9                	test   %ecx,%ecx
  8014c5:	74 1b                	je     8014e2 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8014c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ca:	8b 00                	mov    (%eax),%eax
  8014cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014cf:	89 c1                	mov    %eax,%ecx
  8014d1:	c1 f9 1f             	sar    $0x1f,%ecx
  8014d4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014da:	8d 40 04             	lea    0x4(%eax),%eax
  8014dd:	89 45 14             	mov    %eax,0x14(%ebp)
  8014e0:	eb 19                	jmp    8014fb <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8014e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e5:	8b 00                	mov    (%eax),%eax
  8014e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ea:	89 c1                	mov    %eax,%ecx
  8014ec:	c1 f9 1f             	sar    $0x1f,%ecx
  8014ef:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f5:	8d 40 04             	lea    0x4(%eax),%eax
  8014f8:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014fb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014fe:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801501:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801506:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80150a:	0f 89 0e 01 00 00    	jns    80161e <vprintfmt+0x40f>
				putch('-', putdat);
  801510:	83 ec 08             	sub    $0x8,%esp
  801513:	53                   	push   %ebx
  801514:	6a 2d                	push   $0x2d
  801516:	ff d6                	call   *%esi
				num = -(long long) num;
  801518:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80151b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80151e:	f7 da                	neg    %edx
  801520:	83 d1 00             	adc    $0x0,%ecx
  801523:	f7 d9                	neg    %ecx
  801525:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801528:	b8 0a 00 00 00       	mov    $0xa,%eax
  80152d:	e9 ec 00 00 00       	jmp    80161e <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801532:	83 f9 01             	cmp    $0x1,%ecx
  801535:	7e 18                	jle    80154f <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  801537:	8b 45 14             	mov    0x14(%ebp),%eax
  80153a:	8b 10                	mov    (%eax),%edx
  80153c:	8b 48 04             	mov    0x4(%eax),%ecx
  80153f:	8d 40 08             	lea    0x8(%eax),%eax
  801542:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801545:	b8 0a 00 00 00       	mov    $0xa,%eax
  80154a:	e9 cf 00 00 00       	jmp    80161e <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80154f:	85 c9                	test   %ecx,%ecx
  801551:	74 1a                	je     80156d <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  801553:	8b 45 14             	mov    0x14(%ebp),%eax
  801556:	8b 10                	mov    (%eax),%edx
  801558:	b9 00 00 00 00       	mov    $0x0,%ecx
  80155d:	8d 40 04             	lea    0x4(%eax),%eax
  801560:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801563:	b8 0a 00 00 00       	mov    $0xa,%eax
  801568:	e9 b1 00 00 00       	jmp    80161e <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80156d:	8b 45 14             	mov    0x14(%ebp),%eax
  801570:	8b 10                	mov    (%eax),%edx
  801572:	b9 00 00 00 00       	mov    $0x0,%ecx
  801577:	8d 40 04             	lea    0x4(%eax),%eax
  80157a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80157d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801582:	e9 97 00 00 00       	jmp    80161e <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801587:	83 ec 08             	sub    $0x8,%esp
  80158a:	53                   	push   %ebx
  80158b:	6a 58                	push   $0x58
  80158d:	ff d6                	call   *%esi
			putch('X', putdat);
  80158f:	83 c4 08             	add    $0x8,%esp
  801592:	53                   	push   %ebx
  801593:	6a 58                	push   $0x58
  801595:	ff d6                	call   *%esi
			putch('X', putdat);
  801597:	83 c4 08             	add    $0x8,%esp
  80159a:	53                   	push   %ebx
  80159b:	6a 58                	push   $0x58
  80159d:	ff d6                	call   *%esi
			break;
  80159f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8015a5:	e9 8b fc ff ff       	jmp    801235 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8015aa:	83 ec 08             	sub    $0x8,%esp
  8015ad:	53                   	push   %ebx
  8015ae:	6a 30                	push   $0x30
  8015b0:	ff d6                	call   *%esi
			putch('x', putdat);
  8015b2:	83 c4 08             	add    $0x8,%esp
  8015b5:	53                   	push   %ebx
  8015b6:	6a 78                	push   $0x78
  8015b8:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8015bd:	8b 10                	mov    (%eax),%edx
  8015bf:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015c4:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015c7:	8d 40 04             	lea    0x4(%eax),%eax
  8015ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015cd:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015d2:	eb 4a                	jmp    80161e <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015d4:	83 f9 01             	cmp    $0x1,%ecx
  8015d7:	7e 15                	jle    8015ee <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8015d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8015dc:	8b 10                	mov    (%eax),%edx
  8015de:	8b 48 04             	mov    0x4(%eax),%ecx
  8015e1:	8d 40 08             	lea    0x8(%eax),%eax
  8015e4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8015e7:	b8 10 00 00 00       	mov    $0x10,%eax
  8015ec:	eb 30                	jmp    80161e <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8015ee:	85 c9                	test   %ecx,%ecx
  8015f0:	74 17                	je     801609 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8015f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8015f5:	8b 10                	mov    (%eax),%edx
  8015f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015fc:	8d 40 04             	lea    0x4(%eax),%eax
  8015ff:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801602:	b8 10 00 00 00       	mov    $0x10,%eax
  801607:	eb 15                	jmp    80161e <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801609:	8b 45 14             	mov    0x14(%ebp),%eax
  80160c:	8b 10                	mov    (%eax),%edx
  80160e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801613:	8d 40 04             	lea    0x4(%eax),%eax
  801616:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801619:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80161e:	83 ec 0c             	sub    $0xc,%esp
  801621:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801625:	57                   	push   %edi
  801626:	ff 75 e0             	pushl  -0x20(%ebp)
  801629:	50                   	push   %eax
  80162a:	51                   	push   %ecx
  80162b:	52                   	push   %edx
  80162c:	89 da                	mov    %ebx,%edx
  80162e:	89 f0                	mov    %esi,%eax
  801630:	e8 f1 fa ff ff       	call   801126 <printnum>
			break;
  801635:	83 c4 20             	add    $0x20,%esp
  801638:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80163b:	e9 f5 fb ff ff       	jmp    801235 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801640:	83 ec 08             	sub    $0x8,%esp
  801643:	53                   	push   %ebx
  801644:	52                   	push   %edx
  801645:	ff d6                	call   *%esi
			break;
  801647:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80164a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80164d:	e9 e3 fb ff ff       	jmp    801235 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801652:	83 ec 08             	sub    $0x8,%esp
  801655:	53                   	push   %ebx
  801656:	6a 25                	push   $0x25
  801658:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	eb 03                	jmp    801662 <vprintfmt+0x453>
  80165f:	83 ef 01             	sub    $0x1,%edi
  801662:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801666:	75 f7                	jne    80165f <vprintfmt+0x450>
  801668:	e9 c8 fb ff ff       	jmp    801235 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80166d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801670:	5b                   	pop    %ebx
  801671:	5e                   	pop    %esi
  801672:	5f                   	pop    %edi
  801673:	5d                   	pop    %ebp
  801674:	c3                   	ret    

00801675 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	83 ec 18             	sub    $0x18,%esp
  80167b:	8b 45 08             	mov    0x8(%ebp),%eax
  80167e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801681:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801684:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801688:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80168b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801692:	85 c0                	test   %eax,%eax
  801694:	74 26                	je     8016bc <vsnprintf+0x47>
  801696:	85 d2                	test   %edx,%edx
  801698:	7e 22                	jle    8016bc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80169a:	ff 75 14             	pushl  0x14(%ebp)
  80169d:	ff 75 10             	pushl  0x10(%ebp)
  8016a0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016a3:	50                   	push   %eax
  8016a4:	68 d5 11 80 00       	push   $0x8011d5
  8016a9:	e8 61 fb ff ff       	call   80120f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016ae:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016b1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b7:	83 c4 10             	add    $0x10,%esp
  8016ba:	eb 05                	jmp    8016c1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016c1:	c9                   	leave  
  8016c2:	c3                   	ret    

008016c3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016c9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016cc:	50                   	push   %eax
  8016cd:	ff 75 10             	pushl  0x10(%ebp)
  8016d0:	ff 75 0c             	pushl  0xc(%ebp)
  8016d3:	ff 75 08             	pushl  0x8(%ebp)
  8016d6:	e8 9a ff ff ff       	call   801675 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016db:	c9                   	leave  
  8016dc:	c3                   	ret    

008016dd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016dd:	55                   	push   %ebp
  8016de:	89 e5                	mov    %esp,%ebp
  8016e0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e8:	eb 03                	jmp    8016ed <strlen+0x10>
		n++;
  8016ea:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016ed:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016f1:	75 f7                	jne    8016ea <strlen+0xd>
		n++;
	return n;
}
  8016f3:	5d                   	pop    %ebp
  8016f4:	c3                   	ret    

008016f5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016fb:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801703:	eb 03                	jmp    801708 <strnlen+0x13>
		n++;
  801705:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801708:	39 c2                	cmp    %eax,%edx
  80170a:	74 08                	je     801714 <strnlen+0x1f>
  80170c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801710:	75 f3                	jne    801705 <strnlen+0x10>
  801712:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801714:	5d                   	pop    %ebp
  801715:	c3                   	ret    

00801716 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801716:	55                   	push   %ebp
  801717:	89 e5                	mov    %esp,%ebp
  801719:	53                   	push   %ebx
  80171a:	8b 45 08             	mov    0x8(%ebp),%eax
  80171d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801720:	89 c2                	mov    %eax,%edx
  801722:	83 c2 01             	add    $0x1,%edx
  801725:	83 c1 01             	add    $0x1,%ecx
  801728:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80172c:	88 5a ff             	mov    %bl,-0x1(%edx)
  80172f:	84 db                	test   %bl,%bl
  801731:	75 ef                	jne    801722 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801733:	5b                   	pop    %ebx
  801734:	5d                   	pop    %ebp
  801735:	c3                   	ret    

00801736 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	53                   	push   %ebx
  80173a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80173d:	53                   	push   %ebx
  80173e:	e8 9a ff ff ff       	call   8016dd <strlen>
  801743:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801746:	ff 75 0c             	pushl  0xc(%ebp)
  801749:	01 d8                	add    %ebx,%eax
  80174b:	50                   	push   %eax
  80174c:	e8 c5 ff ff ff       	call   801716 <strcpy>
	return dst;
}
  801751:	89 d8                	mov    %ebx,%eax
  801753:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801756:	c9                   	leave  
  801757:	c3                   	ret    

00801758 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	56                   	push   %esi
  80175c:	53                   	push   %ebx
  80175d:	8b 75 08             	mov    0x8(%ebp),%esi
  801760:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801763:	89 f3                	mov    %esi,%ebx
  801765:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801768:	89 f2                	mov    %esi,%edx
  80176a:	eb 0f                	jmp    80177b <strncpy+0x23>
		*dst++ = *src;
  80176c:	83 c2 01             	add    $0x1,%edx
  80176f:	0f b6 01             	movzbl (%ecx),%eax
  801772:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801775:	80 39 01             	cmpb   $0x1,(%ecx)
  801778:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80177b:	39 da                	cmp    %ebx,%edx
  80177d:	75 ed                	jne    80176c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80177f:	89 f0                	mov    %esi,%eax
  801781:	5b                   	pop    %ebx
  801782:	5e                   	pop    %esi
  801783:	5d                   	pop    %ebp
  801784:	c3                   	ret    

00801785 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	56                   	push   %esi
  801789:	53                   	push   %ebx
  80178a:	8b 75 08             	mov    0x8(%ebp),%esi
  80178d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801790:	8b 55 10             	mov    0x10(%ebp),%edx
  801793:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801795:	85 d2                	test   %edx,%edx
  801797:	74 21                	je     8017ba <strlcpy+0x35>
  801799:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80179d:	89 f2                	mov    %esi,%edx
  80179f:	eb 09                	jmp    8017aa <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017a1:	83 c2 01             	add    $0x1,%edx
  8017a4:	83 c1 01             	add    $0x1,%ecx
  8017a7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017aa:	39 c2                	cmp    %eax,%edx
  8017ac:	74 09                	je     8017b7 <strlcpy+0x32>
  8017ae:	0f b6 19             	movzbl (%ecx),%ebx
  8017b1:	84 db                	test   %bl,%bl
  8017b3:	75 ec                	jne    8017a1 <strlcpy+0x1c>
  8017b5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017b7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017ba:	29 f0                	sub    %esi,%eax
}
  8017bc:	5b                   	pop    %ebx
  8017bd:	5e                   	pop    %esi
  8017be:	5d                   	pop    %ebp
  8017bf:	c3                   	ret    

008017c0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017c9:	eb 06                	jmp    8017d1 <strcmp+0x11>
		p++, q++;
  8017cb:	83 c1 01             	add    $0x1,%ecx
  8017ce:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017d1:	0f b6 01             	movzbl (%ecx),%eax
  8017d4:	84 c0                	test   %al,%al
  8017d6:	74 04                	je     8017dc <strcmp+0x1c>
  8017d8:	3a 02                	cmp    (%edx),%al
  8017da:	74 ef                	je     8017cb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017dc:	0f b6 c0             	movzbl %al,%eax
  8017df:	0f b6 12             	movzbl (%edx),%edx
  8017e2:	29 d0                	sub    %edx,%eax
}
  8017e4:	5d                   	pop    %ebp
  8017e5:	c3                   	ret    

008017e6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017e6:	55                   	push   %ebp
  8017e7:	89 e5                	mov    %esp,%ebp
  8017e9:	53                   	push   %ebx
  8017ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f0:	89 c3                	mov    %eax,%ebx
  8017f2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017f5:	eb 06                	jmp    8017fd <strncmp+0x17>
		n--, p++, q++;
  8017f7:	83 c0 01             	add    $0x1,%eax
  8017fa:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017fd:	39 d8                	cmp    %ebx,%eax
  8017ff:	74 15                	je     801816 <strncmp+0x30>
  801801:	0f b6 08             	movzbl (%eax),%ecx
  801804:	84 c9                	test   %cl,%cl
  801806:	74 04                	je     80180c <strncmp+0x26>
  801808:	3a 0a                	cmp    (%edx),%cl
  80180a:	74 eb                	je     8017f7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80180c:	0f b6 00             	movzbl (%eax),%eax
  80180f:	0f b6 12             	movzbl (%edx),%edx
  801812:	29 d0                	sub    %edx,%eax
  801814:	eb 05                	jmp    80181b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801816:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80181b:	5b                   	pop    %ebx
  80181c:	5d                   	pop    %ebp
  80181d:	c3                   	ret    

0080181e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80181e:	55                   	push   %ebp
  80181f:	89 e5                	mov    %esp,%ebp
  801821:	8b 45 08             	mov    0x8(%ebp),%eax
  801824:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801828:	eb 07                	jmp    801831 <strchr+0x13>
		if (*s == c)
  80182a:	38 ca                	cmp    %cl,%dl
  80182c:	74 0f                	je     80183d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80182e:	83 c0 01             	add    $0x1,%eax
  801831:	0f b6 10             	movzbl (%eax),%edx
  801834:	84 d2                	test   %dl,%dl
  801836:	75 f2                	jne    80182a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801838:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80183d:	5d                   	pop    %ebp
  80183e:	c3                   	ret    

0080183f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
  801842:	8b 45 08             	mov    0x8(%ebp),%eax
  801845:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801849:	eb 03                	jmp    80184e <strfind+0xf>
  80184b:	83 c0 01             	add    $0x1,%eax
  80184e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801851:	38 ca                	cmp    %cl,%dl
  801853:	74 04                	je     801859 <strfind+0x1a>
  801855:	84 d2                	test   %dl,%dl
  801857:	75 f2                	jne    80184b <strfind+0xc>
			break;
	return (char *) s;
}
  801859:	5d                   	pop    %ebp
  80185a:	c3                   	ret    

0080185b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80185b:	55                   	push   %ebp
  80185c:	89 e5                	mov    %esp,%ebp
  80185e:	57                   	push   %edi
  80185f:	56                   	push   %esi
  801860:	53                   	push   %ebx
  801861:	8b 7d 08             	mov    0x8(%ebp),%edi
  801864:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801867:	85 c9                	test   %ecx,%ecx
  801869:	74 36                	je     8018a1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80186b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801871:	75 28                	jne    80189b <memset+0x40>
  801873:	f6 c1 03             	test   $0x3,%cl
  801876:	75 23                	jne    80189b <memset+0x40>
		c &= 0xFF;
  801878:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80187c:	89 d3                	mov    %edx,%ebx
  80187e:	c1 e3 08             	shl    $0x8,%ebx
  801881:	89 d6                	mov    %edx,%esi
  801883:	c1 e6 18             	shl    $0x18,%esi
  801886:	89 d0                	mov    %edx,%eax
  801888:	c1 e0 10             	shl    $0x10,%eax
  80188b:	09 f0                	or     %esi,%eax
  80188d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80188f:	89 d8                	mov    %ebx,%eax
  801891:	09 d0                	or     %edx,%eax
  801893:	c1 e9 02             	shr    $0x2,%ecx
  801896:	fc                   	cld    
  801897:	f3 ab                	rep stos %eax,%es:(%edi)
  801899:	eb 06                	jmp    8018a1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80189b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80189e:	fc                   	cld    
  80189f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8018a1:	89 f8                	mov    %edi,%eax
  8018a3:	5b                   	pop    %ebx
  8018a4:	5e                   	pop    %esi
  8018a5:	5f                   	pop    %edi
  8018a6:	5d                   	pop    %ebp
  8018a7:	c3                   	ret    

008018a8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	57                   	push   %edi
  8018ac:	56                   	push   %esi
  8018ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018b6:	39 c6                	cmp    %eax,%esi
  8018b8:	73 35                	jae    8018ef <memmove+0x47>
  8018ba:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018bd:	39 d0                	cmp    %edx,%eax
  8018bf:	73 2e                	jae    8018ef <memmove+0x47>
		s += n;
		d += n;
  8018c1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018c4:	89 d6                	mov    %edx,%esi
  8018c6:	09 fe                	or     %edi,%esi
  8018c8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018ce:	75 13                	jne    8018e3 <memmove+0x3b>
  8018d0:	f6 c1 03             	test   $0x3,%cl
  8018d3:	75 0e                	jne    8018e3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018d5:	83 ef 04             	sub    $0x4,%edi
  8018d8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018db:	c1 e9 02             	shr    $0x2,%ecx
  8018de:	fd                   	std    
  8018df:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018e1:	eb 09                	jmp    8018ec <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018e3:	83 ef 01             	sub    $0x1,%edi
  8018e6:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018e9:	fd                   	std    
  8018ea:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018ec:	fc                   	cld    
  8018ed:	eb 1d                	jmp    80190c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018ef:	89 f2                	mov    %esi,%edx
  8018f1:	09 c2                	or     %eax,%edx
  8018f3:	f6 c2 03             	test   $0x3,%dl
  8018f6:	75 0f                	jne    801907 <memmove+0x5f>
  8018f8:	f6 c1 03             	test   $0x3,%cl
  8018fb:	75 0a                	jne    801907 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018fd:	c1 e9 02             	shr    $0x2,%ecx
  801900:	89 c7                	mov    %eax,%edi
  801902:	fc                   	cld    
  801903:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801905:	eb 05                	jmp    80190c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801907:	89 c7                	mov    %eax,%edi
  801909:	fc                   	cld    
  80190a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80190c:	5e                   	pop    %esi
  80190d:	5f                   	pop    %edi
  80190e:	5d                   	pop    %ebp
  80190f:	c3                   	ret    

00801910 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801910:	55                   	push   %ebp
  801911:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801913:	ff 75 10             	pushl  0x10(%ebp)
  801916:	ff 75 0c             	pushl  0xc(%ebp)
  801919:	ff 75 08             	pushl  0x8(%ebp)
  80191c:	e8 87 ff ff ff       	call   8018a8 <memmove>
}
  801921:	c9                   	leave  
  801922:	c3                   	ret    

00801923 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801923:	55                   	push   %ebp
  801924:	89 e5                	mov    %esp,%ebp
  801926:	56                   	push   %esi
  801927:	53                   	push   %ebx
  801928:	8b 45 08             	mov    0x8(%ebp),%eax
  80192b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80192e:	89 c6                	mov    %eax,%esi
  801930:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801933:	eb 1a                	jmp    80194f <memcmp+0x2c>
		if (*s1 != *s2)
  801935:	0f b6 08             	movzbl (%eax),%ecx
  801938:	0f b6 1a             	movzbl (%edx),%ebx
  80193b:	38 d9                	cmp    %bl,%cl
  80193d:	74 0a                	je     801949 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80193f:	0f b6 c1             	movzbl %cl,%eax
  801942:	0f b6 db             	movzbl %bl,%ebx
  801945:	29 d8                	sub    %ebx,%eax
  801947:	eb 0f                	jmp    801958 <memcmp+0x35>
		s1++, s2++;
  801949:	83 c0 01             	add    $0x1,%eax
  80194c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80194f:	39 f0                	cmp    %esi,%eax
  801951:	75 e2                	jne    801935 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801953:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801958:	5b                   	pop    %ebx
  801959:	5e                   	pop    %esi
  80195a:	5d                   	pop    %ebp
  80195b:	c3                   	ret    

0080195c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	53                   	push   %ebx
  801960:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801963:	89 c1                	mov    %eax,%ecx
  801965:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801968:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80196c:	eb 0a                	jmp    801978 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80196e:	0f b6 10             	movzbl (%eax),%edx
  801971:	39 da                	cmp    %ebx,%edx
  801973:	74 07                	je     80197c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801975:	83 c0 01             	add    $0x1,%eax
  801978:	39 c8                	cmp    %ecx,%eax
  80197a:	72 f2                	jb     80196e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80197c:	5b                   	pop    %ebx
  80197d:	5d                   	pop    %ebp
  80197e:	c3                   	ret    

0080197f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80197f:	55                   	push   %ebp
  801980:	89 e5                	mov    %esp,%ebp
  801982:	57                   	push   %edi
  801983:	56                   	push   %esi
  801984:	53                   	push   %ebx
  801985:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801988:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80198b:	eb 03                	jmp    801990 <strtol+0x11>
		s++;
  80198d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801990:	0f b6 01             	movzbl (%ecx),%eax
  801993:	3c 20                	cmp    $0x20,%al
  801995:	74 f6                	je     80198d <strtol+0xe>
  801997:	3c 09                	cmp    $0x9,%al
  801999:	74 f2                	je     80198d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80199b:	3c 2b                	cmp    $0x2b,%al
  80199d:	75 0a                	jne    8019a9 <strtol+0x2a>
		s++;
  80199f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019a2:	bf 00 00 00 00       	mov    $0x0,%edi
  8019a7:	eb 11                	jmp    8019ba <strtol+0x3b>
  8019a9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019ae:	3c 2d                	cmp    $0x2d,%al
  8019b0:	75 08                	jne    8019ba <strtol+0x3b>
		s++, neg = 1;
  8019b2:	83 c1 01             	add    $0x1,%ecx
  8019b5:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019ba:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019c0:	75 15                	jne    8019d7 <strtol+0x58>
  8019c2:	80 39 30             	cmpb   $0x30,(%ecx)
  8019c5:	75 10                	jne    8019d7 <strtol+0x58>
  8019c7:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019cb:	75 7c                	jne    801a49 <strtol+0xca>
		s += 2, base = 16;
  8019cd:	83 c1 02             	add    $0x2,%ecx
  8019d0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019d5:	eb 16                	jmp    8019ed <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019d7:	85 db                	test   %ebx,%ebx
  8019d9:	75 12                	jne    8019ed <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019db:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019e0:	80 39 30             	cmpb   $0x30,(%ecx)
  8019e3:	75 08                	jne    8019ed <strtol+0x6e>
		s++, base = 8;
  8019e5:	83 c1 01             	add    $0x1,%ecx
  8019e8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019f5:	0f b6 11             	movzbl (%ecx),%edx
  8019f8:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019fb:	89 f3                	mov    %esi,%ebx
  8019fd:	80 fb 09             	cmp    $0x9,%bl
  801a00:	77 08                	ja     801a0a <strtol+0x8b>
			dig = *s - '0';
  801a02:	0f be d2             	movsbl %dl,%edx
  801a05:	83 ea 30             	sub    $0x30,%edx
  801a08:	eb 22                	jmp    801a2c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a0a:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a0d:	89 f3                	mov    %esi,%ebx
  801a0f:	80 fb 19             	cmp    $0x19,%bl
  801a12:	77 08                	ja     801a1c <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a14:	0f be d2             	movsbl %dl,%edx
  801a17:	83 ea 57             	sub    $0x57,%edx
  801a1a:	eb 10                	jmp    801a2c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a1c:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a1f:	89 f3                	mov    %esi,%ebx
  801a21:	80 fb 19             	cmp    $0x19,%bl
  801a24:	77 16                	ja     801a3c <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a26:	0f be d2             	movsbl %dl,%edx
  801a29:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a2c:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a2f:	7d 0b                	jge    801a3c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a31:	83 c1 01             	add    $0x1,%ecx
  801a34:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a38:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a3a:	eb b9                	jmp    8019f5 <strtol+0x76>

	if (endptr)
  801a3c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a40:	74 0d                	je     801a4f <strtol+0xd0>
		*endptr = (char *) s;
  801a42:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a45:	89 0e                	mov    %ecx,(%esi)
  801a47:	eb 06                	jmp    801a4f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a49:	85 db                	test   %ebx,%ebx
  801a4b:	74 98                	je     8019e5 <strtol+0x66>
  801a4d:	eb 9e                	jmp    8019ed <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a4f:	89 c2                	mov    %eax,%edx
  801a51:	f7 da                	neg    %edx
  801a53:	85 ff                	test   %edi,%edi
  801a55:	0f 45 c2             	cmovne %edx,%eax
}
  801a58:	5b                   	pop    %ebx
  801a59:	5e                   	pop    %esi
  801a5a:	5f                   	pop    %edi
  801a5b:	5d                   	pop    %ebp
  801a5c:	c3                   	ret    

00801a5d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a5d:	55                   	push   %ebp
  801a5e:	89 e5                	mov    %esp,%ebp
  801a60:	56                   	push   %esi
  801a61:	53                   	push   %ebx
  801a62:	8b 75 08             	mov    0x8(%ebp),%esi
  801a65:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a68:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801a6b:	85 c0                	test   %eax,%eax
  801a6d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a72:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801a75:	83 ec 0c             	sub    $0xc,%esp
  801a78:	50                   	push   %eax
  801a79:	e8 90 e8 ff ff       	call   80030e <sys_ipc_recv>
  801a7e:	83 c4 10             	add    $0x10,%esp
  801a81:	85 c0                	test   %eax,%eax
  801a83:	79 16                	jns    801a9b <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801a85:	85 f6                	test   %esi,%esi
  801a87:	74 06                	je     801a8f <ipc_recv+0x32>
            *from_env_store = 0;
  801a89:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801a8f:	85 db                	test   %ebx,%ebx
  801a91:	74 2c                	je     801abf <ipc_recv+0x62>
            *perm_store = 0;
  801a93:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a99:	eb 24                	jmp    801abf <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801a9b:	85 f6                	test   %esi,%esi
  801a9d:	74 0a                	je     801aa9 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801a9f:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa4:	8b 40 74             	mov    0x74(%eax),%eax
  801aa7:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801aa9:	85 db                	test   %ebx,%ebx
  801aab:	74 0a                	je     801ab7 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801aad:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab2:	8b 40 78             	mov    0x78(%eax),%eax
  801ab5:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801ab7:	a1 04 40 80 00       	mov    0x804004,%eax
  801abc:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801abf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac2:	5b                   	pop    %ebx
  801ac3:	5e                   	pop    %esi
  801ac4:	5d                   	pop    %ebp
  801ac5:	c3                   	ret    

00801ac6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	57                   	push   %edi
  801aca:	56                   	push   %esi
  801acb:	53                   	push   %ebx
  801acc:	83 ec 0c             	sub    $0xc,%esp
  801acf:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ad2:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ad5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ad8:	85 c0                	test   %eax,%eax
  801ada:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801adf:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801ae2:	eb 1c                	jmp    801b00 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801ae4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ae7:	74 12                	je     801afb <ipc_send+0x35>
  801ae9:	50                   	push   %eax
  801aea:	68 60 22 80 00       	push   $0x802260
  801aef:	6a 3a                	push   $0x3a
  801af1:	68 76 22 80 00       	push   $0x802276
  801af6:	e8 3e f5 ff ff       	call   801039 <_panic>
		sys_yield();
  801afb:	e8 3f e6 ff ff       	call   80013f <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801b00:	ff 75 14             	pushl  0x14(%ebp)
  801b03:	53                   	push   %ebx
  801b04:	56                   	push   %esi
  801b05:	57                   	push   %edi
  801b06:	e8 e0 e7 ff ff       	call   8002eb <sys_ipc_try_send>
  801b0b:	83 c4 10             	add    $0x10,%esp
  801b0e:	85 c0                	test   %eax,%eax
  801b10:	78 d2                	js     801ae4 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801b12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b15:	5b                   	pop    %ebx
  801b16:	5e                   	pop    %esi
  801b17:	5f                   	pop    %edi
  801b18:	5d                   	pop    %ebp
  801b19:	c3                   	ret    

00801b1a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b1a:	55                   	push   %ebp
  801b1b:	89 e5                	mov    %esp,%ebp
  801b1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b20:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b25:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b28:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b2e:	8b 52 50             	mov    0x50(%edx),%edx
  801b31:	39 ca                	cmp    %ecx,%edx
  801b33:	75 0d                	jne    801b42 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b35:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b38:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b3d:	8b 40 48             	mov    0x48(%eax),%eax
  801b40:	eb 0f                	jmp    801b51 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b42:	83 c0 01             	add    $0x1,%eax
  801b45:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b4a:	75 d9                	jne    801b25 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b51:	5d                   	pop    %ebp
  801b52:	c3                   	ret    

00801b53 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b53:	55                   	push   %ebp
  801b54:	89 e5                	mov    %esp,%ebp
  801b56:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b59:	89 d0                	mov    %edx,%eax
  801b5b:	c1 e8 16             	shr    $0x16,%eax
  801b5e:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b65:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b6a:	f6 c1 01             	test   $0x1,%cl
  801b6d:	74 1d                	je     801b8c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b6f:	c1 ea 0c             	shr    $0xc,%edx
  801b72:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b79:	f6 c2 01             	test   $0x1,%dl
  801b7c:	74 0e                	je     801b8c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b7e:	c1 ea 0c             	shr    $0xc,%edx
  801b81:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b88:	ef 
  801b89:	0f b7 c0             	movzwl %ax,%eax
}
  801b8c:	5d                   	pop    %ebp
  801b8d:	c3                   	ret    
  801b8e:	66 90                	xchg   %ax,%ax

00801b90 <__udivdi3>:
  801b90:	55                   	push   %ebp
  801b91:	57                   	push   %edi
  801b92:	56                   	push   %esi
  801b93:	53                   	push   %ebx
  801b94:	83 ec 1c             	sub    $0x1c,%esp
  801b97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ba3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ba7:	85 f6                	test   %esi,%esi
  801ba9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bad:	89 ca                	mov    %ecx,%edx
  801baf:	89 f8                	mov    %edi,%eax
  801bb1:	75 3d                	jne    801bf0 <__udivdi3+0x60>
  801bb3:	39 cf                	cmp    %ecx,%edi
  801bb5:	0f 87 c5 00 00 00    	ja     801c80 <__udivdi3+0xf0>
  801bbb:	85 ff                	test   %edi,%edi
  801bbd:	89 fd                	mov    %edi,%ebp
  801bbf:	75 0b                	jne    801bcc <__udivdi3+0x3c>
  801bc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc6:	31 d2                	xor    %edx,%edx
  801bc8:	f7 f7                	div    %edi
  801bca:	89 c5                	mov    %eax,%ebp
  801bcc:	89 c8                	mov    %ecx,%eax
  801bce:	31 d2                	xor    %edx,%edx
  801bd0:	f7 f5                	div    %ebp
  801bd2:	89 c1                	mov    %eax,%ecx
  801bd4:	89 d8                	mov    %ebx,%eax
  801bd6:	89 cf                	mov    %ecx,%edi
  801bd8:	f7 f5                	div    %ebp
  801bda:	89 c3                	mov    %eax,%ebx
  801bdc:	89 d8                	mov    %ebx,%eax
  801bde:	89 fa                	mov    %edi,%edx
  801be0:	83 c4 1c             	add    $0x1c,%esp
  801be3:	5b                   	pop    %ebx
  801be4:	5e                   	pop    %esi
  801be5:	5f                   	pop    %edi
  801be6:	5d                   	pop    %ebp
  801be7:	c3                   	ret    
  801be8:	90                   	nop
  801be9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bf0:	39 ce                	cmp    %ecx,%esi
  801bf2:	77 74                	ja     801c68 <__udivdi3+0xd8>
  801bf4:	0f bd fe             	bsr    %esi,%edi
  801bf7:	83 f7 1f             	xor    $0x1f,%edi
  801bfa:	0f 84 98 00 00 00    	je     801c98 <__udivdi3+0x108>
  801c00:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c05:	89 f9                	mov    %edi,%ecx
  801c07:	89 c5                	mov    %eax,%ebp
  801c09:	29 fb                	sub    %edi,%ebx
  801c0b:	d3 e6                	shl    %cl,%esi
  801c0d:	89 d9                	mov    %ebx,%ecx
  801c0f:	d3 ed                	shr    %cl,%ebp
  801c11:	89 f9                	mov    %edi,%ecx
  801c13:	d3 e0                	shl    %cl,%eax
  801c15:	09 ee                	or     %ebp,%esi
  801c17:	89 d9                	mov    %ebx,%ecx
  801c19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c1d:	89 d5                	mov    %edx,%ebp
  801c1f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c23:	d3 ed                	shr    %cl,%ebp
  801c25:	89 f9                	mov    %edi,%ecx
  801c27:	d3 e2                	shl    %cl,%edx
  801c29:	89 d9                	mov    %ebx,%ecx
  801c2b:	d3 e8                	shr    %cl,%eax
  801c2d:	09 c2                	or     %eax,%edx
  801c2f:	89 d0                	mov    %edx,%eax
  801c31:	89 ea                	mov    %ebp,%edx
  801c33:	f7 f6                	div    %esi
  801c35:	89 d5                	mov    %edx,%ebp
  801c37:	89 c3                	mov    %eax,%ebx
  801c39:	f7 64 24 0c          	mull   0xc(%esp)
  801c3d:	39 d5                	cmp    %edx,%ebp
  801c3f:	72 10                	jb     801c51 <__udivdi3+0xc1>
  801c41:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c45:	89 f9                	mov    %edi,%ecx
  801c47:	d3 e6                	shl    %cl,%esi
  801c49:	39 c6                	cmp    %eax,%esi
  801c4b:	73 07                	jae    801c54 <__udivdi3+0xc4>
  801c4d:	39 d5                	cmp    %edx,%ebp
  801c4f:	75 03                	jne    801c54 <__udivdi3+0xc4>
  801c51:	83 eb 01             	sub    $0x1,%ebx
  801c54:	31 ff                	xor    %edi,%edi
  801c56:	89 d8                	mov    %ebx,%eax
  801c58:	89 fa                	mov    %edi,%edx
  801c5a:	83 c4 1c             	add    $0x1c,%esp
  801c5d:	5b                   	pop    %ebx
  801c5e:	5e                   	pop    %esi
  801c5f:	5f                   	pop    %edi
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    
  801c62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c68:	31 ff                	xor    %edi,%edi
  801c6a:	31 db                	xor    %ebx,%ebx
  801c6c:	89 d8                	mov    %ebx,%eax
  801c6e:	89 fa                	mov    %edi,%edx
  801c70:	83 c4 1c             	add    $0x1c,%esp
  801c73:	5b                   	pop    %ebx
  801c74:	5e                   	pop    %esi
  801c75:	5f                   	pop    %edi
  801c76:	5d                   	pop    %ebp
  801c77:	c3                   	ret    
  801c78:	90                   	nop
  801c79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c80:	89 d8                	mov    %ebx,%eax
  801c82:	f7 f7                	div    %edi
  801c84:	31 ff                	xor    %edi,%edi
  801c86:	89 c3                	mov    %eax,%ebx
  801c88:	89 d8                	mov    %ebx,%eax
  801c8a:	89 fa                	mov    %edi,%edx
  801c8c:	83 c4 1c             	add    $0x1c,%esp
  801c8f:	5b                   	pop    %ebx
  801c90:	5e                   	pop    %esi
  801c91:	5f                   	pop    %edi
  801c92:	5d                   	pop    %ebp
  801c93:	c3                   	ret    
  801c94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c98:	39 ce                	cmp    %ecx,%esi
  801c9a:	72 0c                	jb     801ca8 <__udivdi3+0x118>
  801c9c:	31 db                	xor    %ebx,%ebx
  801c9e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ca2:	0f 87 34 ff ff ff    	ja     801bdc <__udivdi3+0x4c>
  801ca8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cad:	e9 2a ff ff ff       	jmp    801bdc <__udivdi3+0x4c>
  801cb2:	66 90                	xchg   %ax,%ax
  801cb4:	66 90                	xchg   %ax,%ax
  801cb6:	66 90                	xchg   %ax,%ax
  801cb8:	66 90                	xchg   %ax,%ax
  801cba:	66 90                	xchg   %ax,%ax
  801cbc:	66 90                	xchg   %ax,%ax
  801cbe:	66 90                	xchg   %ax,%ax

00801cc0 <__umoddi3>:
  801cc0:	55                   	push   %ebp
  801cc1:	57                   	push   %edi
  801cc2:	56                   	push   %esi
  801cc3:	53                   	push   %ebx
  801cc4:	83 ec 1c             	sub    $0x1c,%esp
  801cc7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801ccb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801ccf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cd7:	85 d2                	test   %edx,%edx
  801cd9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801cdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ce1:	89 f3                	mov    %esi,%ebx
  801ce3:	89 3c 24             	mov    %edi,(%esp)
  801ce6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cea:	75 1c                	jne    801d08 <__umoddi3+0x48>
  801cec:	39 f7                	cmp    %esi,%edi
  801cee:	76 50                	jbe    801d40 <__umoddi3+0x80>
  801cf0:	89 c8                	mov    %ecx,%eax
  801cf2:	89 f2                	mov    %esi,%edx
  801cf4:	f7 f7                	div    %edi
  801cf6:	89 d0                	mov    %edx,%eax
  801cf8:	31 d2                	xor    %edx,%edx
  801cfa:	83 c4 1c             	add    $0x1c,%esp
  801cfd:	5b                   	pop    %ebx
  801cfe:	5e                   	pop    %esi
  801cff:	5f                   	pop    %edi
  801d00:	5d                   	pop    %ebp
  801d01:	c3                   	ret    
  801d02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d08:	39 f2                	cmp    %esi,%edx
  801d0a:	89 d0                	mov    %edx,%eax
  801d0c:	77 52                	ja     801d60 <__umoddi3+0xa0>
  801d0e:	0f bd ea             	bsr    %edx,%ebp
  801d11:	83 f5 1f             	xor    $0x1f,%ebp
  801d14:	75 5a                	jne    801d70 <__umoddi3+0xb0>
  801d16:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d1a:	0f 82 e0 00 00 00    	jb     801e00 <__umoddi3+0x140>
  801d20:	39 0c 24             	cmp    %ecx,(%esp)
  801d23:	0f 86 d7 00 00 00    	jbe    801e00 <__umoddi3+0x140>
  801d29:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d2d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d31:	83 c4 1c             	add    $0x1c,%esp
  801d34:	5b                   	pop    %ebx
  801d35:	5e                   	pop    %esi
  801d36:	5f                   	pop    %edi
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    
  801d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d40:	85 ff                	test   %edi,%edi
  801d42:	89 fd                	mov    %edi,%ebp
  801d44:	75 0b                	jne    801d51 <__umoddi3+0x91>
  801d46:	b8 01 00 00 00       	mov    $0x1,%eax
  801d4b:	31 d2                	xor    %edx,%edx
  801d4d:	f7 f7                	div    %edi
  801d4f:	89 c5                	mov    %eax,%ebp
  801d51:	89 f0                	mov    %esi,%eax
  801d53:	31 d2                	xor    %edx,%edx
  801d55:	f7 f5                	div    %ebp
  801d57:	89 c8                	mov    %ecx,%eax
  801d59:	f7 f5                	div    %ebp
  801d5b:	89 d0                	mov    %edx,%eax
  801d5d:	eb 99                	jmp    801cf8 <__umoddi3+0x38>
  801d5f:	90                   	nop
  801d60:	89 c8                	mov    %ecx,%eax
  801d62:	89 f2                	mov    %esi,%edx
  801d64:	83 c4 1c             	add    $0x1c,%esp
  801d67:	5b                   	pop    %ebx
  801d68:	5e                   	pop    %esi
  801d69:	5f                   	pop    %edi
  801d6a:	5d                   	pop    %ebp
  801d6b:	c3                   	ret    
  801d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d70:	8b 34 24             	mov    (%esp),%esi
  801d73:	bf 20 00 00 00       	mov    $0x20,%edi
  801d78:	89 e9                	mov    %ebp,%ecx
  801d7a:	29 ef                	sub    %ebp,%edi
  801d7c:	d3 e0                	shl    %cl,%eax
  801d7e:	89 f9                	mov    %edi,%ecx
  801d80:	89 f2                	mov    %esi,%edx
  801d82:	d3 ea                	shr    %cl,%edx
  801d84:	89 e9                	mov    %ebp,%ecx
  801d86:	09 c2                	or     %eax,%edx
  801d88:	89 d8                	mov    %ebx,%eax
  801d8a:	89 14 24             	mov    %edx,(%esp)
  801d8d:	89 f2                	mov    %esi,%edx
  801d8f:	d3 e2                	shl    %cl,%edx
  801d91:	89 f9                	mov    %edi,%ecx
  801d93:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d97:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d9b:	d3 e8                	shr    %cl,%eax
  801d9d:	89 e9                	mov    %ebp,%ecx
  801d9f:	89 c6                	mov    %eax,%esi
  801da1:	d3 e3                	shl    %cl,%ebx
  801da3:	89 f9                	mov    %edi,%ecx
  801da5:	89 d0                	mov    %edx,%eax
  801da7:	d3 e8                	shr    %cl,%eax
  801da9:	89 e9                	mov    %ebp,%ecx
  801dab:	09 d8                	or     %ebx,%eax
  801dad:	89 d3                	mov    %edx,%ebx
  801daf:	89 f2                	mov    %esi,%edx
  801db1:	f7 34 24             	divl   (%esp)
  801db4:	89 d6                	mov    %edx,%esi
  801db6:	d3 e3                	shl    %cl,%ebx
  801db8:	f7 64 24 04          	mull   0x4(%esp)
  801dbc:	39 d6                	cmp    %edx,%esi
  801dbe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dc2:	89 d1                	mov    %edx,%ecx
  801dc4:	89 c3                	mov    %eax,%ebx
  801dc6:	72 08                	jb     801dd0 <__umoddi3+0x110>
  801dc8:	75 11                	jne    801ddb <__umoddi3+0x11b>
  801dca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dce:	73 0b                	jae    801ddb <__umoddi3+0x11b>
  801dd0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801dd4:	1b 14 24             	sbb    (%esp),%edx
  801dd7:	89 d1                	mov    %edx,%ecx
  801dd9:	89 c3                	mov    %eax,%ebx
  801ddb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801ddf:	29 da                	sub    %ebx,%edx
  801de1:	19 ce                	sbb    %ecx,%esi
  801de3:	89 f9                	mov    %edi,%ecx
  801de5:	89 f0                	mov    %esi,%eax
  801de7:	d3 e0                	shl    %cl,%eax
  801de9:	89 e9                	mov    %ebp,%ecx
  801deb:	d3 ea                	shr    %cl,%edx
  801ded:	89 e9                	mov    %ebp,%ecx
  801def:	d3 ee                	shr    %cl,%esi
  801df1:	09 d0                	or     %edx,%eax
  801df3:	89 f2                	mov    %esi,%edx
  801df5:	83 c4 1c             	add    $0x1c,%esp
  801df8:	5b                   	pop    %ebx
  801df9:	5e                   	pop    %esi
  801dfa:	5f                   	pop    %edi
  801dfb:	5d                   	pop    %ebp
  801dfc:	c3                   	ret    
  801dfd:	8d 76 00             	lea    0x0(%esi),%esi
  801e00:	29 f9                	sub    %edi,%ecx
  801e02:	19 d6                	sbb    %edx,%esi
  801e04:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e08:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e0c:	e9 18 ff ff ff       	jmp    801d29 <__umoddi3+0x69>
