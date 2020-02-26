
obj/user/faultwrite.debug：     文件格式 elf32-i386


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
	*(unsigned*)0 = 0;
  800036:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
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
  80005f:	a3 08 40 80 00       	mov    %eax,0x804008

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
  80008e:	e8 c6 04 00 00       	call   800559 <close_all>
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
  800107:	68 ea 22 80 00       	push   $0x8022ea
  80010c:	6a 23                	push   $0x23
  80010e:	68 07 23 80 00       	push   $0x802307
  800113:	e8 c7 13 00 00       	call   8014df <_panic>

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
  800188:	68 ea 22 80 00       	push   $0x8022ea
  80018d:	6a 23                	push   $0x23
  80018f:	68 07 23 80 00       	push   $0x802307
  800194:	e8 46 13 00 00       	call   8014df <_panic>

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
  8001ca:	68 ea 22 80 00       	push   $0x8022ea
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 07 23 80 00       	push   $0x802307
  8001d6:	e8 04 13 00 00       	call   8014df <_panic>

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
  80020c:	68 ea 22 80 00       	push   $0x8022ea
  800211:	6a 23                	push   $0x23
  800213:	68 07 23 80 00       	push   $0x802307
  800218:	e8 c2 12 00 00       	call   8014df <_panic>

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
  80024e:	68 ea 22 80 00       	push   $0x8022ea
  800253:	6a 23                	push   $0x23
  800255:	68 07 23 80 00       	push   $0x802307
  80025a:	e8 80 12 00 00       	call   8014df <_panic>

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
  800290:	68 ea 22 80 00       	push   $0x8022ea
  800295:	6a 23                	push   $0x23
  800297:	68 07 23 80 00       	push   $0x802307
  80029c:	e8 3e 12 00 00       	call   8014df <_panic>

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
  8002d2:	68 ea 22 80 00       	push   $0x8022ea
  8002d7:	6a 23                	push   $0x23
  8002d9:	68 07 23 80 00       	push   $0x802307
  8002de:	e8 fc 11 00 00       	call   8014df <_panic>

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
  800336:	68 ea 22 80 00       	push   $0x8022ea
  80033b:	6a 23                	push   $0x23
  80033d:	68 07 23 80 00       	push   $0x802307
  800342:	e8 98 11 00 00       	call   8014df <_panic>

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

0080034f <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	57                   	push   %edi
  800353:	56                   	push   %esi
  800354:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800355:	ba 00 00 00 00       	mov    $0x0,%edx
  80035a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80035f:	89 d1                	mov    %edx,%ecx
  800361:	89 d3                	mov    %edx,%ebx
  800363:	89 d7                	mov    %edx,%edi
  800365:	89 d6                	mov    %edx,%esi
  800367:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800369:	5b                   	pop    %ebx
  80036a:	5e                   	pop    %esi
  80036b:	5f                   	pop    %edi
  80036c:	5d                   	pop    %ebp
  80036d:	c3                   	ret    

0080036e <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	57                   	push   %edi
  800372:	56                   	push   %esi
  800373:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800374:	b9 00 00 00 00       	mov    $0x0,%ecx
  800379:	b8 10 00 00 00       	mov    $0x10,%eax
  80037e:	8b 55 08             	mov    0x8(%ebp),%edx
  800381:	89 cb                	mov    %ecx,%ebx
  800383:	89 cf                	mov    %ecx,%edi
  800385:	89 ce                	mov    %ecx,%esi
  800387:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800389:	5b                   	pop    %ebx
  80038a:	5e                   	pop    %esi
  80038b:	5f                   	pop    %edi
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800391:	8b 45 08             	mov    0x8(%ebp),%eax
  800394:	05 00 00 00 30       	add    $0x30000000,%eax
  800399:	c1 e8 0c             	shr    $0xc,%eax
}
  80039c:	5d                   	pop    %ebp
  80039d:	c3                   	ret    

0080039e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80039e:	55                   	push   %ebp
  80039f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a4:	05 00 00 00 30       	add    $0x30000000,%eax
  8003a9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003ae:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003b3:	5d                   	pop    %ebp
  8003b4:	c3                   	ret    

008003b5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003b5:	55                   	push   %ebp
  8003b6:	89 e5                	mov    %esp,%ebp
  8003b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003bb:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003c0:	89 c2                	mov    %eax,%edx
  8003c2:	c1 ea 16             	shr    $0x16,%edx
  8003c5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003cc:	f6 c2 01             	test   $0x1,%dl
  8003cf:	74 11                	je     8003e2 <fd_alloc+0x2d>
  8003d1:	89 c2                	mov    %eax,%edx
  8003d3:	c1 ea 0c             	shr    $0xc,%edx
  8003d6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003dd:	f6 c2 01             	test   $0x1,%dl
  8003e0:	75 09                	jne    8003eb <fd_alloc+0x36>
			*fd_store = fd;
  8003e2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e9:	eb 17                	jmp    800402 <fd_alloc+0x4d>
  8003eb:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003f0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003f5:	75 c9                	jne    8003c0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003f7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003fd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800402:	5d                   	pop    %ebp
  800403:	c3                   	ret    

00800404 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800404:	55                   	push   %ebp
  800405:	89 e5                	mov    %esp,%ebp
  800407:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80040a:	83 f8 1f             	cmp    $0x1f,%eax
  80040d:	77 36                	ja     800445 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80040f:	c1 e0 0c             	shl    $0xc,%eax
  800412:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800417:	89 c2                	mov    %eax,%edx
  800419:	c1 ea 16             	shr    $0x16,%edx
  80041c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800423:	f6 c2 01             	test   $0x1,%dl
  800426:	74 24                	je     80044c <fd_lookup+0x48>
  800428:	89 c2                	mov    %eax,%edx
  80042a:	c1 ea 0c             	shr    $0xc,%edx
  80042d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800434:	f6 c2 01             	test   $0x1,%dl
  800437:	74 1a                	je     800453 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800439:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043c:	89 02                	mov    %eax,(%edx)
	return 0;
  80043e:	b8 00 00 00 00       	mov    $0x0,%eax
  800443:	eb 13                	jmp    800458 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800445:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80044a:	eb 0c                	jmp    800458 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80044c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800451:	eb 05                	jmp    800458 <fd_lookup+0x54>
  800453:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800458:	5d                   	pop    %ebp
  800459:	c3                   	ret    

0080045a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80045a:	55                   	push   %ebp
  80045b:	89 e5                	mov    %esp,%ebp
  80045d:	83 ec 08             	sub    $0x8,%esp
  800460:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800463:	ba 94 23 80 00       	mov    $0x802394,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800468:	eb 13                	jmp    80047d <dev_lookup+0x23>
  80046a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80046d:	39 08                	cmp    %ecx,(%eax)
  80046f:	75 0c                	jne    80047d <dev_lookup+0x23>
			*dev = devtab[i];
  800471:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800474:	89 01                	mov    %eax,(%ecx)
			return 0;
  800476:	b8 00 00 00 00       	mov    $0x0,%eax
  80047b:	eb 2e                	jmp    8004ab <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80047d:	8b 02                	mov    (%edx),%eax
  80047f:	85 c0                	test   %eax,%eax
  800481:	75 e7                	jne    80046a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800483:	a1 08 40 80 00       	mov    0x804008,%eax
  800488:	8b 40 48             	mov    0x48(%eax),%eax
  80048b:	83 ec 04             	sub    $0x4,%esp
  80048e:	51                   	push   %ecx
  80048f:	50                   	push   %eax
  800490:	68 18 23 80 00       	push   $0x802318
  800495:	e8 1e 11 00 00       	call   8015b8 <cprintf>
	*dev = 0;
  80049a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80049d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004ab:	c9                   	leave  
  8004ac:	c3                   	ret    

008004ad <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004ad:	55                   	push   %ebp
  8004ae:	89 e5                	mov    %esp,%ebp
  8004b0:	56                   	push   %esi
  8004b1:	53                   	push   %ebx
  8004b2:	83 ec 10             	sub    $0x10,%esp
  8004b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004be:	50                   	push   %eax
  8004bf:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004c5:	c1 e8 0c             	shr    $0xc,%eax
  8004c8:	50                   	push   %eax
  8004c9:	e8 36 ff ff ff       	call   800404 <fd_lookup>
  8004ce:	83 c4 08             	add    $0x8,%esp
  8004d1:	85 c0                	test   %eax,%eax
  8004d3:	78 05                	js     8004da <fd_close+0x2d>
	    || fd != fd2)
  8004d5:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004d8:	74 0c                	je     8004e6 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004da:	84 db                	test   %bl,%bl
  8004dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e1:	0f 44 c2             	cmove  %edx,%eax
  8004e4:	eb 41                	jmp    800527 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004ec:	50                   	push   %eax
  8004ed:	ff 36                	pushl  (%esi)
  8004ef:	e8 66 ff ff ff       	call   80045a <dev_lookup>
  8004f4:	89 c3                	mov    %eax,%ebx
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	85 c0                	test   %eax,%eax
  8004fb:	78 1a                	js     800517 <fd_close+0x6a>
		if (dev->dev_close)
  8004fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800500:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800503:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800508:	85 c0                	test   %eax,%eax
  80050a:	74 0b                	je     800517 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80050c:	83 ec 0c             	sub    $0xc,%esp
  80050f:	56                   	push   %esi
  800510:	ff d0                	call   *%eax
  800512:	89 c3                	mov    %eax,%ebx
  800514:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800517:	83 ec 08             	sub    $0x8,%esp
  80051a:	56                   	push   %esi
  80051b:	6a 00                	push   $0x0
  80051d:	e8 c1 fc ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  800522:	83 c4 10             	add    $0x10,%esp
  800525:	89 d8                	mov    %ebx,%eax
}
  800527:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80052a:	5b                   	pop    %ebx
  80052b:	5e                   	pop    %esi
  80052c:	5d                   	pop    %ebp
  80052d:	c3                   	ret    

0080052e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80052e:	55                   	push   %ebp
  80052f:	89 e5                	mov    %esp,%ebp
  800531:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800534:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800537:	50                   	push   %eax
  800538:	ff 75 08             	pushl  0x8(%ebp)
  80053b:	e8 c4 fe ff ff       	call   800404 <fd_lookup>
  800540:	83 c4 08             	add    $0x8,%esp
  800543:	85 c0                	test   %eax,%eax
  800545:	78 10                	js     800557 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800547:	83 ec 08             	sub    $0x8,%esp
  80054a:	6a 01                	push   $0x1
  80054c:	ff 75 f4             	pushl  -0xc(%ebp)
  80054f:	e8 59 ff ff ff       	call   8004ad <fd_close>
  800554:	83 c4 10             	add    $0x10,%esp
}
  800557:	c9                   	leave  
  800558:	c3                   	ret    

00800559 <close_all>:

void
close_all(void)
{
  800559:	55                   	push   %ebp
  80055a:	89 e5                	mov    %esp,%ebp
  80055c:	53                   	push   %ebx
  80055d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800560:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800565:	83 ec 0c             	sub    $0xc,%esp
  800568:	53                   	push   %ebx
  800569:	e8 c0 ff ff ff       	call   80052e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80056e:	83 c3 01             	add    $0x1,%ebx
  800571:	83 c4 10             	add    $0x10,%esp
  800574:	83 fb 20             	cmp    $0x20,%ebx
  800577:	75 ec                	jne    800565 <close_all+0xc>
		close(i);
}
  800579:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80057c:	c9                   	leave  
  80057d:	c3                   	ret    

0080057e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80057e:	55                   	push   %ebp
  80057f:	89 e5                	mov    %esp,%ebp
  800581:	57                   	push   %edi
  800582:	56                   	push   %esi
  800583:	53                   	push   %ebx
  800584:	83 ec 2c             	sub    $0x2c,%esp
  800587:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80058a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80058d:	50                   	push   %eax
  80058e:	ff 75 08             	pushl  0x8(%ebp)
  800591:	e8 6e fe ff ff       	call   800404 <fd_lookup>
  800596:	83 c4 08             	add    $0x8,%esp
  800599:	85 c0                	test   %eax,%eax
  80059b:	0f 88 c1 00 00 00    	js     800662 <dup+0xe4>
		return r;
	close(newfdnum);
  8005a1:	83 ec 0c             	sub    $0xc,%esp
  8005a4:	56                   	push   %esi
  8005a5:	e8 84 ff ff ff       	call   80052e <close>

	newfd = INDEX2FD(newfdnum);
  8005aa:	89 f3                	mov    %esi,%ebx
  8005ac:	c1 e3 0c             	shl    $0xc,%ebx
  8005af:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005b5:	83 c4 04             	add    $0x4,%esp
  8005b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005bb:	e8 de fd ff ff       	call   80039e <fd2data>
  8005c0:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005c2:	89 1c 24             	mov    %ebx,(%esp)
  8005c5:	e8 d4 fd ff ff       	call   80039e <fd2data>
  8005ca:	83 c4 10             	add    $0x10,%esp
  8005cd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005d0:	89 f8                	mov    %edi,%eax
  8005d2:	c1 e8 16             	shr    $0x16,%eax
  8005d5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005dc:	a8 01                	test   $0x1,%al
  8005de:	74 37                	je     800617 <dup+0x99>
  8005e0:	89 f8                	mov    %edi,%eax
  8005e2:	c1 e8 0c             	shr    $0xc,%eax
  8005e5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005ec:	f6 c2 01             	test   $0x1,%dl
  8005ef:	74 26                	je     800617 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f8:	83 ec 0c             	sub    $0xc,%esp
  8005fb:	25 07 0e 00 00       	and    $0xe07,%eax
  800600:	50                   	push   %eax
  800601:	ff 75 d4             	pushl  -0x2c(%ebp)
  800604:	6a 00                	push   $0x0
  800606:	57                   	push   %edi
  800607:	6a 00                	push   $0x0
  800609:	e8 93 fb ff ff       	call   8001a1 <sys_page_map>
  80060e:	89 c7                	mov    %eax,%edi
  800610:	83 c4 20             	add    $0x20,%esp
  800613:	85 c0                	test   %eax,%eax
  800615:	78 2e                	js     800645 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800617:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80061a:	89 d0                	mov    %edx,%eax
  80061c:	c1 e8 0c             	shr    $0xc,%eax
  80061f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800626:	83 ec 0c             	sub    $0xc,%esp
  800629:	25 07 0e 00 00       	and    $0xe07,%eax
  80062e:	50                   	push   %eax
  80062f:	53                   	push   %ebx
  800630:	6a 00                	push   $0x0
  800632:	52                   	push   %edx
  800633:	6a 00                	push   $0x0
  800635:	e8 67 fb ff ff       	call   8001a1 <sys_page_map>
  80063a:	89 c7                	mov    %eax,%edi
  80063c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80063f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800641:	85 ff                	test   %edi,%edi
  800643:	79 1d                	jns    800662 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800645:	83 ec 08             	sub    $0x8,%esp
  800648:	53                   	push   %ebx
  800649:	6a 00                	push   $0x0
  80064b:	e8 93 fb ff ff       	call   8001e3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800650:	83 c4 08             	add    $0x8,%esp
  800653:	ff 75 d4             	pushl  -0x2c(%ebp)
  800656:	6a 00                	push   $0x0
  800658:	e8 86 fb ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  80065d:	83 c4 10             	add    $0x10,%esp
  800660:	89 f8                	mov    %edi,%eax
}
  800662:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800665:	5b                   	pop    %ebx
  800666:	5e                   	pop    %esi
  800667:	5f                   	pop    %edi
  800668:	5d                   	pop    %ebp
  800669:	c3                   	ret    

0080066a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80066a:	55                   	push   %ebp
  80066b:	89 e5                	mov    %esp,%ebp
  80066d:	53                   	push   %ebx
  80066e:	83 ec 14             	sub    $0x14,%esp
  800671:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800674:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800677:	50                   	push   %eax
  800678:	53                   	push   %ebx
  800679:	e8 86 fd ff ff       	call   800404 <fd_lookup>
  80067e:	83 c4 08             	add    $0x8,%esp
  800681:	89 c2                	mov    %eax,%edx
  800683:	85 c0                	test   %eax,%eax
  800685:	78 6d                	js     8006f4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80068d:	50                   	push   %eax
  80068e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800691:	ff 30                	pushl  (%eax)
  800693:	e8 c2 fd ff ff       	call   80045a <dev_lookup>
  800698:	83 c4 10             	add    $0x10,%esp
  80069b:	85 c0                	test   %eax,%eax
  80069d:	78 4c                	js     8006eb <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80069f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006a2:	8b 42 08             	mov    0x8(%edx),%eax
  8006a5:	83 e0 03             	and    $0x3,%eax
  8006a8:	83 f8 01             	cmp    $0x1,%eax
  8006ab:	75 21                	jne    8006ce <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006ad:	a1 08 40 80 00       	mov    0x804008,%eax
  8006b2:	8b 40 48             	mov    0x48(%eax),%eax
  8006b5:	83 ec 04             	sub    $0x4,%esp
  8006b8:	53                   	push   %ebx
  8006b9:	50                   	push   %eax
  8006ba:	68 59 23 80 00       	push   $0x802359
  8006bf:	e8 f4 0e 00 00       	call   8015b8 <cprintf>
		return -E_INVAL;
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006cc:	eb 26                	jmp    8006f4 <read+0x8a>
	}
	if (!dev->dev_read)
  8006ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d1:	8b 40 08             	mov    0x8(%eax),%eax
  8006d4:	85 c0                	test   %eax,%eax
  8006d6:	74 17                	je     8006ef <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006d8:	83 ec 04             	sub    $0x4,%esp
  8006db:	ff 75 10             	pushl  0x10(%ebp)
  8006de:	ff 75 0c             	pushl  0xc(%ebp)
  8006e1:	52                   	push   %edx
  8006e2:	ff d0                	call   *%eax
  8006e4:	89 c2                	mov    %eax,%edx
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	eb 09                	jmp    8006f4 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006eb:	89 c2                	mov    %eax,%edx
  8006ed:	eb 05                	jmp    8006f4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006ef:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006f4:	89 d0                	mov    %edx,%eax
  8006f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f9:	c9                   	leave  
  8006fa:	c3                   	ret    

008006fb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006fb:	55                   	push   %ebp
  8006fc:	89 e5                	mov    %esp,%ebp
  8006fe:	57                   	push   %edi
  8006ff:	56                   	push   %esi
  800700:	53                   	push   %ebx
  800701:	83 ec 0c             	sub    $0xc,%esp
  800704:	8b 7d 08             	mov    0x8(%ebp),%edi
  800707:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80070a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80070f:	eb 21                	jmp    800732 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800711:	83 ec 04             	sub    $0x4,%esp
  800714:	89 f0                	mov    %esi,%eax
  800716:	29 d8                	sub    %ebx,%eax
  800718:	50                   	push   %eax
  800719:	89 d8                	mov    %ebx,%eax
  80071b:	03 45 0c             	add    0xc(%ebp),%eax
  80071e:	50                   	push   %eax
  80071f:	57                   	push   %edi
  800720:	e8 45 ff ff ff       	call   80066a <read>
		if (m < 0)
  800725:	83 c4 10             	add    $0x10,%esp
  800728:	85 c0                	test   %eax,%eax
  80072a:	78 10                	js     80073c <readn+0x41>
			return m;
		if (m == 0)
  80072c:	85 c0                	test   %eax,%eax
  80072e:	74 0a                	je     80073a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800730:	01 c3                	add    %eax,%ebx
  800732:	39 f3                	cmp    %esi,%ebx
  800734:	72 db                	jb     800711 <readn+0x16>
  800736:	89 d8                	mov    %ebx,%eax
  800738:	eb 02                	jmp    80073c <readn+0x41>
  80073a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80073c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80073f:	5b                   	pop    %ebx
  800740:	5e                   	pop    %esi
  800741:	5f                   	pop    %edi
  800742:	5d                   	pop    %ebp
  800743:	c3                   	ret    

00800744 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800744:	55                   	push   %ebp
  800745:	89 e5                	mov    %esp,%ebp
  800747:	53                   	push   %ebx
  800748:	83 ec 14             	sub    $0x14,%esp
  80074b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80074e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800751:	50                   	push   %eax
  800752:	53                   	push   %ebx
  800753:	e8 ac fc ff ff       	call   800404 <fd_lookup>
  800758:	83 c4 08             	add    $0x8,%esp
  80075b:	89 c2                	mov    %eax,%edx
  80075d:	85 c0                	test   %eax,%eax
  80075f:	78 68                	js     8007c9 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800761:	83 ec 08             	sub    $0x8,%esp
  800764:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800767:	50                   	push   %eax
  800768:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80076b:	ff 30                	pushl  (%eax)
  80076d:	e8 e8 fc ff ff       	call   80045a <dev_lookup>
  800772:	83 c4 10             	add    $0x10,%esp
  800775:	85 c0                	test   %eax,%eax
  800777:	78 47                	js     8007c0 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800779:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80077c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800780:	75 21                	jne    8007a3 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800782:	a1 08 40 80 00       	mov    0x804008,%eax
  800787:	8b 40 48             	mov    0x48(%eax),%eax
  80078a:	83 ec 04             	sub    $0x4,%esp
  80078d:	53                   	push   %ebx
  80078e:	50                   	push   %eax
  80078f:	68 75 23 80 00       	push   $0x802375
  800794:	e8 1f 0e 00 00       	call   8015b8 <cprintf>
		return -E_INVAL;
  800799:	83 c4 10             	add    $0x10,%esp
  80079c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007a1:	eb 26                	jmp    8007c9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007a6:	8b 52 0c             	mov    0xc(%edx),%edx
  8007a9:	85 d2                	test   %edx,%edx
  8007ab:	74 17                	je     8007c4 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007ad:	83 ec 04             	sub    $0x4,%esp
  8007b0:	ff 75 10             	pushl  0x10(%ebp)
  8007b3:	ff 75 0c             	pushl  0xc(%ebp)
  8007b6:	50                   	push   %eax
  8007b7:	ff d2                	call   *%edx
  8007b9:	89 c2                	mov    %eax,%edx
  8007bb:	83 c4 10             	add    $0x10,%esp
  8007be:	eb 09                	jmp    8007c9 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c0:	89 c2                	mov    %eax,%edx
  8007c2:	eb 05                	jmp    8007c9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007c4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007c9:	89 d0                	mov    %edx,%eax
  8007cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ce:	c9                   	leave  
  8007cf:	c3                   	ret    

008007d0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007d6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007d9:	50                   	push   %eax
  8007da:	ff 75 08             	pushl  0x8(%ebp)
  8007dd:	e8 22 fc ff ff       	call   800404 <fd_lookup>
  8007e2:	83 c4 08             	add    $0x8,%esp
  8007e5:	85 c0                	test   %eax,%eax
  8007e7:	78 0e                	js     8007f7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ef:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007f7:	c9                   	leave  
  8007f8:	c3                   	ret    

008007f9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	53                   	push   %ebx
  8007fd:	83 ec 14             	sub    $0x14,%esp
  800800:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800803:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800806:	50                   	push   %eax
  800807:	53                   	push   %ebx
  800808:	e8 f7 fb ff ff       	call   800404 <fd_lookup>
  80080d:	83 c4 08             	add    $0x8,%esp
  800810:	89 c2                	mov    %eax,%edx
  800812:	85 c0                	test   %eax,%eax
  800814:	78 65                	js     80087b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800816:	83 ec 08             	sub    $0x8,%esp
  800819:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80081c:	50                   	push   %eax
  80081d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800820:	ff 30                	pushl  (%eax)
  800822:	e8 33 fc ff ff       	call   80045a <dev_lookup>
  800827:	83 c4 10             	add    $0x10,%esp
  80082a:	85 c0                	test   %eax,%eax
  80082c:	78 44                	js     800872 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80082e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800831:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800835:	75 21                	jne    800858 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800837:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80083c:	8b 40 48             	mov    0x48(%eax),%eax
  80083f:	83 ec 04             	sub    $0x4,%esp
  800842:	53                   	push   %ebx
  800843:	50                   	push   %eax
  800844:	68 38 23 80 00       	push   $0x802338
  800849:	e8 6a 0d 00 00       	call   8015b8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80084e:	83 c4 10             	add    $0x10,%esp
  800851:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800856:	eb 23                	jmp    80087b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800858:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80085b:	8b 52 18             	mov    0x18(%edx),%edx
  80085e:	85 d2                	test   %edx,%edx
  800860:	74 14                	je     800876 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800862:	83 ec 08             	sub    $0x8,%esp
  800865:	ff 75 0c             	pushl  0xc(%ebp)
  800868:	50                   	push   %eax
  800869:	ff d2                	call   *%edx
  80086b:	89 c2                	mov    %eax,%edx
  80086d:	83 c4 10             	add    $0x10,%esp
  800870:	eb 09                	jmp    80087b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800872:	89 c2                	mov    %eax,%edx
  800874:	eb 05                	jmp    80087b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800876:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80087b:	89 d0                	mov    %edx,%eax
  80087d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800880:	c9                   	leave  
  800881:	c3                   	ret    

00800882 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800882:	55                   	push   %ebp
  800883:	89 e5                	mov    %esp,%ebp
  800885:	53                   	push   %ebx
  800886:	83 ec 14             	sub    $0x14,%esp
  800889:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80088c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80088f:	50                   	push   %eax
  800890:	ff 75 08             	pushl  0x8(%ebp)
  800893:	e8 6c fb ff ff       	call   800404 <fd_lookup>
  800898:	83 c4 08             	add    $0x8,%esp
  80089b:	89 c2                	mov    %eax,%edx
  80089d:	85 c0                	test   %eax,%eax
  80089f:	78 58                	js     8008f9 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a1:	83 ec 08             	sub    $0x8,%esp
  8008a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a7:	50                   	push   %eax
  8008a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008ab:	ff 30                	pushl  (%eax)
  8008ad:	e8 a8 fb ff ff       	call   80045a <dev_lookup>
  8008b2:	83 c4 10             	add    $0x10,%esp
  8008b5:	85 c0                	test   %eax,%eax
  8008b7:	78 37                	js     8008f0 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008bc:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008c0:	74 32                	je     8008f4 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008c2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008c5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008cc:	00 00 00 
	stat->st_isdir = 0;
  8008cf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008d6:	00 00 00 
	stat->st_dev = dev;
  8008d9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008df:	83 ec 08             	sub    $0x8,%esp
  8008e2:	53                   	push   %ebx
  8008e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8008e6:	ff 50 14             	call   *0x14(%eax)
  8008e9:	89 c2                	mov    %eax,%edx
  8008eb:	83 c4 10             	add    $0x10,%esp
  8008ee:	eb 09                	jmp    8008f9 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008f0:	89 c2                	mov    %eax,%edx
  8008f2:	eb 05                	jmp    8008f9 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008f4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008f9:	89 d0                	mov    %edx,%eax
  8008fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008fe:	c9                   	leave  
  8008ff:	c3                   	ret    

00800900 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800900:	55                   	push   %ebp
  800901:	89 e5                	mov    %esp,%ebp
  800903:	56                   	push   %esi
  800904:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800905:	83 ec 08             	sub    $0x8,%esp
  800908:	6a 00                	push   $0x0
  80090a:	ff 75 08             	pushl  0x8(%ebp)
  80090d:	e8 e3 01 00 00       	call   800af5 <open>
  800912:	89 c3                	mov    %eax,%ebx
  800914:	83 c4 10             	add    $0x10,%esp
  800917:	85 c0                	test   %eax,%eax
  800919:	78 1b                	js     800936 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80091b:	83 ec 08             	sub    $0x8,%esp
  80091e:	ff 75 0c             	pushl  0xc(%ebp)
  800921:	50                   	push   %eax
  800922:	e8 5b ff ff ff       	call   800882 <fstat>
  800927:	89 c6                	mov    %eax,%esi
	close(fd);
  800929:	89 1c 24             	mov    %ebx,(%esp)
  80092c:	e8 fd fb ff ff       	call   80052e <close>
	return r;
  800931:	83 c4 10             	add    $0x10,%esp
  800934:	89 f0                	mov    %esi,%eax
}
  800936:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800939:	5b                   	pop    %ebx
  80093a:	5e                   	pop    %esi
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	56                   	push   %esi
  800941:	53                   	push   %ebx
  800942:	89 c6                	mov    %eax,%esi
  800944:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800946:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80094d:	75 12                	jne    800961 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80094f:	83 ec 0c             	sub    $0xc,%esp
  800952:	6a 01                	push   $0x1
  800954:	e8 67 16 00 00       	call   801fc0 <ipc_find_env>
  800959:	a3 00 40 80 00       	mov    %eax,0x804000
  80095e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800961:	6a 07                	push   $0x7
  800963:	68 00 50 80 00       	push   $0x805000
  800968:	56                   	push   %esi
  800969:	ff 35 00 40 80 00    	pushl  0x804000
  80096f:	e8 f8 15 00 00       	call   801f6c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800974:	83 c4 0c             	add    $0xc,%esp
  800977:	6a 00                	push   $0x0
  800979:	53                   	push   %ebx
  80097a:	6a 00                	push   $0x0
  80097c:	e8 82 15 00 00       	call   801f03 <ipc_recv>
}
  800981:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800984:	5b                   	pop    %ebx
  800985:	5e                   	pop    %esi
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	8b 40 0c             	mov    0xc(%eax),%eax
  800994:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800999:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a6:	b8 02 00 00 00       	mov    $0x2,%eax
  8009ab:	e8 8d ff ff ff       	call   80093d <fsipc>
}
  8009b0:	c9                   	leave  
  8009b1:	c3                   	ret    

008009b2 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8009be:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c8:	b8 06 00 00 00       	mov    $0x6,%eax
  8009cd:	e8 6b ff ff ff       	call   80093d <fsipc>
}
  8009d2:	c9                   	leave  
  8009d3:	c3                   	ret    

008009d4 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	53                   	push   %ebx
  8009d8:	83 ec 04             	sub    $0x4,%esp
  8009db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e4:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ee:	b8 05 00 00 00       	mov    $0x5,%eax
  8009f3:	e8 45 ff ff ff       	call   80093d <fsipc>
  8009f8:	85 c0                	test   %eax,%eax
  8009fa:	78 2c                	js     800a28 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009fc:	83 ec 08             	sub    $0x8,%esp
  8009ff:	68 00 50 80 00       	push   $0x805000
  800a04:	53                   	push   %ebx
  800a05:	e8 b2 11 00 00       	call   801bbc <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a0a:	a1 80 50 80 00       	mov    0x805080,%eax
  800a0f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a15:	a1 84 50 80 00       	mov    0x805084,%eax
  800a1a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a20:	83 c4 10             	add    $0x10,%esp
  800a23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a2b:	c9                   	leave  
  800a2c:	c3                   	ret    

00800a2d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a2d:	55                   	push   %ebp
  800a2e:	89 e5                	mov    %esp,%ebp
  800a30:	83 ec 0c             	sub    $0xc,%esp
  800a33:	8b 45 10             	mov    0x10(%ebp),%eax
  800a36:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a3b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a40:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a43:	8b 55 08             	mov    0x8(%ebp),%edx
  800a46:	8b 52 0c             	mov    0xc(%edx),%edx
  800a49:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a4f:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a54:	50                   	push   %eax
  800a55:	ff 75 0c             	pushl  0xc(%ebp)
  800a58:	68 08 50 80 00       	push   $0x805008
  800a5d:	e8 ec 12 00 00       	call   801d4e <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a62:	ba 00 00 00 00       	mov    $0x0,%edx
  800a67:	b8 04 00 00 00       	mov    $0x4,%eax
  800a6c:	e8 cc fe ff ff       	call   80093d <fsipc>
	//panic("devfile_write not implemented");
}
  800a71:	c9                   	leave  
  800a72:	c3                   	ret    

00800a73 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	56                   	push   %esi
  800a77:	53                   	push   %ebx
  800a78:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	8b 40 0c             	mov    0xc(%eax),%eax
  800a81:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a86:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a8c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a91:	b8 03 00 00 00       	mov    $0x3,%eax
  800a96:	e8 a2 fe ff ff       	call   80093d <fsipc>
  800a9b:	89 c3                	mov    %eax,%ebx
  800a9d:	85 c0                	test   %eax,%eax
  800a9f:	78 4b                	js     800aec <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aa1:	39 c6                	cmp    %eax,%esi
  800aa3:	73 16                	jae    800abb <devfile_read+0x48>
  800aa5:	68 a8 23 80 00       	push   $0x8023a8
  800aaa:	68 af 23 80 00       	push   $0x8023af
  800aaf:	6a 7c                	push   $0x7c
  800ab1:	68 c4 23 80 00       	push   $0x8023c4
  800ab6:	e8 24 0a 00 00       	call   8014df <_panic>
	assert(r <= PGSIZE);
  800abb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ac0:	7e 16                	jle    800ad8 <devfile_read+0x65>
  800ac2:	68 cf 23 80 00       	push   $0x8023cf
  800ac7:	68 af 23 80 00       	push   $0x8023af
  800acc:	6a 7d                	push   $0x7d
  800ace:	68 c4 23 80 00       	push   $0x8023c4
  800ad3:	e8 07 0a 00 00       	call   8014df <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ad8:	83 ec 04             	sub    $0x4,%esp
  800adb:	50                   	push   %eax
  800adc:	68 00 50 80 00       	push   $0x805000
  800ae1:	ff 75 0c             	pushl  0xc(%ebp)
  800ae4:	e8 65 12 00 00       	call   801d4e <memmove>
	return r;
  800ae9:	83 c4 10             	add    $0x10,%esp
}
  800aec:	89 d8                	mov    %ebx,%eax
  800aee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	53                   	push   %ebx
  800af9:	83 ec 20             	sub    $0x20,%esp
  800afc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800aff:	53                   	push   %ebx
  800b00:	e8 7e 10 00 00       	call   801b83 <strlen>
  800b05:	83 c4 10             	add    $0x10,%esp
  800b08:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b0d:	7f 67                	jg     800b76 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b0f:	83 ec 0c             	sub    $0xc,%esp
  800b12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b15:	50                   	push   %eax
  800b16:	e8 9a f8 ff ff       	call   8003b5 <fd_alloc>
  800b1b:	83 c4 10             	add    $0x10,%esp
		return r;
  800b1e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b20:	85 c0                	test   %eax,%eax
  800b22:	78 57                	js     800b7b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b24:	83 ec 08             	sub    $0x8,%esp
  800b27:	53                   	push   %ebx
  800b28:	68 00 50 80 00       	push   $0x805000
  800b2d:	e8 8a 10 00 00       	call   801bbc <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b35:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b3d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b42:	e8 f6 fd ff ff       	call   80093d <fsipc>
  800b47:	89 c3                	mov    %eax,%ebx
  800b49:	83 c4 10             	add    $0x10,%esp
  800b4c:	85 c0                	test   %eax,%eax
  800b4e:	79 14                	jns    800b64 <open+0x6f>
		fd_close(fd, 0);
  800b50:	83 ec 08             	sub    $0x8,%esp
  800b53:	6a 00                	push   $0x0
  800b55:	ff 75 f4             	pushl  -0xc(%ebp)
  800b58:	e8 50 f9 ff ff       	call   8004ad <fd_close>
		return r;
  800b5d:	83 c4 10             	add    $0x10,%esp
  800b60:	89 da                	mov    %ebx,%edx
  800b62:	eb 17                	jmp    800b7b <open+0x86>
	}

	return fd2num(fd);
  800b64:	83 ec 0c             	sub    $0xc,%esp
  800b67:	ff 75 f4             	pushl  -0xc(%ebp)
  800b6a:	e8 1f f8 ff ff       	call   80038e <fd2num>
  800b6f:	89 c2                	mov    %eax,%edx
  800b71:	83 c4 10             	add    $0x10,%esp
  800b74:	eb 05                	jmp    800b7b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b76:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b7b:	89 d0                	mov    %edx,%eax
  800b7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b80:	c9                   	leave  
  800b81:	c3                   	ret    

00800b82 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b88:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8d:	b8 08 00 00 00       	mov    $0x8,%eax
  800b92:	e8 a6 fd ff ff       	call   80093d <fsipc>
}
  800b97:	c9                   	leave  
  800b98:	c3                   	ret    

00800b99 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b9f:	68 db 23 80 00       	push   $0x8023db
  800ba4:	ff 75 0c             	pushl  0xc(%ebp)
  800ba7:	e8 10 10 00 00       	call   801bbc <strcpy>
	return 0;
}
  800bac:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb1:	c9                   	leave  
  800bb2:	c3                   	ret    

00800bb3 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	53                   	push   %ebx
  800bb7:	83 ec 10             	sub    $0x10,%esp
  800bba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bbd:	53                   	push   %ebx
  800bbe:	e8 36 14 00 00       	call   801ff9 <pageref>
  800bc3:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bc6:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800bcb:	83 f8 01             	cmp    $0x1,%eax
  800bce:	75 10                	jne    800be0 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800bd0:	83 ec 0c             	sub    $0xc,%esp
  800bd3:	ff 73 0c             	pushl  0xc(%ebx)
  800bd6:	e8 c0 02 00 00       	call   800e9b <nsipc_close>
  800bdb:	89 c2                	mov    %eax,%edx
  800bdd:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800be0:	89 d0                	mov    %edx,%eax
  800be2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be5:	c9                   	leave  
  800be6:	c3                   	ret    

00800be7 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bed:	6a 00                	push   $0x0
  800bef:	ff 75 10             	pushl  0x10(%ebp)
  800bf2:	ff 75 0c             	pushl  0xc(%ebp)
  800bf5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf8:	ff 70 0c             	pushl  0xc(%eax)
  800bfb:	e8 78 03 00 00       	call   800f78 <nsipc_send>
}
  800c00:	c9                   	leave  
  800c01:	c3                   	ret    

00800c02 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c08:	6a 00                	push   $0x0
  800c0a:	ff 75 10             	pushl  0x10(%ebp)
  800c0d:	ff 75 0c             	pushl  0xc(%ebp)
  800c10:	8b 45 08             	mov    0x8(%ebp),%eax
  800c13:	ff 70 0c             	pushl  0xc(%eax)
  800c16:	e8 f1 02 00 00       	call   800f0c <nsipc_recv>
}
  800c1b:	c9                   	leave  
  800c1c:	c3                   	ret    

00800c1d <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c1d:	55                   	push   %ebp
  800c1e:	89 e5                	mov    %esp,%ebp
  800c20:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c23:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c26:	52                   	push   %edx
  800c27:	50                   	push   %eax
  800c28:	e8 d7 f7 ff ff       	call   800404 <fd_lookup>
  800c2d:	83 c4 10             	add    $0x10,%esp
  800c30:	85 c0                	test   %eax,%eax
  800c32:	78 17                	js     800c4b <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c37:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c3d:	39 08                	cmp    %ecx,(%eax)
  800c3f:	75 05                	jne    800c46 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c41:	8b 40 0c             	mov    0xc(%eax),%eax
  800c44:	eb 05                	jmp    800c4b <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c46:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c4b:	c9                   	leave  
  800c4c:	c3                   	ret    

00800c4d <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
  800c52:	83 ec 1c             	sub    $0x1c,%esp
  800c55:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c5a:	50                   	push   %eax
  800c5b:	e8 55 f7 ff ff       	call   8003b5 <fd_alloc>
  800c60:	89 c3                	mov    %eax,%ebx
  800c62:	83 c4 10             	add    $0x10,%esp
  800c65:	85 c0                	test   %eax,%eax
  800c67:	78 1b                	js     800c84 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c69:	83 ec 04             	sub    $0x4,%esp
  800c6c:	68 07 04 00 00       	push   $0x407
  800c71:	ff 75 f4             	pushl  -0xc(%ebp)
  800c74:	6a 00                	push   $0x0
  800c76:	e8 e3 f4 ff ff       	call   80015e <sys_page_alloc>
  800c7b:	89 c3                	mov    %eax,%ebx
  800c7d:	83 c4 10             	add    $0x10,%esp
  800c80:	85 c0                	test   %eax,%eax
  800c82:	79 10                	jns    800c94 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c84:	83 ec 0c             	sub    $0xc,%esp
  800c87:	56                   	push   %esi
  800c88:	e8 0e 02 00 00       	call   800e9b <nsipc_close>
		return r;
  800c8d:	83 c4 10             	add    $0x10,%esp
  800c90:	89 d8                	mov    %ebx,%eax
  800c92:	eb 24                	jmp    800cb8 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800c94:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c9d:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800ca9:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cac:	83 ec 0c             	sub    $0xc,%esp
  800caf:	50                   	push   %eax
  800cb0:	e8 d9 f6 ff ff       	call   80038e <fd2num>
  800cb5:	83 c4 10             	add    $0x10,%esp
}
  800cb8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5d                   	pop    %ebp
  800cbe:	c3                   	ret    

00800cbf <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc8:	e8 50 ff ff ff       	call   800c1d <fd2sockid>
		return r;
  800ccd:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800ccf:	85 c0                	test   %eax,%eax
  800cd1:	78 1f                	js     800cf2 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cd3:	83 ec 04             	sub    $0x4,%esp
  800cd6:	ff 75 10             	pushl  0x10(%ebp)
  800cd9:	ff 75 0c             	pushl  0xc(%ebp)
  800cdc:	50                   	push   %eax
  800cdd:	e8 12 01 00 00       	call   800df4 <nsipc_accept>
  800ce2:	83 c4 10             	add    $0x10,%esp
		return r;
  800ce5:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800ce7:	85 c0                	test   %eax,%eax
  800ce9:	78 07                	js     800cf2 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800ceb:	e8 5d ff ff ff       	call   800c4d <alloc_sockfd>
  800cf0:	89 c1                	mov    %eax,%ecx
}
  800cf2:	89 c8                	mov    %ecx,%eax
  800cf4:	c9                   	leave  
  800cf5:	c3                   	ret    

00800cf6 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cff:	e8 19 ff ff ff       	call   800c1d <fd2sockid>
  800d04:	85 c0                	test   %eax,%eax
  800d06:	78 12                	js     800d1a <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d08:	83 ec 04             	sub    $0x4,%esp
  800d0b:	ff 75 10             	pushl  0x10(%ebp)
  800d0e:	ff 75 0c             	pushl  0xc(%ebp)
  800d11:	50                   	push   %eax
  800d12:	e8 2d 01 00 00       	call   800e44 <nsipc_bind>
  800d17:	83 c4 10             	add    $0x10,%esp
}
  800d1a:	c9                   	leave  
  800d1b:	c3                   	ret    

00800d1c <shutdown>:

int
shutdown(int s, int how)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d22:	8b 45 08             	mov    0x8(%ebp),%eax
  800d25:	e8 f3 fe ff ff       	call   800c1d <fd2sockid>
  800d2a:	85 c0                	test   %eax,%eax
  800d2c:	78 0f                	js     800d3d <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d2e:	83 ec 08             	sub    $0x8,%esp
  800d31:	ff 75 0c             	pushl  0xc(%ebp)
  800d34:	50                   	push   %eax
  800d35:	e8 3f 01 00 00       	call   800e79 <nsipc_shutdown>
  800d3a:	83 c4 10             	add    $0x10,%esp
}
  800d3d:	c9                   	leave  
  800d3e:	c3                   	ret    

00800d3f <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d45:	8b 45 08             	mov    0x8(%ebp),%eax
  800d48:	e8 d0 fe ff ff       	call   800c1d <fd2sockid>
  800d4d:	85 c0                	test   %eax,%eax
  800d4f:	78 12                	js     800d63 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d51:	83 ec 04             	sub    $0x4,%esp
  800d54:	ff 75 10             	pushl  0x10(%ebp)
  800d57:	ff 75 0c             	pushl  0xc(%ebp)
  800d5a:	50                   	push   %eax
  800d5b:	e8 55 01 00 00       	call   800eb5 <nsipc_connect>
  800d60:	83 c4 10             	add    $0x10,%esp
}
  800d63:	c9                   	leave  
  800d64:	c3                   	ret    

00800d65 <listen>:

int
listen(int s, int backlog)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6e:	e8 aa fe ff ff       	call   800c1d <fd2sockid>
  800d73:	85 c0                	test   %eax,%eax
  800d75:	78 0f                	js     800d86 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d77:	83 ec 08             	sub    $0x8,%esp
  800d7a:	ff 75 0c             	pushl  0xc(%ebp)
  800d7d:	50                   	push   %eax
  800d7e:	e8 67 01 00 00       	call   800eea <nsipc_listen>
  800d83:	83 c4 10             	add    $0x10,%esp
}
  800d86:	c9                   	leave  
  800d87:	c3                   	ret    

00800d88 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d8e:	ff 75 10             	pushl  0x10(%ebp)
  800d91:	ff 75 0c             	pushl  0xc(%ebp)
  800d94:	ff 75 08             	pushl  0x8(%ebp)
  800d97:	e8 3a 02 00 00       	call   800fd6 <nsipc_socket>
  800d9c:	83 c4 10             	add    $0x10,%esp
  800d9f:	85 c0                	test   %eax,%eax
  800da1:	78 05                	js     800da8 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800da3:	e8 a5 fe ff ff       	call   800c4d <alloc_sockfd>
}
  800da8:	c9                   	leave  
  800da9:	c3                   	ret    

00800daa <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	53                   	push   %ebx
  800dae:	83 ec 04             	sub    $0x4,%esp
  800db1:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800db3:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dba:	75 12                	jne    800dce <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dbc:	83 ec 0c             	sub    $0xc,%esp
  800dbf:	6a 02                	push   $0x2
  800dc1:	e8 fa 11 00 00       	call   801fc0 <ipc_find_env>
  800dc6:	a3 04 40 80 00       	mov    %eax,0x804004
  800dcb:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dce:	6a 07                	push   $0x7
  800dd0:	68 00 60 80 00       	push   $0x806000
  800dd5:	53                   	push   %ebx
  800dd6:	ff 35 04 40 80 00    	pushl  0x804004
  800ddc:	e8 8b 11 00 00       	call   801f6c <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800de1:	83 c4 0c             	add    $0xc,%esp
  800de4:	6a 00                	push   $0x0
  800de6:	6a 00                	push   $0x0
  800de8:	6a 00                	push   $0x0
  800dea:	e8 14 11 00 00       	call   801f03 <ipc_recv>
}
  800def:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800df2:	c9                   	leave  
  800df3:	c3                   	ret    

00800df4 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	56                   	push   %esi
  800df8:	53                   	push   %ebx
  800df9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800dfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dff:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e04:	8b 06                	mov    (%esi),%eax
  800e06:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e0b:	b8 01 00 00 00       	mov    $0x1,%eax
  800e10:	e8 95 ff ff ff       	call   800daa <nsipc>
  800e15:	89 c3                	mov    %eax,%ebx
  800e17:	85 c0                	test   %eax,%eax
  800e19:	78 20                	js     800e3b <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e1b:	83 ec 04             	sub    $0x4,%esp
  800e1e:	ff 35 10 60 80 00    	pushl  0x806010
  800e24:	68 00 60 80 00       	push   $0x806000
  800e29:	ff 75 0c             	pushl  0xc(%ebp)
  800e2c:	e8 1d 0f 00 00       	call   801d4e <memmove>
		*addrlen = ret->ret_addrlen;
  800e31:	a1 10 60 80 00       	mov    0x806010,%eax
  800e36:	89 06                	mov    %eax,(%esi)
  800e38:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e3b:	89 d8                	mov    %ebx,%eax
  800e3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e40:	5b                   	pop    %ebx
  800e41:	5e                   	pop    %esi
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    

00800e44 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	53                   	push   %ebx
  800e48:	83 ec 08             	sub    $0x8,%esp
  800e4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e51:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e56:	53                   	push   %ebx
  800e57:	ff 75 0c             	pushl  0xc(%ebp)
  800e5a:	68 04 60 80 00       	push   $0x806004
  800e5f:	e8 ea 0e 00 00       	call   801d4e <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e64:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e6a:	b8 02 00 00 00       	mov    $0x2,%eax
  800e6f:	e8 36 ff ff ff       	call   800daa <nsipc>
}
  800e74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e77:	c9                   	leave  
  800e78:	c3                   	ret    

00800e79 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e82:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e8f:	b8 03 00 00 00       	mov    $0x3,%eax
  800e94:	e8 11 ff ff ff       	call   800daa <nsipc>
}
  800e99:	c9                   	leave  
  800e9a:	c3                   	ret    

00800e9b <nsipc_close>:

int
nsipc_close(int s)
{
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ea1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea4:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800ea9:	b8 04 00 00 00       	mov    $0x4,%eax
  800eae:	e8 f7 fe ff ff       	call   800daa <nsipc>
}
  800eb3:	c9                   	leave  
  800eb4:	c3                   	ret    

00800eb5 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	53                   	push   %ebx
  800eb9:	83 ec 08             	sub    $0x8,%esp
  800ebc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ebf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec2:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ec7:	53                   	push   %ebx
  800ec8:	ff 75 0c             	pushl  0xc(%ebp)
  800ecb:	68 04 60 80 00       	push   $0x806004
  800ed0:	e8 79 0e 00 00       	call   801d4e <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ed5:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800edb:	b8 05 00 00 00       	mov    $0x5,%eax
  800ee0:	e8 c5 fe ff ff       	call   800daa <nsipc>
}
  800ee5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ee8:	c9                   	leave  
  800ee9:	c3                   	ret    

00800eea <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ef0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800ef8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800efb:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f00:	b8 06 00 00 00       	mov    $0x6,%eax
  800f05:	e8 a0 fe ff ff       	call   800daa <nsipc>
}
  800f0a:	c9                   	leave  
  800f0b:	c3                   	ret    

00800f0c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	56                   	push   %esi
  800f10:	53                   	push   %ebx
  800f11:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f14:	8b 45 08             	mov    0x8(%ebp),%eax
  800f17:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f1c:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f22:	8b 45 14             	mov    0x14(%ebp),%eax
  800f25:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f2a:	b8 07 00 00 00       	mov    $0x7,%eax
  800f2f:	e8 76 fe ff ff       	call   800daa <nsipc>
  800f34:	89 c3                	mov    %eax,%ebx
  800f36:	85 c0                	test   %eax,%eax
  800f38:	78 35                	js     800f6f <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f3a:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f3f:	7f 04                	jg     800f45 <nsipc_recv+0x39>
  800f41:	39 c6                	cmp    %eax,%esi
  800f43:	7d 16                	jge    800f5b <nsipc_recv+0x4f>
  800f45:	68 e7 23 80 00       	push   $0x8023e7
  800f4a:	68 af 23 80 00       	push   $0x8023af
  800f4f:	6a 62                	push   $0x62
  800f51:	68 fc 23 80 00       	push   $0x8023fc
  800f56:	e8 84 05 00 00       	call   8014df <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f5b:	83 ec 04             	sub    $0x4,%esp
  800f5e:	50                   	push   %eax
  800f5f:	68 00 60 80 00       	push   $0x806000
  800f64:	ff 75 0c             	pushl  0xc(%ebp)
  800f67:	e8 e2 0d 00 00       	call   801d4e <memmove>
  800f6c:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f6f:	89 d8                	mov    %ebx,%eax
  800f71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f74:	5b                   	pop    %ebx
  800f75:	5e                   	pop    %esi
  800f76:	5d                   	pop    %ebp
  800f77:	c3                   	ret    

00800f78 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	53                   	push   %ebx
  800f7c:	83 ec 04             	sub    $0x4,%esp
  800f7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f82:	8b 45 08             	mov    0x8(%ebp),%eax
  800f85:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f8a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f90:	7e 16                	jle    800fa8 <nsipc_send+0x30>
  800f92:	68 08 24 80 00       	push   $0x802408
  800f97:	68 af 23 80 00       	push   $0x8023af
  800f9c:	6a 6d                	push   $0x6d
  800f9e:	68 fc 23 80 00       	push   $0x8023fc
  800fa3:	e8 37 05 00 00       	call   8014df <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fa8:	83 ec 04             	sub    $0x4,%esp
  800fab:	53                   	push   %ebx
  800fac:	ff 75 0c             	pushl  0xc(%ebp)
  800faf:	68 0c 60 80 00       	push   $0x80600c
  800fb4:	e8 95 0d 00 00       	call   801d4e <memmove>
	nsipcbuf.send.req_size = size;
  800fb9:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fbf:	8b 45 14             	mov    0x14(%ebp),%eax
  800fc2:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fc7:	b8 08 00 00 00       	mov    $0x8,%eax
  800fcc:	e8 d9 fd ff ff       	call   800daa <nsipc>
}
  800fd1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd4:	c9                   	leave  
  800fd5:	c3                   	ret    

00800fd6 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fdc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800fe4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe7:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800fec:	8b 45 10             	mov    0x10(%ebp),%eax
  800fef:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  800ff4:	b8 09 00 00 00       	mov    $0x9,%eax
  800ff9:	e8 ac fd ff ff       	call   800daa <nsipc>
}
  800ffe:	c9                   	leave  
  800fff:	c3                   	ret    

00801000 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	56                   	push   %esi
  801004:	53                   	push   %ebx
  801005:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801008:	83 ec 0c             	sub    $0xc,%esp
  80100b:	ff 75 08             	pushl  0x8(%ebp)
  80100e:	e8 8b f3 ff ff       	call   80039e <fd2data>
  801013:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801015:	83 c4 08             	add    $0x8,%esp
  801018:	68 14 24 80 00       	push   $0x802414
  80101d:	53                   	push   %ebx
  80101e:	e8 99 0b 00 00       	call   801bbc <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801023:	8b 46 04             	mov    0x4(%esi),%eax
  801026:	2b 06                	sub    (%esi),%eax
  801028:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80102e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801035:	00 00 00 
	stat->st_dev = &devpipe;
  801038:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80103f:	30 80 00 
	return 0;
}
  801042:	b8 00 00 00 00       	mov    $0x0,%eax
  801047:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80104a:	5b                   	pop    %ebx
  80104b:	5e                   	pop    %esi
  80104c:	5d                   	pop    %ebp
  80104d:	c3                   	ret    

0080104e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80104e:	55                   	push   %ebp
  80104f:	89 e5                	mov    %esp,%ebp
  801051:	53                   	push   %ebx
  801052:	83 ec 0c             	sub    $0xc,%esp
  801055:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801058:	53                   	push   %ebx
  801059:	6a 00                	push   $0x0
  80105b:	e8 83 f1 ff ff       	call   8001e3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801060:	89 1c 24             	mov    %ebx,(%esp)
  801063:	e8 36 f3 ff ff       	call   80039e <fd2data>
  801068:	83 c4 08             	add    $0x8,%esp
  80106b:	50                   	push   %eax
  80106c:	6a 00                	push   $0x0
  80106e:	e8 70 f1 ff ff       	call   8001e3 <sys_page_unmap>
}
  801073:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801076:	c9                   	leave  
  801077:	c3                   	ret    

00801078 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	57                   	push   %edi
  80107c:	56                   	push   %esi
  80107d:	53                   	push   %ebx
  80107e:	83 ec 1c             	sub    $0x1c,%esp
  801081:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801084:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801086:	a1 08 40 80 00       	mov    0x804008,%eax
  80108b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80108e:	83 ec 0c             	sub    $0xc,%esp
  801091:	ff 75 e0             	pushl  -0x20(%ebp)
  801094:	e8 60 0f 00 00       	call   801ff9 <pageref>
  801099:	89 c3                	mov    %eax,%ebx
  80109b:	89 3c 24             	mov    %edi,(%esp)
  80109e:	e8 56 0f 00 00       	call   801ff9 <pageref>
  8010a3:	83 c4 10             	add    $0x10,%esp
  8010a6:	39 c3                	cmp    %eax,%ebx
  8010a8:	0f 94 c1             	sete   %cl
  8010ab:	0f b6 c9             	movzbl %cl,%ecx
  8010ae:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010b1:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010b7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010ba:	39 ce                	cmp    %ecx,%esi
  8010bc:	74 1b                	je     8010d9 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010be:	39 c3                	cmp    %eax,%ebx
  8010c0:	75 c4                	jne    801086 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010c2:	8b 42 58             	mov    0x58(%edx),%eax
  8010c5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c8:	50                   	push   %eax
  8010c9:	56                   	push   %esi
  8010ca:	68 1b 24 80 00       	push   $0x80241b
  8010cf:	e8 e4 04 00 00       	call   8015b8 <cprintf>
  8010d4:	83 c4 10             	add    $0x10,%esp
  8010d7:	eb ad                	jmp    801086 <_pipeisclosed+0xe>
	}
}
  8010d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010df:	5b                   	pop    %ebx
  8010e0:	5e                   	pop    %esi
  8010e1:	5f                   	pop    %edi
  8010e2:	5d                   	pop    %ebp
  8010e3:	c3                   	ret    

008010e4 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	57                   	push   %edi
  8010e8:	56                   	push   %esi
  8010e9:	53                   	push   %ebx
  8010ea:	83 ec 28             	sub    $0x28,%esp
  8010ed:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8010f0:	56                   	push   %esi
  8010f1:	e8 a8 f2 ff ff       	call   80039e <fd2data>
  8010f6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010f8:	83 c4 10             	add    $0x10,%esp
  8010fb:	bf 00 00 00 00       	mov    $0x0,%edi
  801100:	eb 4b                	jmp    80114d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801102:	89 da                	mov    %ebx,%edx
  801104:	89 f0                	mov    %esi,%eax
  801106:	e8 6d ff ff ff       	call   801078 <_pipeisclosed>
  80110b:	85 c0                	test   %eax,%eax
  80110d:	75 48                	jne    801157 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80110f:	e8 2b f0 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801114:	8b 43 04             	mov    0x4(%ebx),%eax
  801117:	8b 0b                	mov    (%ebx),%ecx
  801119:	8d 51 20             	lea    0x20(%ecx),%edx
  80111c:	39 d0                	cmp    %edx,%eax
  80111e:	73 e2                	jae    801102 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801120:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801123:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801127:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80112a:	89 c2                	mov    %eax,%edx
  80112c:	c1 fa 1f             	sar    $0x1f,%edx
  80112f:	89 d1                	mov    %edx,%ecx
  801131:	c1 e9 1b             	shr    $0x1b,%ecx
  801134:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801137:	83 e2 1f             	and    $0x1f,%edx
  80113a:	29 ca                	sub    %ecx,%edx
  80113c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801140:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801144:	83 c0 01             	add    $0x1,%eax
  801147:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80114a:	83 c7 01             	add    $0x1,%edi
  80114d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801150:	75 c2                	jne    801114 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801152:	8b 45 10             	mov    0x10(%ebp),%eax
  801155:	eb 05                	jmp    80115c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801157:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80115c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115f:	5b                   	pop    %ebx
  801160:	5e                   	pop    %esi
  801161:	5f                   	pop    %edi
  801162:	5d                   	pop    %ebp
  801163:	c3                   	ret    

00801164 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	57                   	push   %edi
  801168:	56                   	push   %esi
  801169:	53                   	push   %ebx
  80116a:	83 ec 18             	sub    $0x18,%esp
  80116d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801170:	57                   	push   %edi
  801171:	e8 28 f2 ff ff       	call   80039e <fd2data>
  801176:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801178:	83 c4 10             	add    $0x10,%esp
  80117b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801180:	eb 3d                	jmp    8011bf <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801182:	85 db                	test   %ebx,%ebx
  801184:	74 04                	je     80118a <devpipe_read+0x26>
				return i;
  801186:	89 d8                	mov    %ebx,%eax
  801188:	eb 44                	jmp    8011ce <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80118a:	89 f2                	mov    %esi,%edx
  80118c:	89 f8                	mov    %edi,%eax
  80118e:	e8 e5 fe ff ff       	call   801078 <_pipeisclosed>
  801193:	85 c0                	test   %eax,%eax
  801195:	75 32                	jne    8011c9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801197:	e8 a3 ef ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80119c:	8b 06                	mov    (%esi),%eax
  80119e:	3b 46 04             	cmp    0x4(%esi),%eax
  8011a1:	74 df                	je     801182 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011a3:	99                   	cltd   
  8011a4:	c1 ea 1b             	shr    $0x1b,%edx
  8011a7:	01 d0                	add    %edx,%eax
  8011a9:	83 e0 1f             	and    $0x1f,%eax
  8011ac:	29 d0                	sub    %edx,%eax
  8011ae:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011b9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011bc:	83 c3 01             	add    $0x1,%ebx
  8011bf:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011c2:	75 d8                	jne    80119c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8011c7:	eb 05                	jmp    8011ce <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011c9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d1:	5b                   	pop    %ebx
  8011d2:	5e                   	pop    %esi
  8011d3:	5f                   	pop    %edi
  8011d4:	5d                   	pop    %ebp
  8011d5:	c3                   	ret    

008011d6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011d6:	55                   	push   %ebp
  8011d7:	89 e5                	mov    %esp,%ebp
  8011d9:	56                   	push   %esi
  8011da:	53                   	push   %ebx
  8011db:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e1:	50                   	push   %eax
  8011e2:	e8 ce f1 ff ff       	call   8003b5 <fd_alloc>
  8011e7:	83 c4 10             	add    $0x10,%esp
  8011ea:	89 c2                	mov    %eax,%edx
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	0f 88 2c 01 00 00    	js     801320 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011f4:	83 ec 04             	sub    $0x4,%esp
  8011f7:	68 07 04 00 00       	push   $0x407
  8011fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8011ff:	6a 00                	push   $0x0
  801201:	e8 58 ef ff ff       	call   80015e <sys_page_alloc>
  801206:	83 c4 10             	add    $0x10,%esp
  801209:	89 c2                	mov    %eax,%edx
  80120b:	85 c0                	test   %eax,%eax
  80120d:	0f 88 0d 01 00 00    	js     801320 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801213:	83 ec 0c             	sub    $0xc,%esp
  801216:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801219:	50                   	push   %eax
  80121a:	e8 96 f1 ff ff       	call   8003b5 <fd_alloc>
  80121f:	89 c3                	mov    %eax,%ebx
  801221:	83 c4 10             	add    $0x10,%esp
  801224:	85 c0                	test   %eax,%eax
  801226:	0f 88 e2 00 00 00    	js     80130e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80122c:	83 ec 04             	sub    $0x4,%esp
  80122f:	68 07 04 00 00       	push   $0x407
  801234:	ff 75 f0             	pushl  -0x10(%ebp)
  801237:	6a 00                	push   $0x0
  801239:	e8 20 ef ff ff       	call   80015e <sys_page_alloc>
  80123e:	89 c3                	mov    %eax,%ebx
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	85 c0                	test   %eax,%eax
  801245:	0f 88 c3 00 00 00    	js     80130e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80124b:	83 ec 0c             	sub    $0xc,%esp
  80124e:	ff 75 f4             	pushl  -0xc(%ebp)
  801251:	e8 48 f1 ff ff       	call   80039e <fd2data>
  801256:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801258:	83 c4 0c             	add    $0xc,%esp
  80125b:	68 07 04 00 00       	push   $0x407
  801260:	50                   	push   %eax
  801261:	6a 00                	push   $0x0
  801263:	e8 f6 ee ff ff       	call   80015e <sys_page_alloc>
  801268:	89 c3                	mov    %eax,%ebx
  80126a:	83 c4 10             	add    $0x10,%esp
  80126d:	85 c0                	test   %eax,%eax
  80126f:	0f 88 89 00 00 00    	js     8012fe <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801275:	83 ec 0c             	sub    $0xc,%esp
  801278:	ff 75 f0             	pushl  -0x10(%ebp)
  80127b:	e8 1e f1 ff ff       	call   80039e <fd2data>
  801280:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801287:	50                   	push   %eax
  801288:	6a 00                	push   $0x0
  80128a:	56                   	push   %esi
  80128b:	6a 00                	push   $0x0
  80128d:	e8 0f ef ff ff       	call   8001a1 <sys_page_map>
  801292:	89 c3                	mov    %eax,%ebx
  801294:	83 c4 20             	add    $0x20,%esp
  801297:	85 c0                	test   %eax,%eax
  801299:	78 55                	js     8012f0 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80129b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012b0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012be:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012c5:	83 ec 0c             	sub    $0xc,%esp
  8012c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8012cb:	e8 be f0 ff ff       	call   80038e <fd2num>
  8012d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012d5:	83 c4 04             	add    $0x4,%esp
  8012d8:	ff 75 f0             	pushl  -0x10(%ebp)
  8012db:	e8 ae f0 ff ff       	call   80038e <fd2num>
  8012e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012e6:	83 c4 10             	add    $0x10,%esp
  8012e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ee:	eb 30                	jmp    801320 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8012f0:	83 ec 08             	sub    $0x8,%esp
  8012f3:	56                   	push   %esi
  8012f4:	6a 00                	push   $0x0
  8012f6:	e8 e8 ee ff ff       	call   8001e3 <sys_page_unmap>
  8012fb:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8012fe:	83 ec 08             	sub    $0x8,%esp
  801301:	ff 75 f0             	pushl  -0x10(%ebp)
  801304:	6a 00                	push   $0x0
  801306:	e8 d8 ee ff ff       	call   8001e3 <sys_page_unmap>
  80130b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80130e:	83 ec 08             	sub    $0x8,%esp
  801311:	ff 75 f4             	pushl  -0xc(%ebp)
  801314:	6a 00                	push   $0x0
  801316:	e8 c8 ee ff ff       	call   8001e3 <sys_page_unmap>
  80131b:	83 c4 10             	add    $0x10,%esp
  80131e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801320:	89 d0                	mov    %edx,%eax
  801322:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801325:	5b                   	pop    %ebx
  801326:	5e                   	pop    %esi
  801327:	5d                   	pop    %ebp
  801328:	c3                   	ret    

00801329 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801329:	55                   	push   %ebp
  80132a:	89 e5                	mov    %esp,%ebp
  80132c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80132f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801332:	50                   	push   %eax
  801333:	ff 75 08             	pushl  0x8(%ebp)
  801336:	e8 c9 f0 ff ff       	call   800404 <fd_lookup>
  80133b:	83 c4 10             	add    $0x10,%esp
  80133e:	85 c0                	test   %eax,%eax
  801340:	78 18                	js     80135a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801342:	83 ec 0c             	sub    $0xc,%esp
  801345:	ff 75 f4             	pushl  -0xc(%ebp)
  801348:	e8 51 f0 ff ff       	call   80039e <fd2data>
	return _pipeisclosed(fd, p);
  80134d:	89 c2                	mov    %eax,%edx
  80134f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801352:	e8 21 fd ff ff       	call   801078 <_pipeisclosed>
  801357:	83 c4 10             	add    $0x10,%esp
}
  80135a:	c9                   	leave  
  80135b:	c3                   	ret    

0080135c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80135f:	b8 00 00 00 00       	mov    $0x0,%eax
  801364:	5d                   	pop    %ebp
  801365:	c3                   	ret    

00801366 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801366:	55                   	push   %ebp
  801367:	89 e5                	mov    %esp,%ebp
  801369:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80136c:	68 33 24 80 00       	push   $0x802433
  801371:	ff 75 0c             	pushl  0xc(%ebp)
  801374:	e8 43 08 00 00       	call   801bbc <strcpy>
	return 0;
}
  801379:	b8 00 00 00 00       	mov    $0x0,%eax
  80137e:	c9                   	leave  
  80137f:	c3                   	ret    

00801380 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	57                   	push   %edi
  801384:	56                   	push   %esi
  801385:	53                   	push   %ebx
  801386:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80138c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801391:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801397:	eb 2d                	jmp    8013c6 <devcons_write+0x46>
		m = n - tot;
  801399:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80139c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80139e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013a1:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013a6:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013a9:	83 ec 04             	sub    $0x4,%esp
  8013ac:	53                   	push   %ebx
  8013ad:	03 45 0c             	add    0xc(%ebp),%eax
  8013b0:	50                   	push   %eax
  8013b1:	57                   	push   %edi
  8013b2:	e8 97 09 00 00       	call   801d4e <memmove>
		sys_cputs(buf, m);
  8013b7:	83 c4 08             	add    $0x8,%esp
  8013ba:	53                   	push   %ebx
  8013bb:	57                   	push   %edi
  8013bc:	e8 e1 ec ff ff       	call   8000a2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013c1:	01 de                	add    %ebx,%esi
  8013c3:	83 c4 10             	add    $0x10,%esp
  8013c6:	89 f0                	mov    %esi,%eax
  8013c8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013cb:	72 cc                	jb     801399 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d0:	5b                   	pop    %ebx
  8013d1:	5e                   	pop    %esi
  8013d2:	5f                   	pop    %edi
  8013d3:	5d                   	pop    %ebp
  8013d4:	c3                   	ret    

008013d5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013d5:	55                   	push   %ebp
  8013d6:	89 e5                	mov    %esp,%ebp
  8013d8:	83 ec 08             	sub    $0x8,%esp
  8013db:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013e0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013e4:	74 2a                	je     801410 <devcons_read+0x3b>
  8013e6:	eb 05                	jmp    8013ed <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013e8:	e8 52 ed ff ff       	call   80013f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013ed:	e8 ce ec ff ff       	call   8000c0 <sys_cgetc>
  8013f2:	85 c0                	test   %eax,%eax
  8013f4:	74 f2                	je     8013e8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013f6:	85 c0                	test   %eax,%eax
  8013f8:	78 16                	js     801410 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8013fa:	83 f8 04             	cmp    $0x4,%eax
  8013fd:	74 0c                	je     80140b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8013ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801402:	88 02                	mov    %al,(%edx)
	return 1;
  801404:	b8 01 00 00 00       	mov    $0x1,%eax
  801409:	eb 05                	jmp    801410 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80140b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801410:	c9                   	leave  
  801411:	c3                   	ret    

00801412 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801412:	55                   	push   %ebp
  801413:	89 e5                	mov    %esp,%ebp
  801415:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801418:	8b 45 08             	mov    0x8(%ebp),%eax
  80141b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80141e:	6a 01                	push   $0x1
  801420:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801423:	50                   	push   %eax
  801424:	e8 79 ec ff ff       	call   8000a2 <sys_cputs>
}
  801429:	83 c4 10             	add    $0x10,%esp
  80142c:	c9                   	leave  
  80142d:	c3                   	ret    

0080142e <getchar>:

int
getchar(void)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801434:	6a 01                	push   $0x1
  801436:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801439:	50                   	push   %eax
  80143a:	6a 00                	push   $0x0
  80143c:	e8 29 f2 ff ff       	call   80066a <read>
	if (r < 0)
  801441:	83 c4 10             	add    $0x10,%esp
  801444:	85 c0                	test   %eax,%eax
  801446:	78 0f                	js     801457 <getchar+0x29>
		return r;
	if (r < 1)
  801448:	85 c0                	test   %eax,%eax
  80144a:	7e 06                	jle    801452 <getchar+0x24>
		return -E_EOF;
	return c;
  80144c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801450:	eb 05                	jmp    801457 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801452:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801457:	c9                   	leave  
  801458:	c3                   	ret    

00801459 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801459:	55                   	push   %ebp
  80145a:	89 e5                	mov    %esp,%ebp
  80145c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80145f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801462:	50                   	push   %eax
  801463:	ff 75 08             	pushl  0x8(%ebp)
  801466:	e8 99 ef ff ff       	call   800404 <fd_lookup>
  80146b:	83 c4 10             	add    $0x10,%esp
  80146e:	85 c0                	test   %eax,%eax
  801470:	78 11                	js     801483 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801472:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801475:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80147b:	39 10                	cmp    %edx,(%eax)
  80147d:	0f 94 c0             	sete   %al
  801480:	0f b6 c0             	movzbl %al,%eax
}
  801483:	c9                   	leave  
  801484:	c3                   	ret    

00801485 <opencons>:

int
opencons(void)
{
  801485:	55                   	push   %ebp
  801486:	89 e5                	mov    %esp,%ebp
  801488:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80148b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148e:	50                   	push   %eax
  80148f:	e8 21 ef ff ff       	call   8003b5 <fd_alloc>
  801494:	83 c4 10             	add    $0x10,%esp
		return r;
  801497:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801499:	85 c0                	test   %eax,%eax
  80149b:	78 3e                	js     8014db <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80149d:	83 ec 04             	sub    $0x4,%esp
  8014a0:	68 07 04 00 00       	push   $0x407
  8014a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8014a8:	6a 00                	push   $0x0
  8014aa:	e8 af ec ff ff       	call   80015e <sys_page_alloc>
  8014af:	83 c4 10             	add    $0x10,%esp
		return r;
  8014b2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	78 23                	js     8014db <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014b8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014cd:	83 ec 0c             	sub    $0xc,%esp
  8014d0:	50                   	push   %eax
  8014d1:	e8 b8 ee ff ff       	call   80038e <fd2num>
  8014d6:	89 c2                	mov    %eax,%edx
  8014d8:	83 c4 10             	add    $0x10,%esp
}
  8014db:	89 d0                	mov    %edx,%eax
  8014dd:	c9                   	leave  
  8014de:	c3                   	ret    

008014df <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014df:	55                   	push   %ebp
  8014e0:	89 e5                	mov    %esp,%ebp
  8014e2:	56                   	push   %esi
  8014e3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014e4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014e7:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014ed:	e8 2e ec ff ff       	call   800120 <sys_getenvid>
  8014f2:	83 ec 0c             	sub    $0xc,%esp
  8014f5:	ff 75 0c             	pushl  0xc(%ebp)
  8014f8:	ff 75 08             	pushl  0x8(%ebp)
  8014fb:	56                   	push   %esi
  8014fc:	50                   	push   %eax
  8014fd:	68 40 24 80 00       	push   $0x802440
  801502:	e8 b1 00 00 00       	call   8015b8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801507:	83 c4 18             	add    $0x18,%esp
  80150a:	53                   	push   %ebx
  80150b:	ff 75 10             	pushl  0x10(%ebp)
  80150e:	e8 54 00 00 00       	call   801567 <vcprintf>
	cprintf("\n");
  801513:	c7 04 24 2c 24 80 00 	movl   $0x80242c,(%esp)
  80151a:	e8 99 00 00 00       	call   8015b8 <cprintf>
  80151f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801522:	cc                   	int3   
  801523:	eb fd                	jmp    801522 <_panic+0x43>

00801525 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801525:	55                   	push   %ebp
  801526:	89 e5                	mov    %esp,%ebp
  801528:	53                   	push   %ebx
  801529:	83 ec 04             	sub    $0x4,%esp
  80152c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80152f:	8b 13                	mov    (%ebx),%edx
  801531:	8d 42 01             	lea    0x1(%edx),%eax
  801534:	89 03                	mov    %eax,(%ebx)
  801536:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801539:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80153d:	3d ff 00 00 00       	cmp    $0xff,%eax
  801542:	75 1a                	jne    80155e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801544:	83 ec 08             	sub    $0x8,%esp
  801547:	68 ff 00 00 00       	push   $0xff
  80154c:	8d 43 08             	lea    0x8(%ebx),%eax
  80154f:	50                   	push   %eax
  801550:	e8 4d eb ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  801555:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80155b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80155e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801562:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801565:	c9                   	leave  
  801566:	c3                   	ret    

00801567 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801567:	55                   	push   %ebp
  801568:	89 e5                	mov    %esp,%ebp
  80156a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801570:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801577:	00 00 00 
	b.cnt = 0;
  80157a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801581:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801584:	ff 75 0c             	pushl  0xc(%ebp)
  801587:	ff 75 08             	pushl  0x8(%ebp)
  80158a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801590:	50                   	push   %eax
  801591:	68 25 15 80 00       	push   $0x801525
  801596:	e8 1a 01 00 00       	call   8016b5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80159b:	83 c4 08             	add    $0x8,%esp
  80159e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015a4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015aa:	50                   	push   %eax
  8015ab:	e8 f2 ea ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  8015b0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015b6:	c9                   	leave  
  8015b7:	c3                   	ret    

008015b8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015b8:	55                   	push   %ebp
  8015b9:	89 e5                	mov    %esp,%ebp
  8015bb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015be:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015c1:	50                   	push   %eax
  8015c2:	ff 75 08             	pushl  0x8(%ebp)
  8015c5:	e8 9d ff ff ff       	call   801567 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015ca:	c9                   	leave  
  8015cb:	c3                   	ret    

008015cc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015cc:	55                   	push   %ebp
  8015cd:	89 e5                	mov    %esp,%ebp
  8015cf:	57                   	push   %edi
  8015d0:	56                   	push   %esi
  8015d1:	53                   	push   %ebx
  8015d2:	83 ec 1c             	sub    $0x1c,%esp
  8015d5:	89 c7                	mov    %eax,%edi
  8015d7:	89 d6                	mov    %edx,%esi
  8015d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015e2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015e5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015ed:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015f0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015f3:	39 d3                	cmp    %edx,%ebx
  8015f5:	72 05                	jb     8015fc <printnum+0x30>
  8015f7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8015fa:	77 45                	ja     801641 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015fc:	83 ec 0c             	sub    $0xc,%esp
  8015ff:	ff 75 18             	pushl  0x18(%ebp)
  801602:	8b 45 14             	mov    0x14(%ebp),%eax
  801605:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801608:	53                   	push   %ebx
  801609:	ff 75 10             	pushl  0x10(%ebp)
  80160c:	83 ec 08             	sub    $0x8,%esp
  80160f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801612:	ff 75 e0             	pushl  -0x20(%ebp)
  801615:	ff 75 dc             	pushl  -0x24(%ebp)
  801618:	ff 75 d8             	pushl  -0x28(%ebp)
  80161b:	e8 20 0a 00 00       	call   802040 <__udivdi3>
  801620:	83 c4 18             	add    $0x18,%esp
  801623:	52                   	push   %edx
  801624:	50                   	push   %eax
  801625:	89 f2                	mov    %esi,%edx
  801627:	89 f8                	mov    %edi,%eax
  801629:	e8 9e ff ff ff       	call   8015cc <printnum>
  80162e:	83 c4 20             	add    $0x20,%esp
  801631:	eb 18                	jmp    80164b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801633:	83 ec 08             	sub    $0x8,%esp
  801636:	56                   	push   %esi
  801637:	ff 75 18             	pushl  0x18(%ebp)
  80163a:	ff d7                	call   *%edi
  80163c:	83 c4 10             	add    $0x10,%esp
  80163f:	eb 03                	jmp    801644 <printnum+0x78>
  801641:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801644:	83 eb 01             	sub    $0x1,%ebx
  801647:	85 db                	test   %ebx,%ebx
  801649:	7f e8                	jg     801633 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80164b:	83 ec 08             	sub    $0x8,%esp
  80164e:	56                   	push   %esi
  80164f:	83 ec 04             	sub    $0x4,%esp
  801652:	ff 75 e4             	pushl  -0x1c(%ebp)
  801655:	ff 75 e0             	pushl  -0x20(%ebp)
  801658:	ff 75 dc             	pushl  -0x24(%ebp)
  80165b:	ff 75 d8             	pushl  -0x28(%ebp)
  80165e:	e8 0d 0b 00 00       	call   802170 <__umoddi3>
  801663:	83 c4 14             	add    $0x14,%esp
  801666:	0f be 80 63 24 80 00 	movsbl 0x802463(%eax),%eax
  80166d:	50                   	push   %eax
  80166e:	ff d7                	call   *%edi
}
  801670:	83 c4 10             	add    $0x10,%esp
  801673:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801676:	5b                   	pop    %ebx
  801677:	5e                   	pop    %esi
  801678:	5f                   	pop    %edi
  801679:	5d                   	pop    %ebp
  80167a:	c3                   	ret    

0080167b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801681:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801685:	8b 10                	mov    (%eax),%edx
  801687:	3b 50 04             	cmp    0x4(%eax),%edx
  80168a:	73 0a                	jae    801696 <sprintputch+0x1b>
		*b->buf++ = ch;
  80168c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80168f:	89 08                	mov    %ecx,(%eax)
  801691:	8b 45 08             	mov    0x8(%ebp),%eax
  801694:	88 02                	mov    %al,(%edx)
}
  801696:	5d                   	pop    %ebp
  801697:	c3                   	ret    

00801698 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80169e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016a1:	50                   	push   %eax
  8016a2:	ff 75 10             	pushl  0x10(%ebp)
  8016a5:	ff 75 0c             	pushl  0xc(%ebp)
  8016a8:	ff 75 08             	pushl  0x8(%ebp)
  8016ab:	e8 05 00 00 00       	call   8016b5 <vprintfmt>
	va_end(ap);
}
  8016b0:	83 c4 10             	add    $0x10,%esp
  8016b3:	c9                   	leave  
  8016b4:	c3                   	ret    

008016b5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	57                   	push   %edi
  8016b9:	56                   	push   %esi
  8016ba:	53                   	push   %ebx
  8016bb:	83 ec 2c             	sub    $0x2c,%esp
  8016be:	8b 75 08             	mov    0x8(%ebp),%esi
  8016c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016c4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016c7:	eb 12                	jmp    8016db <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016c9:	85 c0                	test   %eax,%eax
  8016cb:	0f 84 42 04 00 00    	je     801b13 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8016d1:	83 ec 08             	sub    $0x8,%esp
  8016d4:	53                   	push   %ebx
  8016d5:	50                   	push   %eax
  8016d6:	ff d6                	call   *%esi
  8016d8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016db:	83 c7 01             	add    $0x1,%edi
  8016de:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016e2:	83 f8 25             	cmp    $0x25,%eax
  8016e5:	75 e2                	jne    8016c9 <vprintfmt+0x14>
  8016e7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8016eb:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8016f2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016f9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801700:	b9 00 00 00 00       	mov    $0x0,%ecx
  801705:	eb 07                	jmp    80170e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801707:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80170a:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80170e:	8d 47 01             	lea    0x1(%edi),%eax
  801711:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801714:	0f b6 07             	movzbl (%edi),%eax
  801717:	0f b6 d0             	movzbl %al,%edx
  80171a:	83 e8 23             	sub    $0x23,%eax
  80171d:	3c 55                	cmp    $0x55,%al
  80171f:	0f 87 d3 03 00 00    	ja     801af8 <vprintfmt+0x443>
  801725:	0f b6 c0             	movzbl %al,%eax
  801728:	ff 24 85 a0 25 80 00 	jmp    *0x8025a0(,%eax,4)
  80172f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801732:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801736:	eb d6                	jmp    80170e <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801738:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80173b:	b8 00 00 00 00       	mov    $0x0,%eax
  801740:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801743:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801746:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80174a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80174d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801750:	83 f9 09             	cmp    $0x9,%ecx
  801753:	77 3f                	ja     801794 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801755:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801758:	eb e9                	jmp    801743 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80175a:	8b 45 14             	mov    0x14(%ebp),%eax
  80175d:	8b 00                	mov    (%eax),%eax
  80175f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801762:	8b 45 14             	mov    0x14(%ebp),%eax
  801765:	8d 40 04             	lea    0x4(%eax),%eax
  801768:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80176b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80176e:	eb 2a                	jmp    80179a <vprintfmt+0xe5>
  801770:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801773:	85 c0                	test   %eax,%eax
  801775:	ba 00 00 00 00       	mov    $0x0,%edx
  80177a:	0f 49 d0             	cmovns %eax,%edx
  80177d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801780:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801783:	eb 89                	jmp    80170e <vprintfmt+0x59>
  801785:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801788:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80178f:	e9 7a ff ff ff       	jmp    80170e <vprintfmt+0x59>
  801794:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801797:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80179a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80179e:	0f 89 6a ff ff ff    	jns    80170e <vprintfmt+0x59>
				width = precision, precision = -1;
  8017a4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017aa:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017b1:	e9 58 ff ff ff       	jmp    80170e <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017b6:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017bc:	e9 4d ff ff ff       	jmp    80170e <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8017c4:	8d 78 04             	lea    0x4(%eax),%edi
  8017c7:	83 ec 08             	sub    $0x8,%esp
  8017ca:	53                   	push   %ebx
  8017cb:	ff 30                	pushl  (%eax)
  8017cd:	ff d6                	call   *%esi
			break;
  8017cf:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017d2:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8017d8:	e9 fe fe ff ff       	jmp    8016db <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8017dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8017e0:	8d 78 04             	lea    0x4(%eax),%edi
  8017e3:	8b 00                	mov    (%eax),%eax
  8017e5:	99                   	cltd   
  8017e6:	31 d0                	xor    %edx,%eax
  8017e8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017ea:	83 f8 0f             	cmp    $0xf,%eax
  8017ed:	7f 0b                	jg     8017fa <vprintfmt+0x145>
  8017ef:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  8017f6:	85 d2                	test   %edx,%edx
  8017f8:	75 1b                	jne    801815 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8017fa:	50                   	push   %eax
  8017fb:	68 7b 24 80 00       	push   $0x80247b
  801800:	53                   	push   %ebx
  801801:	56                   	push   %esi
  801802:	e8 91 fe ff ff       	call   801698 <printfmt>
  801807:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80180a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80180d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801810:	e9 c6 fe ff ff       	jmp    8016db <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801815:	52                   	push   %edx
  801816:	68 c1 23 80 00       	push   $0x8023c1
  80181b:	53                   	push   %ebx
  80181c:	56                   	push   %esi
  80181d:	e8 76 fe ff ff       	call   801698 <printfmt>
  801822:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801825:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801828:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80182b:	e9 ab fe ff ff       	jmp    8016db <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801830:	8b 45 14             	mov    0x14(%ebp),%eax
  801833:	83 c0 04             	add    $0x4,%eax
  801836:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801839:	8b 45 14             	mov    0x14(%ebp),%eax
  80183c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80183e:	85 ff                	test   %edi,%edi
  801840:	b8 74 24 80 00       	mov    $0x802474,%eax
  801845:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801848:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80184c:	0f 8e 94 00 00 00    	jle    8018e6 <vprintfmt+0x231>
  801852:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801856:	0f 84 98 00 00 00    	je     8018f4 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  80185c:	83 ec 08             	sub    $0x8,%esp
  80185f:	ff 75 d0             	pushl  -0x30(%ebp)
  801862:	57                   	push   %edi
  801863:	e8 33 03 00 00       	call   801b9b <strnlen>
  801868:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80186b:	29 c1                	sub    %eax,%ecx
  80186d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801870:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801873:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801877:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80187a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80187d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80187f:	eb 0f                	jmp    801890 <vprintfmt+0x1db>
					putch(padc, putdat);
  801881:	83 ec 08             	sub    $0x8,%esp
  801884:	53                   	push   %ebx
  801885:	ff 75 e0             	pushl  -0x20(%ebp)
  801888:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80188a:	83 ef 01             	sub    $0x1,%edi
  80188d:	83 c4 10             	add    $0x10,%esp
  801890:	85 ff                	test   %edi,%edi
  801892:	7f ed                	jg     801881 <vprintfmt+0x1cc>
  801894:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801897:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80189a:	85 c9                	test   %ecx,%ecx
  80189c:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a1:	0f 49 c1             	cmovns %ecx,%eax
  8018a4:	29 c1                	sub    %eax,%ecx
  8018a6:	89 75 08             	mov    %esi,0x8(%ebp)
  8018a9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018ac:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018af:	89 cb                	mov    %ecx,%ebx
  8018b1:	eb 4d                	jmp    801900 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018b3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018b7:	74 1b                	je     8018d4 <vprintfmt+0x21f>
  8018b9:	0f be c0             	movsbl %al,%eax
  8018bc:	83 e8 20             	sub    $0x20,%eax
  8018bf:	83 f8 5e             	cmp    $0x5e,%eax
  8018c2:	76 10                	jbe    8018d4 <vprintfmt+0x21f>
					putch('?', putdat);
  8018c4:	83 ec 08             	sub    $0x8,%esp
  8018c7:	ff 75 0c             	pushl  0xc(%ebp)
  8018ca:	6a 3f                	push   $0x3f
  8018cc:	ff 55 08             	call   *0x8(%ebp)
  8018cf:	83 c4 10             	add    $0x10,%esp
  8018d2:	eb 0d                	jmp    8018e1 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8018d4:	83 ec 08             	sub    $0x8,%esp
  8018d7:	ff 75 0c             	pushl  0xc(%ebp)
  8018da:	52                   	push   %edx
  8018db:	ff 55 08             	call   *0x8(%ebp)
  8018de:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018e1:	83 eb 01             	sub    $0x1,%ebx
  8018e4:	eb 1a                	jmp    801900 <vprintfmt+0x24b>
  8018e6:	89 75 08             	mov    %esi,0x8(%ebp)
  8018e9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018ec:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018ef:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018f2:	eb 0c                	jmp    801900 <vprintfmt+0x24b>
  8018f4:	89 75 08             	mov    %esi,0x8(%ebp)
  8018f7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018fa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018fd:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801900:	83 c7 01             	add    $0x1,%edi
  801903:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801907:	0f be d0             	movsbl %al,%edx
  80190a:	85 d2                	test   %edx,%edx
  80190c:	74 23                	je     801931 <vprintfmt+0x27c>
  80190e:	85 f6                	test   %esi,%esi
  801910:	78 a1                	js     8018b3 <vprintfmt+0x1fe>
  801912:	83 ee 01             	sub    $0x1,%esi
  801915:	79 9c                	jns    8018b3 <vprintfmt+0x1fe>
  801917:	89 df                	mov    %ebx,%edi
  801919:	8b 75 08             	mov    0x8(%ebp),%esi
  80191c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80191f:	eb 18                	jmp    801939 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801921:	83 ec 08             	sub    $0x8,%esp
  801924:	53                   	push   %ebx
  801925:	6a 20                	push   $0x20
  801927:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801929:	83 ef 01             	sub    $0x1,%edi
  80192c:	83 c4 10             	add    $0x10,%esp
  80192f:	eb 08                	jmp    801939 <vprintfmt+0x284>
  801931:	89 df                	mov    %ebx,%edi
  801933:	8b 75 08             	mov    0x8(%ebp),%esi
  801936:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801939:	85 ff                	test   %edi,%edi
  80193b:	7f e4                	jg     801921 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80193d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801940:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801943:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801946:	e9 90 fd ff ff       	jmp    8016db <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80194b:	83 f9 01             	cmp    $0x1,%ecx
  80194e:	7e 19                	jle    801969 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  801950:	8b 45 14             	mov    0x14(%ebp),%eax
  801953:	8b 50 04             	mov    0x4(%eax),%edx
  801956:	8b 00                	mov    (%eax),%eax
  801958:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80195b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80195e:	8b 45 14             	mov    0x14(%ebp),%eax
  801961:	8d 40 08             	lea    0x8(%eax),%eax
  801964:	89 45 14             	mov    %eax,0x14(%ebp)
  801967:	eb 38                	jmp    8019a1 <vprintfmt+0x2ec>
	else if (lflag)
  801969:	85 c9                	test   %ecx,%ecx
  80196b:	74 1b                	je     801988 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  80196d:	8b 45 14             	mov    0x14(%ebp),%eax
  801970:	8b 00                	mov    (%eax),%eax
  801972:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801975:	89 c1                	mov    %eax,%ecx
  801977:	c1 f9 1f             	sar    $0x1f,%ecx
  80197a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80197d:	8b 45 14             	mov    0x14(%ebp),%eax
  801980:	8d 40 04             	lea    0x4(%eax),%eax
  801983:	89 45 14             	mov    %eax,0x14(%ebp)
  801986:	eb 19                	jmp    8019a1 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  801988:	8b 45 14             	mov    0x14(%ebp),%eax
  80198b:	8b 00                	mov    (%eax),%eax
  80198d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801990:	89 c1                	mov    %eax,%ecx
  801992:	c1 f9 1f             	sar    $0x1f,%ecx
  801995:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801998:	8b 45 14             	mov    0x14(%ebp),%eax
  80199b:	8d 40 04             	lea    0x4(%eax),%eax
  80199e:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019a1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8019a4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019a7:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019ac:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019b0:	0f 89 0e 01 00 00    	jns    801ac4 <vprintfmt+0x40f>
				putch('-', putdat);
  8019b6:	83 ec 08             	sub    $0x8,%esp
  8019b9:	53                   	push   %ebx
  8019ba:	6a 2d                	push   $0x2d
  8019bc:	ff d6                	call   *%esi
				num = -(long long) num;
  8019be:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8019c1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8019c4:	f7 da                	neg    %edx
  8019c6:	83 d1 00             	adc    $0x0,%ecx
  8019c9:	f7 d9                	neg    %ecx
  8019cb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019ce:	b8 0a 00 00 00       	mov    $0xa,%eax
  8019d3:	e9 ec 00 00 00       	jmp    801ac4 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8019d8:	83 f9 01             	cmp    $0x1,%ecx
  8019db:	7e 18                	jle    8019f5 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8019dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8019e0:	8b 10                	mov    (%eax),%edx
  8019e2:	8b 48 04             	mov    0x4(%eax),%ecx
  8019e5:	8d 40 08             	lea    0x8(%eax),%eax
  8019e8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8019eb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8019f0:	e9 cf 00 00 00       	jmp    801ac4 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8019f5:	85 c9                	test   %ecx,%ecx
  8019f7:	74 1a                	je     801a13 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8019f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019fc:	8b 10                	mov    (%eax),%edx
  8019fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a03:	8d 40 04             	lea    0x4(%eax),%eax
  801a06:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801a09:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a0e:	e9 b1 00 00 00       	jmp    801ac4 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801a13:	8b 45 14             	mov    0x14(%ebp),%eax
  801a16:	8b 10                	mov    (%eax),%edx
  801a18:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a1d:	8d 40 04             	lea    0x4(%eax),%eax
  801a20:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801a23:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a28:	e9 97 00 00 00       	jmp    801ac4 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801a2d:	83 ec 08             	sub    $0x8,%esp
  801a30:	53                   	push   %ebx
  801a31:	6a 58                	push   $0x58
  801a33:	ff d6                	call   *%esi
			putch('X', putdat);
  801a35:	83 c4 08             	add    $0x8,%esp
  801a38:	53                   	push   %ebx
  801a39:	6a 58                	push   $0x58
  801a3b:	ff d6                	call   *%esi
			putch('X', putdat);
  801a3d:	83 c4 08             	add    $0x8,%esp
  801a40:	53                   	push   %ebx
  801a41:	6a 58                	push   $0x58
  801a43:	ff d6                	call   *%esi
			break;
  801a45:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a48:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  801a4b:	e9 8b fc ff ff       	jmp    8016db <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  801a50:	83 ec 08             	sub    $0x8,%esp
  801a53:	53                   	push   %ebx
  801a54:	6a 30                	push   $0x30
  801a56:	ff d6                	call   *%esi
			putch('x', putdat);
  801a58:	83 c4 08             	add    $0x8,%esp
  801a5b:	53                   	push   %ebx
  801a5c:	6a 78                	push   $0x78
  801a5e:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a60:	8b 45 14             	mov    0x14(%ebp),%eax
  801a63:	8b 10                	mov    (%eax),%edx
  801a65:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a6a:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a6d:	8d 40 04             	lea    0x4(%eax),%eax
  801a70:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a73:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801a78:	eb 4a                	jmp    801ac4 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a7a:	83 f9 01             	cmp    $0x1,%ecx
  801a7d:	7e 15                	jle    801a94 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  801a7f:	8b 45 14             	mov    0x14(%ebp),%eax
  801a82:	8b 10                	mov    (%eax),%edx
  801a84:	8b 48 04             	mov    0x4(%eax),%ecx
  801a87:	8d 40 08             	lea    0x8(%eax),%eax
  801a8a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801a8d:	b8 10 00 00 00       	mov    $0x10,%eax
  801a92:	eb 30                	jmp    801ac4 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801a94:	85 c9                	test   %ecx,%ecx
  801a96:	74 17                	je     801aaf <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  801a98:	8b 45 14             	mov    0x14(%ebp),%eax
  801a9b:	8b 10                	mov    (%eax),%edx
  801a9d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801aa2:	8d 40 04             	lea    0x4(%eax),%eax
  801aa5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801aa8:	b8 10 00 00 00       	mov    $0x10,%eax
  801aad:	eb 15                	jmp    801ac4 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801aaf:	8b 45 14             	mov    0x14(%ebp),%eax
  801ab2:	8b 10                	mov    (%eax),%edx
  801ab4:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ab9:	8d 40 04             	lea    0x4(%eax),%eax
  801abc:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801abf:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801ac4:	83 ec 0c             	sub    $0xc,%esp
  801ac7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801acb:	57                   	push   %edi
  801acc:	ff 75 e0             	pushl  -0x20(%ebp)
  801acf:	50                   	push   %eax
  801ad0:	51                   	push   %ecx
  801ad1:	52                   	push   %edx
  801ad2:	89 da                	mov    %ebx,%edx
  801ad4:	89 f0                	mov    %esi,%eax
  801ad6:	e8 f1 fa ff ff       	call   8015cc <printnum>
			break;
  801adb:	83 c4 20             	add    $0x20,%esp
  801ade:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ae1:	e9 f5 fb ff ff       	jmp    8016db <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801ae6:	83 ec 08             	sub    $0x8,%esp
  801ae9:	53                   	push   %ebx
  801aea:	52                   	push   %edx
  801aeb:	ff d6                	call   *%esi
			break;
  801aed:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801af0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801af3:	e9 e3 fb ff ff       	jmp    8016db <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801af8:	83 ec 08             	sub    $0x8,%esp
  801afb:	53                   	push   %ebx
  801afc:	6a 25                	push   $0x25
  801afe:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b00:	83 c4 10             	add    $0x10,%esp
  801b03:	eb 03                	jmp    801b08 <vprintfmt+0x453>
  801b05:	83 ef 01             	sub    $0x1,%edi
  801b08:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b0c:	75 f7                	jne    801b05 <vprintfmt+0x450>
  801b0e:	e9 c8 fb ff ff       	jmp    8016db <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b16:	5b                   	pop    %ebx
  801b17:	5e                   	pop    %esi
  801b18:	5f                   	pop    %edi
  801b19:	5d                   	pop    %ebp
  801b1a:	c3                   	ret    

00801b1b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b1b:	55                   	push   %ebp
  801b1c:	89 e5                	mov    %esp,%ebp
  801b1e:	83 ec 18             	sub    $0x18,%esp
  801b21:	8b 45 08             	mov    0x8(%ebp),%eax
  801b24:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b27:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b2a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b2e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b31:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b38:	85 c0                	test   %eax,%eax
  801b3a:	74 26                	je     801b62 <vsnprintf+0x47>
  801b3c:	85 d2                	test   %edx,%edx
  801b3e:	7e 22                	jle    801b62 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b40:	ff 75 14             	pushl  0x14(%ebp)
  801b43:	ff 75 10             	pushl  0x10(%ebp)
  801b46:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b49:	50                   	push   %eax
  801b4a:	68 7b 16 80 00       	push   $0x80167b
  801b4f:	e8 61 fb ff ff       	call   8016b5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b54:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b57:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b5d:	83 c4 10             	add    $0x10,%esp
  801b60:	eb 05                	jmp    801b67 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b62:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b67:	c9                   	leave  
  801b68:	c3                   	ret    

00801b69 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b6f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b72:	50                   	push   %eax
  801b73:	ff 75 10             	pushl  0x10(%ebp)
  801b76:	ff 75 0c             	pushl  0xc(%ebp)
  801b79:	ff 75 08             	pushl  0x8(%ebp)
  801b7c:	e8 9a ff ff ff       	call   801b1b <vsnprintf>
	va_end(ap);

	return rc;
}
  801b81:	c9                   	leave  
  801b82:	c3                   	ret    

00801b83 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b83:	55                   	push   %ebp
  801b84:	89 e5                	mov    %esp,%ebp
  801b86:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b89:	b8 00 00 00 00       	mov    $0x0,%eax
  801b8e:	eb 03                	jmp    801b93 <strlen+0x10>
		n++;
  801b90:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b93:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b97:	75 f7                	jne    801b90 <strlen+0xd>
		n++;
	return n;
}
  801b99:	5d                   	pop    %ebp
  801b9a:	c3                   	ret    

00801b9b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b9b:	55                   	push   %ebp
  801b9c:	89 e5                	mov    %esp,%ebp
  801b9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ba1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801ba4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba9:	eb 03                	jmp    801bae <strnlen+0x13>
		n++;
  801bab:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bae:	39 c2                	cmp    %eax,%edx
  801bb0:	74 08                	je     801bba <strnlen+0x1f>
  801bb2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801bb6:	75 f3                	jne    801bab <strnlen+0x10>
  801bb8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801bba:	5d                   	pop    %ebp
  801bbb:	c3                   	ret    

00801bbc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801bbc:	55                   	push   %ebp
  801bbd:	89 e5                	mov    %esp,%ebp
  801bbf:	53                   	push   %ebx
  801bc0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801bc6:	89 c2                	mov    %eax,%edx
  801bc8:	83 c2 01             	add    $0x1,%edx
  801bcb:	83 c1 01             	add    $0x1,%ecx
  801bce:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801bd2:	88 5a ff             	mov    %bl,-0x1(%edx)
  801bd5:	84 db                	test   %bl,%bl
  801bd7:	75 ef                	jne    801bc8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801bd9:	5b                   	pop    %ebx
  801bda:	5d                   	pop    %ebp
  801bdb:	c3                   	ret    

00801bdc <strcat>:

char *
strcat(char *dst, const char *src)
{
  801bdc:	55                   	push   %ebp
  801bdd:	89 e5                	mov    %esp,%ebp
  801bdf:	53                   	push   %ebx
  801be0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801be3:	53                   	push   %ebx
  801be4:	e8 9a ff ff ff       	call   801b83 <strlen>
  801be9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801bec:	ff 75 0c             	pushl  0xc(%ebp)
  801bef:	01 d8                	add    %ebx,%eax
  801bf1:	50                   	push   %eax
  801bf2:	e8 c5 ff ff ff       	call   801bbc <strcpy>
	return dst;
}
  801bf7:	89 d8                	mov    %ebx,%eax
  801bf9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bfc:	c9                   	leave  
  801bfd:	c3                   	ret    

00801bfe <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bfe:	55                   	push   %ebp
  801bff:	89 e5                	mov    %esp,%ebp
  801c01:	56                   	push   %esi
  801c02:	53                   	push   %ebx
  801c03:	8b 75 08             	mov    0x8(%ebp),%esi
  801c06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c09:	89 f3                	mov    %esi,%ebx
  801c0b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c0e:	89 f2                	mov    %esi,%edx
  801c10:	eb 0f                	jmp    801c21 <strncpy+0x23>
		*dst++ = *src;
  801c12:	83 c2 01             	add    $0x1,%edx
  801c15:	0f b6 01             	movzbl (%ecx),%eax
  801c18:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c1b:	80 39 01             	cmpb   $0x1,(%ecx)
  801c1e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c21:	39 da                	cmp    %ebx,%edx
  801c23:	75 ed                	jne    801c12 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c25:	89 f0                	mov    %esi,%eax
  801c27:	5b                   	pop    %ebx
  801c28:	5e                   	pop    %esi
  801c29:	5d                   	pop    %ebp
  801c2a:	c3                   	ret    

00801c2b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c2b:	55                   	push   %ebp
  801c2c:	89 e5                	mov    %esp,%ebp
  801c2e:	56                   	push   %esi
  801c2f:	53                   	push   %ebx
  801c30:	8b 75 08             	mov    0x8(%ebp),%esi
  801c33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c36:	8b 55 10             	mov    0x10(%ebp),%edx
  801c39:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c3b:	85 d2                	test   %edx,%edx
  801c3d:	74 21                	je     801c60 <strlcpy+0x35>
  801c3f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c43:	89 f2                	mov    %esi,%edx
  801c45:	eb 09                	jmp    801c50 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c47:	83 c2 01             	add    $0x1,%edx
  801c4a:	83 c1 01             	add    $0x1,%ecx
  801c4d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c50:	39 c2                	cmp    %eax,%edx
  801c52:	74 09                	je     801c5d <strlcpy+0x32>
  801c54:	0f b6 19             	movzbl (%ecx),%ebx
  801c57:	84 db                	test   %bl,%bl
  801c59:	75 ec                	jne    801c47 <strlcpy+0x1c>
  801c5b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c5d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c60:	29 f0                	sub    %esi,%eax
}
  801c62:	5b                   	pop    %ebx
  801c63:	5e                   	pop    %esi
  801c64:	5d                   	pop    %ebp
  801c65:	c3                   	ret    

00801c66 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c66:	55                   	push   %ebp
  801c67:	89 e5                	mov    %esp,%ebp
  801c69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c6c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c6f:	eb 06                	jmp    801c77 <strcmp+0x11>
		p++, q++;
  801c71:	83 c1 01             	add    $0x1,%ecx
  801c74:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c77:	0f b6 01             	movzbl (%ecx),%eax
  801c7a:	84 c0                	test   %al,%al
  801c7c:	74 04                	je     801c82 <strcmp+0x1c>
  801c7e:	3a 02                	cmp    (%edx),%al
  801c80:	74 ef                	je     801c71 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c82:	0f b6 c0             	movzbl %al,%eax
  801c85:	0f b6 12             	movzbl (%edx),%edx
  801c88:	29 d0                	sub    %edx,%eax
}
  801c8a:	5d                   	pop    %ebp
  801c8b:	c3                   	ret    

00801c8c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	53                   	push   %ebx
  801c90:	8b 45 08             	mov    0x8(%ebp),%eax
  801c93:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c96:	89 c3                	mov    %eax,%ebx
  801c98:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c9b:	eb 06                	jmp    801ca3 <strncmp+0x17>
		n--, p++, q++;
  801c9d:	83 c0 01             	add    $0x1,%eax
  801ca0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801ca3:	39 d8                	cmp    %ebx,%eax
  801ca5:	74 15                	je     801cbc <strncmp+0x30>
  801ca7:	0f b6 08             	movzbl (%eax),%ecx
  801caa:	84 c9                	test   %cl,%cl
  801cac:	74 04                	je     801cb2 <strncmp+0x26>
  801cae:	3a 0a                	cmp    (%edx),%cl
  801cb0:	74 eb                	je     801c9d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801cb2:	0f b6 00             	movzbl (%eax),%eax
  801cb5:	0f b6 12             	movzbl (%edx),%edx
  801cb8:	29 d0                	sub    %edx,%eax
  801cba:	eb 05                	jmp    801cc1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801cbc:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801cc1:	5b                   	pop    %ebx
  801cc2:	5d                   	pop    %ebp
  801cc3:	c3                   	ret    

00801cc4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801cc4:	55                   	push   %ebp
  801cc5:	89 e5                	mov    %esp,%ebp
  801cc7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cca:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cce:	eb 07                	jmp    801cd7 <strchr+0x13>
		if (*s == c)
  801cd0:	38 ca                	cmp    %cl,%dl
  801cd2:	74 0f                	je     801ce3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801cd4:	83 c0 01             	add    $0x1,%eax
  801cd7:	0f b6 10             	movzbl (%eax),%edx
  801cda:	84 d2                	test   %dl,%dl
  801cdc:	75 f2                	jne    801cd0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801cde:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    

00801ce5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801ce5:	55                   	push   %ebp
  801ce6:	89 e5                	mov    %esp,%ebp
  801ce8:	8b 45 08             	mov    0x8(%ebp),%eax
  801ceb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cef:	eb 03                	jmp    801cf4 <strfind+0xf>
  801cf1:	83 c0 01             	add    $0x1,%eax
  801cf4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cf7:	38 ca                	cmp    %cl,%dl
  801cf9:	74 04                	je     801cff <strfind+0x1a>
  801cfb:	84 d2                	test   %dl,%dl
  801cfd:	75 f2                	jne    801cf1 <strfind+0xc>
			break;
	return (char *) s;
}
  801cff:	5d                   	pop    %ebp
  801d00:	c3                   	ret    

00801d01 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
  801d04:	57                   	push   %edi
  801d05:	56                   	push   %esi
  801d06:	53                   	push   %ebx
  801d07:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d0d:	85 c9                	test   %ecx,%ecx
  801d0f:	74 36                	je     801d47 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d11:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d17:	75 28                	jne    801d41 <memset+0x40>
  801d19:	f6 c1 03             	test   $0x3,%cl
  801d1c:	75 23                	jne    801d41 <memset+0x40>
		c &= 0xFF;
  801d1e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d22:	89 d3                	mov    %edx,%ebx
  801d24:	c1 e3 08             	shl    $0x8,%ebx
  801d27:	89 d6                	mov    %edx,%esi
  801d29:	c1 e6 18             	shl    $0x18,%esi
  801d2c:	89 d0                	mov    %edx,%eax
  801d2e:	c1 e0 10             	shl    $0x10,%eax
  801d31:	09 f0                	or     %esi,%eax
  801d33:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d35:	89 d8                	mov    %ebx,%eax
  801d37:	09 d0                	or     %edx,%eax
  801d39:	c1 e9 02             	shr    $0x2,%ecx
  801d3c:	fc                   	cld    
  801d3d:	f3 ab                	rep stos %eax,%es:(%edi)
  801d3f:	eb 06                	jmp    801d47 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d41:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d44:	fc                   	cld    
  801d45:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d47:	89 f8                	mov    %edi,%eax
  801d49:	5b                   	pop    %ebx
  801d4a:	5e                   	pop    %esi
  801d4b:	5f                   	pop    %edi
  801d4c:	5d                   	pop    %ebp
  801d4d:	c3                   	ret    

00801d4e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
  801d51:	57                   	push   %edi
  801d52:	56                   	push   %esi
  801d53:	8b 45 08             	mov    0x8(%ebp),%eax
  801d56:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d59:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d5c:	39 c6                	cmp    %eax,%esi
  801d5e:	73 35                	jae    801d95 <memmove+0x47>
  801d60:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d63:	39 d0                	cmp    %edx,%eax
  801d65:	73 2e                	jae    801d95 <memmove+0x47>
		s += n;
		d += n;
  801d67:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d6a:	89 d6                	mov    %edx,%esi
  801d6c:	09 fe                	or     %edi,%esi
  801d6e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d74:	75 13                	jne    801d89 <memmove+0x3b>
  801d76:	f6 c1 03             	test   $0x3,%cl
  801d79:	75 0e                	jne    801d89 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d7b:	83 ef 04             	sub    $0x4,%edi
  801d7e:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d81:	c1 e9 02             	shr    $0x2,%ecx
  801d84:	fd                   	std    
  801d85:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d87:	eb 09                	jmp    801d92 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d89:	83 ef 01             	sub    $0x1,%edi
  801d8c:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d8f:	fd                   	std    
  801d90:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d92:	fc                   	cld    
  801d93:	eb 1d                	jmp    801db2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d95:	89 f2                	mov    %esi,%edx
  801d97:	09 c2                	or     %eax,%edx
  801d99:	f6 c2 03             	test   $0x3,%dl
  801d9c:	75 0f                	jne    801dad <memmove+0x5f>
  801d9e:	f6 c1 03             	test   $0x3,%cl
  801da1:	75 0a                	jne    801dad <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801da3:	c1 e9 02             	shr    $0x2,%ecx
  801da6:	89 c7                	mov    %eax,%edi
  801da8:	fc                   	cld    
  801da9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801dab:	eb 05                	jmp    801db2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801dad:	89 c7                	mov    %eax,%edi
  801daf:	fc                   	cld    
  801db0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801db2:	5e                   	pop    %esi
  801db3:	5f                   	pop    %edi
  801db4:	5d                   	pop    %ebp
  801db5:	c3                   	ret    

00801db6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801db6:	55                   	push   %ebp
  801db7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801db9:	ff 75 10             	pushl  0x10(%ebp)
  801dbc:	ff 75 0c             	pushl  0xc(%ebp)
  801dbf:	ff 75 08             	pushl  0x8(%ebp)
  801dc2:	e8 87 ff ff ff       	call   801d4e <memmove>
}
  801dc7:	c9                   	leave  
  801dc8:	c3                   	ret    

00801dc9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801dc9:	55                   	push   %ebp
  801dca:	89 e5                	mov    %esp,%ebp
  801dcc:	56                   	push   %esi
  801dcd:	53                   	push   %ebx
  801dce:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dd4:	89 c6                	mov    %eax,%esi
  801dd6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dd9:	eb 1a                	jmp    801df5 <memcmp+0x2c>
		if (*s1 != *s2)
  801ddb:	0f b6 08             	movzbl (%eax),%ecx
  801dde:	0f b6 1a             	movzbl (%edx),%ebx
  801de1:	38 d9                	cmp    %bl,%cl
  801de3:	74 0a                	je     801def <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801de5:	0f b6 c1             	movzbl %cl,%eax
  801de8:	0f b6 db             	movzbl %bl,%ebx
  801deb:	29 d8                	sub    %ebx,%eax
  801ded:	eb 0f                	jmp    801dfe <memcmp+0x35>
		s1++, s2++;
  801def:	83 c0 01             	add    $0x1,%eax
  801df2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801df5:	39 f0                	cmp    %esi,%eax
  801df7:	75 e2                	jne    801ddb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801df9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dfe:	5b                   	pop    %ebx
  801dff:	5e                   	pop    %esi
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    

00801e02 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	53                   	push   %ebx
  801e06:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e09:	89 c1                	mov    %eax,%ecx
  801e0b:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e0e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e12:	eb 0a                	jmp    801e1e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e14:	0f b6 10             	movzbl (%eax),%edx
  801e17:	39 da                	cmp    %ebx,%edx
  801e19:	74 07                	je     801e22 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e1b:	83 c0 01             	add    $0x1,%eax
  801e1e:	39 c8                	cmp    %ecx,%eax
  801e20:	72 f2                	jb     801e14 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e22:	5b                   	pop    %ebx
  801e23:	5d                   	pop    %ebp
  801e24:	c3                   	ret    

00801e25 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e25:	55                   	push   %ebp
  801e26:	89 e5                	mov    %esp,%ebp
  801e28:	57                   	push   %edi
  801e29:	56                   	push   %esi
  801e2a:	53                   	push   %ebx
  801e2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e2e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e31:	eb 03                	jmp    801e36 <strtol+0x11>
		s++;
  801e33:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e36:	0f b6 01             	movzbl (%ecx),%eax
  801e39:	3c 20                	cmp    $0x20,%al
  801e3b:	74 f6                	je     801e33 <strtol+0xe>
  801e3d:	3c 09                	cmp    $0x9,%al
  801e3f:	74 f2                	je     801e33 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e41:	3c 2b                	cmp    $0x2b,%al
  801e43:	75 0a                	jne    801e4f <strtol+0x2a>
		s++;
  801e45:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e48:	bf 00 00 00 00       	mov    $0x0,%edi
  801e4d:	eb 11                	jmp    801e60 <strtol+0x3b>
  801e4f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e54:	3c 2d                	cmp    $0x2d,%al
  801e56:	75 08                	jne    801e60 <strtol+0x3b>
		s++, neg = 1;
  801e58:	83 c1 01             	add    $0x1,%ecx
  801e5b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e60:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e66:	75 15                	jne    801e7d <strtol+0x58>
  801e68:	80 39 30             	cmpb   $0x30,(%ecx)
  801e6b:	75 10                	jne    801e7d <strtol+0x58>
  801e6d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e71:	75 7c                	jne    801eef <strtol+0xca>
		s += 2, base = 16;
  801e73:	83 c1 02             	add    $0x2,%ecx
  801e76:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e7b:	eb 16                	jmp    801e93 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e7d:	85 db                	test   %ebx,%ebx
  801e7f:	75 12                	jne    801e93 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e81:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e86:	80 39 30             	cmpb   $0x30,(%ecx)
  801e89:	75 08                	jne    801e93 <strtol+0x6e>
		s++, base = 8;
  801e8b:	83 c1 01             	add    $0x1,%ecx
  801e8e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e93:	b8 00 00 00 00       	mov    $0x0,%eax
  801e98:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e9b:	0f b6 11             	movzbl (%ecx),%edx
  801e9e:	8d 72 d0             	lea    -0x30(%edx),%esi
  801ea1:	89 f3                	mov    %esi,%ebx
  801ea3:	80 fb 09             	cmp    $0x9,%bl
  801ea6:	77 08                	ja     801eb0 <strtol+0x8b>
			dig = *s - '0';
  801ea8:	0f be d2             	movsbl %dl,%edx
  801eab:	83 ea 30             	sub    $0x30,%edx
  801eae:	eb 22                	jmp    801ed2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801eb0:	8d 72 9f             	lea    -0x61(%edx),%esi
  801eb3:	89 f3                	mov    %esi,%ebx
  801eb5:	80 fb 19             	cmp    $0x19,%bl
  801eb8:	77 08                	ja     801ec2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801eba:	0f be d2             	movsbl %dl,%edx
  801ebd:	83 ea 57             	sub    $0x57,%edx
  801ec0:	eb 10                	jmp    801ed2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801ec2:	8d 72 bf             	lea    -0x41(%edx),%esi
  801ec5:	89 f3                	mov    %esi,%ebx
  801ec7:	80 fb 19             	cmp    $0x19,%bl
  801eca:	77 16                	ja     801ee2 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801ecc:	0f be d2             	movsbl %dl,%edx
  801ecf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801ed2:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ed5:	7d 0b                	jge    801ee2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801ed7:	83 c1 01             	add    $0x1,%ecx
  801eda:	0f af 45 10          	imul   0x10(%ebp),%eax
  801ede:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801ee0:	eb b9                	jmp    801e9b <strtol+0x76>

	if (endptr)
  801ee2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ee6:	74 0d                	je     801ef5 <strtol+0xd0>
		*endptr = (char *) s;
  801ee8:	8b 75 0c             	mov    0xc(%ebp),%esi
  801eeb:	89 0e                	mov    %ecx,(%esi)
  801eed:	eb 06                	jmp    801ef5 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801eef:	85 db                	test   %ebx,%ebx
  801ef1:	74 98                	je     801e8b <strtol+0x66>
  801ef3:	eb 9e                	jmp    801e93 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801ef5:	89 c2                	mov    %eax,%edx
  801ef7:	f7 da                	neg    %edx
  801ef9:	85 ff                	test   %edi,%edi
  801efb:	0f 45 c2             	cmovne %edx,%eax
}
  801efe:	5b                   	pop    %ebx
  801eff:	5e                   	pop    %esi
  801f00:	5f                   	pop    %edi
  801f01:	5d                   	pop    %ebp
  801f02:	c3                   	ret    

00801f03 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f03:	55                   	push   %ebp
  801f04:	89 e5                	mov    %esp,%ebp
  801f06:	56                   	push   %esi
  801f07:	53                   	push   %ebx
  801f08:	8b 75 08             	mov    0x8(%ebp),%esi
  801f0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801f11:	85 c0                	test   %eax,%eax
  801f13:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f18:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801f1b:	83 ec 0c             	sub    $0xc,%esp
  801f1e:	50                   	push   %eax
  801f1f:	e8 ea e3 ff ff       	call   80030e <sys_ipc_recv>
  801f24:	83 c4 10             	add    $0x10,%esp
  801f27:	85 c0                	test   %eax,%eax
  801f29:	79 16                	jns    801f41 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801f2b:	85 f6                	test   %esi,%esi
  801f2d:	74 06                	je     801f35 <ipc_recv+0x32>
            *from_env_store = 0;
  801f2f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801f35:	85 db                	test   %ebx,%ebx
  801f37:	74 2c                	je     801f65 <ipc_recv+0x62>
            *perm_store = 0;
  801f39:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f3f:	eb 24                	jmp    801f65 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801f41:	85 f6                	test   %esi,%esi
  801f43:	74 0a                	je     801f4f <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801f45:	a1 08 40 80 00       	mov    0x804008,%eax
  801f4a:	8b 40 74             	mov    0x74(%eax),%eax
  801f4d:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801f4f:	85 db                	test   %ebx,%ebx
  801f51:	74 0a                	je     801f5d <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801f53:	a1 08 40 80 00       	mov    0x804008,%eax
  801f58:	8b 40 78             	mov    0x78(%eax),%eax
  801f5b:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801f5d:	a1 08 40 80 00       	mov    0x804008,%eax
  801f62:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801f65:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f68:	5b                   	pop    %ebx
  801f69:	5e                   	pop    %esi
  801f6a:	5d                   	pop    %ebp
  801f6b:	c3                   	ret    

00801f6c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f6c:	55                   	push   %ebp
  801f6d:	89 e5                	mov    %esp,%ebp
  801f6f:	57                   	push   %edi
  801f70:	56                   	push   %esi
  801f71:	53                   	push   %ebx
  801f72:	83 ec 0c             	sub    $0xc,%esp
  801f75:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f78:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f7b:	8b 45 10             	mov    0x10(%ebp),%eax
  801f7e:	85 c0                	test   %eax,%eax
  801f80:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801f85:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801f88:	eb 1c                	jmp    801fa6 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801f8a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f8d:	74 12                	je     801fa1 <ipc_send+0x35>
  801f8f:	50                   	push   %eax
  801f90:	68 60 27 80 00       	push   $0x802760
  801f95:	6a 3b                	push   $0x3b
  801f97:	68 76 27 80 00       	push   $0x802776
  801f9c:	e8 3e f5 ff ff       	call   8014df <_panic>
		sys_yield();
  801fa1:	e8 99 e1 ff ff       	call   80013f <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801fa6:	ff 75 14             	pushl  0x14(%ebp)
  801fa9:	53                   	push   %ebx
  801faa:	56                   	push   %esi
  801fab:	57                   	push   %edi
  801fac:	e8 3a e3 ff ff       	call   8002eb <sys_ipc_try_send>
  801fb1:	83 c4 10             	add    $0x10,%esp
  801fb4:	85 c0                	test   %eax,%eax
  801fb6:	78 d2                	js     801f8a <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801fb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fbb:	5b                   	pop    %ebx
  801fbc:	5e                   	pop    %esi
  801fbd:	5f                   	pop    %edi
  801fbe:	5d                   	pop    %ebp
  801fbf:	c3                   	ret    

00801fc0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fc0:	55                   	push   %ebp
  801fc1:	89 e5                	mov    %esp,%ebp
  801fc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fc6:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fcb:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fce:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fd4:	8b 52 50             	mov    0x50(%edx),%edx
  801fd7:	39 ca                	cmp    %ecx,%edx
  801fd9:	75 0d                	jne    801fe8 <ipc_find_env+0x28>
			return envs[i].env_id;
  801fdb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fde:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fe3:	8b 40 48             	mov    0x48(%eax),%eax
  801fe6:	eb 0f                	jmp    801ff7 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fe8:	83 c0 01             	add    $0x1,%eax
  801feb:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ff0:	75 d9                	jne    801fcb <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ff2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ff7:	5d                   	pop    %ebp
  801ff8:	c3                   	ret    

00801ff9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ff9:	55                   	push   %ebp
  801ffa:	89 e5                	mov    %esp,%ebp
  801ffc:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fff:	89 d0                	mov    %edx,%eax
  802001:	c1 e8 16             	shr    $0x16,%eax
  802004:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80200b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802010:	f6 c1 01             	test   $0x1,%cl
  802013:	74 1d                	je     802032 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802015:	c1 ea 0c             	shr    $0xc,%edx
  802018:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80201f:	f6 c2 01             	test   $0x1,%dl
  802022:	74 0e                	je     802032 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802024:	c1 ea 0c             	shr    $0xc,%edx
  802027:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80202e:	ef 
  80202f:	0f b7 c0             	movzwl %ax,%eax
}
  802032:	5d                   	pop    %ebp
  802033:	c3                   	ret    
  802034:	66 90                	xchg   %ax,%ax
  802036:	66 90                	xchg   %ax,%ax
  802038:	66 90                	xchg   %ax,%ax
  80203a:	66 90                	xchg   %ax,%ax
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
