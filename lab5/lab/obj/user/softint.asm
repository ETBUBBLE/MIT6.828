
obj/user/softint.debug：     文件格式 elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800045:	e8 ce 00 00 00       	call   800118 <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800057:	a3 04 40 80 00       	mov    %eax,0x804004

    // save the name of the program so that panic() can use it
    if (argc > 0)
  80005c:	85 db                	test   %ebx,%ebx
  80005e:	7e 07                	jle    800067 <libmain+0x2d>
        binaryname = argv[0];
  800060:	8b 06                	mov    (%esi),%eax
  800062:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  800067:	83 ec 08             	sub    $0x8,%esp
  80006a:	56                   	push   %esi
  80006b:	53                   	push   %ebx
  80006c:	e8 c2 ff ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  800071:	e8 0a 00 00 00       	call   800080 <exit>
}
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007c:	5b                   	pop    %ebx
  80007d:	5e                   	pop    %esi
  80007e:	5d                   	pop    %ebp
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800086:	e8 87 04 00 00       	call   800512 <close_all>
	sys_env_destroy(0);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	6a 00                	push   $0x0
  800090:	e8 42 00 00 00       	call   8000d7 <sys_env_destroy>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	57                   	push   %edi
  80009e:	56                   	push   %esi
  80009f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ab:	89 c3                	mov    %eax,%ebx
  8000ad:	89 c7                	mov    %eax,%edi
  8000af:	89 c6                	mov    %eax,%esi
  8000b1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000be:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c8:	89 d1                	mov    %edx,%ecx
  8000ca:	89 d3                	mov    %edx,%ebx
  8000cc:	89 d7                	mov    %edx,%edi
  8000ce:	89 d6                	mov    %edx,%esi
  8000d0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ed:	89 cb                	mov    %ecx,%ebx
  8000ef:	89 cf                	mov    %ecx,%edi
  8000f1:	89 ce                	mov    %ecx,%esi
  8000f3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	7e 17                	jle    800110 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f9:	83 ec 0c             	sub    $0xc,%esp
  8000fc:	50                   	push   %eax
  8000fd:	6a 03                	push   $0x3
  8000ff:	68 2a 1e 80 00       	push   $0x801e2a
  800104:	6a 23                	push   $0x23
  800106:	68 47 1e 80 00       	push   $0x801e47
  80010b:	e8 21 0f 00 00       	call   801031 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800113:	5b                   	pop    %ebx
  800114:	5e                   	pop    %esi
  800115:	5f                   	pop    %edi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	57                   	push   %edi
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011e:	ba 00 00 00 00       	mov    $0x0,%edx
  800123:	b8 02 00 00 00       	mov    $0x2,%eax
  800128:	89 d1                	mov    %edx,%ecx
  80012a:	89 d3                	mov    %edx,%ebx
  80012c:	89 d7                	mov    %edx,%edi
  80012e:	89 d6                	mov    %edx,%esi
  800130:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <sys_yield>:

void
sys_yield(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	57                   	push   %edi
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013d:	ba 00 00 00 00       	mov    $0x0,%edx
  800142:	b8 0b 00 00 00       	mov    $0xb,%eax
  800147:	89 d1                	mov    %edx,%ecx
  800149:	89 d3                	mov    %edx,%ebx
  80014b:	89 d7                	mov    %edx,%edi
  80014d:	89 d6                	mov    %edx,%esi
  80014f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
  80015c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015f:	be 00 00 00 00       	mov    $0x0,%esi
  800164:	b8 04 00 00 00       	mov    $0x4,%eax
  800169:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800172:	89 f7                	mov    %esi,%edi
  800174:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800176:	85 c0                	test   %eax,%eax
  800178:	7e 17                	jle    800191 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017a:	83 ec 0c             	sub    $0xc,%esp
  80017d:	50                   	push   %eax
  80017e:	6a 04                	push   $0x4
  800180:	68 2a 1e 80 00       	push   $0x801e2a
  800185:	6a 23                	push   $0x23
  800187:	68 47 1e 80 00       	push   $0x801e47
  80018c:	e8 a0 0e 00 00       	call   801031 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800194:	5b                   	pop    %ebx
  800195:	5e                   	pop    %esi
  800196:	5f                   	pop    %edi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    

00800199 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b8:	85 c0                	test   %eax,%eax
  8001ba:	7e 17                	jle    8001d3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	50                   	push   %eax
  8001c0:	6a 05                	push   $0x5
  8001c2:	68 2a 1e 80 00       	push   $0x801e2a
  8001c7:	6a 23                	push   $0x23
  8001c9:	68 47 1e 80 00       	push   $0x801e47
  8001ce:	e8 5e 0e 00 00       	call   801031 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f4:	89 df                	mov    %ebx,%edi
  8001f6:	89 de                	mov    %ebx,%esi
  8001f8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7e 17                	jle    800215 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	50                   	push   %eax
  800202:	6a 06                	push   $0x6
  800204:	68 2a 1e 80 00       	push   $0x801e2a
  800209:	6a 23                	push   $0x23
  80020b:	68 47 1e 80 00       	push   $0x801e47
  800210:	e8 1c 0e 00 00       	call   801031 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5f                   	pop    %edi
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    

0080021d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	57                   	push   %edi
  800221:	56                   	push   %esi
  800222:	53                   	push   %ebx
  800223:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800226:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022b:	b8 08 00 00 00       	mov    $0x8,%eax
  800230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800233:	8b 55 08             	mov    0x8(%ebp),%edx
  800236:	89 df                	mov    %ebx,%edi
  800238:	89 de                	mov    %ebx,%esi
  80023a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80023c:	85 c0                	test   %eax,%eax
  80023e:	7e 17                	jle    800257 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	50                   	push   %eax
  800244:	6a 08                	push   $0x8
  800246:	68 2a 1e 80 00       	push   $0x801e2a
  80024b:	6a 23                	push   $0x23
  80024d:	68 47 1e 80 00       	push   $0x801e47
  800252:	e8 da 0d 00 00       	call   801031 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026d:	b8 09 00 00 00       	mov    $0x9,%eax
  800272:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800275:	8b 55 08             	mov    0x8(%ebp),%edx
  800278:	89 df                	mov    %ebx,%edi
  80027a:	89 de                	mov    %ebx,%esi
  80027c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	7e 17                	jle    800299 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	50                   	push   %eax
  800286:	6a 09                	push   $0x9
  800288:	68 2a 1e 80 00       	push   $0x801e2a
  80028d:	6a 23                	push   $0x23
  80028f:	68 47 1e 80 00       	push   $0x801e47
  800294:	e8 98 0d 00 00       	call   801031 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800299:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029c:	5b                   	pop    %ebx
  80029d:	5e                   	pop    %esi
  80029e:	5f                   	pop    %edi
  80029f:	5d                   	pop    %ebp
  8002a0:	c3                   	ret    

008002a1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
  8002a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ba:	89 df                	mov    %ebx,%edi
  8002bc:	89 de                	mov    %ebx,%esi
  8002be:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002c0:	85 c0                	test   %eax,%eax
  8002c2:	7e 17                	jle    8002db <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c4:	83 ec 0c             	sub    $0xc,%esp
  8002c7:	50                   	push   %eax
  8002c8:	6a 0a                	push   $0xa
  8002ca:	68 2a 1e 80 00       	push   $0x801e2a
  8002cf:	6a 23                	push   $0x23
  8002d1:	68 47 1e 80 00       	push   $0x801e47
  8002d6:	e8 56 0d 00 00       	call   801031 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002de:	5b                   	pop    %ebx
  8002df:	5e                   	pop    %esi
  8002e0:	5f                   	pop    %edi
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	57                   	push   %edi
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e9:	be 00 00 00 00       	mov    $0x0,%esi
  8002ee:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002ff:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
  80030c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800314:	b8 0d 00 00 00       	mov    $0xd,%eax
  800319:	8b 55 08             	mov    0x8(%ebp),%edx
  80031c:	89 cb                	mov    %ecx,%ebx
  80031e:	89 cf                	mov    %ecx,%edi
  800320:	89 ce                	mov    %ecx,%esi
  800322:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800324:	85 c0                	test   %eax,%eax
  800326:	7e 17                	jle    80033f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800328:	83 ec 0c             	sub    $0xc,%esp
  80032b:	50                   	push   %eax
  80032c:	6a 0d                	push   $0xd
  80032e:	68 2a 1e 80 00       	push   $0x801e2a
  800333:	6a 23                	push   $0x23
  800335:	68 47 1e 80 00       	push   $0x801e47
  80033a:	e8 f2 0c 00 00       	call   801031 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800342:	5b                   	pop    %ebx
  800343:	5e                   	pop    %esi
  800344:	5f                   	pop    %edi
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    

00800347 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80034a:	8b 45 08             	mov    0x8(%ebp),%eax
  80034d:	05 00 00 00 30       	add    $0x30000000,%eax
  800352:	c1 e8 0c             	shr    $0xc,%eax
}
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
  800362:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800367:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80036c:	5d                   	pop    %ebp
  80036d:	c3                   	ret    

0080036e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800374:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800379:	89 c2                	mov    %eax,%edx
  80037b:	c1 ea 16             	shr    $0x16,%edx
  80037e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800385:	f6 c2 01             	test   $0x1,%dl
  800388:	74 11                	je     80039b <fd_alloc+0x2d>
  80038a:	89 c2                	mov    %eax,%edx
  80038c:	c1 ea 0c             	shr    $0xc,%edx
  80038f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800396:	f6 c2 01             	test   $0x1,%dl
  800399:	75 09                	jne    8003a4 <fd_alloc+0x36>
			*fd_store = fd;
  80039b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80039d:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a2:	eb 17                	jmp    8003bb <fd_alloc+0x4d>
  8003a4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003a9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ae:	75 c9                	jne    800379 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003b6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c3:	83 f8 1f             	cmp    $0x1f,%eax
  8003c6:	77 36                	ja     8003fe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c8:	c1 e0 0c             	shl    $0xc,%eax
  8003cb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d0:	89 c2                	mov    %eax,%edx
  8003d2:	c1 ea 16             	shr    $0x16,%edx
  8003d5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003dc:	f6 c2 01             	test   $0x1,%dl
  8003df:	74 24                	je     800405 <fd_lookup+0x48>
  8003e1:	89 c2                	mov    %eax,%edx
  8003e3:	c1 ea 0c             	shr    $0xc,%edx
  8003e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ed:	f6 c2 01             	test   $0x1,%dl
  8003f0:	74 1a                	je     80040c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f5:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fc:	eb 13                	jmp    800411 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8003fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800403:	eb 0c                	jmp    800411 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800405:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040a:	eb 05                	jmp    800411 <fd_lookup+0x54>
  80040c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800411:	5d                   	pop    %ebp
  800412:	c3                   	ret    

00800413 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800413:	55                   	push   %ebp
  800414:	89 e5                	mov    %esp,%ebp
  800416:	83 ec 08             	sub    $0x8,%esp
  800419:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80041c:	ba d4 1e 80 00       	mov    $0x801ed4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800421:	eb 13                	jmp    800436 <dev_lookup+0x23>
  800423:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800426:	39 08                	cmp    %ecx,(%eax)
  800428:	75 0c                	jne    800436 <dev_lookup+0x23>
			*dev = devtab[i];
  80042a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80042f:	b8 00 00 00 00       	mov    $0x0,%eax
  800434:	eb 2e                	jmp    800464 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800436:	8b 02                	mov    (%edx),%eax
  800438:	85 c0                	test   %eax,%eax
  80043a:	75 e7                	jne    800423 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80043c:	a1 04 40 80 00       	mov    0x804004,%eax
  800441:	8b 40 48             	mov    0x48(%eax),%eax
  800444:	83 ec 04             	sub    $0x4,%esp
  800447:	51                   	push   %ecx
  800448:	50                   	push   %eax
  800449:	68 58 1e 80 00       	push   $0x801e58
  80044e:	e8 b7 0c 00 00       	call   80110a <cprintf>
	*dev = 0;
  800453:	8b 45 0c             	mov    0xc(%ebp),%eax
  800456:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80045c:	83 c4 10             	add    $0x10,%esp
  80045f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800464:	c9                   	leave  
  800465:	c3                   	ret    

00800466 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800466:	55                   	push   %ebp
  800467:	89 e5                	mov    %esp,%ebp
  800469:	56                   	push   %esi
  80046a:	53                   	push   %ebx
  80046b:	83 ec 10             	sub    $0x10,%esp
  80046e:	8b 75 08             	mov    0x8(%ebp),%esi
  800471:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800474:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800477:	50                   	push   %eax
  800478:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80047e:	c1 e8 0c             	shr    $0xc,%eax
  800481:	50                   	push   %eax
  800482:	e8 36 ff ff ff       	call   8003bd <fd_lookup>
  800487:	83 c4 08             	add    $0x8,%esp
  80048a:	85 c0                	test   %eax,%eax
  80048c:	78 05                	js     800493 <fd_close+0x2d>
	    || fd != fd2)
  80048e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800491:	74 0c                	je     80049f <fd_close+0x39>
		return (must_exist ? r : 0);
  800493:	84 db                	test   %bl,%bl
  800495:	ba 00 00 00 00       	mov    $0x0,%edx
  80049a:	0f 44 c2             	cmove  %edx,%eax
  80049d:	eb 41                	jmp    8004e0 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80049f:	83 ec 08             	sub    $0x8,%esp
  8004a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a5:	50                   	push   %eax
  8004a6:	ff 36                	pushl  (%esi)
  8004a8:	e8 66 ff ff ff       	call   800413 <dev_lookup>
  8004ad:	89 c3                	mov    %eax,%ebx
  8004af:	83 c4 10             	add    $0x10,%esp
  8004b2:	85 c0                	test   %eax,%eax
  8004b4:	78 1a                	js     8004d0 <fd_close+0x6a>
		if (dev->dev_close)
  8004b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004b9:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004bc:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c1:	85 c0                	test   %eax,%eax
  8004c3:	74 0b                	je     8004d0 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c5:	83 ec 0c             	sub    $0xc,%esp
  8004c8:	56                   	push   %esi
  8004c9:	ff d0                	call   *%eax
  8004cb:	89 c3                	mov    %eax,%ebx
  8004cd:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	56                   	push   %esi
  8004d4:	6a 00                	push   $0x0
  8004d6:	e8 00 fd ff ff       	call   8001db <sys_page_unmap>
	return r;
  8004db:	83 c4 10             	add    $0x10,%esp
  8004de:	89 d8                	mov    %ebx,%eax
}
  8004e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e3:	5b                   	pop    %ebx
  8004e4:	5e                   	pop    %esi
  8004e5:	5d                   	pop    %ebp
  8004e6:	c3                   	ret    

008004e7 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004e7:	55                   	push   %ebp
  8004e8:	89 e5                	mov    %esp,%ebp
  8004ea:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f0:	50                   	push   %eax
  8004f1:	ff 75 08             	pushl  0x8(%ebp)
  8004f4:	e8 c4 fe ff ff       	call   8003bd <fd_lookup>
  8004f9:	83 c4 08             	add    $0x8,%esp
  8004fc:	85 c0                	test   %eax,%eax
  8004fe:	78 10                	js     800510 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	6a 01                	push   $0x1
  800505:	ff 75 f4             	pushl  -0xc(%ebp)
  800508:	e8 59 ff ff ff       	call   800466 <fd_close>
  80050d:	83 c4 10             	add    $0x10,%esp
}
  800510:	c9                   	leave  
  800511:	c3                   	ret    

00800512 <close_all>:

void
close_all(void)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	53                   	push   %ebx
  800516:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800519:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	53                   	push   %ebx
  800522:	e8 c0 ff ff ff       	call   8004e7 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800527:	83 c3 01             	add    $0x1,%ebx
  80052a:	83 c4 10             	add    $0x10,%esp
  80052d:	83 fb 20             	cmp    $0x20,%ebx
  800530:	75 ec                	jne    80051e <close_all+0xc>
		close(i);
}
  800532:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800535:	c9                   	leave  
  800536:	c3                   	ret    

00800537 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800537:	55                   	push   %ebp
  800538:	89 e5                	mov    %esp,%ebp
  80053a:	57                   	push   %edi
  80053b:	56                   	push   %esi
  80053c:	53                   	push   %ebx
  80053d:	83 ec 2c             	sub    $0x2c,%esp
  800540:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800543:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800546:	50                   	push   %eax
  800547:	ff 75 08             	pushl  0x8(%ebp)
  80054a:	e8 6e fe ff ff       	call   8003bd <fd_lookup>
  80054f:	83 c4 08             	add    $0x8,%esp
  800552:	85 c0                	test   %eax,%eax
  800554:	0f 88 c1 00 00 00    	js     80061b <dup+0xe4>
		return r;
	close(newfdnum);
  80055a:	83 ec 0c             	sub    $0xc,%esp
  80055d:	56                   	push   %esi
  80055e:	e8 84 ff ff ff       	call   8004e7 <close>

	newfd = INDEX2FD(newfdnum);
  800563:	89 f3                	mov    %esi,%ebx
  800565:	c1 e3 0c             	shl    $0xc,%ebx
  800568:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80056e:	83 c4 04             	add    $0x4,%esp
  800571:	ff 75 e4             	pushl  -0x1c(%ebp)
  800574:	e8 de fd ff ff       	call   800357 <fd2data>
  800579:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80057b:	89 1c 24             	mov    %ebx,(%esp)
  80057e:	e8 d4 fd ff ff       	call   800357 <fd2data>
  800583:	83 c4 10             	add    $0x10,%esp
  800586:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800589:	89 f8                	mov    %edi,%eax
  80058b:	c1 e8 16             	shr    $0x16,%eax
  80058e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800595:	a8 01                	test   $0x1,%al
  800597:	74 37                	je     8005d0 <dup+0x99>
  800599:	89 f8                	mov    %edi,%eax
  80059b:	c1 e8 0c             	shr    $0xc,%eax
  80059e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a5:	f6 c2 01             	test   $0x1,%dl
  8005a8:	74 26                	je     8005d0 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005aa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b1:	83 ec 0c             	sub    $0xc,%esp
  8005b4:	25 07 0e 00 00       	and    $0xe07,%eax
  8005b9:	50                   	push   %eax
  8005ba:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005bd:	6a 00                	push   $0x0
  8005bf:	57                   	push   %edi
  8005c0:	6a 00                	push   $0x0
  8005c2:	e8 d2 fb ff ff       	call   800199 <sys_page_map>
  8005c7:	89 c7                	mov    %eax,%edi
  8005c9:	83 c4 20             	add    $0x20,%esp
  8005cc:	85 c0                	test   %eax,%eax
  8005ce:	78 2e                	js     8005fe <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d3:	89 d0                	mov    %edx,%eax
  8005d5:	c1 e8 0c             	shr    $0xc,%eax
  8005d8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e7:	50                   	push   %eax
  8005e8:	53                   	push   %ebx
  8005e9:	6a 00                	push   $0x0
  8005eb:	52                   	push   %edx
  8005ec:	6a 00                	push   $0x0
  8005ee:	e8 a6 fb ff ff       	call   800199 <sys_page_map>
  8005f3:	89 c7                	mov    %eax,%edi
  8005f5:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005f8:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fa:	85 ff                	test   %edi,%edi
  8005fc:	79 1d                	jns    80061b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8005fe:	83 ec 08             	sub    $0x8,%esp
  800601:	53                   	push   %ebx
  800602:	6a 00                	push   $0x0
  800604:	e8 d2 fb ff ff       	call   8001db <sys_page_unmap>
	sys_page_unmap(0, nva);
  800609:	83 c4 08             	add    $0x8,%esp
  80060c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80060f:	6a 00                	push   $0x0
  800611:	e8 c5 fb ff ff       	call   8001db <sys_page_unmap>
	return r;
  800616:	83 c4 10             	add    $0x10,%esp
  800619:	89 f8                	mov    %edi,%eax
}
  80061b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061e:	5b                   	pop    %ebx
  80061f:	5e                   	pop    %esi
  800620:	5f                   	pop    %edi
  800621:	5d                   	pop    %ebp
  800622:	c3                   	ret    

00800623 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800623:	55                   	push   %ebp
  800624:	89 e5                	mov    %esp,%ebp
  800626:	53                   	push   %ebx
  800627:	83 ec 14             	sub    $0x14,%esp
  80062a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80062d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800630:	50                   	push   %eax
  800631:	53                   	push   %ebx
  800632:	e8 86 fd ff ff       	call   8003bd <fd_lookup>
  800637:	83 c4 08             	add    $0x8,%esp
  80063a:	89 c2                	mov    %eax,%edx
  80063c:	85 c0                	test   %eax,%eax
  80063e:	78 6d                	js     8006ad <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800646:	50                   	push   %eax
  800647:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064a:	ff 30                	pushl  (%eax)
  80064c:	e8 c2 fd ff ff       	call   800413 <dev_lookup>
  800651:	83 c4 10             	add    $0x10,%esp
  800654:	85 c0                	test   %eax,%eax
  800656:	78 4c                	js     8006a4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800658:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065b:	8b 42 08             	mov    0x8(%edx),%eax
  80065e:	83 e0 03             	and    $0x3,%eax
  800661:	83 f8 01             	cmp    $0x1,%eax
  800664:	75 21                	jne    800687 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800666:	a1 04 40 80 00       	mov    0x804004,%eax
  80066b:	8b 40 48             	mov    0x48(%eax),%eax
  80066e:	83 ec 04             	sub    $0x4,%esp
  800671:	53                   	push   %ebx
  800672:	50                   	push   %eax
  800673:	68 99 1e 80 00       	push   $0x801e99
  800678:	e8 8d 0a 00 00       	call   80110a <cprintf>
		return -E_INVAL;
  80067d:	83 c4 10             	add    $0x10,%esp
  800680:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800685:	eb 26                	jmp    8006ad <read+0x8a>
	}
	if (!dev->dev_read)
  800687:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068a:	8b 40 08             	mov    0x8(%eax),%eax
  80068d:	85 c0                	test   %eax,%eax
  80068f:	74 17                	je     8006a8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800691:	83 ec 04             	sub    $0x4,%esp
  800694:	ff 75 10             	pushl  0x10(%ebp)
  800697:	ff 75 0c             	pushl  0xc(%ebp)
  80069a:	52                   	push   %edx
  80069b:	ff d0                	call   *%eax
  80069d:	89 c2                	mov    %eax,%edx
  80069f:	83 c4 10             	add    $0x10,%esp
  8006a2:	eb 09                	jmp    8006ad <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a4:	89 c2                	mov    %eax,%edx
  8006a6:	eb 05                	jmp    8006ad <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ad:	89 d0                	mov    %edx,%eax
  8006af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b2:	c9                   	leave  
  8006b3:	c3                   	ret    

008006b4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	57                   	push   %edi
  8006b8:	56                   	push   %esi
  8006b9:	53                   	push   %ebx
  8006ba:	83 ec 0c             	sub    $0xc,%esp
  8006bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c8:	eb 21                	jmp    8006eb <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ca:	83 ec 04             	sub    $0x4,%esp
  8006cd:	89 f0                	mov    %esi,%eax
  8006cf:	29 d8                	sub    %ebx,%eax
  8006d1:	50                   	push   %eax
  8006d2:	89 d8                	mov    %ebx,%eax
  8006d4:	03 45 0c             	add    0xc(%ebp),%eax
  8006d7:	50                   	push   %eax
  8006d8:	57                   	push   %edi
  8006d9:	e8 45 ff ff ff       	call   800623 <read>
		if (m < 0)
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	85 c0                	test   %eax,%eax
  8006e3:	78 10                	js     8006f5 <readn+0x41>
			return m;
		if (m == 0)
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	74 0a                	je     8006f3 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e9:	01 c3                	add    %eax,%ebx
  8006eb:	39 f3                	cmp    %esi,%ebx
  8006ed:	72 db                	jb     8006ca <readn+0x16>
  8006ef:	89 d8                	mov    %ebx,%eax
  8006f1:	eb 02                	jmp    8006f5 <readn+0x41>
  8006f3:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f8:	5b                   	pop    %ebx
  8006f9:	5e                   	pop    %esi
  8006fa:	5f                   	pop    %edi
  8006fb:	5d                   	pop    %ebp
  8006fc:	c3                   	ret    

008006fd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006fd:	55                   	push   %ebp
  8006fe:	89 e5                	mov    %esp,%ebp
  800700:	53                   	push   %ebx
  800701:	83 ec 14             	sub    $0x14,%esp
  800704:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800707:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80070a:	50                   	push   %eax
  80070b:	53                   	push   %ebx
  80070c:	e8 ac fc ff ff       	call   8003bd <fd_lookup>
  800711:	83 c4 08             	add    $0x8,%esp
  800714:	89 c2                	mov    %eax,%edx
  800716:	85 c0                	test   %eax,%eax
  800718:	78 68                	js     800782 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80071a:	83 ec 08             	sub    $0x8,%esp
  80071d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800720:	50                   	push   %eax
  800721:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800724:	ff 30                	pushl  (%eax)
  800726:	e8 e8 fc ff ff       	call   800413 <dev_lookup>
  80072b:	83 c4 10             	add    $0x10,%esp
  80072e:	85 c0                	test   %eax,%eax
  800730:	78 47                	js     800779 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800732:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800735:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800739:	75 21                	jne    80075c <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073b:	a1 04 40 80 00       	mov    0x804004,%eax
  800740:	8b 40 48             	mov    0x48(%eax),%eax
  800743:	83 ec 04             	sub    $0x4,%esp
  800746:	53                   	push   %ebx
  800747:	50                   	push   %eax
  800748:	68 b5 1e 80 00       	push   $0x801eb5
  80074d:	e8 b8 09 00 00       	call   80110a <cprintf>
		return -E_INVAL;
  800752:	83 c4 10             	add    $0x10,%esp
  800755:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80075a:	eb 26                	jmp    800782 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80075c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80075f:	8b 52 0c             	mov    0xc(%edx),%edx
  800762:	85 d2                	test   %edx,%edx
  800764:	74 17                	je     80077d <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800766:	83 ec 04             	sub    $0x4,%esp
  800769:	ff 75 10             	pushl  0x10(%ebp)
  80076c:	ff 75 0c             	pushl  0xc(%ebp)
  80076f:	50                   	push   %eax
  800770:	ff d2                	call   *%edx
  800772:	89 c2                	mov    %eax,%edx
  800774:	83 c4 10             	add    $0x10,%esp
  800777:	eb 09                	jmp    800782 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800779:	89 c2                	mov    %eax,%edx
  80077b:	eb 05                	jmp    800782 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80077d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800782:	89 d0                	mov    %edx,%eax
  800784:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800787:	c9                   	leave  
  800788:	c3                   	ret    

00800789 <seek>:

int
seek(int fdnum, off_t offset)
{
  800789:	55                   	push   %ebp
  80078a:	89 e5                	mov    %esp,%ebp
  80078c:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80078f:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800792:	50                   	push   %eax
  800793:	ff 75 08             	pushl  0x8(%ebp)
  800796:	e8 22 fc ff ff       	call   8003bd <fd_lookup>
  80079b:	83 c4 08             	add    $0x8,%esp
  80079e:	85 c0                	test   %eax,%eax
  8007a0:	78 0e                	js     8007b0 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    

008007b2 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	53                   	push   %ebx
  8007b6:	83 ec 14             	sub    $0x14,%esp
  8007b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007bc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007bf:	50                   	push   %eax
  8007c0:	53                   	push   %ebx
  8007c1:	e8 f7 fb ff ff       	call   8003bd <fd_lookup>
  8007c6:	83 c4 08             	add    $0x8,%esp
  8007c9:	89 c2                	mov    %eax,%edx
  8007cb:	85 c0                	test   %eax,%eax
  8007cd:	78 65                	js     800834 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007cf:	83 ec 08             	sub    $0x8,%esp
  8007d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d5:	50                   	push   %eax
  8007d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d9:	ff 30                	pushl  (%eax)
  8007db:	e8 33 fc ff ff       	call   800413 <dev_lookup>
  8007e0:	83 c4 10             	add    $0x10,%esp
  8007e3:	85 c0                	test   %eax,%eax
  8007e5:	78 44                	js     80082b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ee:	75 21                	jne    800811 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f0:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f5:	8b 40 48             	mov    0x48(%eax),%eax
  8007f8:	83 ec 04             	sub    $0x4,%esp
  8007fb:	53                   	push   %ebx
  8007fc:	50                   	push   %eax
  8007fd:	68 78 1e 80 00       	push   $0x801e78
  800802:	e8 03 09 00 00       	call   80110a <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800807:	83 c4 10             	add    $0x10,%esp
  80080a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80080f:	eb 23                	jmp    800834 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800811:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800814:	8b 52 18             	mov    0x18(%edx),%edx
  800817:	85 d2                	test   %edx,%edx
  800819:	74 14                	je     80082f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081b:	83 ec 08             	sub    $0x8,%esp
  80081e:	ff 75 0c             	pushl  0xc(%ebp)
  800821:	50                   	push   %eax
  800822:	ff d2                	call   *%edx
  800824:	89 c2                	mov    %eax,%edx
  800826:	83 c4 10             	add    $0x10,%esp
  800829:	eb 09                	jmp    800834 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082b:	89 c2                	mov    %eax,%edx
  80082d:	eb 05                	jmp    800834 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80082f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800834:	89 d0                	mov    %edx,%eax
  800836:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800839:	c9                   	leave  
  80083a:	c3                   	ret    

0080083b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	83 ec 14             	sub    $0x14,%esp
  800842:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800845:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800848:	50                   	push   %eax
  800849:	ff 75 08             	pushl  0x8(%ebp)
  80084c:	e8 6c fb ff ff       	call   8003bd <fd_lookup>
  800851:	83 c4 08             	add    $0x8,%esp
  800854:	89 c2                	mov    %eax,%edx
  800856:	85 c0                	test   %eax,%eax
  800858:	78 58                	js     8008b2 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085a:	83 ec 08             	sub    $0x8,%esp
  80085d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800860:	50                   	push   %eax
  800861:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800864:	ff 30                	pushl  (%eax)
  800866:	e8 a8 fb ff ff       	call   800413 <dev_lookup>
  80086b:	83 c4 10             	add    $0x10,%esp
  80086e:	85 c0                	test   %eax,%eax
  800870:	78 37                	js     8008a9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800872:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800875:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800879:	74 32                	je     8008ad <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80087e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800885:	00 00 00 
	stat->st_isdir = 0;
  800888:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80088f:	00 00 00 
	stat->st_dev = dev;
  800892:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800898:	83 ec 08             	sub    $0x8,%esp
  80089b:	53                   	push   %ebx
  80089c:	ff 75 f0             	pushl  -0x10(%ebp)
  80089f:	ff 50 14             	call   *0x14(%eax)
  8008a2:	89 c2                	mov    %eax,%edx
  8008a4:	83 c4 10             	add    $0x10,%esp
  8008a7:	eb 09                	jmp    8008b2 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a9:	89 c2                	mov    %eax,%edx
  8008ab:	eb 05                	jmp    8008b2 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ad:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b2:	89 d0                	mov    %edx,%eax
  8008b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008b7:	c9                   	leave  
  8008b8:	c3                   	ret    

008008b9 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008b9:	55                   	push   %ebp
  8008ba:	89 e5                	mov    %esp,%ebp
  8008bc:	56                   	push   %esi
  8008bd:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008be:	83 ec 08             	sub    $0x8,%esp
  8008c1:	6a 00                	push   $0x0
  8008c3:	ff 75 08             	pushl  0x8(%ebp)
  8008c6:	e8 e3 01 00 00       	call   800aae <open>
  8008cb:	89 c3                	mov    %eax,%ebx
  8008cd:	83 c4 10             	add    $0x10,%esp
  8008d0:	85 c0                	test   %eax,%eax
  8008d2:	78 1b                	js     8008ef <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d4:	83 ec 08             	sub    $0x8,%esp
  8008d7:	ff 75 0c             	pushl  0xc(%ebp)
  8008da:	50                   	push   %eax
  8008db:	e8 5b ff ff ff       	call   80083b <fstat>
  8008e0:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e2:	89 1c 24             	mov    %ebx,(%esp)
  8008e5:	e8 fd fb ff ff       	call   8004e7 <close>
	return r;
  8008ea:	83 c4 10             	add    $0x10,%esp
  8008ed:	89 f0                	mov    %esi,%eax
}
  8008ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f2:	5b                   	pop    %ebx
  8008f3:	5e                   	pop    %esi
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	56                   	push   %esi
  8008fa:	53                   	push   %ebx
  8008fb:	89 c6                	mov    %eax,%esi
  8008fd:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008ff:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800906:	75 12                	jne    80091a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800908:	83 ec 0c             	sub    $0xc,%esp
  80090b:	6a 01                	push   $0x1
  80090d:	e8 00 12 00 00       	call   801b12 <ipc_find_env>
  800912:	a3 00 40 80 00       	mov    %eax,0x804000
  800917:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80091a:	6a 07                	push   $0x7
  80091c:	68 00 50 80 00       	push   $0x805000
  800921:	56                   	push   %esi
  800922:	ff 35 00 40 80 00    	pushl  0x804000
  800928:	e8 91 11 00 00       	call   801abe <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80092d:	83 c4 0c             	add    $0xc,%esp
  800930:	6a 00                	push   $0x0
  800932:	53                   	push   %ebx
  800933:	6a 00                	push   $0x0
  800935:	e8 1b 11 00 00       	call   801a55 <ipc_recv>
}
  80093a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093d:	5b                   	pop    %ebx
  80093e:	5e                   	pop    %esi
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8b 40 0c             	mov    0xc(%eax),%eax
  80094d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800952:	8b 45 0c             	mov    0xc(%ebp),%eax
  800955:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80095a:	ba 00 00 00 00       	mov    $0x0,%edx
  80095f:	b8 02 00 00 00       	mov    $0x2,%eax
  800964:	e8 8d ff ff ff       	call   8008f6 <fsipc>
}
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800971:	8b 45 08             	mov    0x8(%ebp),%eax
  800974:	8b 40 0c             	mov    0xc(%eax),%eax
  800977:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80097c:	ba 00 00 00 00       	mov    $0x0,%edx
  800981:	b8 06 00 00 00       	mov    $0x6,%eax
  800986:	e8 6b ff ff ff       	call   8008f6 <fsipc>
}
  80098b:	c9                   	leave  
  80098c:	c3                   	ret    

0080098d <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	53                   	push   %ebx
  800991:	83 ec 04             	sub    $0x4,%esp
  800994:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 40 0c             	mov    0xc(%eax),%eax
  80099d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ac:	e8 45 ff ff ff       	call   8008f6 <fsipc>
  8009b1:	85 c0                	test   %eax,%eax
  8009b3:	78 2c                	js     8009e1 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b5:	83 ec 08             	sub    $0x8,%esp
  8009b8:	68 00 50 80 00       	push   $0x805000
  8009bd:	53                   	push   %ebx
  8009be:	e8 4b 0d 00 00       	call   80170e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c3:	a1 80 50 80 00       	mov    0x805080,%eax
  8009c8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009ce:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009d9:	83 c4 10             	add    $0x10,%esp
  8009dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e4:	c9                   	leave  
  8009e5:	c3                   	ret    

008009e6 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	83 ec 0c             	sub    $0xc,%esp
  8009ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ef:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009f4:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009f9:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ff:	8b 52 0c             	mov    0xc(%edx),%edx
  800a02:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a08:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a0d:	50                   	push   %eax
  800a0e:	ff 75 0c             	pushl  0xc(%ebp)
  800a11:	68 08 50 80 00       	push   $0x805008
  800a16:	e8 85 0e 00 00       	call   8018a0 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a20:	b8 04 00 00 00       	mov    $0x4,%eax
  800a25:	e8 cc fe ff ff       	call   8008f6 <fsipc>
	//panic("devfile_write not implemented");
}
  800a2a:	c9                   	leave  
  800a2b:	c3                   	ret    

00800a2c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	56                   	push   %esi
  800a30:	53                   	push   %ebx
  800a31:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a34:	8b 45 08             	mov    0x8(%ebp),%eax
  800a37:	8b 40 0c             	mov    0xc(%eax),%eax
  800a3a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a3f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a45:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a4f:	e8 a2 fe ff ff       	call   8008f6 <fsipc>
  800a54:	89 c3                	mov    %eax,%ebx
  800a56:	85 c0                	test   %eax,%eax
  800a58:	78 4b                	js     800aa5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a5a:	39 c6                	cmp    %eax,%esi
  800a5c:	73 16                	jae    800a74 <devfile_read+0x48>
  800a5e:	68 e4 1e 80 00       	push   $0x801ee4
  800a63:	68 eb 1e 80 00       	push   $0x801eeb
  800a68:	6a 7c                	push   $0x7c
  800a6a:	68 00 1f 80 00       	push   $0x801f00
  800a6f:	e8 bd 05 00 00       	call   801031 <_panic>
	assert(r <= PGSIZE);
  800a74:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a79:	7e 16                	jle    800a91 <devfile_read+0x65>
  800a7b:	68 0b 1f 80 00       	push   $0x801f0b
  800a80:	68 eb 1e 80 00       	push   $0x801eeb
  800a85:	6a 7d                	push   $0x7d
  800a87:	68 00 1f 80 00       	push   $0x801f00
  800a8c:	e8 a0 05 00 00       	call   801031 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a91:	83 ec 04             	sub    $0x4,%esp
  800a94:	50                   	push   %eax
  800a95:	68 00 50 80 00       	push   $0x805000
  800a9a:	ff 75 0c             	pushl  0xc(%ebp)
  800a9d:	e8 fe 0d 00 00       	call   8018a0 <memmove>
	return r;
  800aa2:	83 c4 10             	add    $0x10,%esp
}
  800aa5:	89 d8                	mov    %ebx,%eax
  800aa7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aaa:	5b                   	pop    %ebx
  800aab:	5e                   	pop    %esi
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    

00800aae <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800aae:	55                   	push   %ebp
  800aaf:	89 e5                	mov    %esp,%ebp
  800ab1:	53                   	push   %ebx
  800ab2:	83 ec 20             	sub    $0x20,%esp
  800ab5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ab8:	53                   	push   %ebx
  800ab9:	e8 17 0c 00 00       	call   8016d5 <strlen>
  800abe:	83 c4 10             	add    $0x10,%esp
  800ac1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ac6:	7f 67                	jg     800b2f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ac8:	83 ec 0c             	sub    $0xc,%esp
  800acb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ace:	50                   	push   %eax
  800acf:	e8 9a f8 ff ff       	call   80036e <fd_alloc>
  800ad4:	83 c4 10             	add    $0x10,%esp
		return r;
  800ad7:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ad9:	85 c0                	test   %eax,%eax
  800adb:	78 57                	js     800b34 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800add:	83 ec 08             	sub    $0x8,%esp
  800ae0:	53                   	push   %ebx
  800ae1:	68 00 50 80 00       	push   $0x805000
  800ae6:	e8 23 0c 00 00       	call   80170e <strcpy>
	fsipcbuf.open.req_omode = mode;
  800aeb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aee:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800af3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800af6:	b8 01 00 00 00       	mov    $0x1,%eax
  800afb:	e8 f6 fd ff ff       	call   8008f6 <fsipc>
  800b00:	89 c3                	mov    %eax,%ebx
  800b02:	83 c4 10             	add    $0x10,%esp
  800b05:	85 c0                	test   %eax,%eax
  800b07:	79 14                	jns    800b1d <open+0x6f>
		fd_close(fd, 0);
  800b09:	83 ec 08             	sub    $0x8,%esp
  800b0c:	6a 00                	push   $0x0
  800b0e:	ff 75 f4             	pushl  -0xc(%ebp)
  800b11:	e8 50 f9 ff ff       	call   800466 <fd_close>
		return r;
  800b16:	83 c4 10             	add    $0x10,%esp
  800b19:	89 da                	mov    %ebx,%edx
  800b1b:	eb 17                	jmp    800b34 <open+0x86>
	}

	return fd2num(fd);
  800b1d:	83 ec 0c             	sub    $0xc,%esp
  800b20:	ff 75 f4             	pushl  -0xc(%ebp)
  800b23:	e8 1f f8 ff ff       	call   800347 <fd2num>
  800b28:	89 c2                	mov    %eax,%edx
  800b2a:	83 c4 10             	add    $0x10,%esp
  800b2d:	eb 05                	jmp    800b34 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b2f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b34:	89 d0                	mov    %edx,%eax
  800b36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b39:	c9                   	leave  
  800b3a:	c3                   	ret    

00800b3b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b41:	ba 00 00 00 00       	mov    $0x0,%edx
  800b46:	b8 08 00 00 00       	mov    $0x8,%eax
  800b4b:	e8 a6 fd ff ff       	call   8008f6 <fsipc>
}
  800b50:	c9                   	leave  
  800b51:	c3                   	ret    

00800b52 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	56                   	push   %esi
  800b56:	53                   	push   %ebx
  800b57:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b5a:	83 ec 0c             	sub    $0xc,%esp
  800b5d:	ff 75 08             	pushl  0x8(%ebp)
  800b60:	e8 f2 f7 ff ff       	call   800357 <fd2data>
  800b65:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b67:	83 c4 08             	add    $0x8,%esp
  800b6a:	68 17 1f 80 00       	push   $0x801f17
  800b6f:	53                   	push   %ebx
  800b70:	e8 99 0b 00 00       	call   80170e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b75:	8b 46 04             	mov    0x4(%esi),%eax
  800b78:	2b 06                	sub    (%esi),%eax
  800b7a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b80:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b87:	00 00 00 
	stat->st_dev = &devpipe;
  800b8a:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b91:	30 80 00 
	return 0;
}
  800b94:	b8 00 00 00 00       	mov    $0x0,%eax
  800b99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    

00800ba0 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	53                   	push   %ebx
  800ba4:	83 ec 0c             	sub    $0xc,%esp
  800ba7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800baa:	53                   	push   %ebx
  800bab:	6a 00                	push   $0x0
  800bad:	e8 29 f6 ff ff       	call   8001db <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bb2:	89 1c 24             	mov    %ebx,(%esp)
  800bb5:	e8 9d f7 ff ff       	call   800357 <fd2data>
  800bba:	83 c4 08             	add    $0x8,%esp
  800bbd:	50                   	push   %eax
  800bbe:	6a 00                	push   $0x0
  800bc0:	e8 16 f6 ff ff       	call   8001db <sys_page_unmap>
}
  800bc5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bc8:	c9                   	leave  
  800bc9:	c3                   	ret    

00800bca <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	57                   	push   %edi
  800bce:	56                   	push   %esi
  800bcf:	53                   	push   %ebx
  800bd0:	83 ec 1c             	sub    $0x1c,%esp
  800bd3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bd6:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bd8:	a1 04 40 80 00       	mov    0x804004,%eax
  800bdd:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800be0:	83 ec 0c             	sub    $0xc,%esp
  800be3:	ff 75 e0             	pushl  -0x20(%ebp)
  800be6:	e8 60 0f 00 00       	call   801b4b <pageref>
  800beb:	89 c3                	mov    %eax,%ebx
  800bed:	89 3c 24             	mov    %edi,(%esp)
  800bf0:	e8 56 0f 00 00       	call   801b4b <pageref>
  800bf5:	83 c4 10             	add    $0x10,%esp
  800bf8:	39 c3                	cmp    %eax,%ebx
  800bfa:	0f 94 c1             	sete   %cl
  800bfd:	0f b6 c9             	movzbl %cl,%ecx
  800c00:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c03:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c09:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c0c:	39 ce                	cmp    %ecx,%esi
  800c0e:	74 1b                	je     800c2b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c10:	39 c3                	cmp    %eax,%ebx
  800c12:	75 c4                	jne    800bd8 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c14:	8b 42 58             	mov    0x58(%edx),%eax
  800c17:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c1a:	50                   	push   %eax
  800c1b:	56                   	push   %esi
  800c1c:	68 1e 1f 80 00       	push   $0x801f1e
  800c21:	e8 e4 04 00 00       	call   80110a <cprintf>
  800c26:	83 c4 10             	add    $0x10,%esp
  800c29:	eb ad                	jmp    800bd8 <_pipeisclosed+0xe>
	}
}
  800c2b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
  800c3c:	83 ec 28             	sub    $0x28,%esp
  800c3f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c42:	56                   	push   %esi
  800c43:	e8 0f f7 ff ff       	call   800357 <fd2data>
  800c48:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c4a:	83 c4 10             	add    $0x10,%esp
  800c4d:	bf 00 00 00 00       	mov    $0x0,%edi
  800c52:	eb 4b                	jmp    800c9f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c54:	89 da                	mov    %ebx,%edx
  800c56:	89 f0                	mov    %esi,%eax
  800c58:	e8 6d ff ff ff       	call   800bca <_pipeisclosed>
  800c5d:	85 c0                	test   %eax,%eax
  800c5f:	75 48                	jne    800ca9 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c61:	e8 d1 f4 ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c66:	8b 43 04             	mov    0x4(%ebx),%eax
  800c69:	8b 0b                	mov    (%ebx),%ecx
  800c6b:	8d 51 20             	lea    0x20(%ecx),%edx
  800c6e:	39 d0                	cmp    %edx,%eax
  800c70:	73 e2                	jae    800c54 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c75:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c79:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c7c:	89 c2                	mov    %eax,%edx
  800c7e:	c1 fa 1f             	sar    $0x1f,%edx
  800c81:	89 d1                	mov    %edx,%ecx
  800c83:	c1 e9 1b             	shr    $0x1b,%ecx
  800c86:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c89:	83 e2 1f             	and    $0x1f,%edx
  800c8c:	29 ca                	sub    %ecx,%edx
  800c8e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c92:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c96:	83 c0 01             	add    $0x1,%eax
  800c99:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c9c:	83 c7 01             	add    $0x1,%edi
  800c9f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ca2:	75 c2                	jne    800c66 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ca4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca7:	eb 05                	jmp    800cae <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ca9:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5f                   	pop    %edi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	57                   	push   %edi
  800cba:	56                   	push   %esi
  800cbb:	53                   	push   %ebx
  800cbc:	83 ec 18             	sub    $0x18,%esp
  800cbf:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cc2:	57                   	push   %edi
  800cc3:	e8 8f f6 ff ff       	call   800357 <fd2data>
  800cc8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cca:	83 c4 10             	add    $0x10,%esp
  800ccd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd2:	eb 3d                	jmp    800d11 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cd4:	85 db                	test   %ebx,%ebx
  800cd6:	74 04                	je     800cdc <devpipe_read+0x26>
				return i;
  800cd8:	89 d8                	mov    %ebx,%eax
  800cda:	eb 44                	jmp    800d20 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cdc:	89 f2                	mov    %esi,%edx
  800cde:	89 f8                	mov    %edi,%eax
  800ce0:	e8 e5 fe ff ff       	call   800bca <_pipeisclosed>
  800ce5:	85 c0                	test   %eax,%eax
  800ce7:	75 32                	jne    800d1b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800ce9:	e8 49 f4 ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cee:	8b 06                	mov    (%esi),%eax
  800cf0:	3b 46 04             	cmp    0x4(%esi),%eax
  800cf3:	74 df                	je     800cd4 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cf5:	99                   	cltd   
  800cf6:	c1 ea 1b             	shr    $0x1b,%edx
  800cf9:	01 d0                	add    %edx,%eax
  800cfb:	83 e0 1f             	and    $0x1f,%eax
  800cfe:	29 d0                	sub    %edx,%eax
  800d00:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d08:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d0b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d0e:	83 c3 01             	add    $0x1,%ebx
  800d11:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d14:	75 d8                	jne    800cee <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d16:	8b 45 10             	mov    0x10(%ebp),%eax
  800d19:	eb 05                	jmp    800d20 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d1b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d23:	5b                   	pop    %ebx
  800d24:	5e                   	pop    %esi
  800d25:	5f                   	pop    %edi
  800d26:	5d                   	pop    %ebp
  800d27:	c3                   	ret    

00800d28 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d33:	50                   	push   %eax
  800d34:	e8 35 f6 ff ff       	call   80036e <fd_alloc>
  800d39:	83 c4 10             	add    $0x10,%esp
  800d3c:	89 c2                	mov    %eax,%edx
  800d3e:	85 c0                	test   %eax,%eax
  800d40:	0f 88 2c 01 00 00    	js     800e72 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d46:	83 ec 04             	sub    $0x4,%esp
  800d49:	68 07 04 00 00       	push   $0x407
  800d4e:	ff 75 f4             	pushl  -0xc(%ebp)
  800d51:	6a 00                	push   $0x0
  800d53:	e8 fe f3 ff ff       	call   800156 <sys_page_alloc>
  800d58:	83 c4 10             	add    $0x10,%esp
  800d5b:	89 c2                	mov    %eax,%edx
  800d5d:	85 c0                	test   %eax,%eax
  800d5f:	0f 88 0d 01 00 00    	js     800e72 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d65:	83 ec 0c             	sub    $0xc,%esp
  800d68:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d6b:	50                   	push   %eax
  800d6c:	e8 fd f5 ff ff       	call   80036e <fd_alloc>
  800d71:	89 c3                	mov    %eax,%ebx
  800d73:	83 c4 10             	add    $0x10,%esp
  800d76:	85 c0                	test   %eax,%eax
  800d78:	0f 88 e2 00 00 00    	js     800e60 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d7e:	83 ec 04             	sub    $0x4,%esp
  800d81:	68 07 04 00 00       	push   $0x407
  800d86:	ff 75 f0             	pushl  -0x10(%ebp)
  800d89:	6a 00                	push   $0x0
  800d8b:	e8 c6 f3 ff ff       	call   800156 <sys_page_alloc>
  800d90:	89 c3                	mov    %eax,%ebx
  800d92:	83 c4 10             	add    $0x10,%esp
  800d95:	85 c0                	test   %eax,%eax
  800d97:	0f 88 c3 00 00 00    	js     800e60 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d9d:	83 ec 0c             	sub    $0xc,%esp
  800da0:	ff 75 f4             	pushl  -0xc(%ebp)
  800da3:	e8 af f5 ff ff       	call   800357 <fd2data>
  800da8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800daa:	83 c4 0c             	add    $0xc,%esp
  800dad:	68 07 04 00 00       	push   $0x407
  800db2:	50                   	push   %eax
  800db3:	6a 00                	push   $0x0
  800db5:	e8 9c f3 ff ff       	call   800156 <sys_page_alloc>
  800dba:	89 c3                	mov    %eax,%ebx
  800dbc:	83 c4 10             	add    $0x10,%esp
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	0f 88 89 00 00 00    	js     800e50 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc7:	83 ec 0c             	sub    $0xc,%esp
  800dca:	ff 75 f0             	pushl  -0x10(%ebp)
  800dcd:	e8 85 f5 ff ff       	call   800357 <fd2data>
  800dd2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dd9:	50                   	push   %eax
  800dda:	6a 00                	push   $0x0
  800ddc:	56                   	push   %esi
  800ddd:	6a 00                	push   $0x0
  800ddf:	e8 b5 f3 ff ff       	call   800199 <sys_page_map>
  800de4:	89 c3                	mov    %eax,%ebx
  800de6:	83 c4 20             	add    $0x20,%esp
  800de9:	85 c0                	test   %eax,%eax
  800deb:	78 55                	js     800e42 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800ded:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800df3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800df6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dfb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e02:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e0b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e10:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e17:	83 ec 0c             	sub    $0xc,%esp
  800e1a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e1d:	e8 25 f5 ff ff       	call   800347 <fd2num>
  800e22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e25:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e27:	83 c4 04             	add    $0x4,%esp
  800e2a:	ff 75 f0             	pushl  -0x10(%ebp)
  800e2d:	e8 15 f5 ff ff       	call   800347 <fd2num>
  800e32:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e35:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e38:	83 c4 10             	add    $0x10,%esp
  800e3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e40:	eb 30                	jmp    800e72 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e42:	83 ec 08             	sub    $0x8,%esp
  800e45:	56                   	push   %esi
  800e46:	6a 00                	push   $0x0
  800e48:	e8 8e f3 ff ff       	call   8001db <sys_page_unmap>
  800e4d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e50:	83 ec 08             	sub    $0x8,%esp
  800e53:	ff 75 f0             	pushl  -0x10(%ebp)
  800e56:	6a 00                	push   $0x0
  800e58:	e8 7e f3 ff ff       	call   8001db <sys_page_unmap>
  800e5d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e60:	83 ec 08             	sub    $0x8,%esp
  800e63:	ff 75 f4             	pushl  -0xc(%ebp)
  800e66:	6a 00                	push   $0x0
  800e68:	e8 6e f3 ff ff       	call   8001db <sys_page_unmap>
  800e6d:	83 c4 10             	add    $0x10,%esp
  800e70:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e72:	89 d0                	mov    %edx,%eax
  800e74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e77:	5b                   	pop    %ebx
  800e78:	5e                   	pop    %esi
  800e79:	5d                   	pop    %ebp
  800e7a:	c3                   	ret    

00800e7b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e7b:	55                   	push   %ebp
  800e7c:	89 e5                	mov    %esp,%ebp
  800e7e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e84:	50                   	push   %eax
  800e85:	ff 75 08             	pushl  0x8(%ebp)
  800e88:	e8 30 f5 ff ff       	call   8003bd <fd_lookup>
  800e8d:	83 c4 10             	add    $0x10,%esp
  800e90:	85 c0                	test   %eax,%eax
  800e92:	78 18                	js     800eac <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e94:	83 ec 0c             	sub    $0xc,%esp
  800e97:	ff 75 f4             	pushl  -0xc(%ebp)
  800e9a:	e8 b8 f4 ff ff       	call   800357 <fd2data>
	return _pipeisclosed(fd, p);
  800e9f:	89 c2                	mov    %eax,%edx
  800ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ea4:	e8 21 fd ff ff       	call   800bca <_pipeisclosed>
  800ea9:	83 c4 10             	add    $0x10,%esp
}
  800eac:	c9                   	leave  
  800ead:	c3                   	ret    

00800eae <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb6:	5d                   	pop    %ebp
  800eb7:	c3                   	ret    

00800eb8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ebe:	68 36 1f 80 00       	push   $0x801f36
  800ec3:	ff 75 0c             	pushl  0xc(%ebp)
  800ec6:	e8 43 08 00 00       	call   80170e <strcpy>
	return 0;
}
  800ecb:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed0:	c9                   	leave  
  800ed1:	c3                   	ret    

00800ed2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	57                   	push   %edi
  800ed6:	56                   	push   %esi
  800ed7:	53                   	push   %ebx
  800ed8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ede:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ee3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ee9:	eb 2d                	jmp    800f18 <devcons_write+0x46>
		m = n - tot;
  800eeb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eee:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ef0:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ef3:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800ef8:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800efb:	83 ec 04             	sub    $0x4,%esp
  800efe:	53                   	push   %ebx
  800eff:	03 45 0c             	add    0xc(%ebp),%eax
  800f02:	50                   	push   %eax
  800f03:	57                   	push   %edi
  800f04:	e8 97 09 00 00       	call   8018a0 <memmove>
		sys_cputs(buf, m);
  800f09:	83 c4 08             	add    $0x8,%esp
  800f0c:	53                   	push   %ebx
  800f0d:	57                   	push   %edi
  800f0e:	e8 87 f1 ff ff       	call   80009a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f13:	01 de                	add    %ebx,%esi
  800f15:	83 c4 10             	add    $0x10,%esp
  800f18:	89 f0                	mov    %esi,%eax
  800f1a:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f1d:	72 cc                	jb     800eeb <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f22:	5b                   	pop    %ebx
  800f23:	5e                   	pop    %esi
  800f24:	5f                   	pop    %edi
  800f25:	5d                   	pop    %ebp
  800f26:	c3                   	ret    

00800f27 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f27:	55                   	push   %ebp
  800f28:	89 e5                	mov    %esp,%ebp
  800f2a:	83 ec 08             	sub    $0x8,%esp
  800f2d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f32:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f36:	74 2a                	je     800f62 <devcons_read+0x3b>
  800f38:	eb 05                	jmp    800f3f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f3a:	e8 f8 f1 ff ff       	call   800137 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f3f:	e8 74 f1 ff ff       	call   8000b8 <sys_cgetc>
  800f44:	85 c0                	test   %eax,%eax
  800f46:	74 f2                	je     800f3a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f48:	85 c0                	test   %eax,%eax
  800f4a:	78 16                	js     800f62 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f4c:	83 f8 04             	cmp    $0x4,%eax
  800f4f:	74 0c                	je     800f5d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f51:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f54:	88 02                	mov    %al,(%edx)
	return 1;
  800f56:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5b:	eb 05                	jmp    800f62 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f5d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f62:	c9                   	leave  
  800f63:	c3                   	ret    

00800f64 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f70:	6a 01                	push   $0x1
  800f72:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f75:	50                   	push   %eax
  800f76:	e8 1f f1 ff ff       	call   80009a <sys_cputs>
}
  800f7b:	83 c4 10             	add    $0x10,%esp
  800f7e:	c9                   	leave  
  800f7f:	c3                   	ret    

00800f80 <getchar>:

int
getchar(void)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f86:	6a 01                	push   $0x1
  800f88:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f8b:	50                   	push   %eax
  800f8c:	6a 00                	push   $0x0
  800f8e:	e8 90 f6 ff ff       	call   800623 <read>
	if (r < 0)
  800f93:	83 c4 10             	add    $0x10,%esp
  800f96:	85 c0                	test   %eax,%eax
  800f98:	78 0f                	js     800fa9 <getchar+0x29>
		return r;
	if (r < 1)
  800f9a:	85 c0                	test   %eax,%eax
  800f9c:	7e 06                	jle    800fa4 <getchar+0x24>
		return -E_EOF;
	return c;
  800f9e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fa2:	eb 05                	jmp    800fa9 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fa4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fa9:	c9                   	leave  
  800faa:	c3                   	ret    

00800fab <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb4:	50                   	push   %eax
  800fb5:	ff 75 08             	pushl  0x8(%ebp)
  800fb8:	e8 00 f4 ff ff       	call   8003bd <fd_lookup>
  800fbd:	83 c4 10             	add    $0x10,%esp
  800fc0:	85 c0                	test   %eax,%eax
  800fc2:	78 11                	js     800fd5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fcd:	39 10                	cmp    %edx,(%eax)
  800fcf:	0f 94 c0             	sete   %al
  800fd2:	0f b6 c0             	movzbl %al,%eax
}
  800fd5:	c9                   	leave  
  800fd6:	c3                   	ret    

00800fd7 <opencons>:

int
opencons(void)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fdd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe0:	50                   	push   %eax
  800fe1:	e8 88 f3 ff ff       	call   80036e <fd_alloc>
  800fe6:	83 c4 10             	add    $0x10,%esp
		return r;
  800fe9:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800feb:	85 c0                	test   %eax,%eax
  800fed:	78 3e                	js     80102d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fef:	83 ec 04             	sub    $0x4,%esp
  800ff2:	68 07 04 00 00       	push   $0x407
  800ff7:	ff 75 f4             	pushl  -0xc(%ebp)
  800ffa:	6a 00                	push   $0x0
  800ffc:	e8 55 f1 ff ff       	call   800156 <sys_page_alloc>
  801001:	83 c4 10             	add    $0x10,%esp
		return r;
  801004:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801006:	85 c0                	test   %eax,%eax
  801008:	78 23                	js     80102d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80100a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801010:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801013:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801015:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801018:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80101f:	83 ec 0c             	sub    $0xc,%esp
  801022:	50                   	push   %eax
  801023:	e8 1f f3 ff ff       	call   800347 <fd2num>
  801028:	89 c2                	mov    %eax,%edx
  80102a:	83 c4 10             	add    $0x10,%esp
}
  80102d:	89 d0                	mov    %edx,%eax
  80102f:	c9                   	leave  
  801030:	c3                   	ret    

00801031 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	56                   	push   %esi
  801035:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801036:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801039:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80103f:	e8 d4 f0 ff ff       	call   800118 <sys_getenvid>
  801044:	83 ec 0c             	sub    $0xc,%esp
  801047:	ff 75 0c             	pushl  0xc(%ebp)
  80104a:	ff 75 08             	pushl  0x8(%ebp)
  80104d:	56                   	push   %esi
  80104e:	50                   	push   %eax
  80104f:	68 44 1f 80 00       	push   $0x801f44
  801054:	e8 b1 00 00 00       	call   80110a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801059:	83 c4 18             	add    $0x18,%esp
  80105c:	53                   	push   %ebx
  80105d:	ff 75 10             	pushl  0x10(%ebp)
  801060:	e8 54 00 00 00       	call   8010b9 <vcprintf>
	cprintf("\n");
  801065:	c7 04 24 2f 1f 80 00 	movl   $0x801f2f,(%esp)
  80106c:	e8 99 00 00 00       	call   80110a <cprintf>
  801071:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801074:	cc                   	int3   
  801075:	eb fd                	jmp    801074 <_panic+0x43>

00801077 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	53                   	push   %ebx
  80107b:	83 ec 04             	sub    $0x4,%esp
  80107e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801081:	8b 13                	mov    (%ebx),%edx
  801083:	8d 42 01             	lea    0x1(%edx),%eax
  801086:	89 03                	mov    %eax,(%ebx)
  801088:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80108b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80108f:	3d ff 00 00 00       	cmp    $0xff,%eax
  801094:	75 1a                	jne    8010b0 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801096:	83 ec 08             	sub    $0x8,%esp
  801099:	68 ff 00 00 00       	push   $0xff
  80109e:	8d 43 08             	lea    0x8(%ebx),%eax
  8010a1:	50                   	push   %eax
  8010a2:	e8 f3 ef ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  8010a7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010ad:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010b0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b7:	c9                   	leave  
  8010b8:	c3                   	ret    

008010b9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010b9:	55                   	push   %ebp
  8010ba:	89 e5                	mov    %esp,%ebp
  8010bc:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010c2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010c9:	00 00 00 
	b.cnt = 0;
  8010cc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010d3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010d6:	ff 75 0c             	pushl  0xc(%ebp)
  8010d9:	ff 75 08             	pushl  0x8(%ebp)
  8010dc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010e2:	50                   	push   %eax
  8010e3:	68 77 10 80 00       	push   $0x801077
  8010e8:	e8 1a 01 00 00       	call   801207 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010ed:	83 c4 08             	add    $0x8,%esp
  8010f0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010f6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010fc:	50                   	push   %eax
  8010fd:	e8 98 ef ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  801102:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801108:	c9                   	leave  
  801109:	c3                   	ret    

0080110a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80110a:	55                   	push   %ebp
  80110b:	89 e5                	mov    %esp,%ebp
  80110d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801110:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801113:	50                   	push   %eax
  801114:	ff 75 08             	pushl  0x8(%ebp)
  801117:	e8 9d ff ff ff       	call   8010b9 <vcprintf>
	va_end(ap);

	return cnt;
}
  80111c:	c9                   	leave  
  80111d:	c3                   	ret    

0080111e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80111e:	55                   	push   %ebp
  80111f:	89 e5                	mov    %esp,%ebp
  801121:	57                   	push   %edi
  801122:	56                   	push   %esi
  801123:	53                   	push   %ebx
  801124:	83 ec 1c             	sub    $0x1c,%esp
  801127:	89 c7                	mov    %eax,%edi
  801129:	89 d6                	mov    %edx,%esi
  80112b:	8b 45 08             	mov    0x8(%ebp),%eax
  80112e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801131:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801134:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801137:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80113a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80113f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801142:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801145:	39 d3                	cmp    %edx,%ebx
  801147:	72 05                	jb     80114e <printnum+0x30>
  801149:	39 45 10             	cmp    %eax,0x10(%ebp)
  80114c:	77 45                	ja     801193 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80114e:	83 ec 0c             	sub    $0xc,%esp
  801151:	ff 75 18             	pushl  0x18(%ebp)
  801154:	8b 45 14             	mov    0x14(%ebp),%eax
  801157:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80115a:	53                   	push   %ebx
  80115b:	ff 75 10             	pushl  0x10(%ebp)
  80115e:	83 ec 08             	sub    $0x8,%esp
  801161:	ff 75 e4             	pushl  -0x1c(%ebp)
  801164:	ff 75 e0             	pushl  -0x20(%ebp)
  801167:	ff 75 dc             	pushl  -0x24(%ebp)
  80116a:	ff 75 d8             	pushl  -0x28(%ebp)
  80116d:	e8 1e 0a 00 00       	call   801b90 <__udivdi3>
  801172:	83 c4 18             	add    $0x18,%esp
  801175:	52                   	push   %edx
  801176:	50                   	push   %eax
  801177:	89 f2                	mov    %esi,%edx
  801179:	89 f8                	mov    %edi,%eax
  80117b:	e8 9e ff ff ff       	call   80111e <printnum>
  801180:	83 c4 20             	add    $0x20,%esp
  801183:	eb 18                	jmp    80119d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801185:	83 ec 08             	sub    $0x8,%esp
  801188:	56                   	push   %esi
  801189:	ff 75 18             	pushl  0x18(%ebp)
  80118c:	ff d7                	call   *%edi
  80118e:	83 c4 10             	add    $0x10,%esp
  801191:	eb 03                	jmp    801196 <printnum+0x78>
  801193:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801196:	83 eb 01             	sub    $0x1,%ebx
  801199:	85 db                	test   %ebx,%ebx
  80119b:	7f e8                	jg     801185 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80119d:	83 ec 08             	sub    $0x8,%esp
  8011a0:	56                   	push   %esi
  8011a1:	83 ec 04             	sub    $0x4,%esp
  8011a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8011aa:	ff 75 dc             	pushl  -0x24(%ebp)
  8011ad:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b0:	e8 0b 0b 00 00       	call   801cc0 <__umoddi3>
  8011b5:	83 c4 14             	add    $0x14,%esp
  8011b8:	0f be 80 67 1f 80 00 	movsbl 0x801f67(%eax),%eax
  8011bf:	50                   	push   %eax
  8011c0:	ff d7                	call   *%edi
}
  8011c2:	83 c4 10             	add    $0x10,%esp
  8011c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c8:	5b                   	pop    %ebx
  8011c9:	5e                   	pop    %esi
  8011ca:	5f                   	pop    %edi
  8011cb:	5d                   	pop    %ebp
  8011cc:	c3                   	ret    

008011cd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011d3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011d7:	8b 10                	mov    (%eax),%edx
  8011d9:	3b 50 04             	cmp    0x4(%eax),%edx
  8011dc:	73 0a                	jae    8011e8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011de:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011e1:	89 08                	mov    %ecx,(%eax)
  8011e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e6:	88 02                	mov    %al,(%edx)
}
  8011e8:	5d                   	pop    %ebp
  8011e9:	c3                   	ret    

008011ea <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
  8011ed:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011f3:	50                   	push   %eax
  8011f4:	ff 75 10             	pushl  0x10(%ebp)
  8011f7:	ff 75 0c             	pushl  0xc(%ebp)
  8011fa:	ff 75 08             	pushl  0x8(%ebp)
  8011fd:	e8 05 00 00 00       	call   801207 <vprintfmt>
	va_end(ap);
}
  801202:	83 c4 10             	add    $0x10,%esp
  801205:	c9                   	leave  
  801206:	c3                   	ret    

00801207 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801207:	55                   	push   %ebp
  801208:	89 e5                	mov    %esp,%ebp
  80120a:	57                   	push   %edi
  80120b:	56                   	push   %esi
  80120c:	53                   	push   %ebx
  80120d:	83 ec 2c             	sub    $0x2c,%esp
  801210:	8b 75 08             	mov    0x8(%ebp),%esi
  801213:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801216:	8b 7d 10             	mov    0x10(%ebp),%edi
  801219:	eb 12                	jmp    80122d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80121b:	85 c0                	test   %eax,%eax
  80121d:	0f 84 42 04 00 00    	je     801665 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  801223:	83 ec 08             	sub    $0x8,%esp
  801226:	53                   	push   %ebx
  801227:	50                   	push   %eax
  801228:	ff d6                	call   *%esi
  80122a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80122d:	83 c7 01             	add    $0x1,%edi
  801230:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801234:	83 f8 25             	cmp    $0x25,%eax
  801237:	75 e2                	jne    80121b <vprintfmt+0x14>
  801239:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80123d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801244:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80124b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801252:	b9 00 00 00 00       	mov    $0x0,%ecx
  801257:	eb 07                	jmp    801260 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801259:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80125c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801260:	8d 47 01             	lea    0x1(%edi),%eax
  801263:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801266:	0f b6 07             	movzbl (%edi),%eax
  801269:	0f b6 d0             	movzbl %al,%edx
  80126c:	83 e8 23             	sub    $0x23,%eax
  80126f:	3c 55                	cmp    $0x55,%al
  801271:	0f 87 d3 03 00 00    	ja     80164a <vprintfmt+0x443>
  801277:	0f b6 c0             	movzbl %al,%eax
  80127a:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  801281:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801284:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801288:	eb d6                	jmp    801260 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80128a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80128d:	b8 00 00 00 00       	mov    $0x0,%eax
  801292:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801295:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801298:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80129c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80129f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8012a2:	83 f9 09             	cmp    $0x9,%ecx
  8012a5:	77 3f                	ja     8012e6 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012a7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012aa:	eb e9                	jmp    801295 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8012af:	8b 00                	mov    (%eax),%eax
  8012b1:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8012b7:	8d 40 04             	lea    0x4(%eax),%eax
  8012ba:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012c0:	eb 2a                	jmp    8012ec <vprintfmt+0xe5>
  8012c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012c5:	85 c0                	test   %eax,%eax
  8012c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8012cc:	0f 49 d0             	cmovns %eax,%edx
  8012cf:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012d5:	eb 89                	jmp    801260 <vprintfmt+0x59>
  8012d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012da:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012e1:	e9 7a ff ff ff       	jmp    801260 <vprintfmt+0x59>
  8012e6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012e9:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8012ec:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012f0:	0f 89 6a ff ff ff    	jns    801260 <vprintfmt+0x59>
				width = precision, precision = -1;
  8012f6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8012f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012fc:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801303:	e9 58 ff ff ff       	jmp    801260 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801308:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80130b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80130e:	e9 4d ff ff ff       	jmp    801260 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801313:	8b 45 14             	mov    0x14(%ebp),%eax
  801316:	8d 78 04             	lea    0x4(%eax),%edi
  801319:	83 ec 08             	sub    $0x8,%esp
  80131c:	53                   	push   %ebx
  80131d:	ff 30                	pushl  (%eax)
  80131f:	ff d6                	call   *%esi
			break;
  801321:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801324:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801327:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80132a:	e9 fe fe ff ff       	jmp    80122d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80132f:	8b 45 14             	mov    0x14(%ebp),%eax
  801332:	8d 78 04             	lea    0x4(%eax),%edi
  801335:	8b 00                	mov    (%eax),%eax
  801337:	99                   	cltd   
  801338:	31 d0                	xor    %edx,%eax
  80133a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80133c:	83 f8 0f             	cmp    $0xf,%eax
  80133f:	7f 0b                	jg     80134c <vprintfmt+0x145>
  801341:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  801348:	85 d2                	test   %edx,%edx
  80134a:	75 1b                	jne    801367 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80134c:	50                   	push   %eax
  80134d:	68 7f 1f 80 00       	push   $0x801f7f
  801352:	53                   	push   %ebx
  801353:	56                   	push   %esi
  801354:	e8 91 fe ff ff       	call   8011ea <printfmt>
  801359:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80135c:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801362:	e9 c6 fe ff ff       	jmp    80122d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801367:	52                   	push   %edx
  801368:	68 fd 1e 80 00       	push   $0x801efd
  80136d:	53                   	push   %ebx
  80136e:	56                   	push   %esi
  80136f:	e8 76 fe ff ff       	call   8011ea <printfmt>
  801374:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801377:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80137d:	e9 ab fe ff ff       	jmp    80122d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801382:	8b 45 14             	mov    0x14(%ebp),%eax
  801385:	83 c0 04             	add    $0x4,%eax
  801388:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80138b:	8b 45 14             	mov    0x14(%ebp),%eax
  80138e:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801390:	85 ff                	test   %edi,%edi
  801392:	b8 78 1f 80 00       	mov    $0x801f78,%eax
  801397:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80139a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80139e:	0f 8e 94 00 00 00    	jle    801438 <vprintfmt+0x231>
  8013a4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013a8:	0f 84 98 00 00 00    	je     801446 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013ae:	83 ec 08             	sub    $0x8,%esp
  8013b1:	ff 75 d0             	pushl  -0x30(%ebp)
  8013b4:	57                   	push   %edi
  8013b5:	e8 33 03 00 00       	call   8016ed <strnlen>
  8013ba:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013bd:	29 c1                	sub    %eax,%ecx
  8013bf:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013c2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013c5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013cc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013cf:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013d1:	eb 0f                	jmp    8013e2 <vprintfmt+0x1db>
					putch(padc, putdat);
  8013d3:	83 ec 08             	sub    $0x8,%esp
  8013d6:	53                   	push   %ebx
  8013d7:	ff 75 e0             	pushl  -0x20(%ebp)
  8013da:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013dc:	83 ef 01             	sub    $0x1,%edi
  8013df:	83 c4 10             	add    $0x10,%esp
  8013e2:	85 ff                	test   %edi,%edi
  8013e4:	7f ed                	jg     8013d3 <vprintfmt+0x1cc>
  8013e6:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013e9:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013ec:	85 c9                	test   %ecx,%ecx
  8013ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f3:	0f 49 c1             	cmovns %ecx,%eax
  8013f6:	29 c1                	sub    %eax,%ecx
  8013f8:	89 75 08             	mov    %esi,0x8(%ebp)
  8013fb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8013fe:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801401:	89 cb                	mov    %ecx,%ebx
  801403:	eb 4d                	jmp    801452 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801405:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801409:	74 1b                	je     801426 <vprintfmt+0x21f>
  80140b:	0f be c0             	movsbl %al,%eax
  80140e:	83 e8 20             	sub    $0x20,%eax
  801411:	83 f8 5e             	cmp    $0x5e,%eax
  801414:	76 10                	jbe    801426 <vprintfmt+0x21f>
					putch('?', putdat);
  801416:	83 ec 08             	sub    $0x8,%esp
  801419:	ff 75 0c             	pushl  0xc(%ebp)
  80141c:	6a 3f                	push   $0x3f
  80141e:	ff 55 08             	call   *0x8(%ebp)
  801421:	83 c4 10             	add    $0x10,%esp
  801424:	eb 0d                	jmp    801433 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  801426:	83 ec 08             	sub    $0x8,%esp
  801429:	ff 75 0c             	pushl  0xc(%ebp)
  80142c:	52                   	push   %edx
  80142d:	ff 55 08             	call   *0x8(%ebp)
  801430:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801433:	83 eb 01             	sub    $0x1,%ebx
  801436:	eb 1a                	jmp    801452 <vprintfmt+0x24b>
  801438:	89 75 08             	mov    %esi,0x8(%ebp)
  80143b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80143e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801441:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801444:	eb 0c                	jmp    801452 <vprintfmt+0x24b>
  801446:	89 75 08             	mov    %esi,0x8(%ebp)
  801449:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80144c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80144f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801452:	83 c7 01             	add    $0x1,%edi
  801455:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801459:	0f be d0             	movsbl %al,%edx
  80145c:	85 d2                	test   %edx,%edx
  80145e:	74 23                	je     801483 <vprintfmt+0x27c>
  801460:	85 f6                	test   %esi,%esi
  801462:	78 a1                	js     801405 <vprintfmt+0x1fe>
  801464:	83 ee 01             	sub    $0x1,%esi
  801467:	79 9c                	jns    801405 <vprintfmt+0x1fe>
  801469:	89 df                	mov    %ebx,%edi
  80146b:	8b 75 08             	mov    0x8(%ebp),%esi
  80146e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801471:	eb 18                	jmp    80148b <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801473:	83 ec 08             	sub    $0x8,%esp
  801476:	53                   	push   %ebx
  801477:	6a 20                	push   $0x20
  801479:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80147b:	83 ef 01             	sub    $0x1,%edi
  80147e:	83 c4 10             	add    $0x10,%esp
  801481:	eb 08                	jmp    80148b <vprintfmt+0x284>
  801483:	89 df                	mov    %ebx,%edi
  801485:	8b 75 08             	mov    0x8(%ebp),%esi
  801488:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80148b:	85 ff                	test   %edi,%edi
  80148d:	7f e4                	jg     801473 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80148f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801492:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801495:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801498:	e9 90 fd ff ff       	jmp    80122d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80149d:	83 f9 01             	cmp    $0x1,%ecx
  8014a0:	7e 19                	jle    8014bb <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8014a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a5:	8b 50 04             	mov    0x4(%eax),%edx
  8014a8:	8b 00                	mov    (%eax),%eax
  8014aa:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ad:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b3:	8d 40 08             	lea    0x8(%eax),%eax
  8014b6:	89 45 14             	mov    %eax,0x14(%ebp)
  8014b9:	eb 38                	jmp    8014f3 <vprintfmt+0x2ec>
	else if (lflag)
  8014bb:	85 c9                	test   %ecx,%ecx
  8014bd:	74 1b                	je     8014da <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8014bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c2:	8b 00                	mov    (%eax),%eax
  8014c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014c7:	89 c1                	mov    %eax,%ecx
  8014c9:	c1 f9 1f             	sar    $0x1f,%ecx
  8014cc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d2:	8d 40 04             	lea    0x4(%eax),%eax
  8014d5:	89 45 14             	mov    %eax,0x14(%ebp)
  8014d8:	eb 19                	jmp    8014f3 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8014da:	8b 45 14             	mov    0x14(%ebp),%eax
  8014dd:	8b 00                	mov    (%eax),%eax
  8014df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014e2:	89 c1                	mov    %eax,%ecx
  8014e4:	c1 f9 1f             	sar    $0x1f,%ecx
  8014e7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ed:	8d 40 04             	lea    0x4(%eax),%eax
  8014f0:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8014f3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014f6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8014f9:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8014fe:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801502:	0f 89 0e 01 00 00    	jns    801616 <vprintfmt+0x40f>
				putch('-', putdat);
  801508:	83 ec 08             	sub    $0x8,%esp
  80150b:	53                   	push   %ebx
  80150c:	6a 2d                	push   $0x2d
  80150e:	ff d6                	call   *%esi
				num = -(long long) num;
  801510:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801513:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801516:	f7 da                	neg    %edx
  801518:	83 d1 00             	adc    $0x0,%ecx
  80151b:	f7 d9                	neg    %ecx
  80151d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801520:	b8 0a 00 00 00       	mov    $0xa,%eax
  801525:	e9 ec 00 00 00       	jmp    801616 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80152a:	83 f9 01             	cmp    $0x1,%ecx
  80152d:	7e 18                	jle    801547 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  80152f:	8b 45 14             	mov    0x14(%ebp),%eax
  801532:	8b 10                	mov    (%eax),%edx
  801534:	8b 48 04             	mov    0x4(%eax),%ecx
  801537:	8d 40 08             	lea    0x8(%eax),%eax
  80153a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80153d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801542:	e9 cf 00 00 00       	jmp    801616 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801547:	85 c9                	test   %ecx,%ecx
  801549:	74 1a                	je     801565 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80154b:	8b 45 14             	mov    0x14(%ebp),%eax
  80154e:	8b 10                	mov    (%eax),%edx
  801550:	b9 00 00 00 00       	mov    $0x0,%ecx
  801555:	8d 40 04             	lea    0x4(%eax),%eax
  801558:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80155b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801560:	e9 b1 00 00 00       	jmp    801616 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801565:	8b 45 14             	mov    0x14(%ebp),%eax
  801568:	8b 10                	mov    (%eax),%edx
  80156a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80156f:	8d 40 04             	lea    0x4(%eax),%eax
  801572:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801575:	b8 0a 00 00 00       	mov    $0xa,%eax
  80157a:	e9 97 00 00 00       	jmp    801616 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80157f:	83 ec 08             	sub    $0x8,%esp
  801582:	53                   	push   %ebx
  801583:	6a 58                	push   $0x58
  801585:	ff d6                	call   *%esi
			putch('X', putdat);
  801587:	83 c4 08             	add    $0x8,%esp
  80158a:	53                   	push   %ebx
  80158b:	6a 58                	push   $0x58
  80158d:	ff d6                	call   *%esi
			putch('X', putdat);
  80158f:	83 c4 08             	add    $0x8,%esp
  801592:	53                   	push   %ebx
  801593:	6a 58                	push   $0x58
  801595:	ff d6                	call   *%esi
			break;
  801597:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80159a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80159d:	e9 8b fc ff ff       	jmp    80122d <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8015a2:	83 ec 08             	sub    $0x8,%esp
  8015a5:	53                   	push   %ebx
  8015a6:	6a 30                	push   $0x30
  8015a8:	ff d6                	call   *%esi
			putch('x', putdat);
  8015aa:	83 c4 08             	add    $0x8,%esp
  8015ad:	53                   	push   %ebx
  8015ae:	6a 78                	push   $0x78
  8015b0:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b5:	8b 10                	mov    (%eax),%edx
  8015b7:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015bc:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015bf:	8d 40 04             	lea    0x4(%eax),%eax
  8015c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015c5:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015ca:	eb 4a                	jmp    801616 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015cc:	83 f9 01             	cmp    $0x1,%ecx
  8015cf:	7e 15                	jle    8015e6 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8015d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d4:	8b 10                	mov    (%eax),%edx
  8015d6:	8b 48 04             	mov    0x4(%eax),%ecx
  8015d9:	8d 40 08             	lea    0x8(%eax),%eax
  8015dc:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8015df:	b8 10 00 00 00       	mov    $0x10,%eax
  8015e4:	eb 30                	jmp    801616 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8015e6:	85 c9                	test   %ecx,%ecx
  8015e8:	74 17                	je     801601 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8015ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ed:	8b 10                	mov    (%eax),%edx
  8015ef:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015f4:	8d 40 04             	lea    0x4(%eax),%eax
  8015f7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8015fa:	b8 10 00 00 00       	mov    $0x10,%eax
  8015ff:	eb 15                	jmp    801616 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801601:	8b 45 14             	mov    0x14(%ebp),%eax
  801604:	8b 10                	mov    (%eax),%edx
  801606:	b9 00 00 00 00       	mov    $0x0,%ecx
  80160b:	8d 40 04             	lea    0x4(%eax),%eax
  80160e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801611:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801616:	83 ec 0c             	sub    $0xc,%esp
  801619:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80161d:	57                   	push   %edi
  80161e:	ff 75 e0             	pushl  -0x20(%ebp)
  801621:	50                   	push   %eax
  801622:	51                   	push   %ecx
  801623:	52                   	push   %edx
  801624:	89 da                	mov    %ebx,%edx
  801626:	89 f0                	mov    %esi,%eax
  801628:	e8 f1 fa ff ff       	call   80111e <printnum>
			break;
  80162d:	83 c4 20             	add    $0x20,%esp
  801630:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801633:	e9 f5 fb ff ff       	jmp    80122d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801638:	83 ec 08             	sub    $0x8,%esp
  80163b:	53                   	push   %ebx
  80163c:	52                   	push   %edx
  80163d:	ff d6                	call   *%esi
			break;
  80163f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801642:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801645:	e9 e3 fb ff ff       	jmp    80122d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80164a:	83 ec 08             	sub    $0x8,%esp
  80164d:	53                   	push   %ebx
  80164e:	6a 25                	push   $0x25
  801650:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	eb 03                	jmp    80165a <vprintfmt+0x453>
  801657:	83 ef 01             	sub    $0x1,%edi
  80165a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80165e:	75 f7                	jne    801657 <vprintfmt+0x450>
  801660:	e9 c8 fb ff ff       	jmp    80122d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801665:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801668:	5b                   	pop    %ebx
  801669:	5e                   	pop    %esi
  80166a:	5f                   	pop    %edi
  80166b:	5d                   	pop    %ebp
  80166c:	c3                   	ret    

0080166d <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80166d:	55                   	push   %ebp
  80166e:	89 e5                	mov    %esp,%ebp
  801670:	83 ec 18             	sub    $0x18,%esp
  801673:	8b 45 08             	mov    0x8(%ebp),%eax
  801676:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801679:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80167c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801680:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801683:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80168a:	85 c0                	test   %eax,%eax
  80168c:	74 26                	je     8016b4 <vsnprintf+0x47>
  80168e:	85 d2                	test   %edx,%edx
  801690:	7e 22                	jle    8016b4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801692:	ff 75 14             	pushl  0x14(%ebp)
  801695:	ff 75 10             	pushl  0x10(%ebp)
  801698:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80169b:	50                   	push   %eax
  80169c:	68 cd 11 80 00       	push   $0x8011cd
  8016a1:	e8 61 fb ff ff       	call   801207 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016a6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016a9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016af:	83 c4 10             	add    $0x10,%esp
  8016b2:	eb 05                	jmp    8016b9 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016b9:	c9                   	leave  
  8016ba:	c3                   	ret    

008016bb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016c1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016c4:	50                   	push   %eax
  8016c5:	ff 75 10             	pushl  0x10(%ebp)
  8016c8:	ff 75 0c             	pushl  0xc(%ebp)
  8016cb:	ff 75 08             	pushl  0x8(%ebp)
  8016ce:	e8 9a ff ff ff       	call   80166d <vsnprintf>
	va_end(ap);

	return rc;
}
  8016d3:	c9                   	leave  
  8016d4:	c3                   	ret    

008016d5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016db:	b8 00 00 00 00       	mov    $0x0,%eax
  8016e0:	eb 03                	jmp    8016e5 <strlen+0x10>
		n++;
  8016e2:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016e5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016e9:	75 f7                	jne    8016e2 <strlen+0xd>
		n++;
	return n;
}
  8016eb:	5d                   	pop    %ebp
  8016ec:	c3                   	ret    

008016ed <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016ed:	55                   	push   %ebp
  8016ee:	89 e5                	mov    %esp,%ebp
  8016f0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016f3:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fb:	eb 03                	jmp    801700 <strnlen+0x13>
		n++;
  8016fd:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801700:	39 c2                	cmp    %eax,%edx
  801702:	74 08                	je     80170c <strnlen+0x1f>
  801704:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801708:	75 f3                	jne    8016fd <strnlen+0x10>
  80170a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80170c:	5d                   	pop    %ebp
  80170d:	c3                   	ret    

0080170e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	53                   	push   %ebx
  801712:	8b 45 08             	mov    0x8(%ebp),%eax
  801715:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801718:	89 c2                	mov    %eax,%edx
  80171a:	83 c2 01             	add    $0x1,%edx
  80171d:	83 c1 01             	add    $0x1,%ecx
  801720:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801724:	88 5a ff             	mov    %bl,-0x1(%edx)
  801727:	84 db                	test   %bl,%bl
  801729:	75 ef                	jne    80171a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80172b:	5b                   	pop    %ebx
  80172c:	5d                   	pop    %ebp
  80172d:	c3                   	ret    

0080172e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80172e:	55                   	push   %ebp
  80172f:	89 e5                	mov    %esp,%ebp
  801731:	53                   	push   %ebx
  801732:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801735:	53                   	push   %ebx
  801736:	e8 9a ff ff ff       	call   8016d5 <strlen>
  80173b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80173e:	ff 75 0c             	pushl  0xc(%ebp)
  801741:	01 d8                	add    %ebx,%eax
  801743:	50                   	push   %eax
  801744:	e8 c5 ff ff ff       	call   80170e <strcpy>
	return dst;
}
  801749:	89 d8                	mov    %ebx,%eax
  80174b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80174e:	c9                   	leave  
  80174f:	c3                   	ret    

00801750 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
  801753:	56                   	push   %esi
  801754:	53                   	push   %ebx
  801755:	8b 75 08             	mov    0x8(%ebp),%esi
  801758:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80175b:	89 f3                	mov    %esi,%ebx
  80175d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801760:	89 f2                	mov    %esi,%edx
  801762:	eb 0f                	jmp    801773 <strncpy+0x23>
		*dst++ = *src;
  801764:	83 c2 01             	add    $0x1,%edx
  801767:	0f b6 01             	movzbl (%ecx),%eax
  80176a:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80176d:	80 39 01             	cmpb   $0x1,(%ecx)
  801770:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801773:	39 da                	cmp    %ebx,%edx
  801775:	75 ed                	jne    801764 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801777:	89 f0                	mov    %esi,%eax
  801779:	5b                   	pop    %ebx
  80177a:	5e                   	pop    %esi
  80177b:	5d                   	pop    %ebp
  80177c:	c3                   	ret    

0080177d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
  801780:	56                   	push   %esi
  801781:	53                   	push   %ebx
  801782:	8b 75 08             	mov    0x8(%ebp),%esi
  801785:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801788:	8b 55 10             	mov    0x10(%ebp),%edx
  80178b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80178d:	85 d2                	test   %edx,%edx
  80178f:	74 21                	je     8017b2 <strlcpy+0x35>
  801791:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801795:	89 f2                	mov    %esi,%edx
  801797:	eb 09                	jmp    8017a2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801799:	83 c2 01             	add    $0x1,%edx
  80179c:	83 c1 01             	add    $0x1,%ecx
  80179f:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017a2:	39 c2                	cmp    %eax,%edx
  8017a4:	74 09                	je     8017af <strlcpy+0x32>
  8017a6:	0f b6 19             	movzbl (%ecx),%ebx
  8017a9:	84 db                	test   %bl,%bl
  8017ab:	75 ec                	jne    801799 <strlcpy+0x1c>
  8017ad:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017af:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017b2:	29 f0                	sub    %esi,%eax
}
  8017b4:	5b                   	pop    %ebx
  8017b5:	5e                   	pop    %esi
  8017b6:	5d                   	pop    %ebp
  8017b7:	c3                   	ret    

008017b8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017b8:	55                   	push   %ebp
  8017b9:	89 e5                	mov    %esp,%ebp
  8017bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017be:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017c1:	eb 06                	jmp    8017c9 <strcmp+0x11>
		p++, q++;
  8017c3:	83 c1 01             	add    $0x1,%ecx
  8017c6:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017c9:	0f b6 01             	movzbl (%ecx),%eax
  8017cc:	84 c0                	test   %al,%al
  8017ce:	74 04                	je     8017d4 <strcmp+0x1c>
  8017d0:	3a 02                	cmp    (%edx),%al
  8017d2:	74 ef                	je     8017c3 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017d4:	0f b6 c0             	movzbl %al,%eax
  8017d7:	0f b6 12             	movzbl (%edx),%edx
  8017da:	29 d0                	sub    %edx,%eax
}
  8017dc:	5d                   	pop    %ebp
  8017dd:	c3                   	ret    

008017de <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	53                   	push   %ebx
  8017e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017e8:	89 c3                	mov    %eax,%ebx
  8017ea:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017ed:	eb 06                	jmp    8017f5 <strncmp+0x17>
		n--, p++, q++;
  8017ef:	83 c0 01             	add    $0x1,%eax
  8017f2:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017f5:	39 d8                	cmp    %ebx,%eax
  8017f7:	74 15                	je     80180e <strncmp+0x30>
  8017f9:	0f b6 08             	movzbl (%eax),%ecx
  8017fc:	84 c9                	test   %cl,%cl
  8017fe:	74 04                	je     801804 <strncmp+0x26>
  801800:	3a 0a                	cmp    (%edx),%cl
  801802:	74 eb                	je     8017ef <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801804:	0f b6 00             	movzbl (%eax),%eax
  801807:	0f b6 12             	movzbl (%edx),%edx
  80180a:	29 d0                	sub    %edx,%eax
  80180c:	eb 05                	jmp    801813 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80180e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801813:	5b                   	pop    %ebx
  801814:	5d                   	pop    %ebp
  801815:	c3                   	ret    

00801816 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801816:	55                   	push   %ebp
  801817:	89 e5                	mov    %esp,%ebp
  801819:	8b 45 08             	mov    0x8(%ebp),%eax
  80181c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801820:	eb 07                	jmp    801829 <strchr+0x13>
		if (*s == c)
  801822:	38 ca                	cmp    %cl,%dl
  801824:	74 0f                	je     801835 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801826:	83 c0 01             	add    $0x1,%eax
  801829:	0f b6 10             	movzbl (%eax),%edx
  80182c:	84 d2                	test   %dl,%dl
  80182e:	75 f2                	jne    801822 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801830:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801835:	5d                   	pop    %ebp
  801836:	c3                   	ret    

00801837 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	8b 45 08             	mov    0x8(%ebp),%eax
  80183d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801841:	eb 03                	jmp    801846 <strfind+0xf>
  801843:	83 c0 01             	add    $0x1,%eax
  801846:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801849:	38 ca                	cmp    %cl,%dl
  80184b:	74 04                	je     801851 <strfind+0x1a>
  80184d:	84 d2                	test   %dl,%dl
  80184f:	75 f2                	jne    801843 <strfind+0xc>
			break;
	return (char *) s;
}
  801851:	5d                   	pop    %ebp
  801852:	c3                   	ret    

00801853 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801853:	55                   	push   %ebp
  801854:	89 e5                	mov    %esp,%ebp
  801856:	57                   	push   %edi
  801857:	56                   	push   %esi
  801858:	53                   	push   %ebx
  801859:	8b 7d 08             	mov    0x8(%ebp),%edi
  80185c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80185f:	85 c9                	test   %ecx,%ecx
  801861:	74 36                	je     801899 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801863:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801869:	75 28                	jne    801893 <memset+0x40>
  80186b:	f6 c1 03             	test   $0x3,%cl
  80186e:	75 23                	jne    801893 <memset+0x40>
		c &= 0xFF;
  801870:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801874:	89 d3                	mov    %edx,%ebx
  801876:	c1 e3 08             	shl    $0x8,%ebx
  801879:	89 d6                	mov    %edx,%esi
  80187b:	c1 e6 18             	shl    $0x18,%esi
  80187e:	89 d0                	mov    %edx,%eax
  801880:	c1 e0 10             	shl    $0x10,%eax
  801883:	09 f0                	or     %esi,%eax
  801885:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801887:	89 d8                	mov    %ebx,%eax
  801889:	09 d0                	or     %edx,%eax
  80188b:	c1 e9 02             	shr    $0x2,%ecx
  80188e:	fc                   	cld    
  80188f:	f3 ab                	rep stos %eax,%es:(%edi)
  801891:	eb 06                	jmp    801899 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801893:	8b 45 0c             	mov    0xc(%ebp),%eax
  801896:	fc                   	cld    
  801897:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801899:	89 f8                	mov    %edi,%eax
  80189b:	5b                   	pop    %ebx
  80189c:	5e                   	pop    %esi
  80189d:	5f                   	pop    %edi
  80189e:	5d                   	pop    %ebp
  80189f:	c3                   	ret    

008018a0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018a0:	55                   	push   %ebp
  8018a1:	89 e5                	mov    %esp,%ebp
  8018a3:	57                   	push   %edi
  8018a4:	56                   	push   %esi
  8018a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018ab:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018ae:	39 c6                	cmp    %eax,%esi
  8018b0:	73 35                	jae    8018e7 <memmove+0x47>
  8018b2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018b5:	39 d0                	cmp    %edx,%eax
  8018b7:	73 2e                	jae    8018e7 <memmove+0x47>
		s += n;
		d += n;
  8018b9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018bc:	89 d6                	mov    %edx,%esi
  8018be:	09 fe                	or     %edi,%esi
  8018c0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018c6:	75 13                	jne    8018db <memmove+0x3b>
  8018c8:	f6 c1 03             	test   $0x3,%cl
  8018cb:	75 0e                	jne    8018db <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018cd:	83 ef 04             	sub    $0x4,%edi
  8018d0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018d3:	c1 e9 02             	shr    $0x2,%ecx
  8018d6:	fd                   	std    
  8018d7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018d9:	eb 09                	jmp    8018e4 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018db:	83 ef 01             	sub    $0x1,%edi
  8018de:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018e1:	fd                   	std    
  8018e2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018e4:	fc                   	cld    
  8018e5:	eb 1d                	jmp    801904 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018e7:	89 f2                	mov    %esi,%edx
  8018e9:	09 c2                	or     %eax,%edx
  8018eb:	f6 c2 03             	test   $0x3,%dl
  8018ee:	75 0f                	jne    8018ff <memmove+0x5f>
  8018f0:	f6 c1 03             	test   $0x3,%cl
  8018f3:	75 0a                	jne    8018ff <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018f5:	c1 e9 02             	shr    $0x2,%ecx
  8018f8:	89 c7                	mov    %eax,%edi
  8018fa:	fc                   	cld    
  8018fb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018fd:	eb 05                	jmp    801904 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018ff:	89 c7                	mov    %eax,%edi
  801901:	fc                   	cld    
  801902:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801904:	5e                   	pop    %esi
  801905:	5f                   	pop    %edi
  801906:	5d                   	pop    %ebp
  801907:	c3                   	ret    

00801908 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801908:	55                   	push   %ebp
  801909:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80190b:	ff 75 10             	pushl  0x10(%ebp)
  80190e:	ff 75 0c             	pushl  0xc(%ebp)
  801911:	ff 75 08             	pushl  0x8(%ebp)
  801914:	e8 87 ff ff ff       	call   8018a0 <memmove>
}
  801919:	c9                   	leave  
  80191a:	c3                   	ret    

0080191b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80191b:	55                   	push   %ebp
  80191c:	89 e5                	mov    %esp,%ebp
  80191e:	56                   	push   %esi
  80191f:	53                   	push   %ebx
  801920:	8b 45 08             	mov    0x8(%ebp),%eax
  801923:	8b 55 0c             	mov    0xc(%ebp),%edx
  801926:	89 c6                	mov    %eax,%esi
  801928:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80192b:	eb 1a                	jmp    801947 <memcmp+0x2c>
		if (*s1 != *s2)
  80192d:	0f b6 08             	movzbl (%eax),%ecx
  801930:	0f b6 1a             	movzbl (%edx),%ebx
  801933:	38 d9                	cmp    %bl,%cl
  801935:	74 0a                	je     801941 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801937:	0f b6 c1             	movzbl %cl,%eax
  80193a:	0f b6 db             	movzbl %bl,%ebx
  80193d:	29 d8                	sub    %ebx,%eax
  80193f:	eb 0f                	jmp    801950 <memcmp+0x35>
		s1++, s2++;
  801941:	83 c0 01             	add    $0x1,%eax
  801944:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801947:	39 f0                	cmp    %esi,%eax
  801949:	75 e2                	jne    80192d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80194b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801950:	5b                   	pop    %ebx
  801951:	5e                   	pop    %esi
  801952:	5d                   	pop    %ebp
  801953:	c3                   	ret    

00801954 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801954:	55                   	push   %ebp
  801955:	89 e5                	mov    %esp,%ebp
  801957:	53                   	push   %ebx
  801958:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80195b:	89 c1                	mov    %eax,%ecx
  80195d:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801960:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801964:	eb 0a                	jmp    801970 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801966:	0f b6 10             	movzbl (%eax),%edx
  801969:	39 da                	cmp    %ebx,%edx
  80196b:	74 07                	je     801974 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80196d:	83 c0 01             	add    $0x1,%eax
  801970:	39 c8                	cmp    %ecx,%eax
  801972:	72 f2                	jb     801966 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801974:	5b                   	pop    %ebx
  801975:	5d                   	pop    %ebp
  801976:	c3                   	ret    

00801977 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801977:	55                   	push   %ebp
  801978:	89 e5                	mov    %esp,%ebp
  80197a:	57                   	push   %edi
  80197b:	56                   	push   %esi
  80197c:	53                   	push   %ebx
  80197d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801980:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801983:	eb 03                	jmp    801988 <strtol+0x11>
		s++;
  801985:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801988:	0f b6 01             	movzbl (%ecx),%eax
  80198b:	3c 20                	cmp    $0x20,%al
  80198d:	74 f6                	je     801985 <strtol+0xe>
  80198f:	3c 09                	cmp    $0x9,%al
  801991:	74 f2                	je     801985 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801993:	3c 2b                	cmp    $0x2b,%al
  801995:	75 0a                	jne    8019a1 <strtol+0x2a>
		s++;
  801997:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80199a:	bf 00 00 00 00       	mov    $0x0,%edi
  80199f:	eb 11                	jmp    8019b2 <strtol+0x3b>
  8019a1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019a6:	3c 2d                	cmp    $0x2d,%al
  8019a8:	75 08                	jne    8019b2 <strtol+0x3b>
		s++, neg = 1;
  8019aa:	83 c1 01             	add    $0x1,%ecx
  8019ad:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019b2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019b8:	75 15                	jne    8019cf <strtol+0x58>
  8019ba:	80 39 30             	cmpb   $0x30,(%ecx)
  8019bd:	75 10                	jne    8019cf <strtol+0x58>
  8019bf:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019c3:	75 7c                	jne    801a41 <strtol+0xca>
		s += 2, base = 16;
  8019c5:	83 c1 02             	add    $0x2,%ecx
  8019c8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019cd:	eb 16                	jmp    8019e5 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019cf:	85 db                	test   %ebx,%ebx
  8019d1:	75 12                	jne    8019e5 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019d3:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019d8:	80 39 30             	cmpb   $0x30,(%ecx)
  8019db:	75 08                	jne    8019e5 <strtol+0x6e>
		s++, base = 8;
  8019dd:	83 c1 01             	add    $0x1,%ecx
  8019e0:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ea:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019ed:	0f b6 11             	movzbl (%ecx),%edx
  8019f0:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019f3:	89 f3                	mov    %esi,%ebx
  8019f5:	80 fb 09             	cmp    $0x9,%bl
  8019f8:	77 08                	ja     801a02 <strtol+0x8b>
			dig = *s - '0';
  8019fa:	0f be d2             	movsbl %dl,%edx
  8019fd:	83 ea 30             	sub    $0x30,%edx
  801a00:	eb 22                	jmp    801a24 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a02:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a05:	89 f3                	mov    %esi,%ebx
  801a07:	80 fb 19             	cmp    $0x19,%bl
  801a0a:	77 08                	ja     801a14 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a0c:	0f be d2             	movsbl %dl,%edx
  801a0f:	83 ea 57             	sub    $0x57,%edx
  801a12:	eb 10                	jmp    801a24 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a14:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a17:	89 f3                	mov    %esi,%ebx
  801a19:	80 fb 19             	cmp    $0x19,%bl
  801a1c:	77 16                	ja     801a34 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a1e:	0f be d2             	movsbl %dl,%edx
  801a21:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a24:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a27:	7d 0b                	jge    801a34 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a29:	83 c1 01             	add    $0x1,%ecx
  801a2c:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a30:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a32:	eb b9                	jmp    8019ed <strtol+0x76>

	if (endptr)
  801a34:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a38:	74 0d                	je     801a47 <strtol+0xd0>
		*endptr = (char *) s;
  801a3a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a3d:	89 0e                	mov    %ecx,(%esi)
  801a3f:	eb 06                	jmp    801a47 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a41:	85 db                	test   %ebx,%ebx
  801a43:	74 98                	je     8019dd <strtol+0x66>
  801a45:	eb 9e                	jmp    8019e5 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a47:	89 c2                	mov    %eax,%edx
  801a49:	f7 da                	neg    %edx
  801a4b:	85 ff                	test   %edi,%edi
  801a4d:	0f 45 c2             	cmovne %edx,%eax
}
  801a50:	5b                   	pop    %ebx
  801a51:	5e                   	pop    %esi
  801a52:	5f                   	pop    %edi
  801a53:	5d                   	pop    %ebp
  801a54:	c3                   	ret    

00801a55 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a55:	55                   	push   %ebp
  801a56:	89 e5                	mov    %esp,%ebp
  801a58:	56                   	push   %esi
  801a59:	53                   	push   %ebx
  801a5a:	8b 75 08             	mov    0x8(%ebp),%esi
  801a5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a60:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801a63:	85 c0                	test   %eax,%eax
  801a65:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a6a:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801a6d:	83 ec 0c             	sub    $0xc,%esp
  801a70:	50                   	push   %eax
  801a71:	e8 90 e8 ff ff       	call   800306 <sys_ipc_recv>
  801a76:	83 c4 10             	add    $0x10,%esp
  801a79:	85 c0                	test   %eax,%eax
  801a7b:	79 16                	jns    801a93 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801a7d:	85 f6                	test   %esi,%esi
  801a7f:	74 06                	je     801a87 <ipc_recv+0x32>
            *from_env_store = 0;
  801a81:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801a87:	85 db                	test   %ebx,%ebx
  801a89:	74 2c                	je     801ab7 <ipc_recv+0x62>
            *perm_store = 0;
  801a8b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a91:	eb 24                	jmp    801ab7 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801a93:	85 f6                	test   %esi,%esi
  801a95:	74 0a                	je     801aa1 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801a97:	a1 04 40 80 00       	mov    0x804004,%eax
  801a9c:	8b 40 74             	mov    0x74(%eax),%eax
  801a9f:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801aa1:	85 db                	test   %ebx,%ebx
  801aa3:	74 0a                	je     801aaf <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801aa5:	a1 04 40 80 00       	mov    0x804004,%eax
  801aaa:	8b 40 78             	mov    0x78(%eax),%eax
  801aad:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801aaf:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab4:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801ab7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aba:	5b                   	pop    %ebx
  801abb:	5e                   	pop    %esi
  801abc:	5d                   	pop    %ebp
  801abd:	c3                   	ret    

00801abe <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801abe:	55                   	push   %ebp
  801abf:	89 e5                	mov    %esp,%ebp
  801ac1:	57                   	push   %edi
  801ac2:	56                   	push   %esi
  801ac3:	53                   	push   %ebx
  801ac4:	83 ec 0c             	sub    $0xc,%esp
  801ac7:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aca:	8b 75 0c             	mov    0xc(%ebp),%esi
  801acd:	8b 45 10             	mov    0x10(%ebp),%eax
  801ad0:	85 c0                	test   %eax,%eax
  801ad2:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ad7:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801ada:	eb 1c                	jmp    801af8 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801adc:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801adf:	74 12                	je     801af3 <ipc_send+0x35>
  801ae1:	50                   	push   %eax
  801ae2:	68 60 22 80 00       	push   $0x802260
  801ae7:	6a 3a                	push   $0x3a
  801ae9:	68 76 22 80 00       	push   $0x802276
  801aee:	e8 3e f5 ff ff       	call   801031 <_panic>
		sys_yield();
  801af3:	e8 3f e6 ff ff       	call   800137 <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801af8:	ff 75 14             	pushl  0x14(%ebp)
  801afb:	53                   	push   %ebx
  801afc:	56                   	push   %esi
  801afd:	57                   	push   %edi
  801afe:	e8 e0 e7 ff ff       	call   8002e3 <sys_ipc_try_send>
  801b03:	83 c4 10             	add    $0x10,%esp
  801b06:	85 c0                	test   %eax,%eax
  801b08:	78 d2                	js     801adc <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801b0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0d:	5b                   	pop    %ebx
  801b0e:	5e                   	pop    %esi
  801b0f:	5f                   	pop    %edi
  801b10:	5d                   	pop    %ebp
  801b11:	c3                   	ret    

00801b12 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b12:	55                   	push   %ebp
  801b13:	89 e5                	mov    %esp,%ebp
  801b15:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b18:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b1d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b20:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b26:	8b 52 50             	mov    0x50(%edx),%edx
  801b29:	39 ca                	cmp    %ecx,%edx
  801b2b:	75 0d                	jne    801b3a <ipc_find_env+0x28>
			return envs[i].env_id;
  801b2d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b30:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b35:	8b 40 48             	mov    0x48(%eax),%eax
  801b38:	eb 0f                	jmp    801b49 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b3a:	83 c0 01             	add    $0x1,%eax
  801b3d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b42:	75 d9                	jne    801b1d <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b49:	5d                   	pop    %ebp
  801b4a:	c3                   	ret    

00801b4b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b51:	89 d0                	mov    %edx,%eax
  801b53:	c1 e8 16             	shr    $0x16,%eax
  801b56:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b5d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b62:	f6 c1 01             	test   $0x1,%cl
  801b65:	74 1d                	je     801b84 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b67:	c1 ea 0c             	shr    $0xc,%edx
  801b6a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b71:	f6 c2 01             	test   $0x1,%dl
  801b74:	74 0e                	je     801b84 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b76:	c1 ea 0c             	shr    $0xc,%edx
  801b79:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b80:	ef 
  801b81:	0f b7 c0             	movzwl %ax,%eax
}
  801b84:	5d                   	pop    %ebp
  801b85:	c3                   	ret    
  801b86:	66 90                	xchg   %ax,%ax
  801b88:	66 90                	xchg   %ax,%ax
  801b8a:	66 90                	xchg   %ax,%ax
  801b8c:	66 90                	xchg   %ax,%ax
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
