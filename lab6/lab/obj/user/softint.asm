
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
  800057:	a3 08 40 80 00       	mov    %eax,0x804008

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
  800086:	e8 c6 04 00 00       	call   800551 <close_all>
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
  8000ff:	68 ca 22 80 00       	push   $0x8022ca
  800104:	6a 23                	push   $0x23
  800106:	68 e7 22 80 00       	push   $0x8022e7
  80010b:	e8 c7 13 00 00       	call   8014d7 <_panic>

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
  800180:	68 ca 22 80 00       	push   $0x8022ca
  800185:	6a 23                	push   $0x23
  800187:	68 e7 22 80 00       	push   $0x8022e7
  80018c:	e8 46 13 00 00       	call   8014d7 <_panic>

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
  8001c2:	68 ca 22 80 00       	push   $0x8022ca
  8001c7:	6a 23                	push   $0x23
  8001c9:	68 e7 22 80 00       	push   $0x8022e7
  8001ce:	e8 04 13 00 00       	call   8014d7 <_panic>

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
  800204:	68 ca 22 80 00       	push   $0x8022ca
  800209:	6a 23                	push   $0x23
  80020b:	68 e7 22 80 00       	push   $0x8022e7
  800210:	e8 c2 12 00 00       	call   8014d7 <_panic>

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
  800246:	68 ca 22 80 00       	push   $0x8022ca
  80024b:	6a 23                	push   $0x23
  80024d:	68 e7 22 80 00       	push   $0x8022e7
  800252:	e8 80 12 00 00       	call   8014d7 <_panic>

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
  800288:	68 ca 22 80 00       	push   $0x8022ca
  80028d:	6a 23                	push   $0x23
  80028f:	68 e7 22 80 00       	push   $0x8022e7
  800294:	e8 3e 12 00 00       	call   8014d7 <_panic>

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
  8002ca:	68 ca 22 80 00       	push   $0x8022ca
  8002cf:	6a 23                	push   $0x23
  8002d1:	68 e7 22 80 00       	push   $0x8022e7
  8002d6:	e8 fc 11 00 00       	call   8014d7 <_panic>

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
  80032e:	68 ca 22 80 00       	push   $0x8022ca
  800333:	6a 23                	push   $0x23
  800335:	68 e7 22 80 00       	push   $0x8022e7
  80033a:	e8 98 11 00 00       	call   8014d7 <_panic>

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

00800347 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	57                   	push   %edi
  80034b:	56                   	push   %esi
  80034c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80034d:	ba 00 00 00 00       	mov    $0x0,%edx
  800352:	b8 0e 00 00 00       	mov    $0xe,%eax
  800357:	89 d1                	mov    %edx,%ecx
  800359:	89 d3                	mov    %edx,%ebx
  80035b:	89 d7                	mov    %edx,%edi
  80035d:	89 d6                	mov    %edx,%esi
  80035f:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800361:	5b                   	pop    %ebx
  800362:	5e                   	pop    %esi
  800363:	5f                   	pop    %edi
  800364:	5d                   	pop    %ebp
  800365:	c3                   	ret    

00800366 <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
  800369:	57                   	push   %edi
  80036a:	56                   	push   %esi
  80036b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80036c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800371:	b8 10 00 00 00       	mov    $0x10,%eax
  800376:	8b 55 08             	mov    0x8(%ebp),%edx
  800379:	89 cb                	mov    %ecx,%ebx
  80037b:	89 cf                	mov    %ecx,%edi
  80037d:	89 ce                	mov    %ecx,%esi
  80037f:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800381:	5b                   	pop    %ebx
  800382:	5e                   	pop    %esi
  800383:	5f                   	pop    %edi
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    

00800386 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
  80038c:	05 00 00 00 30       	add    $0x30000000,%eax
  800391:	c1 e8 0c             	shr    $0xc,%eax
}
  800394:	5d                   	pop    %ebp
  800395:	c3                   	ret    

00800396 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800399:	8b 45 08             	mov    0x8(%ebp),%eax
  80039c:	05 00 00 00 30       	add    $0x30000000,%eax
  8003a1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003a6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003ab:	5d                   	pop    %ebp
  8003ac:	c3                   	ret    

008003ad <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003ad:	55                   	push   %ebp
  8003ae:	89 e5                	mov    %esp,%ebp
  8003b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003b3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003b8:	89 c2                	mov    %eax,%edx
  8003ba:	c1 ea 16             	shr    $0x16,%edx
  8003bd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003c4:	f6 c2 01             	test   $0x1,%dl
  8003c7:	74 11                	je     8003da <fd_alloc+0x2d>
  8003c9:	89 c2                	mov    %eax,%edx
  8003cb:	c1 ea 0c             	shr    $0xc,%edx
  8003ce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003d5:	f6 c2 01             	test   $0x1,%dl
  8003d8:	75 09                	jne    8003e3 <fd_alloc+0x36>
			*fd_store = fd;
  8003da:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e1:	eb 17                	jmp    8003fa <fd_alloc+0x4d>
  8003e3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003e8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ed:	75 c9                	jne    8003b8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003ef:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003f5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003fa:	5d                   	pop    %ebp
  8003fb:	c3                   	ret    

008003fc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
  8003ff:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800402:	83 f8 1f             	cmp    $0x1f,%eax
  800405:	77 36                	ja     80043d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800407:	c1 e0 0c             	shl    $0xc,%eax
  80040a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80040f:	89 c2                	mov    %eax,%edx
  800411:	c1 ea 16             	shr    $0x16,%edx
  800414:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80041b:	f6 c2 01             	test   $0x1,%dl
  80041e:	74 24                	je     800444 <fd_lookup+0x48>
  800420:	89 c2                	mov    %eax,%edx
  800422:	c1 ea 0c             	shr    $0xc,%edx
  800425:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80042c:	f6 c2 01             	test   $0x1,%dl
  80042f:	74 1a                	je     80044b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800431:	8b 55 0c             	mov    0xc(%ebp),%edx
  800434:	89 02                	mov    %eax,(%edx)
	return 0;
  800436:	b8 00 00 00 00       	mov    $0x0,%eax
  80043b:	eb 13                	jmp    800450 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80043d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800442:	eb 0c                	jmp    800450 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800444:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800449:	eb 05                	jmp    800450 <fd_lookup+0x54>
  80044b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800450:	5d                   	pop    %ebp
  800451:	c3                   	ret    

00800452 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800452:	55                   	push   %ebp
  800453:	89 e5                	mov    %esp,%ebp
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80045b:	ba 74 23 80 00       	mov    $0x802374,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800460:	eb 13                	jmp    800475 <dev_lookup+0x23>
  800462:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800465:	39 08                	cmp    %ecx,(%eax)
  800467:	75 0c                	jne    800475 <dev_lookup+0x23>
			*dev = devtab[i];
  800469:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80046c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80046e:	b8 00 00 00 00       	mov    $0x0,%eax
  800473:	eb 2e                	jmp    8004a3 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800475:	8b 02                	mov    (%edx),%eax
  800477:	85 c0                	test   %eax,%eax
  800479:	75 e7                	jne    800462 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80047b:	a1 08 40 80 00       	mov    0x804008,%eax
  800480:	8b 40 48             	mov    0x48(%eax),%eax
  800483:	83 ec 04             	sub    $0x4,%esp
  800486:	51                   	push   %ecx
  800487:	50                   	push   %eax
  800488:	68 f8 22 80 00       	push   $0x8022f8
  80048d:	e8 1e 11 00 00       	call   8015b0 <cprintf>
	*dev = 0;
  800492:	8b 45 0c             	mov    0xc(%ebp),%eax
  800495:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80049b:	83 c4 10             	add    $0x10,%esp
  80049e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004a3:	c9                   	leave  
  8004a4:	c3                   	ret    

008004a5 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004a5:	55                   	push   %ebp
  8004a6:	89 e5                	mov    %esp,%ebp
  8004a8:	56                   	push   %esi
  8004a9:	53                   	push   %ebx
  8004aa:	83 ec 10             	sub    $0x10,%esp
  8004ad:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004b6:	50                   	push   %eax
  8004b7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004bd:	c1 e8 0c             	shr    $0xc,%eax
  8004c0:	50                   	push   %eax
  8004c1:	e8 36 ff ff ff       	call   8003fc <fd_lookup>
  8004c6:	83 c4 08             	add    $0x8,%esp
  8004c9:	85 c0                	test   %eax,%eax
  8004cb:	78 05                	js     8004d2 <fd_close+0x2d>
	    || fd != fd2)
  8004cd:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004d0:	74 0c                	je     8004de <fd_close+0x39>
		return (must_exist ? r : 0);
  8004d2:	84 db                	test   %bl,%bl
  8004d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d9:	0f 44 c2             	cmove  %edx,%eax
  8004dc:	eb 41                	jmp    80051f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004e4:	50                   	push   %eax
  8004e5:	ff 36                	pushl  (%esi)
  8004e7:	e8 66 ff ff ff       	call   800452 <dev_lookup>
  8004ec:	89 c3                	mov    %eax,%ebx
  8004ee:	83 c4 10             	add    $0x10,%esp
  8004f1:	85 c0                	test   %eax,%eax
  8004f3:	78 1a                	js     80050f <fd_close+0x6a>
		if (dev->dev_close)
  8004f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004f8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004fb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800500:	85 c0                	test   %eax,%eax
  800502:	74 0b                	je     80050f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800504:	83 ec 0c             	sub    $0xc,%esp
  800507:	56                   	push   %esi
  800508:	ff d0                	call   *%eax
  80050a:	89 c3                	mov    %eax,%ebx
  80050c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	56                   	push   %esi
  800513:	6a 00                	push   $0x0
  800515:	e8 c1 fc ff ff       	call   8001db <sys_page_unmap>
	return r;
  80051a:	83 c4 10             	add    $0x10,%esp
  80051d:	89 d8                	mov    %ebx,%eax
}
  80051f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800522:	5b                   	pop    %ebx
  800523:	5e                   	pop    %esi
  800524:	5d                   	pop    %ebp
  800525:	c3                   	ret    

00800526 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800526:	55                   	push   %ebp
  800527:	89 e5                	mov    %esp,%ebp
  800529:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80052c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80052f:	50                   	push   %eax
  800530:	ff 75 08             	pushl  0x8(%ebp)
  800533:	e8 c4 fe ff ff       	call   8003fc <fd_lookup>
  800538:	83 c4 08             	add    $0x8,%esp
  80053b:	85 c0                	test   %eax,%eax
  80053d:	78 10                	js     80054f <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	6a 01                	push   $0x1
  800544:	ff 75 f4             	pushl  -0xc(%ebp)
  800547:	e8 59 ff ff ff       	call   8004a5 <fd_close>
  80054c:	83 c4 10             	add    $0x10,%esp
}
  80054f:	c9                   	leave  
  800550:	c3                   	ret    

00800551 <close_all>:

void
close_all(void)
{
  800551:	55                   	push   %ebp
  800552:	89 e5                	mov    %esp,%ebp
  800554:	53                   	push   %ebx
  800555:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800558:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80055d:	83 ec 0c             	sub    $0xc,%esp
  800560:	53                   	push   %ebx
  800561:	e8 c0 ff ff ff       	call   800526 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800566:	83 c3 01             	add    $0x1,%ebx
  800569:	83 c4 10             	add    $0x10,%esp
  80056c:	83 fb 20             	cmp    $0x20,%ebx
  80056f:	75 ec                	jne    80055d <close_all+0xc>
		close(i);
}
  800571:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800574:	c9                   	leave  
  800575:	c3                   	ret    

00800576 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800576:	55                   	push   %ebp
  800577:	89 e5                	mov    %esp,%ebp
  800579:	57                   	push   %edi
  80057a:	56                   	push   %esi
  80057b:	53                   	push   %ebx
  80057c:	83 ec 2c             	sub    $0x2c,%esp
  80057f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800582:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800585:	50                   	push   %eax
  800586:	ff 75 08             	pushl  0x8(%ebp)
  800589:	e8 6e fe ff ff       	call   8003fc <fd_lookup>
  80058e:	83 c4 08             	add    $0x8,%esp
  800591:	85 c0                	test   %eax,%eax
  800593:	0f 88 c1 00 00 00    	js     80065a <dup+0xe4>
		return r;
	close(newfdnum);
  800599:	83 ec 0c             	sub    $0xc,%esp
  80059c:	56                   	push   %esi
  80059d:	e8 84 ff ff ff       	call   800526 <close>

	newfd = INDEX2FD(newfdnum);
  8005a2:	89 f3                	mov    %esi,%ebx
  8005a4:	c1 e3 0c             	shl    $0xc,%ebx
  8005a7:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005ad:	83 c4 04             	add    $0x4,%esp
  8005b0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005b3:	e8 de fd ff ff       	call   800396 <fd2data>
  8005b8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005ba:	89 1c 24             	mov    %ebx,(%esp)
  8005bd:	e8 d4 fd ff ff       	call   800396 <fd2data>
  8005c2:	83 c4 10             	add    $0x10,%esp
  8005c5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005c8:	89 f8                	mov    %edi,%eax
  8005ca:	c1 e8 16             	shr    $0x16,%eax
  8005cd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005d4:	a8 01                	test   $0x1,%al
  8005d6:	74 37                	je     80060f <dup+0x99>
  8005d8:	89 f8                	mov    %edi,%eax
  8005da:	c1 e8 0c             	shr    $0xc,%eax
  8005dd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005e4:	f6 c2 01             	test   $0x1,%dl
  8005e7:	74 26                	je     80060f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005e9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f0:	83 ec 0c             	sub    $0xc,%esp
  8005f3:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f8:	50                   	push   %eax
  8005f9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005fc:	6a 00                	push   $0x0
  8005fe:	57                   	push   %edi
  8005ff:	6a 00                	push   $0x0
  800601:	e8 93 fb ff ff       	call   800199 <sys_page_map>
  800606:	89 c7                	mov    %eax,%edi
  800608:	83 c4 20             	add    $0x20,%esp
  80060b:	85 c0                	test   %eax,%eax
  80060d:	78 2e                	js     80063d <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800612:	89 d0                	mov    %edx,%eax
  800614:	c1 e8 0c             	shr    $0xc,%eax
  800617:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80061e:	83 ec 0c             	sub    $0xc,%esp
  800621:	25 07 0e 00 00       	and    $0xe07,%eax
  800626:	50                   	push   %eax
  800627:	53                   	push   %ebx
  800628:	6a 00                	push   $0x0
  80062a:	52                   	push   %edx
  80062b:	6a 00                	push   $0x0
  80062d:	e8 67 fb ff ff       	call   800199 <sys_page_map>
  800632:	89 c7                	mov    %eax,%edi
  800634:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800637:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800639:	85 ff                	test   %edi,%edi
  80063b:	79 1d                	jns    80065a <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80063d:	83 ec 08             	sub    $0x8,%esp
  800640:	53                   	push   %ebx
  800641:	6a 00                	push   $0x0
  800643:	e8 93 fb ff ff       	call   8001db <sys_page_unmap>
	sys_page_unmap(0, nva);
  800648:	83 c4 08             	add    $0x8,%esp
  80064b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80064e:	6a 00                	push   $0x0
  800650:	e8 86 fb ff ff       	call   8001db <sys_page_unmap>
	return r;
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	89 f8                	mov    %edi,%eax
}
  80065a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80065d:	5b                   	pop    %ebx
  80065e:	5e                   	pop    %esi
  80065f:	5f                   	pop    %edi
  800660:	5d                   	pop    %ebp
  800661:	c3                   	ret    

00800662 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800662:	55                   	push   %ebp
  800663:	89 e5                	mov    %esp,%ebp
  800665:	53                   	push   %ebx
  800666:	83 ec 14             	sub    $0x14,%esp
  800669:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80066c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80066f:	50                   	push   %eax
  800670:	53                   	push   %ebx
  800671:	e8 86 fd ff ff       	call   8003fc <fd_lookup>
  800676:	83 c4 08             	add    $0x8,%esp
  800679:	89 c2                	mov    %eax,%edx
  80067b:	85 c0                	test   %eax,%eax
  80067d:	78 6d                	js     8006ec <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80067f:	83 ec 08             	sub    $0x8,%esp
  800682:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800685:	50                   	push   %eax
  800686:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800689:	ff 30                	pushl  (%eax)
  80068b:	e8 c2 fd ff ff       	call   800452 <dev_lookup>
  800690:	83 c4 10             	add    $0x10,%esp
  800693:	85 c0                	test   %eax,%eax
  800695:	78 4c                	js     8006e3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800697:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80069a:	8b 42 08             	mov    0x8(%edx),%eax
  80069d:	83 e0 03             	and    $0x3,%eax
  8006a0:	83 f8 01             	cmp    $0x1,%eax
  8006a3:	75 21                	jne    8006c6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006a5:	a1 08 40 80 00       	mov    0x804008,%eax
  8006aa:	8b 40 48             	mov    0x48(%eax),%eax
  8006ad:	83 ec 04             	sub    $0x4,%esp
  8006b0:	53                   	push   %ebx
  8006b1:	50                   	push   %eax
  8006b2:	68 39 23 80 00       	push   $0x802339
  8006b7:	e8 f4 0e 00 00       	call   8015b0 <cprintf>
		return -E_INVAL;
  8006bc:	83 c4 10             	add    $0x10,%esp
  8006bf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006c4:	eb 26                	jmp    8006ec <read+0x8a>
	}
	if (!dev->dev_read)
  8006c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c9:	8b 40 08             	mov    0x8(%eax),%eax
  8006cc:	85 c0                	test   %eax,%eax
  8006ce:	74 17                	je     8006e7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006d0:	83 ec 04             	sub    $0x4,%esp
  8006d3:	ff 75 10             	pushl  0x10(%ebp)
  8006d6:	ff 75 0c             	pushl  0xc(%ebp)
  8006d9:	52                   	push   %edx
  8006da:	ff d0                	call   *%eax
  8006dc:	89 c2                	mov    %eax,%edx
  8006de:	83 c4 10             	add    $0x10,%esp
  8006e1:	eb 09                	jmp    8006ec <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006e3:	89 c2                	mov    %eax,%edx
  8006e5:	eb 05                	jmp    8006ec <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006e7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ec:	89 d0                	mov    %edx,%eax
  8006ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006f1:	c9                   	leave  
  8006f2:	c3                   	ret    

008006f3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006f3:	55                   	push   %ebp
  8006f4:	89 e5                	mov    %esp,%ebp
  8006f6:	57                   	push   %edi
  8006f7:	56                   	push   %esi
  8006f8:	53                   	push   %ebx
  8006f9:	83 ec 0c             	sub    $0xc,%esp
  8006fc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ff:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800702:	bb 00 00 00 00       	mov    $0x0,%ebx
  800707:	eb 21                	jmp    80072a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800709:	83 ec 04             	sub    $0x4,%esp
  80070c:	89 f0                	mov    %esi,%eax
  80070e:	29 d8                	sub    %ebx,%eax
  800710:	50                   	push   %eax
  800711:	89 d8                	mov    %ebx,%eax
  800713:	03 45 0c             	add    0xc(%ebp),%eax
  800716:	50                   	push   %eax
  800717:	57                   	push   %edi
  800718:	e8 45 ff ff ff       	call   800662 <read>
		if (m < 0)
  80071d:	83 c4 10             	add    $0x10,%esp
  800720:	85 c0                	test   %eax,%eax
  800722:	78 10                	js     800734 <readn+0x41>
			return m;
		if (m == 0)
  800724:	85 c0                	test   %eax,%eax
  800726:	74 0a                	je     800732 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800728:	01 c3                	add    %eax,%ebx
  80072a:	39 f3                	cmp    %esi,%ebx
  80072c:	72 db                	jb     800709 <readn+0x16>
  80072e:	89 d8                	mov    %ebx,%eax
  800730:	eb 02                	jmp    800734 <readn+0x41>
  800732:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800734:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800737:	5b                   	pop    %ebx
  800738:	5e                   	pop    %esi
  800739:	5f                   	pop    %edi
  80073a:	5d                   	pop    %ebp
  80073b:	c3                   	ret    

0080073c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80073c:	55                   	push   %ebp
  80073d:	89 e5                	mov    %esp,%ebp
  80073f:	53                   	push   %ebx
  800740:	83 ec 14             	sub    $0x14,%esp
  800743:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800746:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800749:	50                   	push   %eax
  80074a:	53                   	push   %ebx
  80074b:	e8 ac fc ff ff       	call   8003fc <fd_lookup>
  800750:	83 c4 08             	add    $0x8,%esp
  800753:	89 c2                	mov    %eax,%edx
  800755:	85 c0                	test   %eax,%eax
  800757:	78 68                	js     8007c1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800759:	83 ec 08             	sub    $0x8,%esp
  80075c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80075f:	50                   	push   %eax
  800760:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800763:	ff 30                	pushl  (%eax)
  800765:	e8 e8 fc ff ff       	call   800452 <dev_lookup>
  80076a:	83 c4 10             	add    $0x10,%esp
  80076d:	85 c0                	test   %eax,%eax
  80076f:	78 47                	js     8007b8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800771:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800774:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800778:	75 21                	jne    80079b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80077a:	a1 08 40 80 00       	mov    0x804008,%eax
  80077f:	8b 40 48             	mov    0x48(%eax),%eax
  800782:	83 ec 04             	sub    $0x4,%esp
  800785:	53                   	push   %ebx
  800786:	50                   	push   %eax
  800787:	68 55 23 80 00       	push   $0x802355
  80078c:	e8 1f 0e 00 00       	call   8015b0 <cprintf>
		return -E_INVAL;
  800791:	83 c4 10             	add    $0x10,%esp
  800794:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800799:	eb 26                	jmp    8007c1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80079b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80079e:	8b 52 0c             	mov    0xc(%edx),%edx
  8007a1:	85 d2                	test   %edx,%edx
  8007a3:	74 17                	je     8007bc <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007a5:	83 ec 04             	sub    $0x4,%esp
  8007a8:	ff 75 10             	pushl  0x10(%ebp)
  8007ab:	ff 75 0c             	pushl  0xc(%ebp)
  8007ae:	50                   	push   %eax
  8007af:	ff d2                	call   *%edx
  8007b1:	89 c2                	mov    %eax,%edx
  8007b3:	83 c4 10             	add    $0x10,%esp
  8007b6:	eb 09                	jmp    8007c1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007b8:	89 c2                	mov    %eax,%edx
  8007ba:	eb 05                	jmp    8007c1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007bc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007c1:	89 d0                	mov    %edx,%eax
  8007c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c6:	c9                   	leave  
  8007c7:	c3                   	ret    

008007c8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ce:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007d1:	50                   	push   %eax
  8007d2:	ff 75 08             	pushl  0x8(%ebp)
  8007d5:	e8 22 fc ff ff       	call   8003fc <fd_lookup>
  8007da:	83 c4 08             	add    $0x8,%esp
  8007dd:	85 c0                	test   %eax,%eax
  8007df:	78 0e                	js     8007ef <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007e7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ef:	c9                   	leave  
  8007f0:	c3                   	ret    

008007f1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007f1:	55                   	push   %ebp
  8007f2:	89 e5                	mov    %esp,%ebp
  8007f4:	53                   	push   %ebx
  8007f5:	83 ec 14             	sub    $0x14,%esp
  8007f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007fe:	50                   	push   %eax
  8007ff:	53                   	push   %ebx
  800800:	e8 f7 fb ff ff       	call   8003fc <fd_lookup>
  800805:	83 c4 08             	add    $0x8,%esp
  800808:	89 c2                	mov    %eax,%edx
  80080a:	85 c0                	test   %eax,%eax
  80080c:	78 65                	js     800873 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80080e:	83 ec 08             	sub    $0x8,%esp
  800811:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800814:	50                   	push   %eax
  800815:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800818:	ff 30                	pushl  (%eax)
  80081a:	e8 33 fc ff ff       	call   800452 <dev_lookup>
  80081f:	83 c4 10             	add    $0x10,%esp
  800822:	85 c0                	test   %eax,%eax
  800824:	78 44                	js     80086a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800826:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800829:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80082d:	75 21                	jne    800850 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80082f:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800834:	8b 40 48             	mov    0x48(%eax),%eax
  800837:	83 ec 04             	sub    $0x4,%esp
  80083a:	53                   	push   %ebx
  80083b:	50                   	push   %eax
  80083c:	68 18 23 80 00       	push   $0x802318
  800841:	e8 6a 0d 00 00       	call   8015b0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800846:	83 c4 10             	add    $0x10,%esp
  800849:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80084e:	eb 23                	jmp    800873 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800850:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800853:	8b 52 18             	mov    0x18(%edx),%edx
  800856:	85 d2                	test   %edx,%edx
  800858:	74 14                	je     80086e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80085a:	83 ec 08             	sub    $0x8,%esp
  80085d:	ff 75 0c             	pushl  0xc(%ebp)
  800860:	50                   	push   %eax
  800861:	ff d2                	call   *%edx
  800863:	89 c2                	mov    %eax,%edx
  800865:	83 c4 10             	add    $0x10,%esp
  800868:	eb 09                	jmp    800873 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086a:	89 c2                	mov    %eax,%edx
  80086c:	eb 05                	jmp    800873 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80086e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800873:	89 d0                	mov    %edx,%eax
  800875:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800878:	c9                   	leave  
  800879:	c3                   	ret    

0080087a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	53                   	push   %ebx
  80087e:	83 ec 14             	sub    $0x14,%esp
  800881:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800884:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800887:	50                   	push   %eax
  800888:	ff 75 08             	pushl  0x8(%ebp)
  80088b:	e8 6c fb ff ff       	call   8003fc <fd_lookup>
  800890:	83 c4 08             	add    $0x8,%esp
  800893:	89 c2                	mov    %eax,%edx
  800895:	85 c0                	test   %eax,%eax
  800897:	78 58                	js     8008f1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800899:	83 ec 08             	sub    $0x8,%esp
  80089c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80089f:	50                   	push   %eax
  8008a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008a3:	ff 30                	pushl  (%eax)
  8008a5:	e8 a8 fb ff ff       	call   800452 <dev_lookup>
  8008aa:	83 c4 10             	add    $0x10,%esp
  8008ad:	85 c0                	test   %eax,%eax
  8008af:	78 37                	js     8008e8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008b8:	74 32                	je     8008ec <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008ba:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008bd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008c4:	00 00 00 
	stat->st_isdir = 0;
  8008c7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ce:	00 00 00 
	stat->st_dev = dev;
  8008d1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008d7:	83 ec 08             	sub    $0x8,%esp
  8008da:	53                   	push   %ebx
  8008db:	ff 75 f0             	pushl  -0x10(%ebp)
  8008de:	ff 50 14             	call   *0x14(%eax)
  8008e1:	89 c2                	mov    %eax,%edx
  8008e3:	83 c4 10             	add    $0x10,%esp
  8008e6:	eb 09                	jmp    8008f1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008e8:	89 c2                	mov    %eax,%edx
  8008ea:	eb 05                	jmp    8008f1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ec:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008f1:	89 d0                	mov    %edx,%eax
  8008f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f6:	c9                   	leave  
  8008f7:	c3                   	ret    

008008f8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	56                   	push   %esi
  8008fc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008fd:	83 ec 08             	sub    $0x8,%esp
  800900:	6a 00                	push   $0x0
  800902:	ff 75 08             	pushl  0x8(%ebp)
  800905:	e8 e3 01 00 00       	call   800aed <open>
  80090a:	89 c3                	mov    %eax,%ebx
  80090c:	83 c4 10             	add    $0x10,%esp
  80090f:	85 c0                	test   %eax,%eax
  800911:	78 1b                	js     80092e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800913:	83 ec 08             	sub    $0x8,%esp
  800916:	ff 75 0c             	pushl  0xc(%ebp)
  800919:	50                   	push   %eax
  80091a:	e8 5b ff ff ff       	call   80087a <fstat>
  80091f:	89 c6                	mov    %eax,%esi
	close(fd);
  800921:	89 1c 24             	mov    %ebx,(%esp)
  800924:	e8 fd fb ff ff       	call   800526 <close>
	return r;
  800929:	83 c4 10             	add    $0x10,%esp
  80092c:	89 f0                	mov    %esi,%eax
}
  80092e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800931:	5b                   	pop    %ebx
  800932:	5e                   	pop    %esi
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	56                   	push   %esi
  800939:	53                   	push   %ebx
  80093a:	89 c6                	mov    %eax,%esi
  80093c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80093e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800945:	75 12                	jne    800959 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800947:	83 ec 0c             	sub    $0xc,%esp
  80094a:	6a 01                	push   $0x1
  80094c:	e8 67 16 00 00       	call   801fb8 <ipc_find_env>
  800951:	a3 00 40 80 00       	mov    %eax,0x804000
  800956:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800959:	6a 07                	push   $0x7
  80095b:	68 00 50 80 00       	push   $0x805000
  800960:	56                   	push   %esi
  800961:	ff 35 00 40 80 00    	pushl  0x804000
  800967:	e8 f8 15 00 00       	call   801f64 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80096c:	83 c4 0c             	add    $0xc,%esp
  80096f:	6a 00                	push   $0x0
  800971:	53                   	push   %ebx
  800972:	6a 00                	push   $0x0
  800974:	e8 82 15 00 00       	call   801efb <ipc_recv>
}
  800979:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80097c:	5b                   	pop    %ebx
  80097d:	5e                   	pop    %esi
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800986:	8b 45 08             	mov    0x8(%ebp),%eax
  800989:	8b 40 0c             	mov    0xc(%eax),%eax
  80098c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800991:	8b 45 0c             	mov    0xc(%ebp),%eax
  800994:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800999:	ba 00 00 00 00       	mov    $0x0,%edx
  80099e:	b8 02 00 00 00       	mov    $0x2,%eax
  8009a3:	e8 8d ff ff ff       	call   800935 <fsipc>
}
  8009a8:	c9                   	leave  
  8009a9:	c3                   	ret    

008009aa <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b3:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c0:	b8 06 00 00 00       	mov    $0x6,%eax
  8009c5:	e8 6b ff ff ff       	call   800935 <fsipc>
}
  8009ca:	c9                   	leave  
  8009cb:	c3                   	ret    

008009cc <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	53                   	push   %ebx
  8009d0:	83 ec 04             	sub    $0x4,%esp
  8009d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8009dc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e6:	b8 05 00 00 00       	mov    $0x5,%eax
  8009eb:	e8 45 ff ff ff       	call   800935 <fsipc>
  8009f0:	85 c0                	test   %eax,%eax
  8009f2:	78 2c                	js     800a20 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009f4:	83 ec 08             	sub    $0x8,%esp
  8009f7:	68 00 50 80 00       	push   $0x805000
  8009fc:	53                   	push   %ebx
  8009fd:	e8 b2 11 00 00       	call   801bb4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a02:	a1 80 50 80 00       	mov    0x805080,%eax
  800a07:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a0d:	a1 84 50 80 00       	mov    0x805084,%eax
  800a12:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a18:	83 c4 10             	add    $0x10,%esp
  800a1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a23:	c9                   	leave  
  800a24:	c3                   	ret    

00800a25 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a25:	55                   	push   %ebp
  800a26:	89 e5                	mov    %esp,%ebp
  800a28:	83 ec 0c             	sub    $0xc,%esp
  800a2b:	8b 45 10             	mov    0x10(%ebp),%eax
  800a2e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a33:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a38:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3e:	8b 52 0c             	mov    0xc(%edx),%edx
  800a41:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a47:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a4c:	50                   	push   %eax
  800a4d:	ff 75 0c             	pushl  0xc(%ebp)
  800a50:	68 08 50 80 00       	push   $0x805008
  800a55:	e8 ec 12 00 00       	call   801d46 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5f:	b8 04 00 00 00       	mov    $0x4,%eax
  800a64:	e8 cc fe ff ff       	call   800935 <fsipc>
	//panic("devfile_write not implemented");
}
  800a69:	c9                   	leave  
  800a6a:	c3                   	ret    

00800a6b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	56                   	push   %esi
  800a6f:	53                   	push   %ebx
  800a70:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a73:	8b 45 08             	mov    0x8(%ebp),%eax
  800a76:	8b 40 0c             	mov    0xc(%eax),%eax
  800a79:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a7e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a84:	ba 00 00 00 00       	mov    $0x0,%edx
  800a89:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8e:	e8 a2 fe ff ff       	call   800935 <fsipc>
  800a93:	89 c3                	mov    %eax,%ebx
  800a95:	85 c0                	test   %eax,%eax
  800a97:	78 4b                	js     800ae4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a99:	39 c6                	cmp    %eax,%esi
  800a9b:	73 16                	jae    800ab3 <devfile_read+0x48>
  800a9d:	68 88 23 80 00       	push   $0x802388
  800aa2:	68 8f 23 80 00       	push   $0x80238f
  800aa7:	6a 7c                	push   $0x7c
  800aa9:	68 a4 23 80 00       	push   $0x8023a4
  800aae:	e8 24 0a 00 00       	call   8014d7 <_panic>
	assert(r <= PGSIZE);
  800ab3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ab8:	7e 16                	jle    800ad0 <devfile_read+0x65>
  800aba:	68 af 23 80 00       	push   $0x8023af
  800abf:	68 8f 23 80 00       	push   $0x80238f
  800ac4:	6a 7d                	push   $0x7d
  800ac6:	68 a4 23 80 00       	push   $0x8023a4
  800acb:	e8 07 0a 00 00       	call   8014d7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ad0:	83 ec 04             	sub    $0x4,%esp
  800ad3:	50                   	push   %eax
  800ad4:	68 00 50 80 00       	push   $0x805000
  800ad9:	ff 75 0c             	pushl  0xc(%ebp)
  800adc:	e8 65 12 00 00       	call   801d46 <memmove>
	return r;
  800ae1:	83 c4 10             	add    $0x10,%esp
}
  800ae4:	89 d8                	mov    %ebx,%eax
  800ae6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    

00800aed <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800aed:	55                   	push   %ebp
  800aee:	89 e5                	mov    %esp,%ebp
  800af0:	53                   	push   %ebx
  800af1:	83 ec 20             	sub    $0x20,%esp
  800af4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800af7:	53                   	push   %ebx
  800af8:	e8 7e 10 00 00       	call   801b7b <strlen>
  800afd:	83 c4 10             	add    $0x10,%esp
  800b00:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b05:	7f 67                	jg     800b6e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b07:	83 ec 0c             	sub    $0xc,%esp
  800b0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b0d:	50                   	push   %eax
  800b0e:	e8 9a f8 ff ff       	call   8003ad <fd_alloc>
  800b13:	83 c4 10             	add    $0x10,%esp
		return r;
  800b16:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b18:	85 c0                	test   %eax,%eax
  800b1a:	78 57                	js     800b73 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b1c:	83 ec 08             	sub    $0x8,%esp
  800b1f:	53                   	push   %ebx
  800b20:	68 00 50 80 00       	push   $0x805000
  800b25:	e8 8a 10 00 00       	call   801bb4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b32:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b35:	b8 01 00 00 00       	mov    $0x1,%eax
  800b3a:	e8 f6 fd ff ff       	call   800935 <fsipc>
  800b3f:	89 c3                	mov    %eax,%ebx
  800b41:	83 c4 10             	add    $0x10,%esp
  800b44:	85 c0                	test   %eax,%eax
  800b46:	79 14                	jns    800b5c <open+0x6f>
		fd_close(fd, 0);
  800b48:	83 ec 08             	sub    $0x8,%esp
  800b4b:	6a 00                	push   $0x0
  800b4d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b50:	e8 50 f9 ff ff       	call   8004a5 <fd_close>
		return r;
  800b55:	83 c4 10             	add    $0x10,%esp
  800b58:	89 da                	mov    %ebx,%edx
  800b5a:	eb 17                	jmp    800b73 <open+0x86>
	}

	return fd2num(fd);
  800b5c:	83 ec 0c             	sub    $0xc,%esp
  800b5f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b62:	e8 1f f8 ff ff       	call   800386 <fd2num>
  800b67:	89 c2                	mov    %eax,%edx
  800b69:	83 c4 10             	add    $0x10,%esp
  800b6c:	eb 05                	jmp    800b73 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b6e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b73:	89 d0                	mov    %edx,%eax
  800b75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b78:	c9                   	leave  
  800b79:	c3                   	ret    

00800b7a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b80:	ba 00 00 00 00       	mov    $0x0,%edx
  800b85:	b8 08 00 00 00       	mov    $0x8,%eax
  800b8a:	e8 a6 fd ff ff       	call   800935 <fsipc>
}
  800b8f:	c9                   	leave  
  800b90:	c3                   	ret    

00800b91 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b97:	68 bb 23 80 00       	push   $0x8023bb
  800b9c:	ff 75 0c             	pushl  0xc(%ebp)
  800b9f:	e8 10 10 00 00       	call   801bb4 <strcpy>
	return 0;
}
  800ba4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba9:	c9                   	leave  
  800baa:	c3                   	ret    

00800bab <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	53                   	push   %ebx
  800baf:	83 ec 10             	sub    $0x10,%esp
  800bb2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bb5:	53                   	push   %ebx
  800bb6:	e8 36 14 00 00       	call   801ff1 <pageref>
  800bbb:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bbe:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800bc3:	83 f8 01             	cmp    $0x1,%eax
  800bc6:	75 10                	jne    800bd8 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800bc8:	83 ec 0c             	sub    $0xc,%esp
  800bcb:	ff 73 0c             	pushl  0xc(%ebx)
  800bce:	e8 c0 02 00 00       	call   800e93 <nsipc_close>
  800bd3:	89 c2                	mov    %eax,%edx
  800bd5:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800bd8:	89 d0                	mov    %edx,%eax
  800bda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bdd:	c9                   	leave  
  800bde:	c3                   	ret    

00800bdf <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800be5:	6a 00                	push   $0x0
  800be7:	ff 75 10             	pushl  0x10(%ebp)
  800bea:	ff 75 0c             	pushl  0xc(%ebp)
  800bed:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf0:	ff 70 0c             	pushl  0xc(%eax)
  800bf3:	e8 78 03 00 00       	call   800f70 <nsipc_send>
}
  800bf8:	c9                   	leave  
  800bf9:	c3                   	ret    

00800bfa <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c00:	6a 00                	push   $0x0
  800c02:	ff 75 10             	pushl  0x10(%ebp)
  800c05:	ff 75 0c             	pushl  0xc(%ebp)
  800c08:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0b:	ff 70 0c             	pushl  0xc(%eax)
  800c0e:	e8 f1 02 00 00       	call   800f04 <nsipc_recv>
}
  800c13:	c9                   	leave  
  800c14:	c3                   	ret    

00800c15 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c1b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c1e:	52                   	push   %edx
  800c1f:	50                   	push   %eax
  800c20:	e8 d7 f7 ff ff       	call   8003fc <fd_lookup>
  800c25:	83 c4 10             	add    $0x10,%esp
  800c28:	85 c0                	test   %eax,%eax
  800c2a:	78 17                	js     800c43 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c2f:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c35:	39 08                	cmp    %ecx,(%eax)
  800c37:	75 05                	jne    800c3e <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c39:	8b 40 0c             	mov    0xc(%eax),%eax
  800c3c:	eb 05                	jmp    800c43 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c3e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c43:	c9                   	leave  
  800c44:	c3                   	ret    

00800c45 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
  800c4a:	83 ec 1c             	sub    $0x1c,%esp
  800c4d:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c52:	50                   	push   %eax
  800c53:	e8 55 f7 ff ff       	call   8003ad <fd_alloc>
  800c58:	89 c3                	mov    %eax,%ebx
  800c5a:	83 c4 10             	add    $0x10,%esp
  800c5d:	85 c0                	test   %eax,%eax
  800c5f:	78 1b                	js     800c7c <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c61:	83 ec 04             	sub    $0x4,%esp
  800c64:	68 07 04 00 00       	push   $0x407
  800c69:	ff 75 f4             	pushl  -0xc(%ebp)
  800c6c:	6a 00                	push   $0x0
  800c6e:	e8 e3 f4 ff ff       	call   800156 <sys_page_alloc>
  800c73:	89 c3                	mov    %eax,%ebx
  800c75:	83 c4 10             	add    $0x10,%esp
  800c78:	85 c0                	test   %eax,%eax
  800c7a:	79 10                	jns    800c8c <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c7c:	83 ec 0c             	sub    $0xc,%esp
  800c7f:	56                   	push   %esi
  800c80:	e8 0e 02 00 00       	call   800e93 <nsipc_close>
		return r;
  800c85:	83 c4 10             	add    $0x10,%esp
  800c88:	89 d8                	mov    %ebx,%eax
  800c8a:	eb 24                	jmp    800cb0 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800c8c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800c92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c95:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c9a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800ca1:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800ca4:	83 ec 0c             	sub    $0xc,%esp
  800ca7:	50                   	push   %eax
  800ca8:	e8 d9 f6 ff ff       	call   800386 <fd2num>
  800cad:	83 c4 10             	add    $0x10,%esp
}
  800cb0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc0:	e8 50 ff ff ff       	call   800c15 <fd2sockid>
		return r;
  800cc5:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cc7:	85 c0                	test   %eax,%eax
  800cc9:	78 1f                	js     800cea <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800ccb:	83 ec 04             	sub    $0x4,%esp
  800cce:	ff 75 10             	pushl  0x10(%ebp)
  800cd1:	ff 75 0c             	pushl  0xc(%ebp)
  800cd4:	50                   	push   %eax
  800cd5:	e8 12 01 00 00       	call   800dec <nsipc_accept>
  800cda:	83 c4 10             	add    $0x10,%esp
		return r;
  800cdd:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cdf:	85 c0                	test   %eax,%eax
  800ce1:	78 07                	js     800cea <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800ce3:	e8 5d ff ff ff       	call   800c45 <alloc_sockfd>
  800ce8:	89 c1                	mov    %eax,%ecx
}
  800cea:	89 c8                	mov    %ecx,%eax
  800cec:	c9                   	leave  
  800ced:	c3                   	ret    

00800cee <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800cee:	55                   	push   %ebp
  800cef:	89 e5                	mov    %esp,%ebp
  800cf1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf7:	e8 19 ff ff ff       	call   800c15 <fd2sockid>
  800cfc:	85 c0                	test   %eax,%eax
  800cfe:	78 12                	js     800d12 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d00:	83 ec 04             	sub    $0x4,%esp
  800d03:	ff 75 10             	pushl  0x10(%ebp)
  800d06:	ff 75 0c             	pushl  0xc(%ebp)
  800d09:	50                   	push   %eax
  800d0a:	e8 2d 01 00 00       	call   800e3c <nsipc_bind>
  800d0f:	83 c4 10             	add    $0x10,%esp
}
  800d12:	c9                   	leave  
  800d13:	c3                   	ret    

00800d14 <shutdown>:

int
shutdown(int s, int how)
{
  800d14:	55                   	push   %ebp
  800d15:	89 e5                	mov    %esp,%ebp
  800d17:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1d:	e8 f3 fe ff ff       	call   800c15 <fd2sockid>
  800d22:	85 c0                	test   %eax,%eax
  800d24:	78 0f                	js     800d35 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d26:	83 ec 08             	sub    $0x8,%esp
  800d29:	ff 75 0c             	pushl  0xc(%ebp)
  800d2c:	50                   	push   %eax
  800d2d:	e8 3f 01 00 00       	call   800e71 <nsipc_shutdown>
  800d32:	83 c4 10             	add    $0x10,%esp
}
  800d35:	c9                   	leave  
  800d36:	c3                   	ret    

00800d37 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d40:	e8 d0 fe ff ff       	call   800c15 <fd2sockid>
  800d45:	85 c0                	test   %eax,%eax
  800d47:	78 12                	js     800d5b <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d49:	83 ec 04             	sub    $0x4,%esp
  800d4c:	ff 75 10             	pushl  0x10(%ebp)
  800d4f:	ff 75 0c             	pushl  0xc(%ebp)
  800d52:	50                   	push   %eax
  800d53:	e8 55 01 00 00       	call   800ead <nsipc_connect>
  800d58:	83 c4 10             	add    $0x10,%esp
}
  800d5b:	c9                   	leave  
  800d5c:	c3                   	ret    

00800d5d <listen>:

int
listen(int s, int backlog)
{
  800d5d:	55                   	push   %ebp
  800d5e:	89 e5                	mov    %esp,%ebp
  800d60:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d63:	8b 45 08             	mov    0x8(%ebp),%eax
  800d66:	e8 aa fe ff ff       	call   800c15 <fd2sockid>
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	78 0f                	js     800d7e <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d6f:	83 ec 08             	sub    $0x8,%esp
  800d72:	ff 75 0c             	pushl  0xc(%ebp)
  800d75:	50                   	push   %eax
  800d76:	e8 67 01 00 00       	call   800ee2 <nsipc_listen>
  800d7b:	83 c4 10             	add    $0x10,%esp
}
  800d7e:	c9                   	leave  
  800d7f:	c3                   	ret    

00800d80 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d80:	55                   	push   %ebp
  800d81:	89 e5                	mov    %esp,%ebp
  800d83:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d86:	ff 75 10             	pushl  0x10(%ebp)
  800d89:	ff 75 0c             	pushl  0xc(%ebp)
  800d8c:	ff 75 08             	pushl  0x8(%ebp)
  800d8f:	e8 3a 02 00 00       	call   800fce <nsipc_socket>
  800d94:	83 c4 10             	add    $0x10,%esp
  800d97:	85 c0                	test   %eax,%eax
  800d99:	78 05                	js     800da0 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800d9b:	e8 a5 fe ff ff       	call   800c45 <alloc_sockfd>
}
  800da0:	c9                   	leave  
  800da1:	c3                   	ret    

00800da2 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	53                   	push   %ebx
  800da6:	83 ec 04             	sub    $0x4,%esp
  800da9:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dab:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800db2:	75 12                	jne    800dc6 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800db4:	83 ec 0c             	sub    $0xc,%esp
  800db7:	6a 02                	push   $0x2
  800db9:	e8 fa 11 00 00       	call   801fb8 <ipc_find_env>
  800dbe:	a3 04 40 80 00       	mov    %eax,0x804004
  800dc3:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dc6:	6a 07                	push   $0x7
  800dc8:	68 00 60 80 00       	push   $0x806000
  800dcd:	53                   	push   %ebx
  800dce:	ff 35 04 40 80 00    	pushl  0x804004
  800dd4:	e8 8b 11 00 00       	call   801f64 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dd9:	83 c4 0c             	add    $0xc,%esp
  800ddc:	6a 00                	push   $0x0
  800dde:	6a 00                	push   $0x0
  800de0:	6a 00                	push   $0x0
  800de2:	e8 14 11 00 00       	call   801efb <ipc_recv>
}
  800de7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dea:	c9                   	leave  
  800deb:	c3                   	ret    

00800dec <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
  800df1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800df4:	8b 45 08             	mov    0x8(%ebp),%eax
  800df7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800dfc:	8b 06                	mov    (%esi),%eax
  800dfe:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e03:	b8 01 00 00 00       	mov    $0x1,%eax
  800e08:	e8 95 ff ff ff       	call   800da2 <nsipc>
  800e0d:	89 c3                	mov    %eax,%ebx
  800e0f:	85 c0                	test   %eax,%eax
  800e11:	78 20                	js     800e33 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e13:	83 ec 04             	sub    $0x4,%esp
  800e16:	ff 35 10 60 80 00    	pushl  0x806010
  800e1c:	68 00 60 80 00       	push   $0x806000
  800e21:	ff 75 0c             	pushl  0xc(%ebp)
  800e24:	e8 1d 0f 00 00       	call   801d46 <memmove>
		*addrlen = ret->ret_addrlen;
  800e29:	a1 10 60 80 00       	mov    0x806010,%eax
  800e2e:	89 06                	mov    %eax,(%esi)
  800e30:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e33:	89 d8                	mov    %ebx,%eax
  800e35:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e38:	5b                   	pop    %ebx
  800e39:	5e                   	pop    %esi
  800e3a:	5d                   	pop    %ebp
  800e3b:	c3                   	ret    

00800e3c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	53                   	push   %ebx
  800e40:	83 ec 08             	sub    $0x8,%esp
  800e43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e46:	8b 45 08             	mov    0x8(%ebp),%eax
  800e49:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e4e:	53                   	push   %ebx
  800e4f:	ff 75 0c             	pushl  0xc(%ebp)
  800e52:	68 04 60 80 00       	push   $0x806004
  800e57:	e8 ea 0e 00 00       	call   801d46 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e5c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e62:	b8 02 00 00 00       	mov    $0x2,%eax
  800e67:	e8 36 ff ff ff       	call   800da2 <nsipc>
}
  800e6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e6f:	c9                   	leave  
  800e70:	c3                   	ret    

00800e71 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e77:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7a:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e82:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e87:	b8 03 00 00 00       	mov    $0x3,%eax
  800e8c:	e8 11 ff ff ff       	call   800da2 <nsipc>
}
  800e91:	c9                   	leave  
  800e92:	c3                   	ret    

00800e93 <nsipc_close>:

int
nsipc_close(int s)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800e99:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9c:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800ea1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ea6:	e8 f7 fe ff ff       	call   800da2 <nsipc>
}
  800eab:	c9                   	leave  
  800eac:	c3                   	ret    

00800ead <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	53                   	push   %ebx
  800eb1:	83 ec 08             	sub    $0x8,%esp
  800eb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eba:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ebf:	53                   	push   %ebx
  800ec0:	ff 75 0c             	pushl  0xc(%ebp)
  800ec3:	68 04 60 80 00       	push   $0x806004
  800ec8:	e8 79 0e 00 00       	call   801d46 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ecd:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ed3:	b8 05 00 00 00       	mov    $0x5,%eax
  800ed8:	e8 c5 fe ff ff       	call   800da2 <nsipc>
}
  800edd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ee0:	c9                   	leave  
  800ee1:	c3                   	ret    

00800ee2 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ee8:	8b 45 08             	mov    0x8(%ebp),%eax
  800eeb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800ef0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef3:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800ef8:	b8 06 00 00 00       	mov    $0x6,%eax
  800efd:	e8 a0 fe ff ff       	call   800da2 <nsipc>
}
  800f02:	c9                   	leave  
  800f03:	c3                   	ret    

00800f04 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	56                   	push   %esi
  800f08:	53                   	push   %ebx
  800f09:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f14:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f1a:	8b 45 14             	mov    0x14(%ebp),%eax
  800f1d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f22:	b8 07 00 00 00       	mov    $0x7,%eax
  800f27:	e8 76 fe ff ff       	call   800da2 <nsipc>
  800f2c:	89 c3                	mov    %eax,%ebx
  800f2e:	85 c0                	test   %eax,%eax
  800f30:	78 35                	js     800f67 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f32:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f37:	7f 04                	jg     800f3d <nsipc_recv+0x39>
  800f39:	39 c6                	cmp    %eax,%esi
  800f3b:	7d 16                	jge    800f53 <nsipc_recv+0x4f>
  800f3d:	68 c7 23 80 00       	push   $0x8023c7
  800f42:	68 8f 23 80 00       	push   $0x80238f
  800f47:	6a 62                	push   $0x62
  800f49:	68 dc 23 80 00       	push   $0x8023dc
  800f4e:	e8 84 05 00 00       	call   8014d7 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f53:	83 ec 04             	sub    $0x4,%esp
  800f56:	50                   	push   %eax
  800f57:	68 00 60 80 00       	push   $0x806000
  800f5c:	ff 75 0c             	pushl  0xc(%ebp)
  800f5f:	e8 e2 0d 00 00       	call   801d46 <memmove>
  800f64:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f67:	89 d8                	mov    %ebx,%eax
  800f69:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f6c:	5b                   	pop    %ebx
  800f6d:	5e                   	pop    %esi
  800f6e:	5d                   	pop    %ebp
  800f6f:	c3                   	ret    

00800f70 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	53                   	push   %ebx
  800f74:	83 ec 04             	sub    $0x4,%esp
  800f77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7d:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f82:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f88:	7e 16                	jle    800fa0 <nsipc_send+0x30>
  800f8a:	68 e8 23 80 00       	push   $0x8023e8
  800f8f:	68 8f 23 80 00       	push   $0x80238f
  800f94:	6a 6d                	push   $0x6d
  800f96:	68 dc 23 80 00       	push   $0x8023dc
  800f9b:	e8 37 05 00 00       	call   8014d7 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fa0:	83 ec 04             	sub    $0x4,%esp
  800fa3:	53                   	push   %ebx
  800fa4:	ff 75 0c             	pushl  0xc(%ebp)
  800fa7:	68 0c 60 80 00       	push   $0x80600c
  800fac:	e8 95 0d 00 00       	call   801d46 <memmove>
	nsipcbuf.send.req_size = size;
  800fb1:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fb7:	8b 45 14             	mov    0x14(%ebp),%eax
  800fba:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fbf:	b8 08 00 00 00       	mov    $0x8,%eax
  800fc4:	e8 d9 fd ff ff       	call   800da2 <nsipc>
}
  800fc9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fcc:	c9                   	leave  
  800fcd:	c3                   	ret    

00800fce <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd7:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800fdc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fdf:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800fe4:	8b 45 10             	mov    0x10(%ebp),%eax
  800fe7:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  800fec:	b8 09 00 00 00       	mov    $0x9,%eax
  800ff1:	e8 ac fd ff ff       	call   800da2 <nsipc>
}
  800ff6:	c9                   	leave  
  800ff7:	c3                   	ret    

00800ff8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	56                   	push   %esi
  800ffc:	53                   	push   %ebx
  800ffd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801000:	83 ec 0c             	sub    $0xc,%esp
  801003:	ff 75 08             	pushl  0x8(%ebp)
  801006:	e8 8b f3 ff ff       	call   800396 <fd2data>
  80100b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80100d:	83 c4 08             	add    $0x8,%esp
  801010:	68 f4 23 80 00       	push   $0x8023f4
  801015:	53                   	push   %ebx
  801016:	e8 99 0b 00 00       	call   801bb4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80101b:	8b 46 04             	mov    0x4(%esi),%eax
  80101e:	2b 06                	sub    (%esi),%eax
  801020:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801026:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80102d:	00 00 00 
	stat->st_dev = &devpipe;
  801030:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801037:	30 80 00 
	return 0;
}
  80103a:	b8 00 00 00 00       	mov    $0x0,%eax
  80103f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801042:	5b                   	pop    %ebx
  801043:	5e                   	pop    %esi
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    

00801046 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801046:	55                   	push   %ebp
  801047:	89 e5                	mov    %esp,%ebp
  801049:	53                   	push   %ebx
  80104a:	83 ec 0c             	sub    $0xc,%esp
  80104d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801050:	53                   	push   %ebx
  801051:	6a 00                	push   $0x0
  801053:	e8 83 f1 ff ff       	call   8001db <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801058:	89 1c 24             	mov    %ebx,(%esp)
  80105b:	e8 36 f3 ff ff       	call   800396 <fd2data>
  801060:	83 c4 08             	add    $0x8,%esp
  801063:	50                   	push   %eax
  801064:	6a 00                	push   $0x0
  801066:	e8 70 f1 ff ff       	call   8001db <sys_page_unmap>
}
  80106b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106e:	c9                   	leave  
  80106f:	c3                   	ret    

00801070 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	57                   	push   %edi
  801074:	56                   	push   %esi
  801075:	53                   	push   %ebx
  801076:	83 ec 1c             	sub    $0x1c,%esp
  801079:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80107c:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80107e:	a1 08 40 80 00       	mov    0x804008,%eax
  801083:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801086:	83 ec 0c             	sub    $0xc,%esp
  801089:	ff 75 e0             	pushl  -0x20(%ebp)
  80108c:	e8 60 0f 00 00       	call   801ff1 <pageref>
  801091:	89 c3                	mov    %eax,%ebx
  801093:	89 3c 24             	mov    %edi,(%esp)
  801096:	e8 56 0f 00 00       	call   801ff1 <pageref>
  80109b:	83 c4 10             	add    $0x10,%esp
  80109e:	39 c3                	cmp    %eax,%ebx
  8010a0:	0f 94 c1             	sete   %cl
  8010a3:	0f b6 c9             	movzbl %cl,%ecx
  8010a6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010a9:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010af:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010b2:	39 ce                	cmp    %ecx,%esi
  8010b4:	74 1b                	je     8010d1 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010b6:	39 c3                	cmp    %eax,%ebx
  8010b8:	75 c4                	jne    80107e <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010ba:	8b 42 58             	mov    0x58(%edx),%eax
  8010bd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010c0:	50                   	push   %eax
  8010c1:	56                   	push   %esi
  8010c2:	68 fb 23 80 00       	push   $0x8023fb
  8010c7:	e8 e4 04 00 00       	call   8015b0 <cprintf>
  8010cc:	83 c4 10             	add    $0x10,%esp
  8010cf:	eb ad                	jmp    80107e <_pipeisclosed+0xe>
	}
}
  8010d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d7:	5b                   	pop    %ebx
  8010d8:	5e                   	pop    %esi
  8010d9:	5f                   	pop    %edi
  8010da:	5d                   	pop    %ebp
  8010db:	c3                   	ret    

008010dc <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010dc:	55                   	push   %ebp
  8010dd:	89 e5                	mov    %esp,%ebp
  8010df:	57                   	push   %edi
  8010e0:	56                   	push   %esi
  8010e1:	53                   	push   %ebx
  8010e2:	83 ec 28             	sub    $0x28,%esp
  8010e5:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8010e8:	56                   	push   %esi
  8010e9:	e8 a8 f2 ff ff       	call   800396 <fd2data>
  8010ee:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010f0:	83 c4 10             	add    $0x10,%esp
  8010f3:	bf 00 00 00 00       	mov    $0x0,%edi
  8010f8:	eb 4b                	jmp    801145 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8010fa:	89 da                	mov    %ebx,%edx
  8010fc:	89 f0                	mov    %esi,%eax
  8010fe:	e8 6d ff ff ff       	call   801070 <_pipeisclosed>
  801103:	85 c0                	test   %eax,%eax
  801105:	75 48                	jne    80114f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801107:	e8 2b f0 ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80110c:	8b 43 04             	mov    0x4(%ebx),%eax
  80110f:	8b 0b                	mov    (%ebx),%ecx
  801111:	8d 51 20             	lea    0x20(%ecx),%edx
  801114:	39 d0                	cmp    %edx,%eax
  801116:	73 e2                	jae    8010fa <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801118:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80111b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80111f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801122:	89 c2                	mov    %eax,%edx
  801124:	c1 fa 1f             	sar    $0x1f,%edx
  801127:	89 d1                	mov    %edx,%ecx
  801129:	c1 e9 1b             	shr    $0x1b,%ecx
  80112c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80112f:	83 e2 1f             	and    $0x1f,%edx
  801132:	29 ca                	sub    %ecx,%edx
  801134:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801138:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80113c:	83 c0 01             	add    $0x1,%eax
  80113f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801142:	83 c7 01             	add    $0x1,%edi
  801145:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801148:	75 c2                	jne    80110c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80114a:	8b 45 10             	mov    0x10(%ebp),%eax
  80114d:	eb 05                	jmp    801154 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80114f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801154:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801157:	5b                   	pop    %ebx
  801158:	5e                   	pop    %esi
  801159:	5f                   	pop    %edi
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    

0080115c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	57                   	push   %edi
  801160:	56                   	push   %esi
  801161:	53                   	push   %ebx
  801162:	83 ec 18             	sub    $0x18,%esp
  801165:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801168:	57                   	push   %edi
  801169:	e8 28 f2 ff ff       	call   800396 <fd2data>
  80116e:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801170:	83 c4 10             	add    $0x10,%esp
  801173:	bb 00 00 00 00       	mov    $0x0,%ebx
  801178:	eb 3d                	jmp    8011b7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80117a:	85 db                	test   %ebx,%ebx
  80117c:	74 04                	je     801182 <devpipe_read+0x26>
				return i;
  80117e:	89 d8                	mov    %ebx,%eax
  801180:	eb 44                	jmp    8011c6 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801182:	89 f2                	mov    %esi,%edx
  801184:	89 f8                	mov    %edi,%eax
  801186:	e8 e5 fe ff ff       	call   801070 <_pipeisclosed>
  80118b:	85 c0                	test   %eax,%eax
  80118d:	75 32                	jne    8011c1 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80118f:	e8 a3 ef ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801194:	8b 06                	mov    (%esi),%eax
  801196:	3b 46 04             	cmp    0x4(%esi),%eax
  801199:	74 df                	je     80117a <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80119b:	99                   	cltd   
  80119c:	c1 ea 1b             	shr    $0x1b,%edx
  80119f:	01 d0                	add    %edx,%eax
  8011a1:	83 e0 1f             	and    $0x1f,%eax
  8011a4:	29 d0                	sub    %edx,%eax
  8011a6:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ae:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011b1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011b4:	83 c3 01             	add    $0x1,%ebx
  8011b7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011ba:	75 d8                	jne    801194 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011bc:	8b 45 10             	mov    0x10(%ebp),%eax
  8011bf:	eb 05                	jmp    8011c6 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011c1:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c9:	5b                   	pop    %ebx
  8011ca:	5e                   	pop    %esi
  8011cb:	5f                   	pop    %edi
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    

008011ce <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	56                   	push   %esi
  8011d2:	53                   	push   %ebx
  8011d3:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d9:	50                   	push   %eax
  8011da:	e8 ce f1 ff ff       	call   8003ad <fd_alloc>
  8011df:	83 c4 10             	add    $0x10,%esp
  8011e2:	89 c2                	mov    %eax,%edx
  8011e4:	85 c0                	test   %eax,%eax
  8011e6:	0f 88 2c 01 00 00    	js     801318 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011ec:	83 ec 04             	sub    $0x4,%esp
  8011ef:	68 07 04 00 00       	push   $0x407
  8011f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8011f7:	6a 00                	push   $0x0
  8011f9:	e8 58 ef ff ff       	call   800156 <sys_page_alloc>
  8011fe:	83 c4 10             	add    $0x10,%esp
  801201:	89 c2                	mov    %eax,%edx
  801203:	85 c0                	test   %eax,%eax
  801205:	0f 88 0d 01 00 00    	js     801318 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80120b:	83 ec 0c             	sub    $0xc,%esp
  80120e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801211:	50                   	push   %eax
  801212:	e8 96 f1 ff ff       	call   8003ad <fd_alloc>
  801217:	89 c3                	mov    %eax,%ebx
  801219:	83 c4 10             	add    $0x10,%esp
  80121c:	85 c0                	test   %eax,%eax
  80121e:	0f 88 e2 00 00 00    	js     801306 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801224:	83 ec 04             	sub    $0x4,%esp
  801227:	68 07 04 00 00       	push   $0x407
  80122c:	ff 75 f0             	pushl  -0x10(%ebp)
  80122f:	6a 00                	push   $0x0
  801231:	e8 20 ef ff ff       	call   800156 <sys_page_alloc>
  801236:	89 c3                	mov    %eax,%ebx
  801238:	83 c4 10             	add    $0x10,%esp
  80123b:	85 c0                	test   %eax,%eax
  80123d:	0f 88 c3 00 00 00    	js     801306 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801243:	83 ec 0c             	sub    $0xc,%esp
  801246:	ff 75 f4             	pushl  -0xc(%ebp)
  801249:	e8 48 f1 ff ff       	call   800396 <fd2data>
  80124e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801250:	83 c4 0c             	add    $0xc,%esp
  801253:	68 07 04 00 00       	push   $0x407
  801258:	50                   	push   %eax
  801259:	6a 00                	push   $0x0
  80125b:	e8 f6 ee ff ff       	call   800156 <sys_page_alloc>
  801260:	89 c3                	mov    %eax,%ebx
  801262:	83 c4 10             	add    $0x10,%esp
  801265:	85 c0                	test   %eax,%eax
  801267:	0f 88 89 00 00 00    	js     8012f6 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80126d:	83 ec 0c             	sub    $0xc,%esp
  801270:	ff 75 f0             	pushl  -0x10(%ebp)
  801273:	e8 1e f1 ff ff       	call   800396 <fd2data>
  801278:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80127f:	50                   	push   %eax
  801280:	6a 00                	push   $0x0
  801282:	56                   	push   %esi
  801283:	6a 00                	push   $0x0
  801285:	e8 0f ef ff ff       	call   800199 <sys_page_map>
  80128a:	89 c3                	mov    %eax,%ebx
  80128c:	83 c4 20             	add    $0x20,%esp
  80128f:	85 c0                	test   %eax,%eax
  801291:	78 55                	js     8012e8 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801293:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801299:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80129c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80129e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012a8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012bd:	83 ec 0c             	sub    $0xc,%esp
  8012c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8012c3:	e8 be f0 ff ff       	call   800386 <fd2num>
  8012c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012cb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012cd:	83 c4 04             	add    $0x4,%esp
  8012d0:	ff 75 f0             	pushl  -0x10(%ebp)
  8012d3:	e8 ae f0 ff ff       	call   800386 <fd2num>
  8012d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012db:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012de:	83 c4 10             	add    $0x10,%esp
  8012e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e6:	eb 30                	jmp    801318 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8012e8:	83 ec 08             	sub    $0x8,%esp
  8012eb:	56                   	push   %esi
  8012ec:	6a 00                	push   $0x0
  8012ee:	e8 e8 ee ff ff       	call   8001db <sys_page_unmap>
  8012f3:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8012f6:	83 ec 08             	sub    $0x8,%esp
  8012f9:	ff 75 f0             	pushl  -0x10(%ebp)
  8012fc:	6a 00                	push   $0x0
  8012fe:	e8 d8 ee ff ff       	call   8001db <sys_page_unmap>
  801303:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801306:	83 ec 08             	sub    $0x8,%esp
  801309:	ff 75 f4             	pushl  -0xc(%ebp)
  80130c:	6a 00                	push   $0x0
  80130e:	e8 c8 ee ff ff       	call   8001db <sys_page_unmap>
  801313:	83 c4 10             	add    $0x10,%esp
  801316:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801318:	89 d0                	mov    %edx,%eax
  80131a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80131d:	5b                   	pop    %ebx
  80131e:	5e                   	pop    %esi
  80131f:	5d                   	pop    %ebp
  801320:	c3                   	ret    

00801321 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801321:	55                   	push   %ebp
  801322:	89 e5                	mov    %esp,%ebp
  801324:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801327:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132a:	50                   	push   %eax
  80132b:	ff 75 08             	pushl  0x8(%ebp)
  80132e:	e8 c9 f0 ff ff       	call   8003fc <fd_lookup>
  801333:	83 c4 10             	add    $0x10,%esp
  801336:	85 c0                	test   %eax,%eax
  801338:	78 18                	js     801352 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80133a:	83 ec 0c             	sub    $0xc,%esp
  80133d:	ff 75 f4             	pushl  -0xc(%ebp)
  801340:	e8 51 f0 ff ff       	call   800396 <fd2data>
	return _pipeisclosed(fd, p);
  801345:	89 c2                	mov    %eax,%edx
  801347:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80134a:	e8 21 fd ff ff       	call   801070 <_pipeisclosed>
  80134f:	83 c4 10             	add    $0x10,%esp
}
  801352:	c9                   	leave  
  801353:	c3                   	ret    

00801354 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801354:	55                   	push   %ebp
  801355:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801357:	b8 00 00 00 00       	mov    $0x0,%eax
  80135c:	5d                   	pop    %ebp
  80135d:	c3                   	ret    

0080135e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80135e:	55                   	push   %ebp
  80135f:	89 e5                	mov    %esp,%ebp
  801361:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801364:	68 13 24 80 00       	push   $0x802413
  801369:	ff 75 0c             	pushl  0xc(%ebp)
  80136c:	e8 43 08 00 00       	call   801bb4 <strcpy>
	return 0;
}
  801371:	b8 00 00 00 00       	mov    $0x0,%eax
  801376:	c9                   	leave  
  801377:	c3                   	ret    

00801378 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	57                   	push   %edi
  80137c:	56                   	push   %esi
  80137d:	53                   	push   %ebx
  80137e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801384:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801389:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80138f:	eb 2d                	jmp    8013be <devcons_write+0x46>
		m = n - tot;
  801391:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801394:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801396:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801399:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80139e:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013a1:	83 ec 04             	sub    $0x4,%esp
  8013a4:	53                   	push   %ebx
  8013a5:	03 45 0c             	add    0xc(%ebp),%eax
  8013a8:	50                   	push   %eax
  8013a9:	57                   	push   %edi
  8013aa:	e8 97 09 00 00       	call   801d46 <memmove>
		sys_cputs(buf, m);
  8013af:	83 c4 08             	add    $0x8,%esp
  8013b2:	53                   	push   %ebx
  8013b3:	57                   	push   %edi
  8013b4:	e8 e1 ec ff ff       	call   80009a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013b9:	01 de                	add    %ebx,%esi
  8013bb:	83 c4 10             	add    $0x10,%esp
  8013be:	89 f0                	mov    %esi,%eax
  8013c0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013c3:	72 cc                	jb     801391 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c8:	5b                   	pop    %ebx
  8013c9:	5e                   	pop    %esi
  8013ca:	5f                   	pop    %edi
  8013cb:	5d                   	pop    %ebp
  8013cc:	c3                   	ret    

008013cd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	83 ec 08             	sub    $0x8,%esp
  8013d3:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013d8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013dc:	74 2a                	je     801408 <devcons_read+0x3b>
  8013de:	eb 05                	jmp    8013e5 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013e0:	e8 52 ed ff ff       	call   800137 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013e5:	e8 ce ec ff ff       	call   8000b8 <sys_cgetc>
  8013ea:	85 c0                	test   %eax,%eax
  8013ec:	74 f2                	je     8013e0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	78 16                	js     801408 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8013f2:	83 f8 04             	cmp    $0x4,%eax
  8013f5:	74 0c                	je     801403 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8013f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013fa:	88 02                	mov    %al,(%edx)
	return 1;
  8013fc:	b8 01 00 00 00       	mov    $0x1,%eax
  801401:	eb 05                	jmp    801408 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801403:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801408:	c9                   	leave  
  801409:	c3                   	ret    

0080140a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801410:	8b 45 08             	mov    0x8(%ebp),%eax
  801413:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801416:	6a 01                	push   $0x1
  801418:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80141b:	50                   	push   %eax
  80141c:	e8 79 ec ff ff       	call   80009a <sys_cputs>
}
  801421:	83 c4 10             	add    $0x10,%esp
  801424:	c9                   	leave  
  801425:	c3                   	ret    

00801426 <getchar>:

int
getchar(void)
{
  801426:	55                   	push   %ebp
  801427:	89 e5                	mov    %esp,%ebp
  801429:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80142c:	6a 01                	push   $0x1
  80142e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801431:	50                   	push   %eax
  801432:	6a 00                	push   $0x0
  801434:	e8 29 f2 ff ff       	call   800662 <read>
	if (r < 0)
  801439:	83 c4 10             	add    $0x10,%esp
  80143c:	85 c0                	test   %eax,%eax
  80143e:	78 0f                	js     80144f <getchar+0x29>
		return r;
	if (r < 1)
  801440:	85 c0                	test   %eax,%eax
  801442:	7e 06                	jle    80144a <getchar+0x24>
		return -E_EOF;
	return c;
  801444:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801448:	eb 05                	jmp    80144f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80144a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80144f:	c9                   	leave  
  801450:	c3                   	ret    

00801451 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801457:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80145a:	50                   	push   %eax
  80145b:	ff 75 08             	pushl  0x8(%ebp)
  80145e:	e8 99 ef ff ff       	call   8003fc <fd_lookup>
  801463:	83 c4 10             	add    $0x10,%esp
  801466:	85 c0                	test   %eax,%eax
  801468:	78 11                	js     80147b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80146a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80146d:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801473:	39 10                	cmp    %edx,(%eax)
  801475:	0f 94 c0             	sete   %al
  801478:	0f b6 c0             	movzbl %al,%eax
}
  80147b:	c9                   	leave  
  80147c:	c3                   	ret    

0080147d <opencons>:

int
opencons(void)
{
  80147d:	55                   	push   %ebp
  80147e:	89 e5                	mov    %esp,%ebp
  801480:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801483:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801486:	50                   	push   %eax
  801487:	e8 21 ef ff ff       	call   8003ad <fd_alloc>
  80148c:	83 c4 10             	add    $0x10,%esp
		return r;
  80148f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801491:	85 c0                	test   %eax,%eax
  801493:	78 3e                	js     8014d3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801495:	83 ec 04             	sub    $0x4,%esp
  801498:	68 07 04 00 00       	push   $0x407
  80149d:	ff 75 f4             	pushl  -0xc(%ebp)
  8014a0:	6a 00                	push   $0x0
  8014a2:	e8 af ec ff ff       	call   800156 <sys_page_alloc>
  8014a7:	83 c4 10             	add    $0x10,%esp
		return r;
  8014aa:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014ac:	85 c0                	test   %eax,%eax
  8014ae:	78 23                	js     8014d3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014b0:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014be:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014c5:	83 ec 0c             	sub    $0xc,%esp
  8014c8:	50                   	push   %eax
  8014c9:	e8 b8 ee ff ff       	call   800386 <fd2num>
  8014ce:	89 c2                	mov    %eax,%edx
  8014d0:	83 c4 10             	add    $0x10,%esp
}
  8014d3:	89 d0                	mov    %edx,%eax
  8014d5:	c9                   	leave  
  8014d6:	c3                   	ret    

008014d7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014d7:	55                   	push   %ebp
  8014d8:	89 e5                	mov    %esp,%ebp
  8014da:	56                   	push   %esi
  8014db:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014dc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014df:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014e5:	e8 2e ec ff ff       	call   800118 <sys_getenvid>
  8014ea:	83 ec 0c             	sub    $0xc,%esp
  8014ed:	ff 75 0c             	pushl  0xc(%ebp)
  8014f0:	ff 75 08             	pushl  0x8(%ebp)
  8014f3:	56                   	push   %esi
  8014f4:	50                   	push   %eax
  8014f5:	68 20 24 80 00       	push   $0x802420
  8014fa:	e8 b1 00 00 00       	call   8015b0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014ff:	83 c4 18             	add    $0x18,%esp
  801502:	53                   	push   %ebx
  801503:	ff 75 10             	pushl  0x10(%ebp)
  801506:	e8 54 00 00 00       	call   80155f <vcprintf>
	cprintf("\n");
  80150b:	c7 04 24 0c 24 80 00 	movl   $0x80240c,(%esp)
  801512:	e8 99 00 00 00       	call   8015b0 <cprintf>
  801517:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80151a:	cc                   	int3   
  80151b:	eb fd                	jmp    80151a <_panic+0x43>

0080151d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	53                   	push   %ebx
  801521:	83 ec 04             	sub    $0x4,%esp
  801524:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801527:	8b 13                	mov    (%ebx),%edx
  801529:	8d 42 01             	lea    0x1(%edx),%eax
  80152c:	89 03                	mov    %eax,(%ebx)
  80152e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801531:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801535:	3d ff 00 00 00       	cmp    $0xff,%eax
  80153a:	75 1a                	jne    801556 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80153c:	83 ec 08             	sub    $0x8,%esp
  80153f:	68 ff 00 00 00       	push   $0xff
  801544:	8d 43 08             	lea    0x8(%ebx),%eax
  801547:	50                   	push   %eax
  801548:	e8 4d eb ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  80154d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801553:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801556:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80155a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155d:	c9                   	leave  
  80155e:	c3                   	ret    

0080155f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80155f:	55                   	push   %ebp
  801560:	89 e5                	mov    %esp,%ebp
  801562:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801568:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80156f:	00 00 00 
	b.cnt = 0;
  801572:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801579:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80157c:	ff 75 0c             	pushl  0xc(%ebp)
  80157f:	ff 75 08             	pushl  0x8(%ebp)
  801582:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801588:	50                   	push   %eax
  801589:	68 1d 15 80 00       	push   $0x80151d
  80158e:	e8 1a 01 00 00       	call   8016ad <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801593:	83 c4 08             	add    $0x8,%esp
  801596:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80159c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015a2:	50                   	push   %eax
  8015a3:	e8 f2 ea ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  8015a8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015ae:	c9                   	leave  
  8015af:	c3                   	ret    

008015b0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015b0:	55                   	push   %ebp
  8015b1:	89 e5                	mov    %esp,%ebp
  8015b3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015b6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015b9:	50                   	push   %eax
  8015ba:	ff 75 08             	pushl  0x8(%ebp)
  8015bd:	e8 9d ff ff ff       	call   80155f <vcprintf>
	va_end(ap);

	return cnt;
}
  8015c2:	c9                   	leave  
  8015c3:	c3                   	ret    

008015c4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015c4:	55                   	push   %ebp
  8015c5:	89 e5                	mov    %esp,%ebp
  8015c7:	57                   	push   %edi
  8015c8:	56                   	push   %esi
  8015c9:	53                   	push   %ebx
  8015ca:	83 ec 1c             	sub    $0x1c,%esp
  8015cd:	89 c7                	mov    %eax,%edi
  8015cf:	89 d6                	mov    %edx,%esi
  8015d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015da:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015dd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015e5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015e8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015eb:	39 d3                	cmp    %edx,%ebx
  8015ed:	72 05                	jb     8015f4 <printnum+0x30>
  8015ef:	39 45 10             	cmp    %eax,0x10(%ebp)
  8015f2:	77 45                	ja     801639 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015f4:	83 ec 0c             	sub    $0xc,%esp
  8015f7:	ff 75 18             	pushl  0x18(%ebp)
  8015fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8015fd:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801600:	53                   	push   %ebx
  801601:	ff 75 10             	pushl  0x10(%ebp)
  801604:	83 ec 08             	sub    $0x8,%esp
  801607:	ff 75 e4             	pushl  -0x1c(%ebp)
  80160a:	ff 75 e0             	pushl  -0x20(%ebp)
  80160d:	ff 75 dc             	pushl  -0x24(%ebp)
  801610:	ff 75 d8             	pushl  -0x28(%ebp)
  801613:	e8 18 0a 00 00       	call   802030 <__udivdi3>
  801618:	83 c4 18             	add    $0x18,%esp
  80161b:	52                   	push   %edx
  80161c:	50                   	push   %eax
  80161d:	89 f2                	mov    %esi,%edx
  80161f:	89 f8                	mov    %edi,%eax
  801621:	e8 9e ff ff ff       	call   8015c4 <printnum>
  801626:	83 c4 20             	add    $0x20,%esp
  801629:	eb 18                	jmp    801643 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80162b:	83 ec 08             	sub    $0x8,%esp
  80162e:	56                   	push   %esi
  80162f:	ff 75 18             	pushl  0x18(%ebp)
  801632:	ff d7                	call   *%edi
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	eb 03                	jmp    80163c <printnum+0x78>
  801639:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80163c:	83 eb 01             	sub    $0x1,%ebx
  80163f:	85 db                	test   %ebx,%ebx
  801641:	7f e8                	jg     80162b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801643:	83 ec 08             	sub    $0x8,%esp
  801646:	56                   	push   %esi
  801647:	83 ec 04             	sub    $0x4,%esp
  80164a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80164d:	ff 75 e0             	pushl  -0x20(%ebp)
  801650:	ff 75 dc             	pushl  -0x24(%ebp)
  801653:	ff 75 d8             	pushl  -0x28(%ebp)
  801656:	e8 05 0b 00 00       	call   802160 <__umoddi3>
  80165b:	83 c4 14             	add    $0x14,%esp
  80165e:	0f be 80 43 24 80 00 	movsbl 0x802443(%eax),%eax
  801665:	50                   	push   %eax
  801666:	ff d7                	call   *%edi
}
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80166e:	5b                   	pop    %ebx
  80166f:	5e                   	pop    %esi
  801670:	5f                   	pop    %edi
  801671:	5d                   	pop    %ebp
  801672:	c3                   	ret    

00801673 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801679:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80167d:	8b 10                	mov    (%eax),%edx
  80167f:	3b 50 04             	cmp    0x4(%eax),%edx
  801682:	73 0a                	jae    80168e <sprintputch+0x1b>
		*b->buf++ = ch;
  801684:	8d 4a 01             	lea    0x1(%edx),%ecx
  801687:	89 08                	mov    %ecx,(%eax)
  801689:	8b 45 08             	mov    0x8(%ebp),%eax
  80168c:	88 02                	mov    %al,(%edx)
}
  80168e:	5d                   	pop    %ebp
  80168f:	c3                   	ret    

00801690 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801696:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801699:	50                   	push   %eax
  80169a:	ff 75 10             	pushl  0x10(%ebp)
  80169d:	ff 75 0c             	pushl  0xc(%ebp)
  8016a0:	ff 75 08             	pushl  0x8(%ebp)
  8016a3:	e8 05 00 00 00       	call   8016ad <vprintfmt>
	va_end(ap);
}
  8016a8:	83 c4 10             	add    $0x10,%esp
  8016ab:	c9                   	leave  
  8016ac:	c3                   	ret    

008016ad <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	57                   	push   %edi
  8016b1:	56                   	push   %esi
  8016b2:	53                   	push   %ebx
  8016b3:	83 ec 2c             	sub    $0x2c,%esp
  8016b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8016b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016bc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016bf:	eb 12                	jmp    8016d3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016c1:	85 c0                	test   %eax,%eax
  8016c3:	0f 84 42 04 00 00    	je     801b0b <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8016c9:	83 ec 08             	sub    $0x8,%esp
  8016cc:	53                   	push   %ebx
  8016cd:	50                   	push   %eax
  8016ce:	ff d6                	call   *%esi
  8016d0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016d3:	83 c7 01             	add    $0x1,%edi
  8016d6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016da:	83 f8 25             	cmp    $0x25,%eax
  8016dd:	75 e2                	jne    8016c1 <vprintfmt+0x14>
  8016df:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8016e3:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8016ea:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016f1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8016f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016fd:	eb 07                	jmp    801706 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801702:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801706:	8d 47 01             	lea    0x1(%edi),%eax
  801709:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80170c:	0f b6 07             	movzbl (%edi),%eax
  80170f:	0f b6 d0             	movzbl %al,%edx
  801712:	83 e8 23             	sub    $0x23,%eax
  801715:	3c 55                	cmp    $0x55,%al
  801717:	0f 87 d3 03 00 00    	ja     801af0 <vprintfmt+0x443>
  80171d:	0f b6 c0             	movzbl %al,%eax
  801720:	ff 24 85 80 25 80 00 	jmp    *0x802580(,%eax,4)
  801727:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80172a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80172e:	eb d6                	jmp    801706 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801730:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801733:	b8 00 00 00 00       	mov    $0x0,%eax
  801738:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80173b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80173e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801742:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801745:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801748:	83 f9 09             	cmp    $0x9,%ecx
  80174b:	77 3f                	ja     80178c <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80174d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801750:	eb e9                	jmp    80173b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801752:	8b 45 14             	mov    0x14(%ebp),%eax
  801755:	8b 00                	mov    (%eax),%eax
  801757:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80175a:	8b 45 14             	mov    0x14(%ebp),%eax
  80175d:	8d 40 04             	lea    0x4(%eax),%eax
  801760:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801763:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801766:	eb 2a                	jmp    801792 <vprintfmt+0xe5>
  801768:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80176b:	85 c0                	test   %eax,%eax
  80176d:	ba 00 00 00 00       	mov    $0x0,%edx
  801772:	0f 49 d0             	cmovns %eax,%edx
  801775:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801778:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80177b:	eb 89                	jmp    801706 <vprintfmt+0x59>
  80177d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801780:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801787:	e9 7a ff ff ff       	jmp    801706 <vprintfmt+0x59>
  80178c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80178f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801792:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801796:	0f 89 6a ff ff ff    	jns    801706 <vprintfmt+0x59>
				width = precision, precision = -1;
  80179c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80179f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017a2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017a9:	e9 58 ff ff ff       	jmp    801706 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017ae:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017b4:	e9 4d ff ff ff       	jmp    801706 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8017bc:	8d 78 04             	lea    0x4(%eax),%edi
  8017bf:	83 ec 08             	sub    $0x8,%esp
  8017c2:	53                   	push   %ebx
  8017c3:	ff 30                	pushl  (%eax)
  8017c5:	ff d6                	call   *%esi
			break;
  8017c7:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017ca:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8017d0:	e9 fe fe ff ff       	jmp    8016d3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8017d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8017d8:	8d 78 04             	lea    0x4(%eax),%edi
  8017db:	8b 00                	mov    (%eax),%eax
  8017dd:	99                   	cltd   
  8017de:	31 d0                	xor    %edx,%eax
  8017e0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017e2:	83 f8 0f             	cmp    $0xf,%eax
  8017e5:	7f 0b                	jg     8017f2 <vprintfmt+0x145>
  8017e7:	8b 14 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%edx
  8017ee:	85 d2                	test   %edx,%edx
  8017f0:	75 1b                	jne    80180d <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8017f2:	50                   	push   %eax
  8017f3:	68 5b 24 80 00       	push   $0x80245b
  8017f8:	53                   	push   %ebx
  8017f9:	56                   	push   %esi
  8017fa:	e8 91 fe ff ff       	call   801690 <printfmt>
  8017ff:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801802:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801805:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801808:	e9 c6 fe ff ff       	jmp    8016d3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80180d:	52                   	push   %edx
  80180e:	68 a1 23 80 00       	push   $0x8023a1
  801813:	53                   	push   %ebx
  801814:	56                   	push   %esi
  801815:	e8 76 fe ff ff       	call   801690 <printfmt>
  80181a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80181d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801820:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801823:	e9 ab fe ff ff       	jmp    8016d3 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801828:	8b 45 14             	mov    0x14(%ebp),%eax
  80182b:	83 c0 04             	add    $0x4,%eax
  80182e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801831:	8b 45 14             	mov    0x14(%ebp),%eax
  801834:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801836:	85 ff                	test   %edi,%edi
  801838:	b8 54 24 80 00       	mov    $0x802454,%eax
  80183d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801840:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801844:	0f 8e 94 00 00 00    	jle    8018de <vprintfmt+0x231>
  80184a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80184e:	0f 84 98 00 00 00    	je     8018ec <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  801854:	83 ec 08             	sub    $0x8,%esp
  801857:	ff 75 d0             	pushl  -0x30(%ebp)
  80185a:	57                   	push   %edi
  80185b:	e8 33 03 00 00       	call   801b93 <strnlen>
  801860:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801863:	29 c1                	sub    %eax,%ecx
  801865:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801868:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80186b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80186f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801872:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801875:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801877:	eb 0f                	jmp    801888 <vprintfmt+0x1db>
					putch(padc, putdat);
  801879:	83 ec 08             	sub    $0x8,%esp
  80187c:	53                   	push   %ebx
  80187d:	ff 75 e0             	pushl  -0x20(%ebp)
  801880:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801882:	83 ef 01             	sub    $0x1,%edi
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	85 ff                	test   %edi,%edi
  80188a:	7f ed                	jg     801879 <vprintfmt+0x1cc>
  80188c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80188f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  801892:	85 c9                	test   %ecx,%ecx
  801894:	b8 00 00 00 00       	mov    $0x0,%eax
  801899:	0f 49 c1             	cmovns %ecx,%eax
  80189c:	29 c1                	sub    %eax,%ecx
  80189e:	89 75 08             	mov    %esi,0x8(%ebp)
  8018a1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018a4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018a7:	89 cb                	mov    %ecx,%ebx
  8018a9:	eb 4d                	jmp    8018f8 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018ab:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018af:	74 1b                	je     8018cc <vprintfmt+0x21f>
  8018b1:	0f be c0             	movsbl %al,%eax
  8018b4:	83 e8 20             	sub    $0x20,%eax
  8018b7:	83 f8 5e             	cmp    $0x5e,%eax
  8018ba:	76 10                	jbe    8018cc <vprintfmt+0x21f>
					putch('?', putdat);
  8018bc:	83 ec 08             	sub    $0x8,%esp
  8018bf:	ff 75 0c             	pushl  0xc(%ebp)
  8018c2:	6a 3f                	push   $0x3f
  8018c4:	ff 55 08             	call   *0x8(%ebp)
  8018c7:	83 c4 10             	add    $0x10,%esp
  8018ca:	eb 0d                	jmp    8018d9 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8018cc:	83 ec 08             	sub    $0x8,%esp
  8018cf:	ff 75 0c             	pushl  0xc(%ebp)
  8018d2:	52                   	push   %edx
  8018d3:	ff 55 08             	call   *0x8(%ebp)
  8018d6:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018d9:	83 eb 01             	sub    $0x1,%ebx
  8018dc:	eb 1a                	jmp    8018f8 <vprintfmt+0x24b>
  8018de:	89 75 08             	mov    %esi,0x8(%ebp)
  8018e1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018e4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018e7:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018ea:	eb 0c                	jmp    8018f8 <vprintfmt+0x24b>
  8018ec:	89 75 08             	mov    %esi,0x8(%ebp)
  8018ef:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018f2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018f5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018f8:	83 c7 01             	add    $0x1,%edi
  8018fb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018ff:	0f be d0             	movsbl %al,%edx
  801902:	85 d2                	test   %edx,%edx
  801904:	74 23                	je     801929 <vprintfmt+0x27c>
  801906:	85 f6                	test   %esi,%esi
  801908:	78 a1                	js     8018ab <vprintfmt+0x1fe>
  80190a:	83 ee 01             	sub    $0x1,%esi
  80190d:	79 9c                	jns    8018ab <vprintfmt+0x1fe>
  80190f:	89 df                	mov    %ebx,%edi
  801911:	8b 75 08             	mov    0x8(%ebp),%esi
  801914:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801917:	eb 18                	jmp    801931 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801919:	83 ec 08             	sub    $0x8,%esp
  80191c:	53                   	push   %ebx
  80191d:	6a 20                	push   $0x20
  80191f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801921:	83 ef 01             	sub    $0x1,%edi
  801924:	83 c4 10             	add    $0x10,%esp
  801927:	eb 08                	jmp    801931 <vprintfmt+0x284>
  801929:	89 df                	mov    %ebx,%edi
  80192b:	8b 75 08             	mov    0x8(%ebp),%esi
  80192e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801931:	85 ff                	test   %edi,%edi
  801933:	7f e4                	jg     801919 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801935:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801938:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80193b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80193e:	e9 90 fd ff ff       	jmp    8016d3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801943:	83 f9 01             	cmp    $0x1,%ecx
  801946:	7e 19                	jle    801961 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  801948:	8b 45 14             	mov    0x14(%ebp),%eax
  80194b:	8b 50 04             	mov    0x4(%eax),%edx
  80194e:	8b 00                	mov    (%eax),%eax
  801950:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801953:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801956:	8b 45 14             	mov    0x14(%ebp),%eax
  801959:	8d 40 08             	lea    0x8(%eax),%eax
  80195c:	89 45 14             	mov    %eax,0x14(%ebp)
  80195f:	eb 38                	jmp    801999 <vprintfmt+0x2ec>
	else if (lflag)
  801961:	85 c9                	test   %ecx,%ecx
  801963:	74 1b                	je     801980 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  801965:	8b 45 14             	mov    0x14(%ebp),%eax
  801968:	8b 00                	mov    (%eax),%eax
  80196a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80196d:	89 c1                	mov    %eax,%ecx
  80196f:	c1 f9 1f             	sar    $0x1f,%ecx
  801972:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801975:	8b 45 14             	mov    0x14(%ebp),%eax
  801978:	8d 40 04             	lea    0x4(%eax),%eax
  80197b:	89 45 14             	mov    %eax,0x14(%ebp)
  80197e:	eb 19                	jmp    801999 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  801980:	8b 45 14             	mov    0x14(%ebp),%eax
  801983:	8b 00                	mov    (%eax),%eax
  801985:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801988:	89 c1                	mov    %eax,%ecx
  80198a:	c1 f9 1f             	sar    $0x1f,%ecx
  80198d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801990:	8b 45 14             	mov    0x14(%ebp),%eax
  801993:	8d 40 04             	lea    0x4(%eax),%eax
  801996:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801999:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80199c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80199f:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019a4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019a8:	0f 89 0e 01 00 00    	jns    801abc <vprintfmt+0x40f>
				putch('-', putdat);
  8019ae:	83 ec 08             	sub    $0x8,%esp
  8019b1:	53                   	push   %ebx
  8019b2:	6a 2d                	push   $0x2d
  8019b4:	ff d6                	call   *%esi
				num = -(long long) num;
  8019b6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8019b9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8019bc:	f7 da                	neg    %edx
  8019be:	83 d1 00             	adc    $0x0,%ecx
  8019c1:	f7 d9                	neg    %ecx
  8019c3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019c6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8019cb:	e9 ec 00 00 00       	jmp    801abc <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8019d0:	83 f9 01             	cmp    $0x1,%ecx
  8019d3:	7e 18                	jle    8019ed <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8019d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8019d8:	8b 10                	mov    (%eax),%edx
  8019da:	8b 48 04             	mov    0x4(%eax),%ecx
  8019dd:	8d 40 08             	lea    0x8(%eax),%eax
  8019e0:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8019e3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8019e8:	e9 cf 00 00 00       	jmp    801abc <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8019ed:	85 c9                	test   %ecx,%ecx
  8019ef:	74 1a                	je     801a0b <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8019f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f4:	8b 10                	mov    (%eax),%edx
  8019f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019fb:	8d 40 04             	lea    0x4(%eax),%eax
  8019fe:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801a01:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a06:	e9 b1 00 00 00       	jmp    801abc <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801a0b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a0e:	8b 10                	mov    (%eax),%edx
  801a10:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a15:	8d 40 04             	lea    0x4(%eax),%eax
  801a18:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801a1b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a20:	e9 97 00 00 00       	jmp    801abc <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801a25:	83 ec 08             	sub    $0x8,%esp
  801a28:	53                   	push   %ebx
  801a29:	6a 58                	push   $0x58
  801a2b:	ff d6                	call   *%esi
			putch('X', putdat);
  801a2d:	83 c4 08             	add    $0x8,%esp
  801a30:	53                   	push   %ebx
  801a31:	6a 58                	push   $0x58
  801a33:	ff d6                	call   *%esi
			putch('X', putdat);
  801a35:	83 c4 08             	add    $0x8,%esp
  801a38:	53                   	push   %ebx
  801a39:	6a 58                	push   $0x58
  801a3b:	ff d6                	call   *%esi
			break;
  801a3d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a40:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  801a43:	e9 8b fc ff ff       	jmp    8016d3 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  801a48:	83 ec 08             	sub    $0x8,%esp
  801a4b:	53                   	push   %ebx
  801a4c:	6a 30                	push   $0x30
  801a4e:	ff d6                	call   *%esi
			putch('x', putdat);
  801a50:	83 c4 08             	add    $0x8,%esp
  801a53:	53                   	push   %ebx
  801a54:	6a 78                	push   $0x78
  801a56:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a58:	8b 45 14             	mov    0x14(%ebp),%eax
  801a5b:	8b 10                	mov    (%eax),%edx
  801a5d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a62:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a65:	8d 40 04             	lea    0x4(%eax),%eax
  801a68:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a6b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801a70:	eb 4a                	jmp    801abc <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a72:	83 f9 01             	cmp    $0x1,%ecx
  801a75:	7e 15                	jle    801a8c <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  801a77:	8b 45 14             	mov    0x14(%ebp),%eax
  801a7a:	8b 10                	mov    (%eax),%edx
  801a7c:	8b 48 04             	mov    0x4(%eax),%ecx
  801a7f:	8d 40 08             	lea    0x8(%eax),%eax
  801a82:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801a85:	b8 10 00 00 00       	mov    $0x10,%eax
  801a8a:	eb 30                	jmp    801abc <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801a8c:	85 c9                	test   %ecx,%ecx
  801a8e:	74 17                	je     801aa7 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  801a90:	8b 45 14             	mov    0x14(%ebp),%eax
  801a93:	8b 10                	mov    (%eax),%edx
  801a95:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a9a:	8d 40 04             	lea    0x4(%eax),%eax
  801a9d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801aa0:	b8 10 00 00 00       	mov    $0x10,%eax
  801aa5:	eb 15                	jmp    801abc <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801aa7:	8b 45 14             	mov    0x14(%ebp),%eax
  801aaa:	8b 10                	mov    (%eax),%edx
  801aac:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ab1:	8d 40 04             	lea    0x4(%eax),%eax
  801ab4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801ab7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801abc:	83 ec 0c             	sub    $0xc,%esp
  801abf:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801ac3:	57                   	push   %edi
  801ac4:	ff 75 e0             	pushl  -0x20(%ebp)
  801ac7:	50                   	push   %eax
  801ac8:	51                   	push   %ecx
  801ac9:	52                   	push   %edx
  801aca:	89 da                	mov    %ebx,%edx
  801acc:	89 f0                	mov    %esi,%eax
  801ace:	e8 f1 fa ff ff       	call   8015c4 <printnum>
			break;
  801ad3:	83 c4 20             	add    $0x20,%esp
  801ad6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ad9:	e9 f5 fb ff ff       	jmp    8016d3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801ade:	83 ec 08             	sub    $0x8,%esp
  801ae1:	53                   	push   %ebx
  801ae2:	52                   	push   %edx
  801ae3:	ff d6                	call   *%esi
			break;
  801ae5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ae8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801aeb:	e9 e3 fb ff ff       	jmp    8016d3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801af0:	83 ec 08             	sub    $0x8,%esp
  801af3:	53                   	push   %ebx
  801af4:	6a 25                	push   $0x25
  801af6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801af8:	83 c4 10             	add    $0x10,%esp
  801afb:	eb 03                	jmp    801b00 <vprintfmt+0x453>
  801afd:	83 ef 01             	sub    $0x1,%edi
  801b00:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b04:	75 f7                	jne    801afd <vprintfmt+0x450>
  801b06:	e9 c8 fb ff ff       	jmp    8016d3 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0e:	5b                   	pop    %ebx
  801b0f:	5e                   	pop    %esi
  801b10:	5f                   	pop    %edi
  801b11:	5d                   	pop    %ebp
  801b12:	c3                   	ret    

00801b13 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	83 ec 18             	sub    $0x18,%esp
  801b19:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b1f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b22:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b26:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b29:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b30:	85 c0                	test   %eax,%eax
  801b32:	74 26                	je     801b5a <vsnprintf+0x47>
  801b34:	85 d2                	test   %edx,%edx
  801b36:	7e 22                	jle    801b5a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b38:	ff 75 14             	pushl  0x14(%ebp)
  801b3b:	ff 75 10             	pushl  0x10(%ebp)
  801b3e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b41:	50                   	push   %eax
  801b42:	68 73 16 80 00       	push   $0x801673
  801b47:	e8 61 fb ff ff       	call   8016ad <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b4f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b55:	83 c4 10             	add    $0x10,%esp
  801b58:	eb 05                	jmp    801b5f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b5a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b5f:	c9                   	leave  
  801b60:	c3                   	ret    

00801b61 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b61:	55                   	push   %ebp
  801b62:	89 e5                	mov    %esp,%ebp
  801b64:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b67:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b6a:	50                   	push   %eax
  801b6b:	ff 75 10             	pushl  0x10(%ebp)
  801b6e:	ff 75 0c             	pushl  0xc(%ebp)
  801b71:	ff 75 08             	pushl  0x8(%ebp)
  801b74:	e8 9a ff ff ff       	call   801b13 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b79:	c9                   	leave  
  801b7a:	c3                   	ret    

00801b7b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b81:	b8 00 00 00 00       	mov    $0x0,%eax
  801b86:	eb 03                	jmp    801b8b <strlen+0x10>
		n++;
  801b88:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b8b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b8f:	75 f7                	jne    801b88 <strlen+0xd>
		n++;
	return n;
}
  801b91:	5d                   	pop    %ebp
  801b92:	c3                   	ret    

00801b93 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b93:	55                   	push   %ebp
  801b94:	89 e5                	mov    %esp,%ebp
  801b96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b99:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b9c:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba1:	eb 03                	jmp    801ba6 <strnlen+0x13>
		n++;
  801ba3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801ba6:	39 c2                	cmp    %eax,%edx
  801ba8:	74 08                	je     801bb2 <strnlen+0x1f>
  801baa:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801bae:	75 f3                	jne    801ba3 <strnlen+0x10>
  801bb0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801bb2:	5d                   	pop    %ebp
  801bb3:	c3                   	ret    

00801bb4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801bb4:	55                   	push   %ebp
  801bb5:	89 e5                	mov    %esp,%ebp
  801bb7:	53                   	push   %ebx
  801bb8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801bbe:	89 c2                	mov    %eax,%edx
  801bc0:	83 c2 01             	add    $0x1,%edx
  801bc3:	83 c1 01             	add    $0x1,%ecx
  801bc6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801bca:	88 5a ff             	mov    %bl,-0x1(%edx)
  801bcd:	84 db                	test   %bl,%bl
  801bcf:	75 ef                	jne    801bc0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801bd1:	5b                   	pop    %ebx
  801bd2:	5d                   	pop    %ebp
  801bd3:	c3                   	ret    

00801bd4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801bd4:	55                   	push   %ebp
  801bd5:	89 e5                	mov    %esp,%ebp
  801bd7:	53                   	push   %ebx
  801bd8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801bdb:	53                   	push   %ebx
  801bdc:	e8 9a ff ff ff       	call   801b7b <strlen>
  801be1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801be4:	ff 75 0c             	pushl  0xc(%ebp)
  801be7:	01 d8                	add    %ebx,%eax
  801be9:	50                   	push   %eax
  801bea:	e8 c5 ff ff ff       	call   801bb4 <strcpy>
	return dst;
}
  801bef:	89 d8                	mov    %ebx,%eax
  801bf1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf4:	c9                   	leave  
  801bf5:	c3                   	ret    

00801bf6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	56                   	push   %esi
  801bfa:	53                   	push   %ebx
  801bfb:	8b 75 08             	mov    0x8(%ebp),%esi
  801bfe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c01:	89 f3                	mov    %esi,%ebx
  801c03:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c06:	89 f2                	mov    %esi,%edx
  801c08:	eb 0f                	jmp    801c19 <strncpy+0x23>
		*dst++ = *src;
  801c0a:	83 c2 01             	add    $0x1,%edx
  801c0d:	0f b6 01             	movzbl (%ecx),%eax
  801c10:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c13:	80 39 01             	cmpb   $0x1,(%ecx)
  801c16:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c19:	39 da                	cmp    %ebx,%edx
  801c1b:	75 ed                	jne    801c0a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c1d:	89 f0                	mov    %esi,%eax
  801c1f:	5b                   	pop    %ebx
  801c20:	5e                   	pop    %esi
  801c21:	5d                   	pop    %ebp
  801c22:	c3                   	ret    

00801c23 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c23:	55                   	push   %ebp
  801c24:	89 e5                	mov    %esp,%ebp
  801c26:	56                   	push   %esi
  801c27:	53                   	push   %ebx
  801c28:	8b 75 08             	mov    0x8(%ebp),%esi
  801c2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c2e:	8b 55 10             	mov    0x10(%ebp),%edx
  801c31:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c33:	85 d2                	test   %edx,%edx
  801c35:	74 21                	je     801c58 <strlcpy+0x35>
  801c37:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c3b:	89 f2                	mov    %esi,%edx
  801c3d:	eb 09                	jmp    801c48 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c3f:	83 c2 01             	add    $0x1,%edx
  801c42:	83 c1 01             	add    $0x1,%ecx
  801c45:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c48:	39 c2                	cmp    %eax,%edx
  801c4a:	74 09                	je     801c55 <strlcpy+0x32>
  801c4c:	0f b6 19             	movzbl (%ecx),%ebx
  801c4f:	84 db                	test   %bl,%bl
  801c51:	75 ec                	jne    801c3f <strlcpy+0x1c>
  801c53:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c55:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c58:	29 f0                	sub    %esi,%eax
}
  801c5a:	5b                   	pop    %ebx
  801c5b:	5e                   	pop    %esi
  801c5c:	5d                   	pop    %ebp
  801c5d:	c3                   	ret    

00801c5e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c5e:	55                   	push   %ebp
  801c5f:	89 e5                	mov    %esp,%ebp
  801c61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c64:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c67:	eb 06                	jmp    801c6f <strcmp+0x11>
		p++, q++;
  801c69:	83 c1 01             	add    $0x1,%ecx
  801c6c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c6f:	0f b6 01             	movzbl (%ecx),%eax
  801c72:	84 c0                	test   %al,%al
  801c74:	74 04                	je     801c7a <strcmp+0x1c>
  801c76:	3a 02                	cmp    (%edx),%al
  801c78:	74 ef                	je     801c69 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c7a:	0f b6 c0             	movzbl %al,%eax
  801c7d:	0f b6 12             	movzbl (%edx),%edx
  801c80:	29 d0                	sub    %edx,%eax
}
  801c82:	5d                   	pop    %ebp
  801c83:	c3                   	ret    

00801c84 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c84:	55                   	push   %ebp
  801c85:	89 e5                	mov    %esp,%ebp
  801c87:	53                   	push   %ebx
  801c88:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c8e:	89 c3                	mov    %eax,%ebx
  801c90:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c93:	eb 06                	jmp    801c9b <strncmp+0x17>
		n--, p++, q++;
  801c95:	83 c0 01             	add    $0x1,%eax
  801c98:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c9b:	39 d8                	cmp    %ebx,%eax
  801c9d:	74 15                	je     801cb4 <strncmp+0x30>
  801c9f:	0f b6 08             	movzbl (%eax),%ecx
  801ca2:	84 c9                	test   %cl,%cl
  801ca4:	74 04                	je     801caa <strncmp+0x26>
  801ca6:	3a 0a                	cmp    (%edx),%cl
  801ca8:	74 eb                	je     801c95 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801caa:	0f b6 00             	movzbl (%eax),%eax
  801cad:	0f b6 12             	movzbl (%edx),%edx
  801cb0:	29 d0                	sub    %edx,%eax
  801cb2:	eb 05                	jmp    801cb9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801cb4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801cb9:	5b                   	pop    %ebx
  801cba:	5d                   	pop    %ebp
  801cbb:	c3                   	ret    

00801cbc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
  801cbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cc6:	eb 07                	jmp    801ccf <strchr+0x13>
		if (*s == c)
  801cc8:	38 ca                	cmp    %cl,%dl
  801cca:	74 0f                	je     801cdb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801ccc:	83 c0 01             	add    $0x1,%eax
  801ccf:	0f b6 10             	movzbl (%eax),%edx
  801cd2:	84 d2                	test   %dl,%dl
  801cd4:	75 f2                	jne    801cc8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801cd6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cdb:	5d                   	pop    %ebp
  801cdc:	c3                   	ret    

00801cdd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cdd:	55                   	push   %ebp
  801cde:	89 e5                	mov    %esp,%ebp
  801ce0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ce7:	eb 03                	jmp    801cec <strfind+0xf>
  801ce9:	83 c0 01             	add    $0x1,%eax
  801cec:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cef:	38 ca                	cmp    %cl,%dl
  801cf1:	74 04                	je     801cf7 <strfind+0x1a>
  801cf3:	84 d2                	test   %dl,%dl
  801cf5:	75 f2                	jne    801ce9 <strfind+0xc>
			break;
	return (char *) s;
}
  801cf7:	5d                   	pop    %ebp
  801cf8:	c3                   	ret    

00801cf9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cf9:	55                   	push   %ebp
  801cfa:	89 e5                	mov    %esp,%ebp
  801cfc:	57                   	push   %edi
  801cfd:	56                   	push   %esi
  801cfe:	53                   	push   %ebx
  801cff:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d05:	85 c9                	test   %ecx,%ecx
  801d07:	74 36                	je     801d3f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d09:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d0f:	75 28                	jne    801d39 <memset+0x40>
  801d11:	f6 c1 03             	test   $0x3,%cl
  801d14:	75 23                	jne    801d39 <memset+0x40>
		c &= 0xFF;
  801d16:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d1a:	89 d3                	mov    %edx,%ebx
  801d1c:	c1 e3 08             	shl    $0x8,%ebx
  801d1f:	89 d6                	mov    %edx,%esi
  801d21:	c1 e6 18             	shl    $0x18,%esi
  801d24:	89 d0                	mov    %edx,%eax
  801d26:	c1 e0 10             	shl    $0x10,%eax
  801d29:	09 f0                	or     %esi,%eax
  801d2b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d2d:	89 d8                	mov    %ebx,%eax
  801d2f:	09 d0                	or     %edx,%eax
  801d31:	c1 e9 02             	shr    $0x2,%ecx
  801d34:	fc                   	cld    
  801d35:	f3 ab                	rep stos %eax,%es:(%edi)
  801d37:	eb 06                	jmp    801d3f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d39:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d3c:	fc                   	cld    
  801d3d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d3f:	89 f8                	mov    %edi,%eax
  801d41:	5b                   	pop    %ebx
  801d42:	5e                   	pop    %esi
  801d43:	5f                   	pop    %edi
  801d44:	5d                   	pop    %ebp
  801d45:	c3                   	ret    

00801d46 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
  801d49:	57                   	push   %edi
  801d4a:	56                   	push   %esi
  801d4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d51:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d54:	39 c6                	cmp    %eax,%esi
  801d56:	73 35                	jae    801d8d <memmove+0x47>
  801d58:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d5b:	39 d0                	cmp    %edx,%eax
  801d5d:	73 2e                	jae    801d8d <memmove+0x47>
		s += n;
		d += n;
  801d5f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d62:	89 d6                	mov    %edx,%esi
  801d64:	09 fe                	or     %edi,%esi
  801d66:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d6c:	75 13                	jne    801d81 <memmove+0x3b>
  801d6e:	f6 c1 03             	test   $0x3,%cl
  801d71:	75 0e                	jne    801d81 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d73:	83 ef 04             	sub    $0x4,%edi
  801d76:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d79:	c1 e9 02             	shr    $0x2,%ecx
  801d7c:	fd                   	std    
  801d7d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d7f:	eb 09                	jmp    801d8a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d81:	83 ef 01             	sub    $0x1,%edi
  801d84:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d87:	fd                   	std    
  801d88:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d8a:	fc                   	cld    
  801d8b:	eb 1d                	jmp    801daa <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d8d:	89 f2                	mov    %esi,%edx
  801d8f:	09 c2                	or     %eax,%edx
  801d91:	f6 c2 03             	test   $0x3,%dl
  801d94:	75 0f                	jne    801da5 <memmove+0x5f>
  801d96:	f6 c1 03             	test   $0x3,%cl
  801d99:	75 0a                	jne    801da5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d9b:	c1 e9 02             	shr    $0x2,%ecx
  801d9e:	89 c7                	mov    %eax,%edi
  801da0:	fc                   	cld    
  801da1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801da3:	eb 05                	jmp    801daa <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801da5:	89 c7                	mov    %eax,%edi
  801da7:	fc                   	cld    
  801da8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801daa:	5e                   	pop    %esi
  801dab:	5f                   	pop    %edi
  801dac:	5d                   	pop    %ebp
  801dad:	c3                   	ret    

00801dae <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801dae:	55                   	push   %ebp
  801daf:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801db1:	ff 75 10             	pushl  0x10(%ebp)
  801db4:	ff 75 0c             	pushl  0xc(%ebp)
  801db7:	ff 75 08             	pushl  0x8(%ebp)
  801dba:	e8 87 ff ff ff       	call   801d46 <memmove>
}
  801dbf:	c9                   	leave  
  801dc0:	c3                   	ret    

00801dc1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801dc1:	55                   	push   %ebp
  801dc2:	89 e5                	mov    %esp,%ebp
  801dc4:	56                   	push   %esi
  801dc5:	53                   	push   %ebx
  801dc6:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dcc:	89 c6                	mov    %eax,%esi
  801dce:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dd1:	eb 1a                	jmp    801ded <memcmp+0x2c>
		if (*s1 != *s2)
  801dd3:	0f b6 08             	movzbl (%eax),%ecx
  801dd6:	0f b6 1a             	movzbl (%edx),%ebx
  801dd9:	38 d9                	cmp    %bl,%cl
  801ddb:	74 0a                	je     801de7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801ddd:	0f b6 c1             	movzbl %cl,%eax
  801de0:	0f b6 db             	movzbl %bl,%ebx
  801de3:	29 d8                	sub    %ebx,%eax
  801de5:	eb 0f                	jmp    801df6 <memcmp+0x35>
		s1++, s2++;
  801de7:	83 c0 01             	add    $0x1,%eax
  801dea:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801ded:	39 f0                	cmp    %esi,%eax
  801def:	75 e2                	jne    801dd3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801df1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801df6:	5b                   	pop    %ebx
  801df7:	5e                   	pop    %esi
  801df8:	5d                   	pop    %ebp
  801df9:	c3                   	ret    

00801dfa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	53                   	push   %ebx
  801dfe:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e01:	89 c1                	mov    %eax,%ecx
  801e03:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e06:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e0a:	eb 0a                	jmp    801e16 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e0c:	0f b6 10             	movzbl (%eax),%edx
  801e0f:	39 da                	cmp    %ebx,%edx
  801e11:	74 07                	je     801e1a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e13:	83 c0 01             	add    $0x1,%eax
  801e16:	39 c8                	cmp    %ecx,%eax
  801e18:	72 f2                	jb     801e0c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e1a:	5b                   	pop    %ebx
  801e1b:	5d                   	pop    %ebp
  801e1c:	c3                   	ret    

00801e1d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e1d:	55                   	push   %ebp
  801e1e:	89 e5                	mov    %esp,%ebp
  801e20:	57                   	push   %edi
  801e21:	56                   	push   %esi
  801e22:	53                   	push   %ebx
  801e23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e26:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e29:	eb 03                	jmp    801e2e <strtol+0x11>
		s++;
  801e2b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e2e:	0f b6 01             	movzbl (%ecx),%eax
  801e31:	3c 20                	cmp    $0x20,%al
  801e33:	74 f6                	je     801e2b <strtol+0xe>
  801e35:	3c 09                	cmp    $0x9,%al
  801e37:	74 f2                	je     801e2b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e39:	3c 2b                	cmp    $0x2b,%al
  801e3b:	75 0a                	jne    801e47 <strtol+0x2a>
		s++;
  801e3d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e40:	bf 00 00 00 00       	mov    $0x0,%edi
  801e45:	eb 11                	jmp    801e58 <strtol+0x3b>
  801e47:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e4c:	3c 2d                	cmp    $0x2d,%al
  801e4e:	75 08                	jne    801e58 <strtol+0x3b>
		s++, neg = 1;
  801e50:	83 c1 01             	add    $0x1,%ecx
  801e53:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e58:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e5e:	75 15                	jne    801e75 <strtol+0x58>
  801e60:	80 39 30             	cmpb   $0x30,(%ecx)
  801e63:	75 10                	jne    801e75 <strtol+0x58>
  801e65:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e69:	75 7c                	jne    801ee7 <strtol+0xca>
		s += 2, base = 16;
  801e6b:	83 c1 02             	add    $0x2,%ecx
  801e6e:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e73:	eb 16                	jmp    801e8b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e75:	85 db                	test   %ebx,%ebx
  801e77:	75 12                	jne    801e8b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e79:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e7e:	80 39 30             	cmpb   $0x30,(%ecx)
  801e81:	75 08                	jne    801e8b <strtol+0x6e>
		s++, base = 8;
  801e83:	83 c1 01             	add    $0x1,%ecx
  801e86:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e8b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e90:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e93:	0f b6 11             	movzbl (%ecx),%edx
  801e96:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e99:	89 f3                	mov    %esi,%ebx
  801e9b:	80 fb 09             	cmp    $0x9,%bl
  801e9e:	77 08                	ja     801ea8 <strtol+0x8b>
			dig = *s - '0';
  801ea0:	0f be d2             	movsbl %dl,%edx
  801ea3:	83 ea 30             	sub    $0x30,%edx
  801ea6:	eb 22                	jmp    801eca <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801ea8:	8d 72 9f             	lea    -0x61(%edx),%esi
  801eab:	89 f3                	mov    %esi,%ebx
  801ead:	80 fb 19             	cmp    $0x19,%bl
  801eb0:	77 08                	ja     801eba <strtol+0x9d>
			dig = *s - 'a' + 10;
  801eb2:	0f be d2             	movsbl %dl,%edx
  801eb5:	83 ea 57             	sub    $0x57,%edx
  801eb8:	eb 10                	jmp    801eca <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801eba:	8d 72 bf             	lea    -0x41(%edx),%esi
  801ebd:	89 f3                	mov    %esi,%ebx
  801ebf:	80 fb 19             	cmp    $0x19,%bl
  801ec2:	77 16                	ja     801eda <strtol+0xbd>
			dig = *s - 'A' + 10;
  801ec4:	0f be d2             	movsbl %dl,%edx
  801ec7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801eca:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ecd:	7d 0b                	jge    801eda <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801ecf:	83 c1 01             	add    $0x1,%ecx
  801ed2:	0f af 45 10          	imul   0x10(%ebp),%eax
  801ed6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801ed8:	eb b9                	jmp    801e93 <strtol+0x76>

	if (endptr)
  801eda:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ede:	74 0d                	je     801eed <strtol+0xd0>
		*endptr = (char *) s;
  801ee0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ee3:	89 0e                	mov    %ecx,(%esi)
  801ee5:	eb 06                	jmp    801eed <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ee7:	85 db                	test   %ebx,%ebx
  801ee9:	74 98                	je     801e83 <strtol+0x66>
  801eeb:	eb 9e                	jmp    801e8b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801eed:	89 c2                	mov    %eax,%edx
  801eef:	f7 da                	neg    %edx
  801ef1:	85 ff                	test   %edi,%edi
  801ef3:	0f 45 c2             	cmovne %edx,%eax
}
  801ef6:	5b                   	pop    %ebx
  801ef7:	5e                   	pop    %esi
  801ef8:	5f                   	pop    %edi
  801ef9:	5d                   	pop    %ebp
  801efa:	c3                   	ret    

00801efb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801efb:	55                   	push   %ebp
  801efc:	89 e5                	mov    %esp,%ebp
  801efe:	56                   	push   %esi
  801eff:	53                   	push   %ebx
  801f00:	8b 75 08             	mov    0x8(%ebp),%esi
  801f03:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801f09:	85 c0                	test   %eax,%eax
  801f0b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f10:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801f13:	83 ec 0c             	sub    $0xc,%esp
  801f16:	50                   	push   %eax
  801f17:	e8 ea e3 ff ff       	call   800306 <sys_ipc_recv>
  801f1c:	83 c4 10             	add    $0x10,%esp
  801f1f:	85 c0                	test   %eax,%eax
  801f21:	79 16                	jns    801f39 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801f23:	85 f6                	test   %esi,%esi
  801f25:	74 06                	je     801f2d <ipc_recv+0x32>
            *from_env_store = 0;
  801f27:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801f2d:	85 db                	test   %ebx,%ebx
  801f2f:	74 2c                	je     801f5d <ipc_recv+0x62>
            *perm_store = 0;
  801f31:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f37:	eb 24                	jmp    801f5d <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801f39:	85 f6                	test   %esi,%esi
  801f3b:	74 0a                	je     801f47 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801f3d:	a1 08 40 80 00       	mov    0x804008,%eax
  801f42:	8b 40 74             	mov    0x74(%eax),%eax
  801f45:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801f47:	85 db                	test   %ebx,%ebx
  801f49:	74 0a                	je     801f55 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801f4b:	a1 08 40 80 00       	mov    0x804008,%eax
  801f50:	8b 40 78             	mov    0x78(%eax),%eax
  801f53:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801f55:	a1 08 40 80 00       	mov    0x804008,%eax
  801f5a:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801f5d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f60:	5b                   	pop    %ebx
  801f61:	5e                   	pop    %esi
  801f62:	5d                   	pop    %ebp
  801f63:	c3                   	ret    

00801f64 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f64:	55                   	push   %ebp
  801f65:	89 e5                	mov    %esp,%ebp
  801f67:	57                   	push   %edi
  801f68:	56                   	push   %esi
  801f69:	53                   	push   %ebx
  801f6a:	83 ec 0c             	sub    $0xc,%esp
  801f6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f70:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f73:	8b 45 10             	mov    0x10(%ebp),%eax
  801f76:	85 c0                	test   %eax,%eax
  801f78:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801f7d:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801f80:	eb 1c                	jmp    801f9e <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801f82:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f85:	74 12                	je     801f99 <ipc_send+0x35>
  801f87:	50                   	push   %eax
  801f88:	68 40 27 80 00       	push   $0x802740
  801f8d:	6a 3b                	push   $0x3b
  801f8f:	68 56 27 80 00       	push   $0x802756
  801f94:	e8 3e f5 ff ff       	call   8014d7 <_panic>
		sys_yield();
  801f99:	e8 99 e1 ff ff       	call   800137 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801f9e:	ff 75 14             	pushl  0x14(%ebp)
  801fa1:	53                   	push   %ebx
  801fa2:	56                   	push   %esi
  801fa3:	57                   	push   %edi
  801fa4:	e8 3a e3 ff ff       	call   8002e3 <sys_ipc_try_send>
  801fa9:	83 c4 10             	add    $0x10,%esp
  801fac:	85 c0                	test   %eax,%eax
  801fae:	78 d2                	js     801f82 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801fb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb3:	5b                   	pop    %ebx
  801fb4:	5e                   	pop    %esi
  801fb5:	5f                   	pop    %edi
  801fb6:	5d                   	pop    %ebp
  801fb7:	c3                   	ret    

00801fb8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fb8:	55                   	push   %ebp
  801fb9:	89 e5                	mov    %esp,%ebp
  801fbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fbe:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fc3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fc6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fcc:	8b 52 50             	mov    0x50(%edx),%edx
  801fcf:	39 ca                	cmp    %ecx,%edx
  801fd1:	75 0d                	jne    801fe0 <ipc_find_env+0x28>
			return envs[i].env_id;
  801fd3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fd6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fdb:	8b 40 48             	mov    0x48(%eax),%eax
  801fde:	eb 0f                	jmp    801fef <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fe0:	83 c0 01             	add    $0x1,%eax
  801fe3:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fe8:	75 d9                	jne    801fc3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fea:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fef:	5d                   	pop    %ebp
  801ff0:	c3                   	ret    

00801ff1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ff1:	55                   	push   %ebp
  801ff2:	89 e5                	mov    %esp,%ebp
  801ff4:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ff7:	89 d0                	mov    %edx,%eax
  801ff9:	c1 e8 16             	shr    $0x16,%eax
  801ffc:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802003:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802008:	f6 c1 01             	test   $0x1,%cl
  80200b:	74 1d                	je     80202a <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80200d:	c1 ea 0c             	shr    $0xc,%edx
  802010:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802017:	f6 c2 01             	test   $0x1,%dl
  80201a:	74 0e                	je     80202a <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80201c:	c1 ea 0c             	shr    $0xc,%edx
  80201f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802026:	ef 
  802027:	0f b7 c0             	movzwl %ax,%eax
}
  80202a:	5d                   	pop    %ebp
  80202b:	c3                   	ret    
  80202c:	66 90                	xchg   %ax,%ax
  80202e:	66 90                	xchg   %ax,%ax

00802030 <__udivdi3>:
  802030:	55                   	push   %ebp
  802031:	57                   	push   %edi
  802032:	56                   	push   %esi
  802033:	53                   	push   %ebx
  802034:	83 ec 1c             	sub    $0x1c,%esp
  802037:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80203b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80203f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802043:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802047:	85 f6                	test   %esi,%esi
  802049:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80204d:	89 ca                	mov    %ecx,%edx
  80204f:	89 f8                	mov    %edi,%eax
  802051:	75 3d                	jne    802090 <__udivdi3+0x60>
  802053:	39 cf                	cmp    %ecx,%edi
  802055:	0f 87 c5 00 00 00    	ja     802120 <__udivdi3+0xf0>
  80205b:	85 ff                	test   %edi,%edi
  80205d:	89 fd                	mov    %edi,%ebp
  80205f:	75 0b                	jne    80206c <__udivdi3+0x3c>
  802061:	b8 01 00 00 00       	mov    $0x1,%eax
  802066:	31 d2                	xor    %edx,%edx
  802068:	f7 f7                	div    %edi
  80206a:	89 c5                	mov    %eax,%ebp
  80206c:	89 c8                	mov    %ecx,%eax
  80206e:	31 d2                	xor    %edx,%edx
  802070:	f7 f5                	div    %ebp
  802072:	89 c1                	mov    %eax,%ecx
  802074:	89 d8                	mov    %ebx,%eax
  802076:	89 cf                	mov    %ecx,%edi
  802078:	f7 f5                	div    %ebp
  80207a:	89 c3                	mov    %eax,%ebx
  80207c:	89 d8                	mov    %ebx,%eax
  80207e:	89 fa                	mov    %edi,%edx
  802080:	83 c4 1c             	add    $0x1c,%esp
  802083:	5b                   	pop    %ebx
  802084:	5e                   	pop    %esi
  802085:	5f                   	pop    %edi
  802086:	5d                   	pop    %ebp
  802087:	c3                   	ret    
  802088:	90                   	nop
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	39 ce                	cmp    %ecx,%esi
  802092:	77 74                	ja     802108 <__udivdi3+0xd8>
  802094:	0f bd fe             	bsr    %esi,%edi
  802097:	83 f7 1f             	xor    $0x1f,%edi
  80209a:	0f 84 98 00 00 00    	je     802138 <__udivdi3+0x108>
  8020a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020a5:	89 f9                	mov    %edi,%ecx
  8020a7:	89 c5                	mov    %eax,%ebp
  8020a9:	29 fb                	sub    %edi,%ebx
  8020ab:	d3 e6                	shl    %cl,%esi
  8020ad:	89 d9                	mov    %ebx,%ecx
  8020af:	d3 ed                	shr    %cl,%ebp
  8020b1:	89 f9                	mov    %edi,%ecx
  8020b3:	d3 e0                	shl    %cl,%eax
  8020b5:	09 ee                	or     %ebp,%esi
  8020b7:	89 d9                	mov    %ebx,%ecx
  8020b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020bd:	89 d5                	mov    %edx,%ebp
  8020bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020c3:	d3 ed                	shr    %cl,%ebp
  8020c5:	89 f9                	mov    %edi,%ecx
  8020c7:	d3 e2                	shl    %cl,%edx
  8020c9:	89 d9                	mov    %ebx,%ecx
  8020cb:	d3 e8                	shr    %cl,%eax
  8020cd:	09 c2                	or     %eax,%edx
  8020cf:	89 d0                	mov    %edx,%eax
  8020d1:	89 ea                	mov    %ebp,%edx
  8020d3:	f7 f6                	div    %esi
  8020d5:	89 d5                	mov    %edx,%ebp
  8020d7:	89 c3                	mov    %eax,%ebx
  8020d9:	f7 64 24 0c          	mull   0xc(%esp)
  8020dd:	39 d5                	cmp    %edx,%ebp
  8020df:	72 10                	jb     8020f1 <__udivdi3+0xc1>
  8020e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	d3 e6                	shl    %cl,%esi
  8020e9:	39 c6                	cmp    %eax,%esi
  8020eb:	73 07                	jae    8020f4 <__udivdi3+0xc4>
  8020ed:	39 d5                	cmp    %edx,%ebp
  8020ef:	75 03                	jne    8020f4 <__udivdi3+0xc4>
  8020f1:	83 eb 01             	sub    $0x1,%ebx
  8020f4:	31 ff                	xor    %edi,%edi
  8020f6:	89 d8                	mov    %ebx,%eax
  8020f8:	89 fa                	mov    %edi,%edx
  8020fa:	83 c4 1c             	add    $0x1c,%esp
  8020fd:	5b                   	pop    %ebx
  8020fe:	5e                   	pop    %esi
  8020ff:	5f                   	pop    %edi
  802100:	5d                   	pop    %ebp
  802101:	c3                   	ret    
  802102:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802108:	31 ff                	xor    %edi,%edi
  80210a:	31 db                	xor    %ebx,%ebx
  80210c:	89 d8                	mov    %ebx,%eax
  80210e:	89 fa                	mov    %edi,%edx
  802110:	83 c4 1c             	add    $0x1c,%esp
  802113:	5b                   	pop    %ebx
  802114:	5e                   	pop    %esi
  802115:	5f                   	pop    %edi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    
  802118:	90                   	nop
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	89 d8                	mov    %ebx,%eax
  802122:	f7 f7                	div    %edi
  802124:	31 ff                	xor    %edi,%edi
  802126:	89 c3                	mov    %eax,%ebx
  802128:	89 d8                	mov    %ebx,%eax
  80212a:	89 fa                	mov    %edi,%edx
  80212c:	83 c4 1c             	add    $0x1c,%esp
  80212f:	5b                   	pop    %ebx
  802130:	5e                   	pop    %esi
  802131:	5f                   	pop    %edi
  802132:	5d                   	pop    %ebp
  802133:	c3                   	ret    
  802134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802138:	39 ce                	cmp    %ecx,%esi
  80213a:	72 0c                	jb     802148 <__udivdi3+0x118>
  80213c:	31 db                	xor    %ebx,%ebx
  80213e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802142:	0f 87 34 ff ff ff    	ja     80207c <__udivdi3+0x4c>
  802148:	bb 01 00 00 00       	mov    $0x1,%ebx
  80214d:	e9 2a ff ff ff       	jmp    80207c <__udivdi3+0x4c>
  802152:	66 90                	xchg   %ax,%ax
  802154:	66 90                	xchg   %ax,%ax
  802156:	66 90                	xchg   %ax,%ax
  802158:	66 90                	xchg   %ax,%ax
  80215a:	66 90                	xchg   %ax,%ax
  80215c:	66 90                	xchg   %ax,%ax
  80215e:	66 90                	xchg   %ax,%ax

00802160 <__umoddi3>:
  802160:	55                   	push   %ebp
  802161:	57                   	push   %edi
  802162:	56                   	push   %esi
  802163:	53                   	push   %ebx
  802164:	83 ec 1c             	sub    $0x1c,%esp
  802167:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80216b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80216f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802173:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802177:	85 d2                	test   %edx,%edx
  802179:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80217d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802181:	89 f3                	mov    %esi,%ebx
  802183:	89 3c 24             	mov    %edi,(%esp)
  802186:	89 74 24 04          	mov    %esi,0x4(%esp)
  80218a:	75 1c                	jne    8021a8 <__umoddi3+0x48>
  80218c:	39 f7                	cmp    %esi,%edi
  80218e:	76 50                	jbe    8021e0 <__umoddi3+0x80>
  802190:	89 c8                	mov    %ecx,%eax
  802192:	89 f2                	mov    %esi,%edx
  802194:	f7 f7                	div    %edi
  802196:	89 d0                	mov    %edx,%eax
  802198:	31 d2                	xor    %edx,%edx
  80219a:	83 c4 1c             	add    $0x1c,%esp
  80219d:	5b                   	pop    %ebx
  80219e:	5e                   	pop    %esi
  80219f:	5f                   	pop    %edi
  8021a0:	5d                   	pop    %ebp
  8021a1:	c3                   	ret    
  8021a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021a8:	39 f2                	cmp    %esi,%edx
  8021aa:	89 d0                	mov    %edx,%eax
  8021ac:	77 52                	ja     802200 <__umoddi3+0xa0>
  8021ae:	0f bd ea             	bsr    %edx,%ebp
  8021b1:	83 f5 1f             	xor    $0x1f,%ebp
  8021b4:	75 5a                	jne    802210 <__umoddi3+0xb0>
  8021b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021ba:	0f 82 e0 00 00 00    	jb     8022a0 <__umoddi3+0x140>
  8021c0:	39 0c 24             	cmp    %ecx,(%esp)
  8021c3:	0f 86 d7 00 00 00    	jbe    8022a0 <__umoddi3+0x140>
  8021c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021d1:	83 c4 1c             	add    $0x1c,%esp
  8021d4:	5b                   	pop    %ebx
  8021d5:	5e                   	pop    %esi
  8021d6:	5f                   	pop    %edi
  8021d7:	5d                   	pop    %ebp
  8021d8:	c3                   	ret    
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	85 ff                	test   %edi,%edi
  8021e2:	89 fd                	mov    %edi,%ebp
  8021e4:	75 0b                	jne    8021f1 <__umoddi3+0x91>
  8021e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021eb:	31 d2                	xor    %edx,%edx
  8021ed:	f7 f7                	div    %edi
  8021ef:	89 c5                	mov    %eax,%ebp
  8021f1:	89 f0                	mov    %esi,%eax
  8021f3:	31 d2                	xor    %edx,%edx
  8021f5:	f7 f5                	div    %ebp
  8021f7:	89 c8                	mov    %ecx,%eax
  8021f9:	f7 f5                	div    %ebp
  8021fb:	89 d0                	mov    %edx,%eax
  8021fd:	eb 99                	jmp    802198 <__umoddi3+0x38>
  8021ff:	90                   	nop
  802200:	89 c8                	mov    %ecx,%eax
  802202:	89 f2                	mov    %esi,%edx
  802204:	83 c4 1c             	add    $0x1c,%esp
  802207:	5b                   	pop    %ebx
  802208:	5e                   	pop    %esi
  802209:	5f                   	pop    %edi
  80220a:	5d                   	pop    %ebp
  80220b:	c3                   	ret    
  80220c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802210:	8b 34 24             	mov    (%esp),%esi
  802213:	bf 20 00 00 00       	mov    $0x20,%edi
  802218:	89 e9                	mov    %ebp,%ecx
  80221a:	29 ef                	sub    %ebp,%edi
  80221c:	d3 e0                	shl    %cl,%eax
  80221e:	89 f9                	mov    %edi,%ecx
  802220:	89 f2                	mov    %esi,%edx
  802222:	d3 ea                	shr    %cl,%edx
  802224:	89 e9                	mov    %ebp,%ecx
  802226:	09 c2                	or     %eax,%edx
  802228:	89 d8                	mov    %ebx,%eax
  80222a:	89 14 24             	mov    %edx,(%esp)
  80222d:	89 f2                	mov    %esi,%edx
  80222f:	d3 e2                	shl    %cl,%edx
  802231:	89 f9                	mov    %edi,%ecx
  802233:	89 54 24 04          	mov    %edx,0x4(%esp)
  802237:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80223b:	d3 e8                	shr    %cl,%eax
  80223d:	89 e9                	mov    %ebp,%ecx
  80223f:	89 c6                	mov    %eax,%esi
  802241:	d3 e3                	shl    %cl,%ebx
  802243:	89 f9                	mov    %edi,%ecx
  802245:	89 d0                	mov    %edx,%eax
  802247:	d3 e8                	shr    %cl,%eax
  802249:	89 e9                	mov    %ebp,%ecx
  80224b:	09 d8                	or     %ebx,%eax
  80224d:	89 d3                	mov    %edx,%ebx
  80224f:	89 f2                	mov    %esi,%edx
  802251:	f7 34 24             	divl   (%esp)
  802254:	89 d6                	mov    %edx,%esi
  802256:	d3 e3                	shl    %cl,%ebx
  802258:	f7 64 24 04          	mull   0x4(%esp)
  80225c:	39 d6                	cmp    %edx,%esi
  80225e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802262:	89 d1                	mov    %edx,%ecx
  802264:	89 c3                	mov    %eax,%ebx
  802266:	72 08                	jb     802270 <__umoddi3+0x110>
  802268:	75 11                	jne    80227b <__umoddi3+0x11b>
  80226a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80226e:	73 0b                	jae    80227b <__umoddi3+0x11b>
  802270:	2b 44 24 04          	sub    0x4(%esp),%eax
  802274:	1b 14 24             	sbb    (%esp),%edx
  802277:	89 d1                	mov    %edx,%ecx
  802279:	89 c3                	mov    %eax,%ebx
  80227b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80227f:	29 da                	sub    %ebx,%edx
  802281:	19 ce                	sbb    %ecx,%esi
  802283:	89 f9                	mov    %edi,%ecx
  802285:	89 f0                	mov    %esi,%eax
  802287:	d3 e0                	shl    %cl,%eax
  802289:	89 e9                	mov    %ebp,%ecx
  80228b:	d3 ea                	shr    %cl,%edx
  80228d:	89 e9                	mov    %ebp,%ecx
  80228f:	d3 ee                	shr    %cl,%esi
  802291:	09 d0                	or     %edx,%eax
  802293:	89 f2                	mov    %esi,%edx
  802295:	83 c4 1c             	add    $0x1c,%esp
  802298:	5b                   	pop    %ebx
  802299:	5e                   	pop    %esi
  80229a:	5f                   	pop    %edi
  80229b:	5d                   	pop    %ebp
  80229c:	c3                   	ret    
  80229d:	8d 76 00             	lea    0x0(%esi),%esi
  8022a0:	29 f9                	sub    %edi,%ecx
  8022a2:	19 d6                	sbb    %edx,%esi
  8022a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022ac:	e9 18 ff ff ff       	jmp    8021c9 <__umoddi3+0x69>
