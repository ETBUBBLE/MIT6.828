
obj/user/breakpoint.debug：     文件格式 elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800044:	e8 ce 00 00 00       	call   800117 <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800056:	a3 08 40 80 00       	mov    %eax,0x804008

    // save the name of the program so that panic() can use it
    if (argc > 0)
  80005b:	85 db                	test   %ebx,%ebx
  80005d:	7e 07                	jle    800066 <libmain+0x2d>
        binaryname = argv[0];
  80005f:	8b 06                	mov    (%esi),%eax
  800061:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	e8 c3 ff ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  800070:	e8 0a 00 00 00       	call   80007f <exit>
}
  800075:	83 c4 10             	add    $0x10,%esp
  800078:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007b:	5b                   	pop    %ebx
  80007c:	5e                   	pop    %esi
  80007d:	5d                   	pop    %ebp
  80007e:	c3                   	ret    

0080007f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800085:	e8 c6 04 00 00       	call   800550 <close_all>
	sys_env_destroy(0);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	e8 42 00 00 00       	call   8000d6 <sys_env_destroy>
}
  800094:	83 c4 10             	add    $0x10,%esp
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	57                   	push   %edi
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009f:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000aa:	89 c3                	mov    %eax,%ebx
  8000ac:	89 c7                	mov    %eax,%edi
  8000ae:	89 c6                	mov    %eax,%esi
  8000b0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b2:	5b                   	pop    %ebx
  8000b3:	5e                   	pop    %esi
  8000b4:	5f                   	pop    %edi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c7:	89 d1                	mov    %edx,%ecx
  8000c9:	89 d3                	mov    %edx,%ebx
  8000cb:	89 d7                	mov    %edx,%edi
  8000cd:	89 d6                	mov    %edx,%esi
  8000cf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ec:	89 cb                	mov    %ecx,%ebx
  8000ee:	89 cf                	mov    %ecx,%edi
  8000f0:	89 ce                	mov    %ecx,%esi
  8000f2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	7e 17                	jle    80010f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	50                   	push   %eax
  8000fc:	6a 03                	push   $0x3
  8000fe:	68 ca 22 80 00       	push   $0x8022ca
  800103:	6a 23                	push   $0x23
  800105:	68 e7 22 80 00       	push   $0x8022e7
  80010a:	e8 c7 13 00 00       	call   8014d6 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800112:	5b                   	pop    %ebx
  800113:	5e                   	pop    %esi
  800114:	5f                   	pop    %edi
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	57                   	push   %edi
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 02 00 00 00       	mov    $0x2,%eax
  800127:	89 d1                	mov    %edx,%ecx
  800129:	89 d3                	mov    %edx,%ebx
  80012b:	89 d7                	mov    %edx,%edi
  80012d:	89 d6                	mov    %edx,%esi
  80012f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    

00800136 <sys_yield>:

void
sys_yield(void)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013c:	ba 00 00 00 00       	mov    $0x0,%edx
  800141:	b8 0b 00 00 00       	mov    $0xb,%eax
  800146:	89 d1                	mov    %edx,%ecx
  800148:	89 d3                	mov    %edx,%ebx
  80014a:	89 d7                	mov    %edx,%edi
  80014c:	89 d6                	mov    %edx,%esi
  80014e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5f                   	pop    %edi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015e:	be 00 00 00 00       	mov    $0x0,%esi
  800163:	b8 04 00 00 00       	mov    $0x4,%eax
  800168:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016b:	8b 55 08             	mov    0x8(%ebp),%edx
  80016e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800171:	89 f7                	mov    %esi,%edi
  800173:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800175:	85 c0                	test   %eax,%eax
  800177:	7e 17                	jle    800190 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800179:	83 ec 0c             	sub    $0xc,%esp
  80017c:	50                   	push   %eax
  80017d:	6a 04                	push   $0x4
  80017f:	68 ca 22 80 00       	push   $0x8022ca
  800184:	6a 23                	push   $0x23
  800186:	68 e7 22 80 00       	push   $0x8022e7
  80018b:	e8 46 13 00 00       	call   8014d6 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800193:	5b                   	pop    %ebx
  800194:	5e                   	pop    %esi
  800195:	5f                   	pop    %edi
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    

00800198 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a1:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b2:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b7:	85 c0                	test   %eax,%eax
  8001b9:	7e 17                	jle    8001d2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	50                   	push   %eax
  8001bf:	6a 05                	push   $0x5
  8001c1:	68 ca 22 80 00       	push   $0x8022ca
  8001c6:	6a 23                	push   $0x23
  8001c8:	68 e7 22 80 00       	push   $0x8022e7
  8001cd:	e8 04 13 00 00       	call   8014d6 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d5:	5b                   	pop    %ebx
  8001d6:	5e                   	pop    %esi
  8001d7:	5f                   	pop    %edi
  8001d8:	5d                   	pop    %ebp
  8001d9:	c3                   	ret    

008001da <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	57                   	push   %edi
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e8:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f3:	89 df                	mov    %ebx,%edi
  8001f5:	89 de                	mov    %ebx,%esi
  8001f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f9:	85 c0                	test   %eax,%eax
  8001fb:	7e 17                	jle    800214 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fd:	83 ec 0c             	sub    $0xc,%esp
  800200:	50                   	push   %eax
  800201:	6a 06                	push   $0x6
  800203:	68 ca 22 80 00       	push   $0x8022ca
  800208:	6a 23                	push   $0x23
  80020a:	68 e7 22 80 00       	push   $0x8022e7
  80020f:	e8 c2 12 00 00       	call   8014d6 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800217:	5b                   	pop    %ebx
  800218:	5e                   	pop    %esi
  800219:	5f                   	pop    %edi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022a:	b8 08 00 00 00       	mov    $0x8,%eax
  80022f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800232:	8b 55 08             	mov    0x8(%ebp),%edx
  800235:	89 df                	mov    %ebx,%edi
  800237:	89 de                	mov    %ebx,%esi
  800239:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80023b:	85 c0                	test   %eax,%eax
  80023d:	7e 17                	jle    800256 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	50                   	push   %eax
  800243:	6a 08                	push   $0x8
  800245:	68 ca 22 80 00       	push   $0x8022ca
  80024a:	6a 23                	push   $0x23
  80024c:	68 e7 22 80 00       	push   $0x8022e7
  800251:	e8 80 12 00 00       	call   8014d6 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800256:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800259:	5b                   	pop    %ebx
  80025a:	5e                   	pop    %esi
  80025b:	5f                   	pop    %edi
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    

0080025e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	57                   	push   %edi
  800262:	56                   	push   %esi
  800263:	53                   	push   %ebx
  800264:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800267:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026c:	b8 09 00 00 00       	mov    $0x9,%eax
  800271:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800274:	8b 55 08             	mov    0x8(%ebp),%edx
  800277:	89 df                	mov    %ebx,%edi
  800279:	89 de                	mov    %ebx,%esi
  80027b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027d:	85 c0                	test   %eax,%eax
  80027f:	7e 17                	jle    800298 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800281:	83 ec 0c             	sub    $0xc,%esp
  800284:	50                   	push   %eax
  800285:	6a 09                	push   $0x9
  800287:	68 ca 22 80 00       	push   $0x8022ca
  80028c:	6a 23                	push   $0x23
  80028e:	68 e7 22 80 00       	push   $0x8022e7
  800293:	e8 3e 12 00 00       	call   8014d6 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800298:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029b:	5b                   	pop    %ebx
  80029c:	5e                   	pop    %esi
  80029d:	5f                   	pop    %edi
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b9:	89 df                	mov    %ebx,%edi
  8002bb:	89 de                	mov    %ebx,%esi
  8002bd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002bf:	85 c0                	test   %eax,%eax
  8002c1:	7e 17                	jle    8002da <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c3:	83 ec 0c             	sub    $0xc,%esp
  8002c6:	50                   	push   %eax
  8002c7:	6a 0a                	push   $0xa
  8002c9:	68 ca 22 80 00       	push   $0x8022ca
  8002ce:	6a 23                	push   $0x23
  8002d0:	68 e7 22 80 00       	push   $0x8022e7
  8002d5:	e8 fc 11 00 00       	call   8014d6 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	57                   	push   %edi
  8002e6:	56                   	push   %esi
  8002e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e8:	be 00 00 00 00       	mov    $0x0,%esi
  8002ed:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002fe:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800313:	b8 0d 00 00 00       	mov    $0xd,%eax
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	89 cb                	mov    %ecx,%ebx
  80031d:	89 cf                	mov    %ecx,%edi
  80031f:	89 ce                	mov    %ecx,%esi
  800321:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800323:	85 c0                	test   %eax,%eax
  800325:	7e 17                	jle    80033e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	50                   	push   %eax
  80032b:	6a 0d                	push   $0xd
  80032d:	68 ca 22 80 00       	push   $0x8022ca
  800332:	6a 23                	push   $0x23
  800334:	68 e7 22 80 00       	push   $0x8022e7
  800339:	e8 98 11 00 00       	call   8014d6 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800341:	5b                   	pop    %ebx
  800342:	5e                   	pop    %esi
  800343:	5f                   	pop    %edi
  800344:	5d                   	pop    %ebp
  800345:	c3                   	ret    

00800346 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	57                   	push   %edi
  80034a:	56                   	push   %esi
  80034b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80034c:	ba 00 00 00 00       	mov    $0x0,%edx
  800351:	b8 0e 00 00 00       	mov    $0xe,%eax
  800356:	89 d1                	mov    %edx,%ecx
  800358:	89 d3                	mov    %edx,%ebx
  80035a:	89 d7                	mov    %edx,%edi
  80035c:	89 d6                	mov    %edx,%esi
  80035e:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800360:	5b                   	pop    %ebx
  800361:	5e                   	pop    %esi
  800362:	5f                   	pop    %edi
  800363:	5d                   	pop    %ebp
  800364:	c3                   	ret    

00800365 <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  800365:	55                   	push   %ebp
  800366:	89 e5                	mov    %esp,%ebp
  800368:	57                   	push   %edi
  800369:	56                   	push   %esi
  80036a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80036b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800370:	b8 10 00 00 00       	mov    $0x10,%eax
  800375:	8b 55 08             	mov    0x8(%ebp),%edx
  800378:	89 cb                	mov    %ecx,%ebx
  80037a:	89 cf                	mov    %ecx,%edi
  80037c:	89 ce                	mov    %ecx,%esi
  80037e:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800380:	5b                   	pop    %ebx
  800381:	5e                   	pop    %esi
  800382:	5f                   	pop    %edi
  800383:	5d                   	pop    %ebp
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
  80045a:	ba 74 23 80 00       	mov    $0x802374,%edx
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
  80047a:	a1 08 40 80 00       	mov    0x804008,%eax
  80047f:	8b 40 48             	mov    0x48(%eax),%eax
  800482:	83 ec 04             	sub    $0x4,%esp
  800485:	51                   	push   %ecx
  800486:	50                   	push   %eax
  800487:	68 f8 22 80 00       	push   $0x8022f8
  80048c:	e8 1e 11 00 00       	call   8015af <cprintf>
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
  800514:	e8 c1 fc ff ff       	call   8001da <sys_page_unmap>
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
  800600:	e8 93 fb ff ff       	call   800198 <sys_page_map>
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
  80062c:	e8 67 fb ff ff       	call   800198 <sys_page_map>
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
  800642:	e8 93 fb ff ff       	call   8001da <sys_page_unmap>
	sys_page_unmap(0, nva);
  800647:	83 c4 08             	add    $0x8,%esp
  80064a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80064d:	6a 00                	push   $0x0
  80064f:	e8 86 fb ff ff       	call   8001da <sys_page_unmap>
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
  8006a4:	a1 08 40 80 00       	mov    0x804008,%eax
  8006a9:	8b 40 48             	mov    0x48(%eax),%eax
  8006ac:	83 ec 04             	sub    $0x4,%esp
  8006af:	53                   	push   %ebx
  8006b0:	50                   	push   %eax
  8006b1:	68 39 23 80 00       	push   $0x802339
  8006b6:	e8 f4 0e 00 00       	call   8015af <cprintf>
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
  800779:	a1 08 40 80 00       	mov    0x804008,%eax
  80077e:	8b 40 48             	mov    0x48(%eax),%eax
  800781:	83 ec 04             	sub    $0x4,%esp
  800784:	53                   	push   %ebx
  800785:	50                   	push   %eax
  800786:	68 55 23 80 00       	push   $0x802355
  80078b:	e8 1f 0e 00 00       	call   8015af <cprintf>
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
  80082e:	a1 08 40 80 00       	mov    0x804008,%eax
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
  80083b:	68 18 23 80 00       	push   $0x802318
  800840:	e8 6a 0d 00 00       	call   8015af <cprintf>
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
  80094b:	e8 67 16 00 00       	call   801fb7 <ipc_find_env>
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
  800966:	e8 f8 15 00 00       	call   801f63 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80096b:	83 c4 0c             	add    $0xc,%esp
  80096e:	6a 00                	push   $0x0
  800970:	53                   	push   %ebx
  800971:	6a 00                	push   $0x0
  800973:	e8 82 15 00 00       	call   801efa <ipc_recv>
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
  8009fc:	e8 b2 11 00 00       	call   801bb3 <strcpy>
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
  800a54:	e8 ec 12 00 00       	call   801d45 <memmove>
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
  800a9c:	68 88 23 80 00       	push   $0x802388
  800aa1:	68 8f 23 80 00       	push   $0x80238f
  800aa6:	6a 7c                	push   $0x7c
  800aa8:	68 a4 23 80 00       	push   $0x8023a4
  800aad:	e8 24 0a 00 00       	call   8014d6 <_panic>
	assert(r <= PGSIZE);
  800ab2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ab7:	7e 16                	jle    800acf <devfile_read+0x65>
  800ab9:	68 af 23 80 00       	push   $0x8023af
  800abe:	68 8f 23 80 00       	push   $0x80238f
  800ac3:	6a 7d                	push   $0x7d
  800ac5:	68 a4 23 80 00       	push   $0x8023a4
  800aca:	e8 07 0a 00 00       	call   8014d6 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800acf:	83 ec 04             	sub    $0x4,%esp
  800ad2:	50                   	push   %eax
  800ad3:	68 00 50 80 00       	push   $0x805000
  800ad8:	ff 75 0c             	pushl  0xc(%ebp)
  800adb:	e8 65 12 00 00       	call   801d45 <memmove>
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
  800af7:	e8 7e 10 00 00       	call   801b7a <strlen>
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
  800b24:	e8 8a 10 00 00       	call   801bb3 <strcpy>
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

00800b90 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b96:	68 bb 23 80 00       	push   $0x8023bb
  800b9b:	ff 75 0c             	pushl  0xc(%ebp)
  800b9e:	e8 10 10 00 00       	call   801bb3 <strcpy>
	return 0;
}
  800ba3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba8:	c9                   	leave  
  800ba9:	c3                   	ret    

00800baa <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	53                   	push   %ebx
  800bae:	83 ec 10             	sub    $0x10,%esp
  800bb1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bb4:	53                   	push   %ebx
  800bb5:	e8 36 14 00 00       	call   801ff0 <pageref>
  800bba:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bbd:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800bc2:	83 f8 01             	cmp    $0x1,%eax
  800bc5:	75 10                	jne    800bd7 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800bc7:	83 ec 0c             	sub    $0xc,%esp
  800bca:	ff 73 0c             	pushl  0xc(%ebx)
  800bcd:	e8 c0 02 00 00       	call   800e92 <nsipc_close>
  800bd2:	89 c2                	mov    %eax,%edx
  800bd4:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800bd7:	89 d0                	mov    %edx,%eax
  800bd9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bdc:	c9                   	leave  
  800bdd:	c3                   	ret    

00800bde <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800be4:	6a 00                	push   $0x0
  800be6:	ff 75 10             	pushl  0x10(%ebp)
  800be9:	ff 75 0c             	pushl  0xc(%ebp)
  800bec:	8b 45 08             	mov    0x8(%ebp),%eax
  800bef:	ff 70 0c             	pushl  0xc(%eax)
  800bf2:	e8 78 03 00 00       	call   800f6f <nsipc_send>
}
  800bf7:	c9                   	leave  
  800bf8:	c3                   	ret    

00800bf9 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800bff:	6a 00                	push   $0x0
  800c01:	ff 75 10             	pushl  0x10(%ebp)
  800c04:	ff 75 0c             	pushl  0xc(%ebp)
  800c07:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0a:	ff 70 0c             	pushl  0xc(%eax)
  800c0d:	e8 f1 02 00 00       	call   800f03 <nsipc_recv>
}
  800c12:	c9                   	leave  
  800c13:	c3                   	ret    

00800c14 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c1a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c1d:	52                   	push   %edx
  800c1e:	50                   	push   %eax
  800c1f:	e8 d7 f7 ff ff       	call   8003fb <fd_lookup>
  800c24:	83 c4 10             	add    $0x10,%esp
  800c27:	85 c0                	test   %eax,%eax
  800c29:	78 17                	js     800c42 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c2e:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c34:	39 08                	cmp    %ecx,(%eax)
  800c36:	75 05                	jne    800c3d <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c38:	8b 40 0c             	mov    0xc(%eax),%eax
  800c3b:	eb 05                	jmp    800c42 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c3d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c42:	c9                   	leave  
  800c43:	c3                   	ret    

00800c44 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 1c             	sub    $0x1c,%esp
  800c4c:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c4e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c51:	50                   	push   %eax
  800c52:	e8 55 f7 ff ff       	call   8003ac <fd_alloc>
  800c57:	89 c3                	mov    %eax,%ebx
  800c59:	83 c4 10             	add    $0x10,%esp
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	78 1b                	js     800c7b <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c60:	83 ec 04             	sub    $0x4,%esp
  800c63:	68 07 04 00 00       	push   $0x407
  800c68:	ff 75 f4             	pushl  -0xc(%ebp)
  800c6b:	6a 00                	push   $0x0
  800c6d:	e8 e3 f4 ff ff       	call   800155 <sys_page_alloc>
  800c72:	89 c3                	mov    %eax,%ebx
  800c74:	83 c4 10             	add    $0x10,%esp
  800c77:	85 c0                	test   %eax,%eax
  800c79:	79 10                	jns    800c8b <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c7b:	83 ec 0c             	sub    $0xc,%esp
  800c7e:	56                   	push   %esi
  800c7f:	e8 0e 02 00 00       	call   800e92 <nsipc_close>
		return r;
  800c84:	83 c4 10             	add    $0x10,%esp
  800c87:	89 d8                	mov    %ebx,%eax
  800c89:	eb 24                	jmp    800caf <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800c8b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800c91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c94:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c99:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800ca0:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	50                   	push   %eax
  800ca7:	e8 d9 f6 ff ff       	call   800385 <fd2num>
  800cac:	83 c4 10             	add    $0x10,%esp
}
  800caf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbf:	e8 50 ff ff ff       	call   800c14 <fd2sockid>
		return r;
  800cc4:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cc6:	85 c0                	test   %eax,%eax
  800cc8:	78 1f                	js     800ce9 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cca:	83 ec 04             	sub    $0x4,%esp
  800ccd:	ff 75 10             	pushl  0x10(%ebp)
  800cd0:	ff 75 0c             	pushl  0xc(%ebp)
  800cd3:	50                   	push   %eax
  800cd4:	e8 12 01 00 00       	call   800deb <nsipc_accept>
  800cd9:	83 c4 10             	add    $0x10,%esp
		return r;
  800cdc:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cde:	85 c0                	test   %eax,%eax
  800ce0:	78 07                	js     800ce9 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800ce2:	e8 5d ff ff ff       	call   800c44 <alloc_sockfd>
  800ce7:	89 c1                	mov    %eax,%ecx
}
  800ce9:	89 c8                	mov    %ecx,%eax
  800ceb:	c9                   	leave  
  800cec:	c3                   	ret    

00800ced <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cf3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf6:	e8 19 ff ff ff       	call   800c14 <fd2sockid>
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	78 12                	js     800d11 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800cff:	83 ec 04             	sub    $0x4,%esp
  800d02:	ff 75 10             	pushl  0x10(%ebp)
  800d05:	ff 75 0c             	pushl  0xc(%ebp)
  800d08:	50                   	push   %eax
  800d09:	e8 2d 01 00 00       	call   800e3b <nsipc_bind>
  800d0e:	83 c4 10             	add    $0x10,%esp
}
  800d11:	c9                   	leave  
  800d12:	c3                   	ret    

00800d13 <shutdown>:

int
shutdown(int s, int how)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d19:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1c:	e8 f3 fe ff ff       	call   800c14 <fd2sockid>
  800d21:	85 c0                	test   %eax,%eax
  800d23:	78 0f                	js     800d34 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d25:	83 ec 08             	sub    $0x8,%esp
  800d28:	ff 75 0c             	pushl  0xc(%ebp)
  800d2b:	50                   	push   %eax
  800d2c:	e8 3f 01 00 00       	call   800e70 <nsipc_shutdown>
  800d31:	83 c4 10             	add    $0x10,%esp
}
  800d34:	c9                   	leave  
  800d35:	c3                   	ret    

00800d36 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3f:	e8 d0 fe ff ff       	call   800c14 <fd2sockid>
  800d44:	85 c0                	test   %eax,%eax
  800d46:	78 12                	js     800d5a <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d48:	83 ec 04             	sub    $0x4,%esp
  800d4b:	ff 75 10             	pushl  0x10(%ebp)
  800d4e:	ff 75 0c             	pushl  0xc(%ebp)
  800d51:	50                   	push   %eax
  800d52:	e8 55 01 00 00       	call   800eac <nsipc_connect>
  800d57:	83 c4 10             	add    $0x10,%esp
}
  800d5a:	c9                   	leave  
  800d5b:	c3                   	ret    

00800d5c <listen>:

int
listen(int s, int backlog)
{
  800d5c:	55                   	push   %ebp
  800d5d:	89 e5                	mov    %esp,%ebp
  800d5f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d62:	8b 45 08             	mov    0x8(%ebp),%eax
  800d65:	e8 aa fe ff ff       	call   800c14 <fd2sockid>
  800d6a:	85 c0                	test   %eax,%eax
  800d6c:	78 0f                	js     800d7d <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d6e:	83 ec 08             	sub    $0x8,%esp
  800d71:	ff 75 0c             	pushl  0xc(%ebp)
  800d74:	50                   	push   %eax
  800d75:	e8 67 01 00 00       	call   800ee1 <nsipc_listen>
  800d7a:	83 c4 10             	add    $0x10,%esp
}
  800d7d:	c9                   	leave  
  800d7e:	c3                   	ret    

00800d7f <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d85:	ff 75 10             	pushl  0x10(%ebp)
  800d88:	ff 75 0c             	pushl  0xc(%ebp)
  800d8b:	ff 75 08             	pushl  0x8(%ebp)
  800d8e:	e8 3a 02 00 00       	call   800fcd <nsipc_socket>
  800d93:	83 c4 10             	add    $0x10,%esp
  800d96:	85 c0                	test   %eax,%eax
  800d98:	78 05                	js     800d9f <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800d9a:	e8 a5 fe ff ff       	call   800c44 <alloc_sockfd>
}
  800d9f:	c9                   	leave  
  800da0:	c3                   	ret    

00800da1 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	53                   	push   %ebx
  800da5:	83 ec 04             	sub    $0x4,%esp
  800da8:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800daa:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800db1:	75 12                	jne    800dc5 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800db3:	83 ec 0c             	sub    $0xc,%esp
  800db6:	6a 02                	push   $0x2
  800db8:	e8 fa 11 00 00       	call   801fb7 <ipc_find_env>
  800dbd:	a3 04 40 80 00       	mov    %eax,0x804004
  800dc2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dc5:	6a 07                	push   $0x7
  800dc7:	68 00 60 80 00       	push   $0x806000
  800dcc:	53                   	push   %ebx
  800dcd:	ff 35 04 40 80 00    	pushl  0x804004
  800dd3:	e8 8b 11 00 00       	call   801f63 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dd8:	83 c4 0c             	add    $0xc,%esp
  800ddb:	6a 00                	push   $0x0
  800ddd:	6a 00                	push   $0x0
  800ddf:	6a 00                	push   $0x0
  800de1:	e8 14 11 00 00       	call   801efa <ipc_recv>
}
  800de6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800de9:	c9                   	leave  
  800dea:	c3                   	ret    

00800deb <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	56                   	push   %esi
  800def:	53                   	push   %ebx
  800df0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800df3:	8b 45 08             	mov    0x8(%ebp),%eax
  800df6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800dfb:	8b 06                	mov    (%esi),%eax
  800dfd:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e02:	b8 01 00 00 00       	mov    $0x1,%eax
  800e07:	e8 95 ff ff ff       	call   800da1 <nsipc>
  800e0c:	89 c3                	mov    %eax,%ebx
  800e0e:	85 c0                	test   %eax,%eax
  800e10:	78 20                	js     800e32 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e12:	83 ec 04             	sub    $0x4,%esp
  800e15:	ff 35 10 60 80 00    	pushl  0x806010
  800e1b:	68 00 60 80 00       	push   $0x806000
  800e20:	ff 75 0c             	pushl  0xc(%ebp)
  800e23:	e8 1d 0f 00 00       	call   801d45 <memmove>
		*addrlen = ret->ret_addrlen;
  800e28:	a1 10 60 80 00       	mov    0x806010,%eax
  800e2d:	89 06                	mov    %eax,(%esi)
  800e2f:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e32:	89 d8                	mov    %ebx,%eax
  800e34:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e37:	5b                   	pop    %ebx
  800e38:	5e                   	pop    %esi
  800e39:	5d                   	pop    %ebp
  800e3a:	c3                   	ret    

00800e3b <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	53                   	push   %ebx
  800e3f:	83 ec 08             	sub    $0x8,%esp
  800e42:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e45:	8b 45 08             	mov    0x8(%ebp),%eax
  800e48:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e4d:	53                   	push   %ebx
  800e4e:	ff 75 0c             	pushl  0xc(%ebp)
  800e51:	68 04 60 80 00       	push   $0x806004
  800e56:	e8 ea 0e 00 00       	call   801d45 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e5b:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e61:	b8 02 00 00 00       	mov    $0x2,%eax
  800e66:	e8 36 ff ff ff       	call   800da1 <nsipc>
}
  800e6b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e6e:	c9                   	leave  
  800e6f:	c3                   	ret    

00800e70 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e76:	8b 45 08             	mov    0x8(%ebp),%eax
  800e79:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e81:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e86:	b8 03 00 00 00       	mov    $0x3,%eax
  800e8b:	e8 11 ff ff ff       	call   800da1 <nsipc>
}
  800e90:	c9                   	leave  
  800e91:	c3                   	ret    

00800e92 <nsipc_close>:

int
nsipc_close(int s)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800e98:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800ea0:	b8 04 00 00 00       	mov    $0x4,%eax
  800ea5:	e8 f7 fe ff ff       	call   800da1 <nsipc>
}
  800eaa:	c9                   	leave  
  800eab:	c3                   	ret    

00800eac <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	53                   	push   %ebx
  800eb0:	83 ec 08             	sub    $0x8,%esp
  800eb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800eb6:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb9:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ebe:	53                   	push   %ebx
  800ebf:	ff 75 0c             	pushl  0xc(%ebp)
  800ec2:	68 04 60 80 00       	push   $0x806004
  800ec7:	e8 79 0e 00 00       	call   801d45 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ecc:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ed2:	b8 05 00 00 00       	mov    $0x5,%eax
  800ed7:	e8 c5 fe ff ff       	call   800da1 <nsipc>
}
  800edc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800edf:	c9                   	leave  
  800ee0:	c3                   	ret    

00800ee1 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ee7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eea:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800eef:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef2:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800ef7:	b8 06 00 00 00       	mov    $0x6,%eax
  800efc:	e8 a0 fe ff ff       	call   800da1 <nsipc>
}
  800f01:	c9                   	leave  
  800f02:	c3                   	ret    

00800f03 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f03:	55                   	push   %ebp
  800f04:	89 e5                	mov    %esp,%ebp
  800f06:	56                   	push   %esi
  800f07:	53                   	push   %ebx
  800f08:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f13:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f19:	8b 45 14             	mov    0x14(%ebp),%eax
  800f1c:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f21:	b8 07 00 00 00       	mov    $0x7,%eax
  800f26:	e8 76 fe ff ff       	call   800da1 <nsipc>
  800f2b:	89 c3                	mov    %eax,%ebx
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	78 35                	js     800f66 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f31:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f36:	7f 04                	jg     800f3c <nsipc_recv+0x39>
  800f38:	39 c6                	cmp    %eax,%esi
  800f3a:	7d 16                	jge    800f52 <nsipc_recv+0x4f>
  800f3c:	68 c7 23 80 00       	push   $0x8023c7
  800f41:	68 8f 23 80 00       	push   $0x80238f
  800f46:	6a 62                	push   $0x62
  800f48:	68 dc 23 80 00       	push   $0x8023dc
  800f4d:	e8 84 05 00 00       	call   8014d6 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f52:	83 ec 04             	sub    $0x4,%esp
  800f55:	50                   	push   %eax
  800f56:	68 00 60 80 00       	push   $0x806000
  800f5b:	ff 75 0c             	pushl  0xc(%ebp)
  800f5e:	e8 e2 0d 00 00       	call   801d45 <memmove>
  800f63:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f66:	89 d8                	mov    %ebx,%eax
  800f68:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f6b:	5b                   	pop    %ebx
  800f6c:	5e                   	pop    %esi
  800f6d:	5d                   	pop    %ebp
  800f6e:	c3                   	ret    

00800f6f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	53                   	push   %ebx
  800f73:	83 ec 04             	sub    $0x4,%esp
  800f76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f79:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7c:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f81:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f87:	7e 16                	jle    800f9f <nsipc_send+0x30>
  800f89:	68 e8 23 80 00       	push   $0x8023e8
  800f8e:	68 8f 23 80 00       	push   $0x80238f
  800f93:	6a 6d                	push   $0x6d
  800f95:	68 dc 23 80 00       	push   $0x8023dc
  800f9a:	e8 37 05 00 00       	call   8014d6 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800f9f:	83 ec 04             	sub    $0x4,%esp
  800fa2:	53                   	push   %ebx
  800fa3:	ff 75 0c             	pushl  0xc(%ebp)
  800fa6:	68 0c 60 80 00       	push   $0x80600c
  800fab:	e8 95 0d 00 00       	call   801d45 <memmove>
	nsipcbuf.send.req_size = size;
  800fb0:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fb6:	8b 45 14             	mov    0x14(%ebp),%eax
  800fb9:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fbe:	b8 08 00 00 00       	mov    $0x8,%eax
  800fc3:	e8 d9 fd ff ff       	call   800da1 <nsipc>
}
  800fc8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fcb:	c9                   	leave  
  800fcc:	c3                   	ret    

00800fcd <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fd3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd6:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800fdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fde:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800fe3:	8b 45 10             	mov    0x10(%ebp),%eax
  800fe6:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  800feb:	b8 09 00 00 00       	mov    $0x9,%eax
  800ff0:	e8 ac fd ff ff       	call   800da1 <nsipc>
}
  800ff5:	c9                   	leave  
  800ff6:	c3                   	ret    

00800ff7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	56                   	push   %esi
  800ffb:	53                   	push   %ebx
  800ffc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800fff:	83 ec 0c             	sub    $0xc,%esp
  801002:	ff 75 08             	pushl  0x8(%ebp)
  801005:	e8 8b f3 ff ff       	call   800395 <fd2data>
  80100a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80100c:	83 c4 08             	add    $0x8,%esp
  80100f:	68 f4 23 80 00       	push   $0x8023f4
  801014:	53                   	push   %ebx
  801015:	e8 99 0b 00 00       	call   801bb3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80101a:	8b 46 04             	mov    0x4(%esi),%eax
  80101d:	2b 06                	sub    (%esi),%eax
  80101f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801025:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80102c:	00 00 00 
	stat->st_dev = &devpipe;
  80102f:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801036:	30 80 00 
	return 0;
}
  801039:	b8 00 00 00 00       	mov    $0x0,%eax
  80103e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801041:	5b                   	pop    %ebx
  801042:	5e                   	pop    %esi
  801043:	5d                   	pop    %ebp
  801044:	c3                   	ret    

00801045 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801045:	55                   	push   %ebp
  801046:	89 e5                	mov    %esp,%ebp
  801048:	53                   	push   %ebx
  801049:	83 ec 0c             	sub    $0xc,%esp
  80104c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80104f:	53                   	push   %ebx
  801050:	6a 00                	push   $0x0
  801052:	e8 83 f1 ff ff       	call   8001da <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801057:	89 1c 24             	mov    %ebx,(%esp)
  80105a:	e8 36 f3 ff ff       	call   800395 <fd2data>
  80105f:	83 c4 08             	add    $0x8,%esp
  801062:	50                   	push   %eax
  801063:	6a 00                	push   $0x0
  801065:	e8 70 f1 ff ff       	call   8001da <sys_page_unmap>
}
  80106a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106d:	c9                   	leave  
  80106e:	c3                   	ret    

0080106f <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80106f:	55                   	push   %ebp
  801070:	89 e5                	mov    %esp,%ebp
  801072:	57                   	push   %edi
  801073:	56                   	push   %esi
  801074:	53                   	push   %ebx
  801075:	83 ec 1c             	sub    $0x1c,%esp
  801078:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80107b:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80107d:	a1 08 40 80 00       	mov    0x804008,%eax
  801082:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801085:	83 ec 0c             	sub    $0xc,%esp
  801088:	ff 75 e0             	pushl  -0x20(%ebp)
  80108b:	e8 60 0f 00 00       	call   801ff0 <pageref>
  801090:	89 c3                	mov    %eax,%ebx
  801092:	89 3c 24             	mov    %edi,(%esp)
  801095:	e8 56 0f 00 00       	call   801ff0 <pageref>
  80109a:	83 c4 10             	add    $0x10,%esp
  80109d:	39 c3                	cmp    %eax,%ebx
  80109f:	0f 94 c1             	sete   %cl
  8010a2:	0f b6 c9             	movzbl %cl,%ecx
  8010a5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010a8:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010ae:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010b1:	39 ce                	cmp    %ecx,%esi
  8010b3:	74 1b                	je     8010d0 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010b5:	39 c3                	cmp    %eax,%ebx
  8010b7:	75 c4                	jne    80107d <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010b9:	8b 42 58             	mov    0x58(%edx),%eax
  8010bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010bf:	50                   	push   %eax
  8010c0:	56                   	push   %esi
  8010c1:	68 fb 23 80 00       	push   $0x8023fb
  8010c6:	e8 e4 04 00 00       	call   8015af <cprintf>
  8010cb:	83 c4 10             	add    $0x10,%esp
  8010ce:	eb ad                	jmp    80107d <_pipeisclosed+0xe>
	}
}
  8010d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d6:	5b                   	pop    %ebx
  8010d7:	5e                   	pop    %esi
  8010d8:	5f                   	pop    %edi
  8010d9:	5d                   	pop    %ebp
  8010da:	c3                   	ret    

008010db <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	57                   	push   %edi
  8010df:	56                   	push   %esi
  8010e0:	53                   	push   %ebx
  8010e1:	83 ec 28             	sub    $0x28,%esp
  8010e4:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8010e7:	56                   	push   %esi
  8010e8:	e8 a8 f2 ff ff       	call   800395 <fd2data>
  8010ed:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010ef:	83 c4 10             	add    $0x10,%esp
  8010f2:	bf 00 00 00 00       	mov    $0x0,%edi
  8010f7:	eb 4b                	jmp    801144 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8010f9:	89 da                	mov    %ebx,%edx
  8010fb:	89 f0                	mov    %esi,%eax
  8010fd:	e8 6d ff ff ff       	call   80106f <_pipeisclosed>
  801102:	85 c0                	test   %eax,%eax
  801104:	75 48                	jne    80114e <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801106:	e8 2b f0 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80110b:	8b 43 04             	mov    0x4(%ebx),%eax
  80110e:	8b 0b                	mov    (%ebx),%ecx
  801110:	8d 51 20             	lea    0x20(%ecx),%edx
  801113:	39 d0                	cmp    %edx,%eax
  801115:	73 e2                	jae    8010f9 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801117:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80111a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80111e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801121:	89 c2                	mov    %eax,%edx
  801123:	c1 fa 1f             	sar    $0x1f,%edx
  801126:	89 d1                	mov    %edx,%ecx
  801128:	c1 e9 1b             	shr    $0x1b,%ecx
  80112b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80112e:	83 e2 1f             	and    $0x1f,%edx
  801131:	29 ca                	sub    %ecx,%edx
  801133:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801137:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80113b:	83 c0 01             	add    $0x1,%eax
  80113e:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801141:	83 c7 01             	add    $0x1,%edi
  801144:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801147:	75 c2                	jne    80110b <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801149:	8b 45 10             	mov    0x10(%ebp),%eax
  80114c:	eb 05                	jmp    801153 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80114e:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801153:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801156:	5b                   	pop    %ebx
  801157:	5e                   	pop    %esi
  801158:	5f                   	pop    %edi
  801159:	5d                   	pop    %ebp
  80115a:	c3                   	ret    

0080115b <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80115b:	55                   	push   %ebp
  80115c:	89 e5                	mov    %esp,%ebp
  80115e:	57                   	push   %edi
  80115f:	56                   	push   %esi
  801160:	53                   	push   %ebx
  801161:	83 ec 18             	sub    $0x18,%esp
  801164:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801167:	57                   	push   %edi
  801168:	e8 28 f2 ff ff       	call   800395 <fd2data>
  80116d:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80116f:	83 c4 10             	add    $0x10,%esp
  801172:	bb 00 00 00 00       	mov    $0x0,%ebx
  801177:	eb 3d                	jmp    8011b6 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801179:	85 db                	test   %ebx,%ebx
  80117b:	74 04                	je     801181 <devpipe_read+0x26>
				return i;
  80117d:	89 d8                	mov    %ebx,%eax
  80117f:	eb 44                	jmp    8011c5 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801181:	89 f2                	mov    %esi,%edx
  801183:	89 f8                	mov    %edi,%eax
  801185:	e8 e5 fe ff ff       	call   80106f <_pipeisclosed>
  80118a:	85 c0                	test   %eax,%eax
  80118c:	75 32                	jne    8011c0 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80118e:	e8 a3 ef ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801193:	8b 06                	mov    (%esi),%eax
  801195:	3b 46 04             	cmp    0x4(%esi),%eax
  801198:	74 df                	je     801179 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80119a:	99                   	cltd   
  80119b:	c1 ea 1b             	shr    $0x1b,%edx
  80119e:	01 d0                	add    %edx,%eax
  8011a0:	83 e0 1f             	and    $0x1f,%eax
  8011a3:	29 d0                	sub    %edx,%eax
  8011a5:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ad:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011b0:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011b3:	83 c3 01             	add    $0x1,%ebx
  8011b6:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011b9:	75 d8                	jne    801193 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8011be:	eb 05                	jmp    8011c5 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011c0:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c8:	5b                   	pop    %ebx
  8011c9:	5e                   	pop    %esi
  8011ca:	5f                   	pop    %edi
  8011cb:	5d                   	pop    %ebp
  8011cc:	c3                   	ret    

008011cd <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
  8011d0:	56                   	push   %esi
  8011d1:	53                   	push   %ebx
  8011d2:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d8:	50                   	push   %eax
  8011d9:	e8 ce f1 ff ff       	call   8003ac <fd_alloc>
  8011de:	83 c4 10             	add    $0x10,%esp
  8011e1:	89 c2                	mov    %eax,%edx
  8011e3:	85 c0                	test   %eax,%eax
  8011e5:	0f 88 2c 01 00 00    	js     801317 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011eb:	83 ec 04             	sub    $0x4,%esp
  8011ee:	68 07 04 00 00       	push   $0x407
  8011f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8011f6:	6a 00                	push   $0x0
  8011f8:	e8 58 ef ff ff       	call   800155 <sys_page_alloc>
  8011fd:	83 c4 10             	add    $0x10,%esp
  801200:	89 c2                	mov    %eax,%edx
  801202:	85 c0                	test   %eax,%eax
  801204:	0f 88 0d 01 00 00    	js     801317 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80120a:	83 ec 0c             	sub    $0xc,%esp
  80120d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801210:	50                   	push   %eax
  801211:	e8 96 f1 ff ff       	call   8003ac <fd_alloc>
  801216:	89 c3                	mov    %eax,%ebx
  801218:	83 c4 10             	add    $0x10,%esp
  80121b:	85 c0                	test   %eax,%eax
  80121d:	0f 88 e2 00 00 00    	js     801305 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801223:	83 ec 04             	sub    $0x4,%esp
  801226:	68 07 04 00 00       	push   $0x407
  80122b:	ff 75 f0             	pushl  -0x10(%ebp)
  80122e:	6a 00                	push   $0x0
  801230:	e8 20 ef ff ff       	call   800155 <sys_page_alloc>
  801235:	89 c3                	mov    %eax,%ebx
  801237:	83 c4 10             	add    $0x10,%esp
  80123a:	85 c0                	test   %eax,%eax
  80123c:	0f 88 c3 00 00 00    	js     801305 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801242:	83 ec 0c             	sub    $0xc,%esp
  801245:	ff 75 f4             	pushl  -0xc(%ebp)
  801248:	e8 48 f1 ff ff       	call   800395 <fd2data>
  80124d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80124f:	83 c4 0c             	add    $0xc,%esp
  801252:	68 07 04 00 00       	push   $0x407
  801257:	50                   	push   %eax
  801258:	6a 00                	push   $0x0
  80125a:	e8 f6 ee ff ff       	call   800155 <sys_page_alloc>
  80125f:	89 c3                	mov    %eax,%ebx
  801261:	83 c4 10             	add    $0x10,%esp
  801264:	85 c0                	test   %eax,%eax
  801266:	0f 88 89 00 00 00    	js     8012f5 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80126c:	83 ec 0c             	sub    $0xc,%esp
  80126f:	ff 75 f0             	pushl  -0x10(%ebp)
  801272:	e8 1e f1 ff ff       	call   800395 <fd2data>
  801277:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80127e:	50                   	push   %eax
  80127f:	6a 00                	push   $0x0
  801281:	56                   	push   %esi
  801282:	6a 00                	push   $0x0
  801284:	e8 0f ef ff ff       	call   800198 <sys_page_map>
  801289:	89 c3                	mov    %eax,%ebx
  80128b:	83 c4 20             	add    $0x20,%esp
  80128e:	85 c0                	test   %eax,%eax
  801290:	78 55                	js     8012e7 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801292:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801298:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80129b:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80129d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a0:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012a7:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b0:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012bc:	83 ec 0c             	sub    $0xc,%esp
  8012bf:	ff 75 f4             	pushl  -0xc(%ebp)
  8012c2:	e8 be f0 ff ff       	call   800385 <fd2num>
  8012c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ca:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012cc:	83 c4 04             	add    $0x4,%esp
  8012cf:	ff 75 f0             	pushl  -0x10(%ebp)
  8012d2:	e8 ae f0 ff ff       	call   800385 <fd2num>
  8012d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012da:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012dd:	83 c4 10             	add    $0x10,%esp
  8012e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e5:	eb 30                	jmp    801317 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8012e7:	83 ec 08             	sub    $0x8,%esp
  8012ea:	56                   	push   %esi
  8012eb:	6a 00                	push   $0x0
  8012ed:	e8 e8 ee ff ff       	call   8001da <sys_page_unmap>
  8012f2:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8012f5:	83 ec 08             	sub    $0x8,%esp
  8012f8:	ff 75 f0             	pushl  -0x10(%ebp)
  8012fb:	6a 00                	push   $0x0
  8012fd:	e8 d8 ee ff ff       	call   8001da <sys_page_unmap>
  801302:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801305:	83 ec 08             	sub    $0x8,%esp
  801308:	ff 75 f4             	pushl  -0xc(%ebp)
  80130b:	6a 00                	push   $0x0
  80130d:	e8 c8 ee ff ff       	call   8001da <sys_page_unmap>
  801312:	83 c4 10             	add    $0x10,%esp
  801315:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801317:	89 d0                	mov    %edx,%eax
  801319:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80131c:	5b                   	pop    %ebx
  80131d:	5e                   	pop    %esi
  80131e:	5d                   	pop    %ebp
  80131f:	c3                   	ret    

00801320 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801326:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801329:	50                   	push   %eax
  80132a:	ff 75 08             	pushl  0x8(%ebp)
  80132d:	e8 c9 f0 ff ff       	call   8003fb <fd_lookup>
  801332:	83 c4 10             	add    $0x10,%esp
  801335:	85 c0                	test   %eax,%eax
  801337:	78 18                	js     801351 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801339:	83 ec 0c             	sub    $0xc,%esp
  80133c:	ff 75 f4             	pushl  -0xc(%ebp)
  80133f:	e8 51 f0 ff ff       	call   800395 <fd2data>
	return _pipeisclosed(fd, p);
  801344:	89 c2                	mov    %eax,%edx
  801346:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801349:	e8 21 fd ff ff       	call   80106f <_pipeisclosed>
  80134e:	83 c4 10             	add    $0x10,%esp
}
  801351:	c9                   	leave  
  801352:	c3                   	ret    

00801353 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801353:	55                   	push   %ebp
  801354:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801356:	b8 00 00 00 00       	mov    $0x0,%eax
  80135b:	5d                   	pop    %ebp
  80135c:	c3                   	ret    

0080135d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801363:	68 13 24 80 00       	push   $0x802413
  801368:	ff 75 0c             	pushl  0xc(%ebp)
  80136b:	e8 43 08 00 00       	call   801bb3 <strcpy>
	return 0;
}
  801370:	b8 00 00 00 00       	mov    $0x0,%eax
  801375:	c9                   	leave  
  801376:	c3                   	ret    

00801377 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	57                   	push   %edi
  80137b:	56                   	push   %esi
  80137c:	53                   	push   %ebx
  80137d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801383:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801388:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80138e:	eb 2d                	jmp    8013bd <devcons_write+0x46>
		m = n - tot;
  801390:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801393:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801395:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801398:	ba 7f 00 00 00       	mov    $0x7f,%edx
  80139d:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013a0:	83 ec 04             	sub    $0x4,%esp
  8013a3:	53                   	push   %ebx
  8013a4:	03 45 0c             	add    0xc(%ebp),%eax
  8013a7:	50                   	push   %eax
  8013a8:	57                   	push   %edi
  8013a9:	e8 97 09 00 00       	call   801d45 <memmove>
		sys_cputs(buf, m);
  8013ae:	83 c4 08             	add    $0x8,%esp
  8013b1:	53                   	push   %ebx
  8013b2:	57                   	push   %edi
  8013b3:	e8 e1 ec ff ff       	call   800099 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013b8:	01 de                	add    %ebx,%esi
  8013ba:	83 c4 10             	add    $0x10,%esp
  8013bd:	89 f0                	mov    %esi,%eax
  8013bf:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013c2:	72 cc                	jb     801390 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c7:	5b                   	pop    %ebx
  8013c8:	5e                   	pop    %esi
  8013c9:	5f                   	pop    %edi
  8013ca:	5d                   	pop    %ebp
  8013cb:	c3                   	ret    

008013cc <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	83 ec 08             	sub    $0x8,%esp
  8013d2:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013d7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013db:	74 2a                	je     801407 <devcons_read+0x3b>
  8013dd:	eb 05                	jmp    8013e4 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013df:	e8 52 ed ff ff       	call   800136 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013e4:	e8 ce ec ff ff       	call   8000b7 <sys_cgetc>
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	74 f2                	je     8013df <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013ed:	85 c0                	test   %eax,%eax
  8013ef:	78 16                	js     801407 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8013f1:	83 f8 04             	cmp    $0x4,%eax
  8013f4:	74 0c                	je     801402 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8013f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013f9:	88 02                	mov    %al,(%edx)
	return 1;
  8013fb:	b8 01 00 00 00       	mov    $0x1,%eax
  801400:	eb 05                	jmp    801407 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801402:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801407:	c9                   	leave  
  801408:	c3                   	ret    

00801409 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801409:	55                   	push   %ebp
  80140a:	89 e5                	mov    %esp,%ebp
  80140c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80140f:	8b 45 08             	mov    0x8(%ebp),%eax
  801412:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801415:	6a 01                	push   $0x1
  801417:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80141a:	50                   	push   %eax
  80141b:	e8 79 ec ff ff       	call   800099 <sys_cputs>
}
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	c9                   	leave  
  801424:	c3                   	ret    

00801425 <getchar>:

int
getchar(void)
{
  801425:	55                   	push   %ebp
  801426:	89 e5                	mov    %esp,%ebp
  801428:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80142b:	6a 01                	push   $0x1
  80142d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801430:	50                   	push   %eax
  801431:	6a 00                	push   $0x0
  801433:	e8 29 f2 ff ff       	call   800661 <read>
	if (r < 0)
  801438:	83 c4 10             	add    $0x10,%esp
  80143b:	85 c0                	test   %eax,%eax
  80143d:	78 0f                	js     80144e <getchar+0x29>
		return r;
	if (r < 1)
  80143f:	85 c0                	test   %eax,%eax
  801441:	7e 06                	jle    801449 <getchar+0x24>
		return -E_EOF;
	return c;
  801443:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801447:	eb 05                	jmp    80144e <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801449:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80144e:	c9                   	leave  
  80144f:	c3                   	ret    

00801450 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801450:	55                   	push   %ebp
  801451:	89 e5                	mov    %esp,%ebp
  801453:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801456:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801459:	50                   	push   %eax
  80145a:	ff 75 08             	pushl  0x8(%ebp)
  80145d:	e8 99 ef ff ff       	call   8003fb <fd_lookup>
  801462:	83 c4 10             	add    $0x10,%esp
  801465:	85 c0                	test   %eax,%eax
  801467:	78 11                	js     80147a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801469:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80146c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801472:	39 10                	cmp    %edx,(%eax)
  801474:	0f 94 c0             	sete   %al
  801477:	0f b6 c0             	movzbl %al,%eax
}
  80147a:	c9                   	leave  
  80147b:	c3                   	ret    

0080147c <opencons>:

int
opencons(void)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801482:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801485:	50                   	push   %eax
  801486:	e8 21 ef ff ff       	call   8003ac <fd_alloc>
  80148b:	83 c4 10             	add    $0x10,%esp
		return r;
  80148e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801490:	85 c0                	test   %eax,%eax
  801492:	78 3e                	js     8014d2 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801494:	83 ec 04             	sub    $0x4,%esp
  801497:	68 07 04 00 00       	push   $0x407
  80149c:	ff 75 f4             	pushl  -0xc(%ebp)
  80149f:	6a 00                	push   $0x0
  8014a1:	e8 af ec ff ff       	call   800155 <sys_page_alloc>
  8014a6:	83 c4 10             	add    $0x10,%esp
		return r;
  8014a9:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014ab:	85 c0                	test   %eax,%eax
  8014ad:	78 23                	js     8014d2 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014af:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014bd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014c4:	83 ec 0c             	sub    $0xc,%esp
  8014c7:	50                   	push   %eax
  8014c8:	e8 b8 ee ff ff       	call   800385 <fd2num>
  8014cd:	89 c2                	mov    %eax,%edx
  8014cf:	83 c4 10             	add    $0x10,%esp
}
  8014d2:	89 d0                	mov    %edx,%eax
  8014d4:	c9                   	leave  
  8014d5:	c3                   	ret    

008014d6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014d6:	55                   	push   %ebp
  8014d7:	89 e5                	mov    %esp,%ebp
  8014d9:	56                   	push   %esi
  8014da:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014db:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014de:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014e4:	e8 2e ec ff ff       	call   800117 <sys_getenvid>
  8014e9:	83 ec 0c             	sub    $0xc,%esp
  8014ec:	ff 75 0c             	pushl  0xc(%ebp)
  8014ef:	ff 75 08             	pushl  0x8(%ebp)
  8014f2:	56                   	push   %esi
  8014f3:	50                   	push   %eax
  8014f4:	68 20 24 80 00       	push   $0x802420
  8014f9:	e8 b1 00 00 00       	call   8015af <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014fe:	83 c4 18             	add    $0x18,%esp
  801501:	53                   	push   %ebx
  801502:	ff 75 10             	pushl  0x10(%ebp)
  801505:	e8 54 00 00 00       	call   80155e <vcprintf>
	cprintf("\n");
  80150a:	c7 04 24 0c 24 80 00 	movl   $0x80240c,(%esp)
  801511:	e8 99 00 00 00       	call   8015af <cprintf>
  801516:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801519:	cc                   	int3   
  80151a:	eb fd                	jmp    801519 <_panic+0x43>

0080151c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80151c:	55                   	push   %ebp
  80151d:	89 e5                	mov    %esp,%ebp
  80151f:	53                   	push   %ebx
  801520:	83 ec 04             	sub    $0x4,%esp
  801523:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801526:	8b 13                	mov    (%ebx),%edx
  801528:	8d 42 01             	lea    0x1(%edx),%eax
  80152b:	89 03                	mov    %eax,(%ebx)
  80152d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801530:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801534:	3d ff 00 00 00       	cmp    $0xff,%eax
  801539:	75 1a                	jne    801555 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80153b:	83 ec 08             	sub    $0x8,%esp
  80153e:	68 ff 00 00 00       	push   $0xff
  801543:	8d 43 08             	lea    0x8(%ebx),%eax
  801546:	50                   	push   %eax
  801547:	e8 4d eb ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  80154c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801552:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801555:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801559:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80155c:	c9                   	leave  
  80155d:	c3                   	ret    

0080155e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80155e:	55                   	push   %ebp
  80155f:	89 e5                	mov    %esp,%ebp
  801561:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801567:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80156e:	00 00 00 
	b.cnt = 0;
  801571:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801578:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80157b:	ff 75 0c             	pushl  0xc(%ebp)
  80157e:	ff 75 08             	pushl  0x8(%ebp)
  801581:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801587:	50                   	push   %eax
  801588:	68 1c 15 80 00       	push   $0x80151c
  80158d:	e8 1a 01 00 00       	call   8016ac <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801592:	83 c4 08             	add    $0x8,%esp
  801595:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80159b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015a1:	50                   	push   %eax
  8015a2:	e8 f2 ea ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  8015a7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015ad:	c9                   	leave  
  8015ae:	c3                   	ret    

008015af <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015af:	55                   	push   %ebp
  8015b0:	89 e5                	mov    %esp,%ebp
  8015b2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015b5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015b8:	50                   	push   %eax
  8015b9:	ff 75 08             	pushl  0x8(%ebp)
  8015bc:	e8 9d ff ff ff       	call   80155e <vcprintf>
	va_end(ap);

	return cnt;
}
  8015c1:	c9                   	leave  
  8015c2:	c3                   	ret    

008015c3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	57                   	push   %edi
  8015c7:	56                   	push   %esi
  8015c8:	53                   	push   %ebx
  8015c9:	83 ec 1c             	sub    $0x1c,%esp
  8015cc:	89 c7                	mov    %eax,%edi
  8015ce:	89 d6                	mov    %edx,%esi
  8015d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015d9:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015e4:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015e7:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015ea:	39 d3                	cmp    %edx,%ebx
  8015ec:	72 05                	jb     8015f3 <printnum+0x30>
  8015ee:	39 45 10             	cmp    %eax,0x10(%ebp)
  8015f1:	77 45                	ja     801638 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015f3:	83 ec 0c             	sub    $0xc,%esp
  8015f6:	ff 75 18             	pushl  0x18(%ebp)
  8015f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8015fc:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8015ff:	53                   	push   %ebx
  801600:	ff 75 10             	pushl  0x10(%ebp)
  801603:	83 ec 08             	sub    $0x8,%esp
  801606:	ff 75 e4             	pushl  -0x1c(%ebp)
  801609:	ff 75 e0             	pushl  -0x20(%ebp)
  80160c:	ff 75 dc             	pushl  -0x24(%ebp)
  80160f:	ff 75 d8             	pushl  -0x28(%ebp)
  801612:	e8 19 0a 00 00       	call   802030 <__udivdi3>
  801617:	83 c4 18             	add    $0x18,%esp
  80161a:	52                   	push   %edx
  80161b:	50                   	push   %eax
  80161c:	89 f2                	mov    %esi,%edx
  80161e:	89 f8                	mov    %edi,%eax
  801620:	e8 9e ff ff ff       	call   8015c3 <printnum>
  801625:	83 c4 20             	add    $0x20,%esp
  801628:	eb 18                	jmp    801642 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80162a:	83 ec 08             	sub    $0x8,%esp
  80162d:	56                   	push   %esi
  80162e:	ff 75 18             	pushl  0x18(%ebp)
  801631:	ff d7                	call   *%edi
  801633:	83 c4 10             	add    $0x10,%esp
  801636:	eb 03                	jmp    80163b <printnum+0x78>
  801638:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80163b:	83 eb 01             	sub    $0x1,%ebx
  80163e:	85 db                	test   %ebx,%ebx
  801640:	7f e8                	jg     80162a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801642:	83 ec 08             	sub    $0x8,%esp
  801645:	56                   	push   %esi
  801646:	83 ec 04             	sub    $0x4,%esp
  801649:	ff 75 e4             	pushl  -0x1c(%ebp)
  80164c:	ff 75 e0             	pushl  -0x20(%ebp)
  80164f:	ff 75 dc             	pushl  -0x24(%ebp)
  801652:	ff 75 d8             	pushl  -0x28(%ebp)
  801655:	e8 06 0b 00 00       	call   802160 <__umoddi3>
  80165a:	83 c4 14             	add    $0x14,%esp
  80165d:	0f be 80 43 24 80 00 	movsbl 0x802443(%eax),%eax
  801664:	50                   	push   %eax
  801665:	ff d7                	call   *%edi
}
  801667:	83 c4 10             	add    $0x10,%esp
  80166a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80166d:	5b                   	pop    %ebx
  80166e:	5e                   	pop    %esi
  80166f:	5f                   	pop    %edi
  801670:	5d                   	pop    %ebp
  801671:	c3                   	ret    

00801672 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801678:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80167c:	8b 10                	mov    (%eax),%edx
  80167e:	3b 50 04             	cmp    0x4(%eax),%edx
  801681:	73 0a                	jae    80168d <sprintputch+0x1b>
		*b->buf++ = ch;
  801683:	8d 4a 01             	lea    0x1(%edx),%ecx
  801686:	89 08                	mov    %ecx,(%eax)
  801688:	8b 45 08             	mov    0x8(%ebp),%eax
  80168b:	88 02                	mov    %al,(%edx)
}
  80168d:	5d                   	pop    %ebp
  80168e:	c3                   	ret    

0080168f <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801695:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801698:	50                   	push   %eax
  801699:	ff 75 10             	pushl  0x10(%ebp)
  80169c:	ff 75 0c             	pushl  0xc(%ebp)
  80169f:	ff 75 08             	pushl  0x8(%ebp)
  8016a2:	e8 05 00 00 00       	call   8016ac <vprintfmt>
	va_end(ap);
}
  8016a7:	83 c4 10             	add    $0x10,%esp
  8016aa:	c9                   	leave  
  8016ab:	c3                   	ret    

008016ac <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	57                   	push   %edi
  8016b0:	56                   	push   %esi
  8016b1:	53                   	push   %ebx
  8016b2:	83 ec 2c             	sub    $0x2c,%esp
  8016b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8016b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016bb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016be:	eb 12                	jmp    8016d2 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016c0:	85 c0                	test   %eax,%eax
  8016c2:	0f 84 42 04 00 00    	je     801b0a <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8016c8:	83 ec 08             	sub    $0x8,%esp
  8016cb:	53                   	push   %ebx
  8016cc:	50                   	push   %eax
  8016cd:	ff d6                	call   *%esi
  8016cf:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016d2:	83 c7 01             	add    $0x1,%edi
  8016d5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016d9:	83 f8 25             	cmp    $0x25,%eax
  8016dc:	75 e2                	jne    8016c0 <vprintfmt+0x14>
  8016de:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8016e2:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8016e9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016f0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8016f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8016fc:	eb 07                	jmp    801705 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801701:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801705:	8d 47 01             	lea    0x1(%edi),%eax
  801708:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80170b:	0f b6 07             	movzbl (%edi),%eax
  80170e:	0f b6 d0             	movzbl %al,%edx
  801711:	83 e8 23             	sub    $0x23,%eax
  801714:	3c 55                	cmp    $0x55,%al
  801716:	0f 87 d3 03 00 00    	ja     801aef <vprintfmt+0x443>
  80171c:	0f b6 c0             	movzbl %al,%eax
  80171f:	ff 24 85 80 25 80 00 	jmp    *0x802580(,%eax,4)
  801726:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801729:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80172d:	eb d6                	jmp    801705 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80172f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801732:	b8 00 00 00 00       	mov    $0x0,%eax
  801737:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80173a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80173d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801741:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801744:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801747:	83 f9 09             	cmp    $0x9,%ecx
  80174a:	77 3f                	ja     80178b <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80174c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80174f:	eb e9                	jmp    80173a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801751:	8b 45 14             	mov    0x14(%ebp),%eax
  801754:	8b 00                	mov    (%eax),%eax
  801756:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801759:	8b 45 14             	mov    0x14(%ebp),%eax
  80175c:	8d 40 04             	lea    0x4(%eax),%eax
  80175f:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801762:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801765:	eb 2a                	jmp    801791 <vprintfmt+0xe5>
  801767:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80176a:	85 c0                	test   %eax,%eax
  80176c:	ba 00 00 00 00       	mov    $0x0,%edx
  801771:	0f 49 d0             	cmovns %eax,%edx
  801774:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801777:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80177a:	eb 89                	jmp    801705 <vprintfmt+0x59>
  80177c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80177f:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801786:	e9 7a ff ff ff       	jmp    801705 <vprintfmt+0x59>
  80178b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80178e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801791:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801795:	0f 89 6a ff ff ff    	jns    801705 <vprintfmt+0x59>
				width = precision, precision = -1;
  80179b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80179e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017a1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017a8:	e9 58 ff ff ff       	jmp    801705 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017ad:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017b3:	e9 4d ff ff ff       	jmp    801705 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8017bb:	8d 78 04             	lea    0x4(%eax),%edi
  8017be:	83 ec 08             	sub    $0x8,%esp
  8017c1:	53                   	push   %ebx
  8017c2:	ff 30                	pushl  (%eax)
  8017c4:	ff d6                	call   *%esi
			break;
  8017c6:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017c9:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8017cf:	e9 fe fe ff ff       	jmp    8016d2 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8017d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8017d7:	8d 78 04             	lea    0x4(%eax),%edi
  8017da:	8b 00                	mov    (%eax),%eax
  8017dc:	99                   	cltd   
  8017dd:	31 d0                	xor    %edx,%eax
  8017df:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017e1:	83 f8 0f             	cmp    $0xf,%eax
  8017e4:	7f 0b                	jg     8017f1 <vprintfmt+0x145>
  8017e6:	8b 14 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%edx
  8017ed:	85 d2                	test   %edx,%edx
  8017ef:	75 1b                	jne    80180c <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8017f1:	50                   	push   %eax
  8017f2:	68 5b 24 80 00       	push   $0x80245b
  8017f7:	53                   	push   %ebx
  8017f8:	56                   	push   %esi
  8017f9:	e8 91 fe ff ff       	call   80168f <printfmt>
  8017fe:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801801:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801804:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801807:	e9 c6 fe ff ff       	jmp    8016d2 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80180c:	52                   	push   %edx
  80180d:	68 a1 23 80 00       	push   $0x8023a1
  801812:	53                   	push   %ebx
  801813:	56                   	push   %esi
  801814:	e8 76 fe ff ff       	call   80168f <printfmt>
  801819:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80181c:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80181f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801822:	e9 ab fe ff ff       	jmp    8016d2 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801827:	8b 45 14             	mov    0x14(%ebp),%eax
  80182a:	83 c0 04             	add    $0x4,%eax
  80182d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801830:	8b 45 14             	mov    0x14(%ebp),%eax
  801833:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801835:	85 ff                	test   %edi,%edi
  801837:	b8 54 24 80 00       	mov    $0x802454,%eax
  80183c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80183f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801843:	0f 8e 94 00 00 00    	jle    8018dd <vprintfmt+0x231>
  801849:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80184d:	0f 84 98 00 00 00    	je     8018eb <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  801853:	83 ec 08             	sub    $0x8,%esp
  801856:	ff 75 d0             	pushl  -0x30(%ebp)
  801859:	57                   	push   %edi
  80185a:	e8 33 03 00 00       	call   801b92 <strnlen>
  80185f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801862:	29 c1                	sub    %eax,%ecx
  801864:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801867:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80186a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80186e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801871:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801874:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801876:	eb 0f                	jmp    801887 <vprintfmt+0x1db>
					putch(padc, putdat);
  801878:	83 ec 08             	sub    $0x8,%esp
  80187b:	53                   	push   %ebx
  80187c:	ff 75 e0             	pushl  -0x20(%ebp)
  80187f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801881:	83 ef 01             	sub    $0x1,%edi
  801884:	83 c4 10             	add    $0x10,%esp
  801887:	85 ff                	test   %edi,%edi
  801889:	7f ed                	jg     801878 <vprintfmt+0x1cc>
  80188b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80188e:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  801891:	85 c9                	test   %ecx,%ecx
  801893:	b8 00 00 00 00       	mov    $0x0,%eax
  801898:	0f 49 c1             	cmovns %ecx,%eax
  80189b:	29 c1                	sub    %eax,%ecx
  80189d:	89 75 08             	mov    %esi,0x8(%ebp)
  8018a0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018a3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018a6:	89 cb                	mov    %ecx,%ebx
  8018a8:	eb 4d                	jmp    8018f7 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018aa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018ae:	74 1b                	je     8018cb <vprintfmt+0x21f>
  8018b0:	0f be c0             	movsbl %al,%eax
  8018b3:	83 e8 20             	sub    $0x20,%eax
  8018b6:	83 f8 5e             	cmp    $0x5e,%eax
  8018b9:	76 10                	jbe    8018cb <vprintfmt+0x21f>
					putch('?', putdat);
  8018bb:	83 ec 08             	sub    $0x8,%esp
  8018be:	ff 75 0c             	pushl  0xc(%ebp)
  8018c1:	6a 3f                	push   $0x3f
  8018c3:	ff 55 08             	call   *0x8(%ebp)
  8018c6:	83 c4 10             	add    $0x10,%esp
  8018c9:	eb 0d                	jmp    8018d8 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8018cb:	83 ec 08             	sub    $0x8,%esp
  8018ce:	ff 75 0c             	pushl  0xc(%ebp)
  8018d1:	52                   	push   %edx
  8018d2:	ff 55 08             	call   *0x8(%ebp)
  8018d5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018d8:	83 eb 01             	sub    $0x1,%ebx
  8018db:	eb 1a                	jmp    8018f7 <vprintfmt+0x24b>
  8018dd:	89 75 08             	mov    %esi,0x8(%ebp)
  8018e0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018e3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018e6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018e9:	eb 0c                	jmp    8018f7 <vprintfmt+0x24b>
  8018eb:	89 75 08             	mov    %esi,0x8(%ebp)
  8018ee:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018f1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018f4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018f7:	83 c7 01             	add    $0x1,%edi
  8018fa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018fe:	0f be d0             	movsbl %al,%edx
  801901:	85 d2                	test   %edx,%edx
  801903:	74 23                	je     801928 <vprintfmt+0x27c>
  801905:	85 f6                	test   %esi,%esi
  801907:	78 a1                	js     8018aa <vprintfmt+0x1fe>
  801909:	83 ee 01             	sub    $0x1,%esi
  80190c:	79 9c                	jns    8018aa <vprintfmt+0x1fe>
  80190e:	89 df                	mov    %ebx,%edi
  801910:	8b 75 08             	mov    0x8(%ebp),%esi
  801913:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801916:	eb 18                	jmp    801930 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801918:	83 ec 08             	sub    $0x8,%esp
  80191b:	53                   	push   %ebx
  80191c:	6a 20                	push   $0x20
  80191e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801920:	83 ef 01             	sub    $0x1,%edi
  801923:	83 c4 10             	add    $0x10,%esp
  801926:	eb 08                	jmp    801930 <vprintfmt+0x284>
  801928:	89 df                	mov    %ebx,%edi
  80192a:	8b 75 08             	mov    0x8(%ebp),%esi
  80192d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801930:	85 ff                	test   %edi,%edi
  801932:	7f e4                	jg     801918 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801934:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801937:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80193a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80193d:	e9 90 fd ff ff       	jmp    8016d2 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801942:	83 f9 01             	cmp    $0x1,%ecx
  801945:	7e 19                	jle    801960 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  801947:	8b 45 14             	mov    0x14(%ebp),%eax
  80194a:	8b 50 04             	mov    0x4(%eax),%edx
  80194d:	8b 00                	mov    (%eax),%eax
  80194f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801952:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801955:	8b 45 14             	mov    0x14(%ebp),%eax
  801958:	8d 40 08             	lea    0x8(%eax),%eax
  80195b:	89 45 14             	mov    %eax,0x14(%ebp)
  80195e:	eb 38                	jmp    801998 <vprintfmt+0x2ec>
	else if (lflag)
  801960:	85 c9                	test   %ecx,%ecx
  801962:	74 1b                	je     80197f <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  801964:	8b 45 14             	mov    0x14(%ebp),%eax
  801967:	8b 00                	mov    (%eax),%eax
  801969:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80196c:	89 c1                	mov    %eax,%ecx
  80196e:	c1 f9 1f             	sar    $0x1f,%ecx
  801971:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801974:	8b 45 14             	mov    0x14(%ebp),%eax
  801977:	8d 40 04             	lea    0x4(%eax),%eax
  80197a:	89 45 14             	mov    %eax,0x14(%ebp)
  80197d:	eb 19                	jmp    801998 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80197f:	8b 45 14             	mov    0x14(%ebp),%eax
  801982:	8b 00                	mov    (%eax),%eax
  801984:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801987:	89 c1                	mov    %eax,%ecx
  801989:	c1 f9 1f             	sar    $0x1f,%ecx
  80198c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80198f:	8b 45 14             	mov    0x14(%ebp),%eax
  801992:	8d 40 04             	lea    0x4(%eax),%eax
  801995:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801998:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80199b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80199e:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019a3:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019a7:	0f 89 0e 01 00 00    	jns    801abb <vprintfmt+0x40f>
				putch('-', putdat);
  8019ad:	83 ec 08             	sub    $0x8,%esp
  8019b0:	53                   	push   %ebx
  8019b1:	6a 2d                	push   $0x2d
  8019b3:	ff d6                	call   *%esi
				num = -(long long) num;
  8019b5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8019b8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8019bb:	f7 da                	neg    %edx
  8019bd:	83 d1 00             	adc    $0x0,%ecx
  8019c0:	f7 d9                	neg    %ecx
  8019c2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8019ca:	e9 ec 00 00 00       	jmp    801abb <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8019cf:	83 f9 01             	cmp    $0x1,%ecx
  8019d2:	7e 18                	jle    8019ec <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8019d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8019d7:	8b 10                	mov    (%eax),%edx
  8019d9:	8b 48 04             	mov    0x4(%eax),%ecx
  8019dc:	8d 40 08             	lea    0x8(%eax),%eax
  8019df:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8019e2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8019e7:	e9 cf 00 00 00       	jmp    801abb <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8019ec:	85 c9                	test   %ecx,%ecx
  8019ee:	74 1a                	je     801a0a <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8019f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f3:	8b 10                	mov    (%eax),%edx
  8019f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019fa:	8d 40 04             	lea    0x4(%eax),%eax
  8019fd:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801a00:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a05:	e9 b1 00 00 00       	jmp    801abb <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801a0a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a0d:	8b 10                	mov    (%eax),%edx
  801a0f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a14:	8d 40 04             	lea    0x4(%eax),%eax
  801a17:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801a1a:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a1f:	e9 97 00 00 00       	jmp    801abb <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801a24:	83 ec 08             	sub    $0x8,%esp
  801a27:	53                   	push   %ebx
  801a28:	6a 58                	push   $0x58
  801a2a:	ff d6                	call   *%esi
			putch('X', putdat);
  801a2c:	83 c4 08             	add    $0x8,%esp
  801a2f:	53                   	push   %ebx
  801a30:	6a 58                	push   $0x58
  801a32:	ff d6                	call   *%esi
			putch('X', putdat);
  801a34:	83 c4 08             	add    $0x8,%esp
  801a37:	53                   	push   %ebx
  801a38:	6a 58                	push   $0x58
  801a3a:	ff d6                	call   *%esi
			break;
  801a3c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a3f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  801a42:	e9 8b fc ff ff       	jmp    8016d2 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  801a47:	83 ec 08             	sub    $0x8,%esp
  801a4a:	53                   	push   %ebx
  801a4b:	6a 30                	push   $0x30
  801a4d:	ff d6                	call   *%esi
			putch('x', putdat);
  801a4f:	83 c4 08             	add    $0x8,%esp
  801a52:	53                   	push   %ebx
  801a53:	6a 78                	push   $0x78
  801a55:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a57:	8b 45 14             	mov    0x14(%ebp),%eax
  801a5a:	8b 10                	mov    (%eax),%edx
  801a5c:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a61:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a64:	8d 40 04             	lea    0x4(%eax),%eax
  801a67:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a6a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801a6f:	eb 4a                	jmp    801abb <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a71:	83 f9 01             	cmp    $0x1,%ecx
  801a74:	7e 15                	jle    801a8b <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  801a76:	8b 45 14             	mov    0x14(%ebp),%eax
  801a79:	8b 10                	mov    (%eax),%edx
  801a7b:	8b 48 04             	mov    0x4(%eax),%ecx
  801a7e:	8d 40 08             	lea    0x8(%eax),%eax
  801a81:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801a84:	b8 10 00 00 00       	mov    $0x10,%eax
  801a89:	eb 30                	jmp    801abb <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801a8b:	85 c9                	test   %ecx,%ecx
  801a8d:	74 17                	je     801aa6 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  801a8f:	8b 45 14             	mov    0x14(%ebp),%eax
  801a92:	8b 10                	mov    (%eax),%edx
  801a94:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a99:	8d 40 04             	lea    0x4(%eax),%eax
  801a9c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801a9f:	b8 10 00 00 00       	mov    $0x10,%eax
  801aa4:	eb 15                	jmp    801abb <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801aa6:	8b 45 14             	mov    0x14(%ebp),%eax
  801aa9:	8b 10                	mov    (%eax),%edx
  801aab:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ab0:	8d 40 04             	lea    0x4(%eax),%eax
  801ab3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801ab6:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801abb:	83 ec 0c             	sub    $0xc,%esp
  801abe:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801ac2:	57                   	push   %edi
  801ac3:	ff 75 e0             	pushl  -0x20(%ebp)
  801ac6:	50                   	push   %eax
  801ac7:	51                   	push   %ecx
  801ac8:	52                   	push   %edx
  801ac9:	89 da                	mov    %ebx,%edx
  801acb:	89 f0                	mov    %esi,%eax
  801acd:	e8 f1 fa ff ff       	call   8015c3 <printnum>
			break;
  801ad2:	83 c4 20             	add    $0x20,%esp
  801ad5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ad8:	e9 f5 fb ff ff       	jmp    8016d2 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801add:	83 ec 08             	sub    $0x8,%esp
  801ae0:	53                   	push   %ebx
  801ae1:	52                   	push   %edx
  801ae2:	ff d6                	call   *%esi
			break;
  801ae4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ae7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801aea:	e9 e3 fb ff ff       	jmp    8016d2 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801aef:	83 ec 08             	sub    $0x8,%esp
  801af2:	53                   	push   %ebx
  801af3:	6a 25                	push   $0x25
  801af5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801af7:	83 c4 10             	add    $0x10,%esp
  801afa:	eb 03                	jmp    801aff <vprintfmt+0x453>
  801afc:	83 ef 01             	sub    $0x1,%edi
  801aff:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b03:	75 f7                	jne    801afc <vprintfmt+0x450>
  801b05:	e9 c8 fb ff ff       	jmp    8016d2 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0d:	5b                   	pop    %ebx
  801b0e:	5e                   	pop    %esi
  801b0f:	5f                   	pop    %edi
  801b10:	5d                   	pop    %ebp
  801b11:	c3                   	ret    

00801b12 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b12:	55                   	push   %ebp
  801b13:	89 e5                	mov    %esp,%ebp
  801b15:	83 ec 18             	sub    $0x18,%esp
  801b18:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b1e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b21:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b25:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b28:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b2f:	85 c0                	test   %eax,%eax
  801b31:	74 26                	je     801b59 <vsnprintf+0x47>
  801b33:	85 d2                	test   %edx,%edx
  801b35:	7e 22                	jle    801b59 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b37:	ff 75 14             	pushl  0x14(%ebp)
  801b3a:	ff 75 10             	pushl  0x10(%ebp)
  801b3d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b40:	50                   	push   %eax
  801b41:	68 72 16 80 00       	push   $0x801672
  801b46:	e8 61 fb ff ff       	call   8016ac <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b4e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b54:	83 c4 10             	add    $0x10,%esp
  801b57:	eb 05                	jmp    801b5e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b59:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b5e:	c9                   	leave  
  801b5f:	c3                   	ret    

00801b60 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b66:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b69:	50                   	push   %eax
  801b6a:	ff 75 10             	pushl  0x10(%ebp)
  801b6d:	ff 75 0c             	pushl  0xc(%ebp)
  801b70:	ff 75 08             	pushl  0x8(%ebp)
  801b73:	e8 9a ff ff ff       	call   801b12 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b78:	c9                   	leave  
  801b79:	c3                   	ret    

00801b7a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b80:	b8 00 00 00 00       	mov    $0x0,%eax
  801b85:	eb 03                	jmp    801b8a <strlen+0x10>
		n++;
  801b87:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b8a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b8e:	75 f7                	jne    801b87 <strlen+0xd>
		n++;
	return n;
}
  801b90:	5d                   	pop    %ebp
  801b91:	c3                   	ret    

00801b92 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b92:	55                   	push   %ebp
  801b93:	89 e5                	mov    %esp,%ebp
  801b95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b98:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b9b:	ba 00 00 00 00       	mov    $0x0,%edx
  801ba0:	eb 03                	jmp    801ba5 <strnlen+0x13>
		n++;
  801ba2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801ba5:	39 c2                	cmp    %eax,%edx
  801ba7:	74 08                	je     801bb1 <strnlen+0x1f>
  801ba9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801bad:	75 f3                	jne    801ba2 <strnlen+0x10>
  801baf:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801bb1:	5d                   	pop    %ebp
  801bb2:	c3                   	ret    

00801bb3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	53                   	push   %ebx
  801bb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801bba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801bbd:	89 c2                	mov    %eax,%edx
  801bbf:	83 c2 01             	add    $0x1,%edx
  801bc2:	83 c1 01             	add    $0x1,%ecx
  801bc5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801bc9:	88 5a ff             	mov    %bl,-0x1(%edx)
  801bcc:	84 db                	test   %bl,%bl
  801bce:	75 ef                	jne    801bbf <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801bd0:	5b                   	pop    %ebx
  801bd1:	5d                   	pop    %ebp
  801bd2:	c3                   	ret    

00801bd3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801bd3:	55                   	push   %ebp
  801bd4:	89 e5                	mov    %esp,%ebp
  801bd6:	53                   	push   %ebx
  801bd7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801bda:	53                   	push   %ebx
  801bdb:	e8 9a ff ff ff       	call   801b7a <strlen>
  801be0:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801be3:	ff 75 0c             	pushl  0xc(%ebp)
  801be6:	01 d8                	add    %ebx,%eax
  801be8:	50                   	push   %eax
  801be9:	e8 c5 ff ff ff       	call   801bb3 <strcpy>
	return dst;
}
  801bee:	89 d8                	mov    %ebx,%eax
  801bf0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf3:	c9                   	leave  
  801bf4:	c3                   	ret    

00801bf5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bf5:	55                   	push   %ebp
  801bf6:	89 e5                	mov    %esp,%ebp
  801bf8:	56                   	push   %esi
  801bf9:	53                   	push   %ebx
  801bfa:	8b 75 08             	mov    0x8(%ebp),%esi
  801bfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c00:	89 f3                	mov    %esi,%ebx
  801c02:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c05:	89 f2                	mov    %esi,%edx
  801c07:	eb 0f                	jmp    801c18 <strncpy+0x23>
		*dst++ = *src;
  801c09:	83 c2 01             	add    $0x1,%edx
  801c0c:	0f b6 01             	movzbl (%ecx),%eax
  801c0f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c12:	80 39 01             	cmpb   $0x1,(%ecx)
  801c15:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c18:	39 da                	cmp    %ebx,%edx
  801c1a:	75 ed                	jne    801c09 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c1c:	89 f0                	mov    %esi,%eax
  801c1e:	5b                   	pop    %ebx
  801c1f:	5e                   	pop    %esi
  801c20:	5d                   	pop    %ebp
  801c21:	c3                   	ret    

00801c22 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c22:	55                   	push   %ebp
  801c23:	89 e5                	mov    %esp,%ebp
  801c25:	56                   	push   %esi
  801c26:	53                   	push   %ebx
  801c27:	8b 75 08             	mov    0x8(%ebp),%esi
  801c2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c2d:	8b 55 10             	mov    0x10(%ebp),%edx
  801c30:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c32:	85 d2                	test   %edx,%edx
  801c34:	74 21                	je     801c57 <strlcpy+0x35>
  801c36:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c3a:	89 f2                	mov    %esi,%edx
  801c3c:	eb 09                	jmp    801c47 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c3e:	83 c2 01             	add    $0x1,%edx
  801c41:	83 c1 01             	add    $0x1,%ecx
  801c44:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c47:	39 c2                	cmp    %eax,%edx
  801c49:	74 09                	je     801c54 <strlcpy+0x32>
  801c4b:	0f b6 19             	movzbl (%ecx),%ebx
  801c4e:	84 db                	test   %bl,%bl
  801c50:	75 ec                	jne    801c3e <strlcpy+0x1c>
  801c52:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c54:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c57:	29 f0                	sub    %esi,%eax
}
  801c59:	5b                   	pop    %ebx
  801c5a:	5e                   	pop    %esi
  801c5b:	5d                   	pop    %ebp
  801c5c:	c3                   	ret    

00801c5d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c5d:	55                   	push   %ebp
  801c5e:	89 e5                	mov    %esp,%ebp
  801c60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c63:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c66:	eb 06                	jmp    801c6e <strcmp+0x11>
		p++, q++;
  801c68:	83 c1 01             	add    $0x1,%ecx
  801c6b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c6e:	0f b6 01             	movzbl (%ecx),%eax
  801c71:	84 c0                	test   %al,%al
  801c73:	74 04                	je     801c79 <strcmp+0x1c>
  801c75:	3a 02                	cmp    (%edx),%al
  801c77:	74 ef                	je     801c68 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c79:	0f b6 c0             	movzbl %al,%eax
  801c7c:	0f b6 12             	movzbl (%edx),%edx
  801c7f:	29 d0                	sub    %edx,%eax
}
  801c81:	5d                   	pop    %ebp
  801c82:	c3                   	ret    

00801c83 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c83:	55                   	push   %ebp
  801c84:	89 e5                	mov    %esp,%ebp
  801c86:	53                   	push   %ebx
  801c87:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c8d:	89 c3                	mov    %eax,%ebx
  801c8f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c92:	eb 06                	jmp    801c9a <strncmp+0x17>
		n--, p++, q++;
  801c94:	83 c0 01             	add    $0x1,%eax
  801c97:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801c9a:	39 d8                	cmp    %ebx,%eax
  801c9c:	74 15                	je     801cb3 <strncmp+0x30>
  801c9e:	0f b6 08             	movzbl (%eax),%ecx
  801ca1:	84 c9                	test   %cl,%cl
  801ca3:	74 04                	je     801ca9 <strncmp+0x26>
  801ca5:	3a 0a                	cmp    (%edx),%cl
  801ca7:	74 eb                	je     801c94 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801ca9:	0f b6 00             	movzbl (%eax),%eax
  801cac:	0f b6 12             	movzbl (%edx),%edx
  801caf:	29 d0                	sub    %edx,%eax
  801cb1:	eb 05                	jmp    801cb8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801cb3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801cb8:	5b                   	pop    %ebx
  801cb9:	5d                   	pop    %ebp
  801cba:	c3                   	ret    

00801cbb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cc5:	eb 07                	jmp    801cce <strchr+0x13>
		if (*s == c)
  801cc7:	38 ca                	cmp    %cl,%dl
  801cc9:	74 0f                	je     801cda <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801ccb:	83 c0 01             	add    $0x1,%eax
  801cce:	0f b6 10             	movzbl (%eax),%edx
  801cd1:	84 d2                	test   %dl,%dl
  801cd3:	75 f2                	jne    801cc7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801cd5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cda:	5d                   	pop    %ebp
  801cdb:	c3                   	ret    

00801cdc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cdc:	55                   	push   %ebp
  801cdd:	89 e5                	mov    %esp,%ebp
  801cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ce6:	eb 03                	jmp    801ceb <strfind+0xf>
  801ce8:	83 c0 01             	add    $0x1,%eax
  801ceb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cee:	38 ca                	cmp    %cl,%dl
  801cf0:	74 04                	je     801cf6 <strfind+0x1a>
  801cf2:	84 d2                	test   %dl,%dl
  801cf4:	75 f2                	jne    801ce8 <strfind+0xc>
			break;
	return (char *) s;
}
  801cf6:	5d                   	pop    %ebp
  801cf7:	c3                   	ret    

00801cf8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cf8:	55                   	push   %ebp
  801cf9:	89 e5                	mov    %esp,%ebp
  801cfb:	57                   	push   %edi
  801cfc:	56                   	push   %esi
  801cfd:	53                   	push   %ebx
  801cfe:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d01:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d04:	85 c9                	test   %ecx,%ecx
  801d06:	74 36                	je     801d3e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d08:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d0e:	75 28                	jne    801d38 <memset+0x40>
  801d10:	f6 c1 03             	test   $0x3,%cl
  801d13:	75 23                	jne    801d38 <memset+0x40>
		c &= 0xFF;
  801d15:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d19:	89 d3                	mov    %edx,%ebx
  801d1b:	c1 e3 08             	shl    $0x8,%ebx
  801d1e:	89 d6                	mov    %edx,%esi
  801d20:	c1 e6 18             	shl    $0x18,%esi
  801d23:	89 d0                	mov    %edx,%eax
  801d25:	c1 e0 10             	shl    $0x10,%eax
  801d28:	09 f0                	or     %esi,%eax
  801d2a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d2c:	89 d8                	mov    %ebx,%eax
  801d2e:	09 d0                	or     %edx,%eax
  801d30:	c1 e9 02             	shr    $0x2,%ecx
  801d33:	fc                   	cld    
  801d34:	f3 ab                	rep stos %eax,%es:(%edi)
  801d36:	eb 06                	jmp    801d3e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d38:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d3b:	fc                   	cld    
  801d3c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d3e:	89 f8                	mov    %edi,%eax
  801d40:	5b                   	pop    %ebx
  801d41:	5e                   	pop    %esi
  801d42:	5f                   	pop    %edi
  801d43:	5d                   	pop    %ebp
  801d44:	c3                   	ret    

00801d45 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d45:	55                   	push   %ebp
  801d46:	89 e5                	mov    %esp,%ebp
  801d48:	57                   	push   %edi
  801d49:	56                   	push   %esi
  801d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d50:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d53:	39 c6                	cmp    %eax,%esi
  801d55:	73 35                	jae    801d8c <memmove+0x47>
  801d57:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d5a:	39 d0                	cmp    %edx,%eax
  801d5c:	73 2e                	jae    801d8c <memmove+0x47>
		s += n;
		d += n;
  801d5e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d61:	89 d6                	mov    %edx,%esi
  801d63:	09 fe                	or     %edi,%esi
  801d65:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d6b:	75 13                	jne    801d80 <memmove+0x3b>
  801d6d:	f6 c1 03             	test   $0x3,%cl
  801d70:	75 0e                	jne    801d80 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d72:	83 ef 04             	sub    $0x4,%edi
  801d75:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d78:	c1 e9 02             	shr    $0x2,%ecx
  801d7b:	fd                   	std    
  801d7c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d7e:	eb 09                	jmp    801d89 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d80:	83 ef 01             	sub    $0x1,%edi
  801d83:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d86:	fd                   	std    
  801d87:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d89:	fc                   	cld    
  801d8a:	eb 1d                	jmp    801da9 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d8c:	89 f2                	mov    %esi,%edx
  801d8e:	09 c2                	or     %eax,%edx
  801d90:	f6 c2 03             	test   $0x3,%dl
  801d93:	75 0f                	jne    801da4 <memmove+0x5f>
  801d95:	f6 c1 03             	test   $0x3,%cl
  801d98:	75 0a                	jne    801da4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801d9a:	c1 e9 02             	shr    $0x2,%ecx
  801d9d:	89 c7                	mov    %eax,%edi
  801d9f:	fc                   	cld    
  801da0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801da2:	eb 05                	jmp    801da9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801da4:	89 c7                	mov    %eax,%edi
  801da6:	fc                   	cld    
  801da7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801da9:	5e                   	pop    %esi
  801daa:	5f                   	pop    %edi
  801dab:	5d                   	pop    %ebp
  801dac:	c3                   	ret    

00801dad <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801dad:	55                   	push   %ebp
  801dae:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801db0:	ff 75 10             	pushl  0x10(%ebp)
  801db3:	ff 75 0c             	pushl  0xc(%ebp)
  801db6:	ff 75 08             	pushl  0x8(%ebp)
  801db9:	e8 87 ff ff ff       	call   801d45 <memmove>
}
  801dbe:	c9                   	leave  
  801dbf:	c3                   	ret    

00801dc0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	56                   	push   %esi
  801dc4:	53                   	push   %ebx
  801dc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dcb:	89 c6                	mov    %eax,%esi
  801dcd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dd0:	eb 1a                	jmp    801dec <memcmp+0x2c>
		if (*s1 != *s2)
  801dd2:	0f b6 08             	movzbl (%eax),%ecx
  801dd5:	0f b6 1a             	movzbl (%edx),%ebx
  801dd8:	38 d9                	cmp    %bl,%cl
  801dda:	74 0a                	je     801de6 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801ddc:	0f b6 c1             	movzbl %cl,%eax
  801ddf:	0f b6 db             	movzbl %bl,%ebx
  801de2:	29 d8                	sub    %ebx,%eax
  801de4:	eb 0f                	jmp    801df5 <memcmp+0x35>
		s1++, s2++;
  801de6:	83 c0 01             	add    $0x1,%eax
  801de9:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dec:	39 f0                	cmp    %esi,%eax
  801dee:	75 e2                	jne    801dd2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801df0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801df5:	5b                   	pop    %ebx
  801df6:	5e                   	pop    %esi
  801df7:	5d                   	pop    %ebp
  801df8:	c3                   	ret    

00801df9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801df9:	55                   	push   %ebp
  801dfa:	89 e5                	mov    %esp,%ebp
  801dfc:	53                   	push   %ebx
  801dfd:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e00:	89 c1                	mov    %eax,%ecx
  801e02:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e05:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e09:	eb 0a                	jmp    801e15 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e0b:	0f b6 10             	movzbl (%eax),%edx
  801e0e:	39 da                	cmp    %ebx,%edx
  801e10:	74 07                	je     801e19 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e12:	83 c0 01             	add    $0x1,%eax
  801e15:	39 c8                	cmp    %ecx,%eax
  801e17:	72 f2                	jb     801e0b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e19:	5b                   	pop    %ebx
  801e1a:	5d                   	pop    %ebp
  801e1b:	c3                   	ret    

00801e1c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	57                   	push   %edi
  801e20:	56                   	push   %esi
  801e21:	53                   	push   %ebx
  801e22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e25:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e28:	eb 03                	jmp    801e2d <strtol+0x11>
		s++;
  801e2a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e2d:	0f b6 01             	movzbl (%ecx),%eax
  801e30:	3c 20                	cmp    $0x20,%al
  801e32:	74 f6                	je     801e2a <strtol+0xe>
  801e34:	3c 09                	cmp    $0x9,%al
  801e36:	74 f2                	je     801e2a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e38:	3c 2b                	cmp    $0x2b,%al
  801e3a:	75 0a                	jne    801e46 <strtol+0x2a>
		s++;
  801e3c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e3f:	bf 00 00 00 00       	mov    $0x0,%edi
  801e44:	eb 11                	jmp    801e57 <strtol+0x3b>
  801e46:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e4b:	3c 2d                	cmp    $0x2d,%al
  801e4d:	75 08                	jne    801e57 <strtol+0x3b>
		s++, neg = 1;
  801e4f:	83 c1 01             	add    $0x1,%ecx
  801e52:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e57:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e5d:	75 15                	jne    801e74 <strtol+0x58>
  801e5f:	80 39 30             	cmpb   $0x30,(%ecx)
  801e62:	75 10                	jne    801e74 <strtol+0x58>
  801e64:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e68:	75 7c                	jne    801ee6 <strtol+0xca>
		s += 2, base = 16;
  801e6a:	83 c1 02             	add    $0x2,%ecx
  801e6d:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e72:	eb 16                	jmp    801e8a <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e74:	85 db                	test   %ebx,%ebx
  801e76:	75 12                	jne    801e8a <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e78:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e7d:	80 39 30             	cmpb   $0x30,(%ecx)
  801e80:	75 08                	jne    801e8a <strtol+0x6e>
		s++, base = 8;
  801e82:	83 c1 01             	add    $0x1,%ecx
  801e85:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e8a:	b8 00 00 00 00       	mov    $0x0,%eax
  801e8f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801e92:	0f b6 11             	movzbl (%ecx),%edx
  801e95:	8d 72 d0             	lea    -0x30(%edx),%esi
  801e98:	89 f3                	mov    %esi,%ebx
  801e9a:	80 fb 09             	cmp    $0x9,%bl
  801e9d:	77 08                	ja     801ea7 <strtol+0x8b>
			dig = *s - '0';
  801e9f:	0f be d2             	movsbl %dl,%edx
  801ea2:	83 ea 30             	sub    $0x30,%edx
  801ea5:	eb 22                	jmp    801ec9 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801ea7:	8d 72 9f             	lea    -0x61(%edx),%esi
  801eaa:	89 f3                	mov    %esi,%ebx
  801eac:	80 fb 19             	cmp    $0x19,%bl
  801eaf:	77 08                	ja     801eb9 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801eb1:	0f be d2             	movsbl %dl,%edx
  801eb4:	83 ea 57             	sub    $0x57,%edx
  801eb7:	eb 10                	jmp    801ec9 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801eb9:	8d 72 bf             	lea    -0x41(%edx),%esi
  801ebc:	89 f3                	mov    %esi,%ebx
  801ebe:	80 fb 19             	cmp    $0x19,%bl
  801ec1:	77 16                	ja     801ed9 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801ec3:	0f be d2             	movsbl %dl,%edx
  801ec6:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801ec9:	3b 55 10             	cmp    0x10(%ebp),%edx
  801ecc:	7d 0b                	jge    801ed9 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801ece:	83 c1 01             	add    $0x1,%ecx
  801ed1:	0f af 45 10          	imul   0x10(%ebp),%eax
  801ed5:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801ed7:	eb b9                	jmp    801e92 <strtol+0x76>

	if (endptr)
  801ed9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801edd:	74 0d                	je     801eec <strtol+0xd0>
		*endptr = (char *) s;
  801edf:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ee2:	89 0e                	mov    %ecx,(%esi)
  801ee4:	eb 06                	jmp    801eec <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ee6:	85 db                	test   %ebx,%ebx
  801ee8:	74 98                	je     801e82 <strtol+0x66>
  801eea:	eb 9e                	jmp    801e8a <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801eec:	89 c2                	mov    %eax,%edx
  801eee:	f7 da                	neg    %edx
  801ef0:	85 ff                	test   %edi,%edi
  801ef2:	0f 45 c2             	cmovne %edx,%eax
}
  801ef5:	5b                   	pop    %ebx
  801ef6:	5e                   	pop    %esi
  801ef7:	5f                   	pop    %edi
  801ef8:	5d                   	pop    %ebp
  801ef9:	c3                   	ret    

00801efa <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801efa:	55                   	push   %ebp
  801efb:	89 e5                	mov    %esp,%ebp
  801efd:	56                   	push   %esi
  801efe:	53                   	push   %ebx
  801eff:	8b 75 08             	mov    0x8(%ebp),%esi
  801f02:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f05:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801f08:	85 c0                	test   %eax,%eax
  801f0a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f0f:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801f12:	83 ec 0c             	sub    $0xc,%esp
  801f15:	50                   	push   %eax
  801f16:	e8 ea e3 ff ff       	call   800305 <sys_ipc_recv>
  801f1b:	83 c4 10             	add    $0x10,%esp
  801f1e:	85 c0                	test   %eax,%eax
  801f20:	79 16                	jns    801f38 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801f22:	85 f6                	test   %esi,%esi
  801f24:	74 06                	je     801f2c <ipc_recv+0x32>
            *from_env_store = 0;
  801f26:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801f2c:	85 db                	test   %ebx,%ebx
  801f2e:	74 2c                	je     801f5c <ipc_recv+0x62>
            *perm_store = 0;
  801f30:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f36:	eb 24                	jmp    801f5c <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801f38:	85 f6                	test   %esi,%esi
  801f3a:	74 0a                	je     801f46 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801f3c:	a1 08 40 80 00       	mov    0x804008,%eax
  801f41:	8b 40 74             	mov    0x74(%eax),%eax
  801f44:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801f46:	85 db                	test   %ebx,%ebx
  801f48:	74 0a                	je     801f54 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801f4a:	a1 08 40 80 00       	mov    0x804008,%eax
  801f4f:	8b 40 78             	mov    0x78(%eax),%eax
  801f52:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801f54:	a1 08 40 80 00       	mov    0x804008,%eax
  801f59:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801f5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f5f:	5b                   	pop    %ebx
  801f60:	5e                   	pop    %esi
  801f61:	5d                   	pop    %ebp
  801f62:	c3                   	ret    

00801f63 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f63:	55                   	push   %ebp
  801f64:	89 e5                	mov    %esp,%ebp
  801f66:	57                   	push   %edi
  801f67:	56                   	push   %esi
  801f68:	53                   	push   %ebx
  801f69:	83 ec 0c             	sub    $0xc,%esp
  801f6c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f6f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f72:	8b 45 10             	mov    0x10(%ebp),%eax
  801f75:	85 c0                	test   %eax,%eax
  801f77:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801f7c:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801f7f:	eb 1c                	jmp    801f9d <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801f81:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f84:	74 12                	je     801f98 <ipc_send+0x35>
  801f86:	50                   	push   %eax
  801f87:	68 40 27 80 00       	push   $0x802740
  801f8c:	6a 3b                	push   $0x3b
  801f8e:	68 56 27 80 00       	push   $0x802756
  801f93:	e8 3e f5 ff ff       	call   8014d6 <_panic>
		sys_yield();
  801f98:	e8 99 e1 ff ff       	call   800136 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801f9d:	ff 75 14             	pushl  0x14(%ebp)
  801fa0:	53                   	push   %ebx
  801fa1:	56                   	push   %esi
  801fa2:	57                   	push   %edi
  801fa3:	e8 3a e3 ff ff       	call   8002e2 <sys_ipc_try_send>
  801fa8:	83 c4 10             	add    $0x10,%esp
  801fab:	85 c0                	test   %eax,%eax
  801fad:	78 d2                	js     801f81 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801faf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb2:	5b                   	pop    %ebx
  801fb3:	5e                   	pop    %esi
  801fb4:	5f                   	pop    %edi
  801fb5:	5d                   	pop    %ebp
  801fb6:	c3                   	ret    

00801fb7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fb7:	55                   	push   %ebp
  801fb8:	89 e5                	mov    %esp,%ebp
  801fba:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fbd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fc2:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fc5:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fcb:	8b 52 50             	mov    0x50(%edx),%edx
  801fce:	39 ca                	cmp    %ecx,%edx
  801fd0:	75 0d                	jne    801fdf <ipc_find_env+0x28>
			return envs[i].env_id;
  801fd2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fd5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fda:	8b 40 48             	mov    0x48(%eax),%eax
  801fdd:	eb 0f                	jmp    801fee <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fdf:	83 c0 01             	add    $0x1,%eax
  801fe2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fe7:	75 d9                	jne    801fc2 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fe9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801fee:	5d                   	pop    %ebp
  801fef:	c3                   	ret    

00801ff0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ff6:	89 d0                	mov    %edx,%eax
  801ff8:	c1 e8 16             	shr    $0x16,%eax
  801ffb:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802002:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802007:	f6 c1 01             	test   $0x1,%cl
  80200a:	74 1d                	je     802029 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80200c:	c1 ea 0c             	shr    $0xc,%edx
  80200f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802016:	f6 c2 01             	test   $0x1,%dl
  802019:	74 0e                	je     802029 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80201b:	c1 ea 0c             	shr    $0xc,%edx
  80201e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802025:	ef 
  802026:	0f b7 c0             	movzwl %ax,%eax
}
  802029:	5d                   	pop    %ebp
  80202a:	c3                   	ret    
  80202b:	66 90                	xchg   %ax,%ax
  80202d:	66 90                	xchg   %ax,%ax
  80202f:	90                   	nop

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
