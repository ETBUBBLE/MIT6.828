
obj/user/buggyhello.debug：     文件格式 elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 65 00 00 00       	call   8000a7 <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800052:	e8 ce 00 00 00       	call   800125 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 40 80 00       	mov    %eax,0x804004

    // save the name of the program so that panic() can use it
    if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
        binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800093:	e8 87 04 00 00       	call   80051f <close_all>
	sys_env_destroy(0);
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	6a 00                	push   $0x0
  80009d:	e8 42 00 00 00       	call   8000e4 <sys_env_destroy>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	89 c6                	mov    %eax,%esi
  8000be:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_cgetc>:

int
sys_cgetc(void)
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
  8000cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d5:	89 d1                	mov    %edx,%ecx
  8000d7:	89 d3                	mov    %edx,%ebx
  8000d9:	89 d7                	mov    %edx,%edi
  8000db:	89 d6                	mov    %edx,%esi
  8000dd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	57                   	push   %edi
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	89 cb                	mov    %ecx,%ebx
  8000fc:	89 cf                	mov    %ecx,%edi
  8000fe:	89 ce                	mov    %ecx,%esi
  800100:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800102:	85 c0                	test   %eax,%eax
  800104:	7e 17                	jle    80011d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	50                   	push   %eax
  80010a:	6a 03                	push   $0x3
  80010c:	68 4a 1e 80 00       	push   $0x801e4a
  800111:	6a 23                	push   $0x23
  800113:	68 67 1e 80 00       	push   $0x801e67
  800118:	e8 21 0f 00 00       	call   80103e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5f                   	pop    %edi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 02 00 00 00       	mov    $0x2,%eax
  800135:	89 d1                	mov    %edx,%ecx
  800137:	89 d3                	mov    %edx,%ebx
  800139:	89 d7                	mov    %edx,%edi
  80013b:	89 d6                	mov    %edx,%esi
  80013d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_yield>:

void
sys_yield(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016c:	be 00 00 00 00       	mov    $0x0,%esi
  800171:	b8 04 00 00 00       	mov    $0x4,%eax
  800176:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	89 f7                	mov    %esi,%edi
  800181:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	7e 17                	jle    80019e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	50                   	push   %eax
  80018b:	6a 04                	push   $0x4
  80018d:	68 4a 1e 80 00       	push   $0x801e4a
  800192:	6a 23                	push   $0x23
  800194:	68 67 1e 80 00       	push   $0x801e67
  800199:	e8 a0 0e 00 00       	call   80103e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001af:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	7e 17                	jle    8001e0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	50                   	push   %eax
  8001cd:	6a 05                	push   $0x5
  8001cf:	68 4a 1e 80 00       	push   $0x801e4a
  8001d4:	6a 23                	push   $0x23
  8001d6:	68 67 1e 80 00       	push   $0x801e67
  8001db:	e8 5e 0e 00 00       	call   80103e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e3:	5b                   	pop    %ebx
  8001e4:	5e                   	pop    %esi
  8001e5:	5f                   	pop    %edi
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    

008001e8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800201:	89 df                	mov    %ebx,%edi
  800203:	89 de                	mov    %ebx,%esi
  800205:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800207:	85 c0                	test   %eax,%eax
  800209:	7e 17                	jle    800222 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020b:	83 ec 0c             	sub    $0xc,%esp
  80020e:	50                   	push   %eax
  80020f:	6a 06                	push   $0x6
  800211:	68 4a 1e 80 00       	push   $0x801e4a
  800216:	6a 23                	push   $0x23
  800218:	68 67 1e 80 00       	push   $0x801e67
  80021d:	e8 1c 0e 00 00       	call   80103e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800225:	5b                   	pop    %ebx
  800226:	5e                   	pop    %esi
  800227:	5f                   	pop    %edi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	b8 08 00 00 00       	mov    $0x8,%eax
  80023d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800240:	8b 55 08             	mov    0x8(%ebp),%edx
  800243:	89 df                	mov    %ebx,%edi
  800245:	89 de                	mov    %ebx,%esi
  800247:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800249:	85 c0                	test   %eax,%eax
  80024b:	7e 17                	jle    800264 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024d:	83 ec 0c             	sub    $0xc,%esp
  800250:	50                   	push   %eax
  800251:	6a 08                	push   $0x8
  800253:	68 4a 1e 80 00       	push   $0x801e4a
  800258:	6a 23                	push   $0x23
  80025a:	68 67 1e 80 00       	push   $0x801e67
  80025f:	e8 da 0d 00 00       	call   80103e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800275:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027a:	b8 09 00 00 00       	mov    $0x9,%eax
  80027f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800282:	8b 55 08             	mov    0x8(%ebp),%edx
  800285:	89 df                	mov    %ebx,%edi
  800287:	89 de                	mov    %ebx,%esi
  800289:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028b:	85 c0                	test   %eax,%eax
  80028d:	7e 17                	jle    8002a6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028f:	83 ec 0c             	sub    $0xc,%esp
  800292:	50                   	push   %eax
  800293:	6a 09                	push   $0x9
  800295:	68 4a 1e 80 00       	push   $0x801e4a
  80029a:	6a 23                	push   $0x23
  80029c:	68 67 1e 80 00       	push   $0x801e67
  8002a1:	e8 98 0d 00 00       	call   80103e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5e                   	pop    %esi
  8002ab:	5f                   	pop    %edi
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c7:	89 df                	mov    %ebx,%edi
  8002c9:	89 de                	mov    %ebx,%esi
  8002cb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	7e 17                	jle    8002e8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d1:	83 ec 0c             	sub    $0xc,%esp
  8002d4:	50                   	push   %eax
  8002d5:	6a 0a                	push   $0xa
  8002d7:	68 4a 1e 80 00       	push   $0x801e4a
  8002dc:	6a 23                	push   $0x23
  8002de:	68 67 1e 80 00       	push   $0x801e67
  8002e3:	e8 56 0d 00 00       	call   80103e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f6:	be 00 00 00 00       	mov    $0x0,%esi
  8002fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800309:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800321:	b8 0d 00 00 00       	mov    $0xd,%eax
  800326:	8b 55 08             	mov    0x8(%ebp),%edx
  800329:	89 cb                	mov    %ecx,%ebx
  80032b:	89 cf                	mov    %ecx,%edi
  80032d:	89 ce                	mov    %ecx,%esi
  80032f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800331:	85 c0                	test   %eax,%eax
  800333:	7e 17                	jle    80034c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	50                   	push   %eax
  800339:	6a 0d                	push   $0xd
  80033b:	68 4a 1e 80 00       	push   $0x801e4a
  800340:	6a 23                	push   $0x23
  800342:	68 67 1e 80 00       	push   $0x801e67
  800347:	e8 f2 0c 00 00       	call   80103e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800357:	8b 45 08             	mov    0x8(%ebp),%eax
  80035a:	05 00 00 00 30       	add    $0x30000000,%eax
  80035f:	c1 e8 0c             	shr    $0xc,%eax
}
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800367:	8b 45 08             	mov    0x8(%ebp),%eax
  80036a:	05 00 00 00 30       	add    $0x30000000,%eax
  80036f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800374:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800381:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800386:	89 c2                	mov    %eax,%edx
  800388:	c1 ea 16             	shr    $0x16,%edx
  80038b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800392:	f6 c2 01             	test   $0x1,%dl
  800395:	74 11                	je     8003a8 <fd_alloc+0x2d>
  800397:	89 c2                	mov    %eax,%edx
  800399:	c1 ea 0c             	shr    $0xc,%edx
  80039c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a3:	f6 c2 01             	test   $0x1,%dl
  8003a6:	75 09                	jne    8003b1 <fd_alloc+0x36>
			*fd_store = fd;
  8003a8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8003af:	eb 17                	jmp    8003c8 <fd_alloc+0x4d>
  8003b1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003bb:	75 c9                	jne    800386 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003bd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003c3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d0:	83 f8 1f             	cmp    $0x1f,%eax
  8003d3:	77 36                	ja     80040b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d5:	c1 e0 0c             	shl    $0xc,%eax
  8003d8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003dd:	89 c2                	mov    %eax,%edx
  8003df:	c1 ea 16             	shr    $0x16,%edx
  8003e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e9:	f6 c2 01             	test   $0x1,%dl
  8003ec:	74 24                	je     800412 <fd_lookup+0x48>
  8003ee:	89 c2                	mov    %eax,%edx
  8003f0:	c1 ea 0c             	shr    $0xc,%edx
  8003f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fa:	f6 c2 01             	test   $0x1,%dl
  8003fd:	74 1a                	je     800419 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800402:	89 02                	mov    %eax,(%edx)
	return 0;
  800404:	b8 00 00 00 00       	mov    $0x0,%eax
  800409:	eb 13                	jmp    80041e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800410:	eb 0c                	jmp    80041e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb 05                	jmp    80041e <fd_lookup+0x54>
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80041e:	5d                   	pop    %ebp
  80041f:	c3                   	ret    

00800420 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	83 ec 08             	sub    $0x8,%esp
  800426:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800429:	ba f4 1e 80 00       	mov    $0x801ef4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80042e:	eb 13                	jmp    800443 <dev_lookup+0x23>
  800430:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800433:	39 08                	cmp    %ecx,(%eax)
  800435:	75 0c                	jne    800443 <dev_lookup+0x23>
			*dev = devtab[i];
  800437:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043c:	b8 00 00 00 00       	mov    $0x0,%eax
  800441:	eb 2e                	jmp    800471 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800443:	8b 02                	mov    (%edx),%eax
  800445:	85 c0                	test   %eax,%eax
  800447:	75 e7                	jne    800430 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800449:	a1 04 40 80 00       	mov    0x804004,%eax
  80044e:	8b 40 48             	mov    0x48(%eax),%eax
  800451:	83 ec 04             	sub    $0x4,%esp
  800454:	51                   	push   %ecx
  800455:	50                   	push   %eax
  800456:	68 78 1e 80 00       	push   $0x801e78
  80045b:	e8 b7 0c 00 00       	call   801117 <cprintf>
	*dev = 0;
  800460:	8b 45 0c             	mov    0xc(%ebp),%eax
  800463:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800469:	83 c4 10             	add    $0x10,%esp
  80046c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800471:	c9                   	leave  
  800472:	c3                   	ret    

00800473 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800473:	55                   	push   %ebp
  800474:	89 e5                	mov    %esp,%ebp
  800476:	56                   	push   %esi
  800477:	53                   	push   %ebx
  800478:	83 ec 10             	sub    $0x10,%esp
  80047b:	8b 75 08             	mov    0x8(%ebp),%esi
  80047e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800481:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800484:	50                   	push   %eax
  800485:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048b:	c1 e8 0c             	shr    $0xc,%eax
  80048e:	50                   	push   %eax
  80048f:	e8 36 ff ff ff       	call   8003ca <fd_lookup>
  800494:	83 c4 08             	add    $0x8,%esp
  800497:	85 c0                	test   %eax,%eax
  800499:	78 05                	js     8004a0 <fd_close+0x2d>
	    || fd != fd2)
  80049b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80049e:	74 0c                	je     8004ac <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a0:	84 db                	test   %bl,%bl
  8004a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a7:	0f 44 c2             	cmove  %edx,%eax
  8004aa:	eb 41                	jmp    8004ed <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b2:	50                   	push   %eax
  8004b3:	ff 36                	pushl  (%esi)
  8004b5:	e8 66 ff ff ff       	call   800420 <dev_lookup>
  8004ba:	89 c3                	mov    %eax,%ebx
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	78 1a                	js     8004dd <fd_close+0x6a>
		if (dev->dev_close)
  8004c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004c9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ce:	85 c0                	test   %eax,%eax
  8004d0:	74 0b                	je     8004dd <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d2:	83 ec 0c             	sub    $0xc,%esp
  8004d5:	56                   	push   %esi
  8004d6:	ff d0                	call   *%eax
  8004d8:	89 c3                	mov    %eax,%ebx
  8004da:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	56                   	push   %esi
  8004e1:	6a 00                	push   $0x0
  8004e3:	e8 00 fd ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	89 d8                	mov    %ebx,%eax
}
  8004ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f0:	5b                   	pop    %ebx
  8004f1:	5e                   	pop    %esi
  8004f2:	5d                   	pop    %ebp
  8004f3:	c3                   	ret    

008004f4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004fd:	50                   	push   %eax
  8004fe:	ff 75 08             	pushl  0x8(%ebp)
  800501:	e8 c4 fe ff ff       	call   8003ca <fd_lookup>
  800506:	83 c4 08             	add    $0x8,%esp
  800509:	85 c0                	test   %eax,%eax
  80050b:	78 10                	js     80051d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	6a 01                	push   $0x1
  800512:	ff 75 f4             	pushl  -0xc(%ebp)
  800515:	e8 59 ff ff ff       	call   800473 <fd_close>
  80051a:	83 c4 10             	add    $0x10,%esp
}
  80051d:	c9                   	leave  
  80051e:	c3                   	ret    

0080051f <close_all>:

void
close_all(void)
{
  80051f:	55                   	push   %ebp
  800520:	89 e5                	mov    %esp,%ebp
  800522:	53                   	push   %ebx
  800523:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800526:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052b:	83 ec 0c             	sub    $0xc,%esp
  80052e:	53                   	push   %ebx
  80052f:	e8 c0 ff ff ff       	call   8004f4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800534:	83 c3 01             	add    $0x1,%ebx
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	83 fb 20             	cmp    $0x20,%ebx
  80053d:	75 ec                	jne    80052b <close_all+0xc>
		close(i);
}
  80053f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800542:	c9                   	leave  
  800543:	c3                   	ret    

00800544 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800544:	55                   	push   %ebp
  800545:	89 e5                	mov    %esp,%ebp
  800547:	57                   	push   %edi
  800548:	56                   	push   %esi
  800549:	53                   	push   %ebx
  80054a:	83 ec 2c             	sub    $0x2c,%esp
  80054d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800550:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800553:	50                   	push   %eax
  800554:	ff 75 08             	pushl  0x8(%ebp)
  800557:	e8 6e fe ff ff       	call   8003ca <fd_lookup>
  80055c:	83 c4 08             	add    $0x8,%esp
  80055f:	85 c0                	test   %eax,%eax
  800561:	0f 88 c1 00 00 00    	js     800628 <dup+0xe4>
		return r;
	close(newfdnum);
  800567:	83 ec 0c             	sub    $0xc,%esp
  80056a:	56                   	push   %esi
  80056b:	e8 84 ff ff ff       	call   8004f4 <close>

	newfd = INDEX2FD(newfdnum);
  800570:	89 f3                	mov    %esi,%ebx
  800572:	c1 e3 0c             	shl    $0xc,%ebx
  800575:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80057b:	83 c4 04             	add    $0x4,%esp
  80057e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800581:	e8 de fd ff ff       	call   800364 <fd2data>
  800586:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800588:	89 1c 24             	mov    %ebx,(%esp)
  80058b:	e8 d4 fd ff ff       	call   800364 <fd2data>
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800596:	89 f8                	mov    %edi,%eax
  800598:	c1 e8 16             	shr    $0x16,%eax
  80059b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a2:	a8 01                	test   $0x1,%al
  8005a4:	74 37                	je     8005dd <dup+0x99>
  8005a6:	89 f8                	mov    %edi,%eax
  8005a8:	c1 e8 0c             	shr    $0xc,%eax
  8005ab:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b2:	f6 c2 01             	test   $0x1,%dl
  8005b5:	74 26                	je     8005dd <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005b7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005be:	83 ec 0c             	sub    $0xc,%esp
  8005c1:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005ca:	6a 00                	push   $0x0
  8005cc:	57                   	push   %edi
  8005cd:	6a 00                	push   $0x0
  8005cf:	e8 d2 fb ff ff       	call   8001a6 <sys_page_map>
  8005d4:	89 c7                	mov    %eax,%edi
  8005d6:	83 c4 20             	add    $0x20,%esp
  8005d9:	85 c0                	test   %eax,%eax
  8005db:	78 2e                	js     80060b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e0:	89 d0                	mov    %edx,%eax
  8005e2:	c1 e8 0c             	shr    $0xc,%eax
  8005e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ec:	83 ec 0c             	sub    $0xc,%esp
  8005ef:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f4:	50                   	push   %eax
  8005f5:	53                   	push   %ebx
  8005f6:	6a 00                	push   $0x0
  8005f8:	52                   	push   %edx
  8005f9:	6a 00                	push   $0x0
  8005fb:	e8 a6 fb ff ff       	call   8001a6 <sys_page_map>
  800600:	89 c7                	mov    %eax,%edi
  800602:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800605:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800607:	85 ff                	test   %edi,%edi
  800609:	79 1d                	jns    800628 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	53                   	push   %ebx
  80060f:	6a 00                	push   $0x0
  800611:	e8 d2 fb ff ff       	call   8001e8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800616:	83 c4 08             	add    $0x8,%esp
  800619:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061c:	6a 00                	push   $0x0
  80061e:	e8 c5 fb ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800623:	83 c4 10             	add    $0x10,%esp
  800626:	89 f8                	mov    %edi,%eax
}
  800628:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062b:	5b                   	pop    %ebx
  80062c:	5e                   	pop    %esi
  80062d:	5f                   	pop    %edi
  80062e:	5d                   	pop    %ebp
  80062f:	c3                   	ret    

00800630 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800630:	55                   	push   %ebp
  800631:	89 e5                	mov    %esp,%ebp
  800633:	53                   	push   %ebx
  800634:	83 ec 14             	sub    $0x14,%esp
  800637:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80063d:	50                   	push   %eax
  80063e:	53                   	push   %ebx
  80063f:	e8 86 fd ff ff       	call   8003ca <fd_lookup>
  800644:	83 c4 08             	add    $0x8,%esp
  800647:	89 c2                	mov    %eax,%edx
  800649:	85 c0                	test   %eax,%eax
  80064b:	78 6d                	js     8006ba <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800653:	50                   	push   %eax
  800654:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800657:	ff 30                	pushl  (%eax)
  800659:	e8 c2 fd ff ff       	call   800420 <dev_lookup>
  80065e:	83 c4 10             	add    $0x10,%esp
  800661:	85 c0                	test   %eax,%eax
  800663:	78 4c                	js     8006b1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800665:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800668:	8b 42 08             	mov    0x8(%edx),%eax
  80066b:	83 e0 03             	and    $0x3,%eax
  80066e:	83 f8 01             	cmp    $0x1,%eax
  800671:	75 21                	jne    800694 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800673:	a1 04 40 80 00       	mov    0x804004,%eax
  800678:	8b 40 48             	mov    0x48(%eax),%eax
  80067b:	83 ec 04             	sub    $0x4,%esp
  80067e:	53                   	push   %ebx
  80067f:	50                   	push   %eax
  800680:	68 b9 1e 80 00       	push   $0x801eb9
  800685:	e8 8d 0a 00 00       	call   801117 <cprintf>
		return -E_INVAL;
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800692:	eb 26                	jmp    8006ba <read+0x8a>
	}
	if (!dev->dev_read)
  800694:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800697:	8b 40 08             	mov    0x8(%eax),%eax
  80069a:	85 c0                	test   %eax,%eax
  80069c:	74 17                	je     8006b5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80069e:	83 ec 04             	sub    $0x4,%esp
  8006a1:	ff 75 10             	pushl  0x10(%ebp)
  8006a4:	ff 75 0c             	pushl  0xc(%ebp)
  8006a7:	52                   	push   %edx
  8006a8:	ff d0                	call   *%eax
  8006aa:	89 c2                	mov    %eax,%edx
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	eb 09                	jmp    8006ba <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b1:	89 c2                	mov    %eax,%edx
  8006b3:	eb 05                	jmp    8006ba <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ba:	89 d0                	mov    %edx,%eax
  8006bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006bf:	c9                   	leave  
  8006c0:	c3                   	ret    

008006c1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c1:	55                   	push   %ebp
  8006c2:	89 e5                	mov    %esp,%ebp
  8006c4:	57                   	push   %edi
  8006c5:	56                   	push   %esi
  8006c6:	53                   	push   %ebx
  8006c7:	83 ec 0c             	sub    $0xc,%esp
  8006ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d5:	eb 21                	jmp    8006f8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d7:	83 ec 04             	sub    $0x4,%esp
  8006da:	89 f0                	mov    %esi,%eax
  8006dc:	29 d8                	sub    %ebx,%eax
  8006de:	50                   	push   %eax
  8006df:	89 d8                	mov    %ebx,%eax
  8006e1:	03 45 0c             	add    0xc(%ebp),%eax
  8006e4:	50                   	push   %eax
  8006e5:	57                   	push   %edi
  8006e6:	e8 45 ff ff ff       	call   800630 <read>
		if (m < 0)
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	85 c0                	test   %eax,%eax
  8006f0:	78 10                	js     800702 <readn+0x41>
			return m;
		if (m == 0)
  8006f2:	85 c0                	test   %eax,%eax
  8006f4:	74 0a                	je     800700 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f6:	01 c3                	add    %eax,%ebx
  8006f8:	39 f3                	cmp    %esi,%ebx
  8006fa:	72 db                	jb     8006d7 <readn+0x16>
  8006fc:	89 d8                	mov    %ebx,%eax
  8006fe:	eb 02                	jmp    800702 <readn+0x41>
  800700:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800702:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800705:	5b                   	pop    %ebx
  800706:	5e                   	pop    %esi
  800707:	5f                   	pop    %edi
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	53                   	push   %ebx
  80070e:	83 ec 14             	sub    $0x14,%esp
  800711:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800714:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800717:	50                   	push   %eax
  800718:	53                   	push   %ebx
  800719:	e8 ac fc ff ff       	call   8003ca <fd_lookup>
  80071e:	83 c4 08             	add    $0x8,%esp
  800721:	89 c2                	mov    %eax,%edx
  800723:	85 c0                	test   %eax,%eax
  800725:	78 68                	js     80078f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80072d:	50                   	push   %eax
  80072e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800731:	ff 30                	pushl  (%eax)
  800733:	e8 e8 fc ff ff       	call   800420 <dev_lookup>
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	85 c0                	test   %eax,%eax
  80073d:	78 47                	js     800786 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800742:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800746:	75 21                	jne    800769 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800748:	a1 04 40 80 00       	mov    0x804004,%eax
  80074d:	8b 40 48             	mov    0x48(%eax),%eax
  800750:	83 ec 04             	sub    $0x4,%esp
  800753:	53                   	push   %ebx
  800754:	50                   	push   %eax
  800755:	68 d5 1e 80 00       	push   $0x801ed5
  80075a:	e8 b8 09 00 00       	call   801117 <cprintf>
		return -E_INVAL;
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800767:	eb 26                	jmp    80078f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800769:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076c:	8b 52 0c             	mov    0xc(%edx),%edx
  80076f:	85 d2                	test   %edx,%edx
  800771:	74 17                	je     80078a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800773:	83 ec 04             	sub    $0x4,%esp
  800776:	ff 75 10             	pushl  0x10(%ebp)
  800779:	ff 75 0c             	pushl  0xc(%ebp)
  80077c:	50                   	push   %eax
  80077d:	ff d2                	call   *%edx
  80077f:	89 c2                	mov    %eax,%edx
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	eb 09                	jmp    80078f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800786:	89 c2                	mov    %eax,%edx
  800788:	eb 05                	jmp    80078f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80078a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80078f:	89 d0                	mov    %edx,%eax
  800791:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800794:	c9                   	leave  
  800795:	c3                   	ret    

00800796 <seek>:

int
seek(int fdnum, off_t offset)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80079c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80079f:	50                   	push   %eax
  8007a0:	ff 75 08             	pushl  0x8(%ebp)
  8007a3:	e8 22 fc ff ff       	call   8003ca <fd_lookup>
  8007a8:	83 c4 08             	add    $0x8,%esp
  8007ab:	85 c0                	test   %eax,%eax
  8007ad:	78 0e                	js     8007bd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    

008007bf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	53                   	push   %ebx
  8007c3:	83 ec 14             	sub    $0x14,%esp
  8007c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cc:	50                   	push   %eax
  8007cd:	53                   	push   %ebx
  8007ce:	e8 f7 fb ff ff       	call   8003ca <fd_lookup>
  8007d3:	83 c4 08             	add    $0x8,%esp
  8007d6:	89 c2                	mov    %eax,%edx
  8007d8:	85 c0                	test   %eax,%eax
  8007da:	78 65                	js     800841 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e2:	50                   	push   %eax
  8007e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e6:	ff 30                	pushl  (%eax)
  8007e8:	e8 33 fc ff ff       	call   800420 <dev_lookup>
  8007ed:	83 c4 10             	add    $0x10,%esp
  8007f0:	85 c0                	test   %eax,%eax
  8007f2:	78 44                	js     800838 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007fb:	75 21                	jne    80081e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007fd:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800802:	8b 40 48             	mov    0x48(%eax),%eax
  800805:	83 ec 04             	sub    $0x4,%esp
  800808:	53                   	push   %ebx
  800809:	50                   	push   %eax
  80080a:	68 98 1e 80 00       	push   $0x801e98
  80080f:	e8 03 09 00 00       	call   801117 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800814:	83 c4 10             	add    $0x10,%esp
  800817:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80081c:	eb 23                	jmp    800841 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80081e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800821:	8b 52 18             	mov    0x18(%edx),%edx
  800824:	85 d2                	test   %edx,%edx
  800826:	74 14                	je     80083c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800828:	83 ec 08             	sub    $0x8,%esp
  80082b:	ff 75 0c             	pushl  0xc(%ebp)
  80082e:	50                   	push   %eax
  80082f:	ff d2                	call   *%edx
  800831:	89 c2                	mov    %eax,%edx
  800833:	83 c4 10             	add    $0x10,%esp
  800836:	eb 09                	jmp    800841 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800838:	89 c2                	mov    %eax,%edx
  80083a:	eb 05                	jmp    800841 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80083c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800841:	89 d0                	mov    %edx,%eax
  800843:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800846:	c9                   	leave  
  800847:	c3                   	ret    

00800848 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	53                   	push   %ebx
  80084c:	83 ec 14             	sub    $0x14,%esp
  80084f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800852:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800855:	50                   	push   %eax
  800856:	ff 75 08             	pushl  0x8(%ebp)
  800859:	e8 6c fb ff ff       	call   8003ca <fd_lookup>
  80085e:	83 c4 08             	add    $0x8,%esp
  800861:	89 c2                	mov    %eax,%edx
  800863:	85 c0                	test   %eax,%eax
  800865:	78 58                	js     8008bf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800867:	83 ec 08             	sub    $0x8,%esp
  80086a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80086d:	50                   	push   %eax
  80086e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800871:	ff 30                	pushl  (%eax)
  800873:	e8 a8 fb ff ff       	call   800420 <dev_lookup>
  800878:	83 c4 10             	add    $0x10,%esp
  80087b:	85 c0                	test   %eax,%eax
  80087d:	78 37                	js     8008b6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80087f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800882:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800886:	74 32                	je     8008ba <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800888:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80088b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800892:	00 00 00 
	stat->st_isdir = 0;
  800895:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80089c:	00 00 00 
	stat->st_dev = dev;
  80089f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a5:	83 ec 08             	sub    $0x8,%esp
  8008a8:	53                   	push   %ebx
  8008a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ac:	ff 50 14             	call   *0x14(%eax)
  8008af:	89 c2                	mov    %eax,%edx
  8008b1:	83 c4 10             	add    $0x10,%esp
  8008b4:	eb 09                	jmp    8008bf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b6:	89 c2                	mov    %eax,%edx
  8008b8:	eb 05                	jmp    8008bf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008bf:	89 d0                	mov    %edx,%eax
  8008c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c4:	c9                   	leave  
  8008c5:	c3                   	ret    

008008c6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008cb:	83 ec 08             	sub    $0x8,%esp
  8008ce:	6a 00                	push   $0x0
  8008d0:	ff 75 08             	pushl  0x8(%ebp)
  8008d3:	e8 e3 01 00 00       	call   800abb <open>
  8008d8:	89 c3                	mov    %eax,%ebx
  8008da:	83 c4 10             	add    $0x10,%esp
  8008dd:	85 c0                	test   %eax,%eax
  8008df:	78 1b                	js     8008fc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	ff 75 0c             	pushl  0xc(%ebp)
  8008e7:	50                   	push   %eax
  8008e8:	e8 5b ff ff ff       	call   800848 <fstat>
  8008ed:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ef:	89 1c 24             	mov    %ebx,(%esp)
  8008f2:	e8 fd fb ff ff       	call   8004f4 <close>
	return r;
  8008f7:	83 c4 10             	add    $0x10,%esp
  8008fa:	89 f0                	mov    %esi,%eax
}
  8008fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	89 c6                	mov    %eax,%esi
  80090a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80090c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800913:	75 12                	jne    800927 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800915:	83 ec 0c             	sub    $0xc,%esp
  800918:	6a 01                	push   $0x1
  80091a:	e8 00 12 00 00       	call   801b1f <ipc_find_env>
  80091f:	a3 00 40 80 00       	mov    %eax,0x804000
  800924:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800927:	6a 07                	push   $0x7
  800929:	68 00 50 80 00       	push   $0x805000
  80092e:	56                   	push   %esi
  80092f:	ff 35 00 40 80 00    	pushl  0x804000
  800935:	e8 91 11 00 00       	call   801acb <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80093a:	83 c4 0c             	add    $0xc,%esp
  80093d:	6a 00                	push   $0x0
  80093f:	53                   	push   %ebx
  800940:	6a 00                	push   $0x0
  800942:	e8 1b 11 00 00       	call   801a62 <ipc_recv>
}
  800947:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094a:	5b                   	pop    %ebx
  80094b:	5e                   	pop    %esi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 40 0c             	mov    0xc(%eax),%eax
  80095a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80095f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800962:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800967:	ba 00 00 00 00       	mov    $0x0,%edx
  80096c:	b8 02 00 00 00       	mov    $0x2,%eax
  800971:	e8 8d ff ff ff       	call   800903 <fsipc>
}
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 40 0c             	mov    0xc(%eax),%eax
  800984:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800989:	ba 00 00 00 00       	mov    $0x0,%edx
  80098e:	b8 06 00 00 00       	mov    $0x6,%eax
  800993:	e8 6b ff ff ff       	call   800903 <fsipc>
}
  800998:	c9                   	leave  
  800999:	c3                   	ret    

0080099a <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	53                   	push   %ebx
  80099e:	83 ec 04             	sub    $0x4,%esp
  8009a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009aa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009af:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b9:	e8 45 ff ff ff       	call   800903 <fsipc>
  8009be:	85 c0                	test   %eax,%eax
  8009c0:	78 2c                	js     8009ee <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c2:	83 ec 08             	sub    $0x8,%esp
  8009c5:	68 00 50 80 00       	push   $0x805000
  8009ca:	53                   	push   %ebx
  8009cb:	e8 4b 0d 00 00       	call   80171b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d0:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009db:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e6:	83 c4 10             	add    $0x10,%esp
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	83 ec 0c             	sub    $0xc,%esp
  8009f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8009fc:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a01:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a06:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a09:	8b 55 08             	mov    0x8(%ebp),%edx
  800a0c:	8b 52 0c             	mov    0xc(%edx),%edx
  800a0f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a15:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a1a:	50                   	push   %eax
  800a1b:	ff 75 0c             	pushl  0xc(%ebp)
  800a1e:	68 08 50 80 00       	push   $0x805008
  800a23:	e8 85 0e 00 00       	call   8018ad <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a28:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2d:	b8 04 00 00 00       	mov    $0x4,%eax
  800a32:	e8 cc fe ff ff       	call   800903 <fsipc>
	//panic("devfile_write not implemented");
}
  800a37:	c9                   	leave  
  800a38:	c3                   	ret    

00800a39 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	56                   	push   %esi
  800a3d:	53                   	push   %ebx
  800a3e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a41:	8b 45 08             	mov    0x8(%ebp),%eax
  800a44:	8b 40 0c             	mov    0xc(%eax),%eax
  800a47:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a4c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a52:	ba 00 00 00 00       	mov    $0x0,%edx
  800a57:	b8 03 00 00 00       	mov    $0x3,%eax
  800a5c:	e8 a2 fe ff ff       	call   800903 <fsipc>
  800a61:	89 c3                	mov    %eax,%ebx
  800a63:	85 c0                	test   %eax,%eax
  800a65:	78 4b                	js     800ab2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a67:	39 c6                	cmp    %eax,%esi
  800a69:	73 16                	jae    800a81 <devfile_read+0x48>
  800a6b:	68 04 1f 80 00       	push   $0x801f04
  800a70:	68 0b 1f 80 00       	push   $0x801f0b
  800a75:	6a 7c                	push   $0x7c
  800a77:	68 20 1f 80 00       	push   $0x801f20
  800a7c:	e8 bd 05 00 00       	call   80103e <_panic>
	assert(r <= PGSIZE);
  800a81:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a86:	7e 16                	jle    800a9e <devfile_read+0x65>
  800a88:	68 2b 1f 80 00       	push   $0x801f2b
  800a8d:	68 0b 1f 80 00       	push   $0x801f0b
  800a92:	6a 7d                	push   $0x7d
  800a94:	68 20 1f 80 00       	push   $0x801f20
  800a99:	e8 a0 05 00 00       	call   80103e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a9e:	83 ec 04             	sub    $0x4,%esp
  800aa1:	50                   	push   %eax
  800aa2:	68 00 50 80 00       	push   $0x805000
  800aa7:	ff 75 0c             	pushl  0xc(%ebp)
  800aaa:	e8 fe 0d 00 00       	call   8018ad <memmove>
	return r;
  800aaf:	83 c4 10             	add    $0x10,%esp
}
  800ab2:	89 d8                	mov    %ebx,%eax
  800ab4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ab7:	5b                   	pop    %ebx
  800ab8:	5e                   	pop    %esi
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	53                   	push   %ebx
  800abf:	83 ec 20             	sub    $0x20,%esp
  800ac2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ac5:	53                   	push   %ebx
  800ac6:	e8 17 0c 00 00       	call   8016e2 <strlen>
  800acb:	83 c4 10             	add    $0x10,%esp
  800ace:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ad3:	7f 67                	jg     800b3c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ad5:	83 ec 0c             	sub    $0xc,%esp
  800ad8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800adb:	50                   	push   %eax
  800adc:	e8 9a f8 ff ff       	call   80037b <fd_alloc>
  800ae1:	83 c4 10             	add    $0x10,%esp
		return r;
  800ae4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ae6:	85 c0                	test   %eax,%eax
  800ae8:	78 57                	js     800b41 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800aea:	83 ec 08             	sub    $0x8,%esp
  800aed:	53                   	push   %ebx
  800aee:	68 00 50 80 00       	push   $0x805000
  800af3:	e8 23 0c 00 00       	call   80171b <strcpy>
	fsipcbuf.open.req_omode = mode;
  800af8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afb:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b00:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b03:	b8 01 00 00 00       	mov    $0x1,%eax
  800b08:	e8 f6 fd ff ff       	call   800903 <fsipc>
  800b0d:	89 c3                	mov    %eax,%ebx
  800b0f:	83 c4 10             	add    $0x10,%esp
  800b12:	85 c0                	test   %eax,%eax
  800b14:	79 14                	jns    800b2a <open+0x6f>
		fd_close(fd, 0);
  800b16:	83 ec 08             	sub    $0x8,%esp
  800b19:	6a 00                	push   $0x0
  800b1b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b1e:	e8 50 f9 ff ff       	call   800473 <fd_close>
		return r;
  800b23:	83 c4 10             	add    $0x10,%esp
  800b26:	89 da                	mov    %ebx,%edx
  800b28:	eb 17                	jmp    800b41 <open+0x86>
	}

	return fd2num(fd);
  800b2a:	83 ec 0c             	sub    $0xc,%esp
  800b2d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b30:	e8 1f f8 ff ff       	call   800354 <fd2num>
  800b35:	89 c2                	mov    %eax,%edx
  800b37:	83 c4 10             	add    $0x10,%esp
  800b3a:	eb 05                	jmp    800b41 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b3c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b41:	89 d0                	mov    %edx,%eax
  800b43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b46:	c9                   	leave  
  800b47:	c3                   	ret    

00800b48 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b53:	b8 08 00 00 00       	mov    $0x8,%eax
  800b58:	e8 a6 fd ff ff       	call   800903 <fsipc>
}
  800b5d:	c9                   	leave  
  800b5e:	c3                   	ret    

00800b5f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
  800b64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b67:	83 ec 0c             	sub    $0xc,%esp
  800b6a:	ff 75 08             	pushl  0x8(%ebp)
  800b6d:	e8 f2 f7 ff ff       	call   800364 <fd2data>
  800b72:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b74:	83 c4 08             	add    $0x8,%esp
  800b77:	68 37 1f 80 00       	push   $0x801f37
  800b7c:	53                   	push   %ebx
  800b7d:	e8 99 0b 00 00       	call   80171b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b82:	8b 46 04             	mov    0x4(%esi),%eax
  800b85:	2b 06                	sub    (%esi),%eax
  800b87:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b8d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b94:	00 00 00 
	stat->st_dev = &devpipe;
  800b97:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b9e:	30 80 00 
	return 0;
}
  800ba1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    

00800bad <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	53                   	push   %ebx
  800bb1:	83 ec 0c             	sub    $0xc,%esp
  800bb4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bb7:	53                   	push   %ebx
  800bb8:	6a 00                	push   $0x0
  800bba:	e8 29 f6 ff ff       	call   8001e8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bbf:	89 1c 24             	mov    %ebx,(%esp)
  800bc2:	e8 9d f7 ff ff       	call   800364 <fd2data>
  800bc7:	83 c4 08             	add    $0x8,%esp
  800bca:	50                   	push   %eax
  800bcb:	6a 00                	push   $0x0
  800bcd:	e8 16 f6 ff ff       	call   8001e8 <sys_page_unmap>
}
  800bd2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bd5:	c9                   	leave  
  800bd6:	c3                   	ret    

00800bd7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
  800bdd:	83 ec 1c             	sub    $0x1c,%esp
  800be0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800be3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800be5:	a1 04 40 80 00       	mov    0x804004,%eax
  800bea:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bed:	83 ec 0c             	sub    $0xc,%esp
  800bf0:	ff 75 e0             	pushl  -0x20(%ebp)
  800bf3:	e8 60 0f 00 00       	call   801b58 <pageref>
  800bf8:	89 c3                	mov    %eax,%ebx
  800bfa:	89 3c 24             	mov    %edi,(%esp)
  800bfd:	e8 56 0f 00 00       	call   801b58 <pageref>
  800c02:	83 c4 10             	add    $0x10,%esp
  800c05:	39 c3                	cmp    %eax,%ebx
  800c07:	0f 94 c1             	sete   %cl
  800c0a:	0f b6 c9             	movzbl %cl,%ecx
  800c0d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c10:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c16:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c19:	39 ce                	cmp    %ecx,%esi
  800c1b:	74 1b                	je     800c38 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c1d:	39 c3                	cmp    %eax,%ebx
  800c1f:	75 c4                	jne    800be5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c21:	8b 42 58             	mov    0x58(%edx),%eax
  800c24:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c27:	50                   	push   %eax
  800c28:	56                   	push   %esi
  800c29:	68 3e 1f 80 00       	push   $0x801f3e
  800c2e:	e8 e4 04 00 00       	call   801117 <cprintf>
  800c33:	83 c4 10             	add    $0x10,%esp
  800c36:	eb ad                	jmp    800be5 <_pipeisclosed+0xe>
	}
}
  800c38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 28             	sub    $0x28,%esp
  800c4c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c4f:	56                   	push   %esi
  800c50:	e8 0f f7 ff ff       	call   800364 <fd2data>
  800c55:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c57:	83 c4 10             	add    $0x10,%esp
  800c5a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5f:	eb 4b                	jmp    800cac <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c61:	89 da                	mov    %ebx,%edx
  800c63:	89 f0                	mov    %esi,%eax
  800c65:	e8 6d ff ff ff       	call   800bd7 <_pipeisclosed>
  800c6a:	85 c0                	test   %eax,%eax
  800c6c:	75 48                	jne    800cb6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c6e:	e8 d1 f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c73:	8b 43 04             	mov    0x4(%ebx),%eax
  800c76:	8b 0b                	mov    (%ebx),%ecx
  800c78:	8d 51 20             	lea    0x20(%ecx),%edx
  800c7b:	39 d0                	cmp    %edx,%eax
  800c7d:	73 e2                	jae    800c61 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c82:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c86:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c89:	89 c2                	mov    %eax,%edx
  800c8b:	c1 fa 1f             	sar    $0x1f,%edx
  800c8e:	89 d1                	mov    %edx,%ecx
  800c90:	c1 e9 1b             	shr    $0x1b,%ecx
  800c93:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c96:	83 e2 1f             	and    $0x1f,%edx
  800c99:	29 ca                	sub    %ecx,%edx
  800c9b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c9f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ca3:	83 c0 01             	add    $0x1,%eax
  800ca6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ca9:	83 c7 01             	add    $0x1,%edi
  800cac:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800caf:	75 c2                	jne    800c73 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cb1:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb4:	eb 05                	jmp    800cbb <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cb6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	83 ec 18             	sub    $0x18,%esp
  800ccc:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ccf:	57                   	push   %edi
  800cd0:	e8 8f f6 ff ff       	call   800364 <fd2data>
  800cd5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cd7:	83 c4 10             	add    $0x10,%esp
  800cda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdf:	eb 3d                	jmp    800d1e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ce1:	85 db                	test   %ebx,%ebx
  800ce3:	74 04                	je     800ce9 <devpipe_read+0x26>
				return i;
  800ce5:	89 d8                	mov    %ebx,%eax
  800ce7:	eb 44                	jmp    800d2d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800ce9:	89 f2                	mov    %esi,%edx
  800ceb:	89 f8                	mov    %edi,%eax
  800ced:	e8 e5 fe ff ff       	call   800bd7 <_pipeisclosed>
  800cf2:	85 c0                	test   %eax,%eax
  800cf4:	75 32                	jne    800d28 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cf6:	e8 49 f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cfb:	8b 06                	mov    (%esi),%eax
  800cfd:	3b 46 04             	cmp    0x4(%esi),%eax
  800d00:	74 df                	je     800ce1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d02:	99                   	cltd   
  800d03:	c1 ea 1b             	shr    $0x1b,%edx
  800d06:	01 d0                	add    %edx,%eax
  800d08:	83 e0 1f             	and    $0x1f,%eax
  800d0b:	29 d0                	sub    %edx,%eax
  800d0d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d15:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d18:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d1b:	83 c3 01             	add    $0x1,%ebx
  800d1e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d21:	75 d8                	jne    800cfb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d23:	8b 45 10             	mov    0x10(%ebp),%eax
  800d26:	eb 05                	jmp    800d2d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d28:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	56                   	push   %esi
  800d39:	53                   	push   %ebx
  800d3a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d3d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d40:	50                   	push   %eax
  800d41:	e8 35 f6 ff ff       	call   80037b <fd_alloc>
  800d46:	83 c4 10             	add    $0x10,%esp
  800d49:	89 c2                	mov    %eax,%edx
  800d4b:	85 c0                	test   %eax,%eax
  800d4d:	0f 88 2c 01 00 00    	js     800e7f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d53:	83 ec 04             	sub    $0x4,%esp
  800d56:	68 07 04 00 00       	push   $0x407
  800d5b:	ff 75 f4             	pushl  -0xc(%ebp)
  800d5e:	6a 00                	push   $0x0
  800d60:	e8 fe f3 ff ff       	call   800163 <sys_page_alloc>
  800d65:	83 c4 10             	add    $0x10,%esp
  800d68:	89 c2                	mov    %eax,%edx
  800d6a:	85 c0                	test   %eax,%eax
  800d6c:	0f 88 0d 01 00 00    	js     800e7f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d72:	83 ec 0c             	sub    $0xc,%esp
  800d75:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d78:	50                   	push   %eax
  800d79:	e8 fd f5 ff ff       	call   80037b <fd_alloc>
  800d7e:	89 c3                	mov    %eax,%ebx
  800d80:	83 c4 10             	add    $0x10,%esp
  800d83:	85 c0                	test   %eax,%eax
  800d85:	0f 88 e2 00 00 00    	js     800e6d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d8b:	83 ec 04             	sub    $0x4,%esp
  800d8e:	68 07 04 00 00       	push   $0x407
  800d93:	ff 75 f0             	pushl  -0x10(%ebp)
  800d96:	6a 00                	push   $0x0
  800d98:	e8 c6 f3 ff ff       	call   800163 <sys_page_alloc>
  800d9d:	89 c3                	mov    %eax,%ebx
  800d9f:	83 c4 10             	add    $0x10,%esp
  800da2:	85 c0                	test   %eax,%eax
  800da4:	0f 88 c3 00 00 00    	js     800e6d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800daa:	83 ec 0c             	sub    $0xc,%esp
  800dad:	ff 75 f4             	pushl  -0xc(%ebp)
  800db0:	e8 af f5 ff ff       	call   800364 <fd2data>
  800db5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db7:	83 c4 0c             	add    $0xc,%esp
  800dba:	68 07 04 00 00       	push   $0x407
  800dbf:	50                   	push   %eax
  800dc0:	6a 00                	push   $0x0
  800dc2:	e8 9c f3 ff ff       	call   800163 <sys_page_alloc>
  800dc7:	89 c3                	mov    %eax,%ebx
  800dc9:	83 c4 10             	add    $0x10,%esp
  800dcc:	85 c0                	test   %eax,%eax
  800dce:	0f 88 89 00 00 00    	js     800e5d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd4:	83 ec 0c             	sub    $0xc,%esp
  800dd7:	ff 75 f0             	pushl  -0x10(%ebp)
  800dda:	e8 85 f5 ff ff       	call   800364 <fd2data>
  800ddf:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800de6:	50                   	push   %eax
  800de7:	6a 00                	push   $0x0
  800de9:	56                   	push   %esi
  800dea:	6a 00                	push   $0x0
  800dec:	e8 b5 f3 ff ff       	call   8001a6 <sys_page_map>
  800df1:	89 c3                	mov    %eax,%ebx
  800df3:	83 c4 20             	add    $0x20,%esp
  800df6:	85 c0                	test   %eax,%eax
  800df8:	78 55                	js     800e4f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dfa:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e03:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e08:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e0f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e18:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e1d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e24:	83 ec 0c             	sub    $0xc,%esp
  800e27:	ff 75 f4             	pushl  -0xc(%ebp)
  800e2a:	e8 25 f5 ff ff       	call   800354 <fd2num>
  800e2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e32:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e34:	83 c4 04             	add    $0x4,%esp
  800e37:	ff 75 f0             	pushl  -0x10(%ebp)
  800e3a:	e8 15 f5 ff ff       	call   800354 <fd2num>
  800e3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e42:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e45:	83 c4 10             	add    $0x10,%esp
  800e48:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4d:	eb 30                	jmp    800e7f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e4f:	83 ec 08             	sub    $0x8,%esp
  800e52:	56                   	push   %esi
  800e53:	6a 00                	push   $0x0
  800e55:	e8 8e f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e5a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e5d:	83 ec 08             	sub    $0x8,%esp
  800e60:	ff 75 f0             	pushl  -0x10(%ebp)
  800e63:	6a 00                	push   $0x0
  800e65:	e8 7e f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e6a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e6d:	83 ec 08             	sub    $0x8,%esp
  800e70:	ff 75 f4             	pushl  -0xc(%ebp)
  800e73:	6a 00                	push   $0x0
  800e75:	e8 6e f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e7a:	83 c4 10             	add    $0x10,%esp
  800e7d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e7f:	89 d0                	mov    %edx,%eax
  800e81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e91:	50                   	push   %eax
  800e92:	ff 75 08             	pushl  0x8(%ebp)
  800e95:	e8 30 f5 ff ff       	call   8003ca <fd_lookup>
  800e9a:	83 c4 10             	add    $0x10,%esp
  800e9d:	85 c0                	test   %eax,%eax
  800e9f:	78 18                	js     800eb9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ea1:	83 ec 0c             	sub    $0xc,%esp
  800ea4:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea7:	e8 b8 f4 ff ff       	call   800364 <fd2data>
	return _pipeisclosed(fd, p);
  800eac:	89 c2                	mov    %eax,%edx
  800eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb1:	e8 21 fd ff ff       	call   800bd7 <_pipeisclosed>
  800eb6:	83 c4 10             	add    $0x10,%esp
}
  800eb9:	c9                   	leave  
  800eba:	c3                   	ret    

00800ebb <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ebe:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    

00800ec5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ecb:	68 56 1f 80 00       	push   $0x801f56
  800ed0:	ff 75 0c             	pushl  0xc(%ebp)
  800ed3:	e8 43 08 00 00       	call   80171b <strcpy>
	return 0;
}
  800ed8:	b8 00 00 00 00       	mov    $0x0,%eax
  800edd:	c9                   	leave  
  800ede:	c3                   	ret    

00800edf <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	57                   	push   %edi
  800ee3:	56                   	push   %esi
  800ee4:	53                   	push   %ebx
  800ee5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eeb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ef0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef6:	eb 2d                	jmp    800f25 <devcons_write+0x46>
		m = n - tot;
  800ef8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800efb:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800efd:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f00:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f05:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f08:	83 ec 04             	sub    $0x4,%esp
  800f0b:	53                   	push   %ebx
  800f0c:	03 45 0c             	add    0xc(%ebp),%eax
  800f0f:	50                   	push   %eax
  800f10:	57                   	push   %edi
  800f11:	e8 97 09 00 00       	call   8018ad <memmove>
		sys_cputs(buf, m);
  800f16:	83 c4 08             	add    $0x8,%esp
  800f19:	53                   	push   %ebx
  800f1a:	57                   	push   %edi
  800f1b:	e8 87 f1 ff ff       	call   8000a7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f20:	01 de                	add    %ebx,%esi
  800f22:	83 c4 10             	add    $0x10,%esp
  800f25:	89 f0                	mov    %esi,%eax
  800f27:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f2a:	72 cc                	jb     800ef8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2f:	5b                   	pop    %ebx
  800f30:	5e                   	pop    %esi
  800f31:	5f                   	pop    %edi
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    

00800f34 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	83 ec 08             	sub    $0x8,%esp
  800f3a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f3f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f43:	74 2a                	je     800f6f <devcons_read+0x3b>
  800f45:	eb 05                	jmp    800f4c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f47:	e8 f8 f1 ff ff       	call   800144 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f4c:	e8 74 f1 ff ff       	call   8000c5 <sys_cgetc>
  800f51:	85 c0                	test   %eax,%eax
  800f53:	74 f2                	je     800f47 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f55:	85 c0                	test   %eax,%eax
  800f57:	78 16                	js     800f6f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f59:	83 f8 04             	cmp    $0x4,%eax
  800f5c:	74 0c                	je     800f6a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f61:	88 02                	mov    %al,(%edx)
	return 1;
  800f63:	b8 01 00 00 00       	mov    $0x1,%eax
  800f68:	eb 05                	jmp    800f6f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f6a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f6f:	c9                   	leave  
  800f70:	c3                   	ret    

00800f71 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f77:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f7d:	6a 01                	push   $0x1
  800f7f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f82:	50                   	push   %eax
  800f83:	e8 1f f1 ff ff       	call   8000a7 <sys_cputs>
}
  800f88:	83 c4 10             	add    $0x10,%esp
  800f8b:	c9                   	leave  
  800f8c:	c3                   	ret    

00800f8d <getchar>:

int
getchar(void)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f93:	6a 01                	push   $0x1
  800f95:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f98:	50                   	push   %eax
  800f99:	6a 00                	push   $0x0
  800f9b:	e8 90 f6 ff ff       	call   800630 <read>
	if (r < 0)
  800fa0:	83 c4 10             	add    $0x10,%esp
  800fa3:	85 c0                	test   %eax,%eax
  800fa5:	78 0f                	js     800fb6 <getchar+0x29>
		return r;
	if (r < 1)
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	7e 06                	jle    800fb1 <getchar+0x24>
		return -E_EOF;
	return c;
  800fab:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800faf:	eb 05                	jmp    800fb6 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fb1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fb6:	c9                   	leave  
  800fb7:	c3                   	ret    

00800fb8 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fbe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc1:	50                   	push   %eax
  800fc2:	ff 75 08             	pushl  0x8(%ebp)
  800fc5:	e8 00 f4 ff ff       	call   8003ca <fd_lookup>
  800fca:	83 c4 10             	add    $0x10,%esp
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	78 11                	js     800fe2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fda:	39 10                	cmp    %edx,(%eax)
  800fdc:	0f 94 c0             	sete   %al
  800fdf:	0f b6 c0             	movzbl %al,%eax
}
  800fe2:	c9                   	leave  
  800fe3:	c3                   	ret    

00800fe4 <opencons>:

int
opencons(void)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fed:	50                   	push   %eax
  800fee:	e8 88 f3 ff ff       	call   80037b <fd_alloc>
  800ff3:	83 c4 10             	add    $0x10,%esp
		return r;
  800ff6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	78 3e                	js     80103a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800ffc:	83 ec 04             	sub    $0x4,%esp
  800fff:	68 07 04 00 00       	push   $0x407
  801004:	ff 75 f4             	pushl  -0xc(%ebp)
  801007:	6a 00                	push   $0x0
  801009:	e8 55 f1 ff ff       	call   800163 <sys_page_alloc>
  80100e:	83 c4 10             	add    $0x10,%esp
		return r;
  801011:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801013:	85 c0                	test   %eax,%eax
  801015:	78 23                	js     80103a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801017:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80101d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801020:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801022:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801025:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80102c:	83 ec 0c             	sub    $0xc,%esp
  80102f:	50                   	push   %eax
  801030:	e8 1f f3 ff ff       	call   800354 <fd2num>
  801035:	89 c2                	mov    %eax,%edx
  801037:	83 c4 10             	add    $0x10,%esp
}
  80103a:	89 d0                	mov    %edx,%eax
  80103c:	c9                   	leave  
  80103d:	c3                   	ret    

0080103e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80103e:	55                   	push   %ebp
  80103f:	89 e5                	mov    %esp,%ebp
  801041:	56                   	push   %esi
  801042:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801043:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801046:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80104c:	e8 d4 f0 ff ff       	call   800125 <sys_getenvid>
  801051:	83 ec 0c             	sub    $0xc,%esp
  801054:	ff 75 0c             	pushl  0xc(%ebp)
  801057:	ff 75 08             	pushl  0x8(%ebp)
  80105a:	56                   	push   %esi
  80105b:	50                   	push   %eax
  80105c:	68 64 1f 80 00       	push   $0x801f64
  801061:	e8 b1 00 00 00       	call   801117 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801066:	83 c4 18             	add    $0x18,%esp
  801069:	53                   	push   %ebx
  80106a:	ff 75 10             	pushl  0x10(%ebp)
  80106d:	e8 54 00 00 00       	call   8010c6 <vcprintf>
	cprintf("\n");
  801072:	c7 04 24 4f 1f 80 00 	movl   $0x801f4f,(%esp)
  801079:	e8 99 00 00 00       	call   801117 <cprintf>
  80107e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801081:	cc                   	int3   
  801082:	eb fd                	jmp    801081 <_panic+0x43>

00801084 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	53                   	push   %ebx
  801088:	83 ec 04             	sub    $0x4,%esp
  80108b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80108e:	8b 13                	mov    (%ebx),%edx
  801090:	8d 42 01             	lea    0x1(%edx),%eax
  801093:	89 03                	mov    %eax,(%ebx)
  801095:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801098:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80109c:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010a1:	75 1a                	jne    8010bd <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010a3:	83 ec 08             	sub    $0x8,%esp
  8010a6:	68 ff 00 00 00       	push   $0xff
  8010ab:	8d 43 08             	lea    0x8(%ebx),%eax
  8010ae:	50                   	push   %eax
  8010af:	e8 f3 ef ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  8010b4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010ba:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010bd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c4:	c9                   	leave  
  8010c5:	c3                   	ret    

008010c6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010c6:	55                   	push   %ebp
  8010c7:	89 e5                	mov    %esp,%ebp
  8010c9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010cf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010d6:	00 00 00 
	b.cnt = 0;
  8010d9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010e0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010e3:	ff 75 0c             	pushl  0xc(%ebp)
  8010e6:	ff 75 08             	pushl  0x8(%ebp)
  8010e9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010ef:	50                   	push   %eax
  8010f0:	68 84 10 80 00       	push   $0x801084
  8010f5:	e8 1a 01 00 00       	call   801214 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010fa:	83 c4 08             	add    $0x8,%esp
  8010fd:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801103:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801109:	50                   	push   %eax
  80110a:	e8 98 ef ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  80110f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801115:	c9                   	leave  
  801116:	c3                   	ret    

00801117 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801117:	55                   	push   %ebp
  801118:	89 e5                	mov    %esp,%ebp
  80111a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80111d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801120:	50                   	push   %eax
  801121:	ff 75 08             	pushl  0x8(%ebp)
  801124:	e8 9d ff ff ff       	call   8010c6 <vcprintf>
	va_end(ap);

	return cnt;
}
  801129:	c9                   	leave  
  80112a:	c3                   	ret    

0080112b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	57                   	push   %edi
  80112f:	56                   	push   %esi
  801130:	53                   	push   %ebx
  801131:	83 ec 1c             	sub    $0x1c,%esp
  801134:	89 c7                	mov    %eax,%edi
  801136:	89 d6                	mov    %edx,%esi
  801138:	8b 45 08             	mov    0x8(%ebp),%eax
  80113b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80113e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801141:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801144:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801147:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80114f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801152:	39 d3                	cmp    %edx,%ebx
  801154:	72 05                	jb     80115b <printnum+0x30>
  801156:	39 45 10             	cmp    %eax,0x10(%ebp)
  801159:	77 45                	ja     8011a0 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80115b:	83 ec 0c             	sub    $0xc,%esp
  80115e:	ff 75 18             	pushl  0x18(%ebp)
  801161:	8b 45 14             	mov    0x14(%ebp),%eax
  801164:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801167:	53                   	push   %ebx
  801168:	ff 75 10             	pushl  0x10(%ebp)
  80116b:	83 ec 08             	sub    $0x8,%esp
  80116e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801171:	ff 75 e0             	pushl  -0x20(%ebp)
  801174:	ff 75 dc             	pushl  -0x24(%ebp)
  801177:	ff 75 d8             	pushl  -0x28(%ebp)
  80117a:	e8 21 0a 00 00       	call   801ba0 <__udivdi3>
  80117f:	83 c4 18             	add    $0x18,%esp
  801182:	52                   	push   %edx
  801183:	50                   	push   %eax
  801184:	89 f2                	mov    %esi,%edx
  801186:	89 f8                	mov    %edi,%eax
  801188:	e8 9e ff ff ff       	call   80112b <printnum>
  80118d:	83 c4 20             	add    $0x20,%esp
  801190:	eb 18                	jmp    8011aa <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801192:	83 ec 08             	sub    $0x8,%esp
  801195:	56                   	push   %esi
  801196:	ff 75 18             	pushl  0x18(%ebp)
  801199:	ff d7                	call   *%edi
  80119b:	83 c4 10             	add    $0x10,%esp
  80119e:	eb 03                	jmp    8011a3 <printnum+0x78>
  8011a0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011a3:	83 eb 01             	sub    $0x1,%ebx
  8011a6:	85 db                	test   %ebx,%ebx
  8011a8:	7f e8                	jg     801192 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011aa:	83 ec 08             	sub    $0x8,%esp
  8011ad:	56                   	push   %esi
  8011ae:	83 ec 04             	sub    $0x4,%esp
  8011b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8011ba:	ff 75 d8             	pushl  -0x28(%ebp)
  8011bd:	e8 0e 0b 00 00       	call   801cd0 <__umoddi3>
  8011c2:	83 c4 14             	add    $0x14,%esp
  8011c5:	0f be 80 87 1f 80 00 	movsbl 0x801f87(%eax),%eax
  8011cc:	50                   	push   %eax
  8011cd:	ff d7                	call   *%edi
}
  8011cf:	83 c4 10             	add    $0x10,%esp
  8011d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d5:	5b                   	pop    %ebx
  8011d6:	5e                   	pop    %esi
  8011d7:	5f                   	pop    %edi
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    

008011da <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
  8011dd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011e0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011e4:	8b 10                	mov    (%eax),%edx
  8011e6:	3b 50 04             	cmp    0x4(%eax),%edx
  8011e9:	73 0a                	jae    8011f5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011eb:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011ee:	89 08                	mov    %ecx,(%eax)
  8011f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f3:	88 02                	mov    %al,(%edx)
}
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    

008011f7 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8011fd:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801200:	50                   	push   %eax
  801201:	ff 75 10             	pushl  0x10(%ebp)
  801204:	ff 75 0c             	pushl  0xc(%ebp)
  801207:	ff 75 08             	pushl  0x8(%ebp)
  80120a:	e8 05 00 00 00       	call   801214 <vprintfmt>
	va_end(ap);
}
  80120f:	83 c4 10             	add    $0x10,%esp
  801212:	c9                   	leave  
  801213:	c3                   	ret    

00801214 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
  801217:	57                   	push   %edi
  801218:	56                   	push   %esi
  801219:	53                   	push   %ebx
  80121a:	83 ec 2c             	sub    $0x2c,%esp
  80121d:	8b 75 08             	mov    0x8(%ebp),%esi
  801220:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801223:	8b 7d 10             	mov    0x10(%ebp),%edi
  801226:	eb 12                	jmp    80123a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801228:	85 c0                	test   %eax,%eax
  80122a:	0f 84 42 04 00 00    	je     801672 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  801230:	83 ec 08             	sub    $0x8,%esp
  801233:	53                   	push   %ebx
  801234:	50                   	push   %eax
  801235:	ff d6                	call   *%esi
  801237:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80123a:	83 c7 01             	add    $0x1,%edi
  80123d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801241:	83 f8 25             	cmp    $0x25,%eax
  801244:	75 e2                	jne    801228 <vprintfmt+0x14>
  801246:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80124a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801251:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801258:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80125f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801264:	eb 07                	jmp    80126d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801266:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801269:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80126d:	8d 47 01             	lea    0x1(%edi),%eax
  801270:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801273:	0f b6 07             	movzbl (%edi),%eax
  801276:	0f b6 d0             	movzbl %al,%edx
  801279:	83 e8 23             	sub    $0x23,%eax
  80127c:	3c 55                	cmp    $0x55,%al
  80127e:	0f 87 d3 03 00 00    	ja     801657 <vprintfmt+0x443>
  801284:	0f b6 c0             	movzbl %al,%eax
  801287:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  80128e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801291:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801295:	eb d6                	jmp    80126d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801297:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80129a:	b8 00 00 00 00       	mov    $0x0,%eax
  80129f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012a2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012a5:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8012a9:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8012ac:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8012af:	83 f9 09             	cmp    $0x9,%ecx
  8012b2:	77 3f                	ja     8012f3 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012b4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012b7:	eb e9                	jmp    8012a2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8012bc:	8b 00                	mov    (%eax),%eax
  8012be:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8012c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c4:	8d 40 04             	lea    0x4(%eax),%eax
  8012c7:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012cd:	eb 2a                	jmp    8012f9 <vprintfmt+0xe5>
  8012cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d9:	0f 49 d0             	cmovns %eax,%edx
  8012dc:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012e2:	eb 89                	jmp    80126d <vprintfmt+0x59>
  8012e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8012e7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8012ee:	e9 7a ff ff ff       	jmp    80126d <vprintfmt+0x59>
  8012f3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012f6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8012f9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012fd:	0f 89 6a ff ff ff    	jns    80126d <vprintfmt+0x59>
				width = precision, precision = -1;
  801303:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801306:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801309:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801310:	e9 58 ff ff ff       	jmp    80126d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801315:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801318:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80131b:	e9 4d ff ff ff       	jmp    80126d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801320:	8b 45 14             	mov    0x14(%ebp),%eax
  801323:	8d 78 04             	lea    0x4(%eax),%edi
  801326:	83 ec 08             	sub    $0x8,%esp
  801329:	53                   	push   %ebx
  80132a:	ff 30                	pushl  (%eax)
  80132c:	ff d6                	call   *%esi
			break;
  80132e:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801331:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801334:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801337:	e9 fe fe ff ff       	jmp    80123a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80133c:	8b 45 14             	mov    0x14(%ebp),%eax
  80133f:	8d 78 04             	lea    0x4(%eax),%edi
  801342:	8b 00                	mov    (%eax),%eax
  801344:	99                   	cltd   
  801345:	31 d0                	xor    %edx,%eax
  801347:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801349:	83 f8 0f             	cmp    $0xf,%eax
  80134c:	7f 0b                	jg     801359 <vprintfmt+0x145>
  80134e:	8b 14 85 20 22 80 00 	mov    0x802220(,%eax,4),%edx
  801355:	85 d2                	test   %edx,%edx
  801357:	75 1b                	jne    801374 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  801359:	50                   	push   %eax
  80135a:	68 9f 1f 80 00       	push   $0x801f9f
  80135f:	53                   	push   %ebx
  801360:	56                   	push   %esi
  801361:	e8 91 fe ff ff       	call   8011f7 <printfmt>
  801366:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801369:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80136c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80136f:	e9 c6 fe ff ff       	jmp    80123a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801374:	52                   	push   %edx
  801375:	68 1d 1f 80 00       	push   $0x801f1d
  80137a:	53                   	push   %ebx
  80137b:	56                   	push   %esi
  80137c:	e8 76 fe ff ff       	call   8011f7 <printfmt>
  801381:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801384:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801387:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80138a:	e9 ab fe ff ff       	jmp    80123a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80138f:	8b 45 14             	mov    0x14(%ebp),%eax
  801392:	83 c0 04             	add    $0x4,%eax
  801395:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801398:	8b 45 14             	mov    0x14(%ebp),%eax
  80139b:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80139d:	85 ff                	test   %edi,%edi
  80139f:	b8 98 1f 80 00       	mov    $0x801f98,%eax
  8013a4:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013a7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013ab:	0f 8e 94 00 00 00    	jle    801445 <vprintfmt+0x231>
  8013b1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013b5:	0f 84 98 00 00 00    	je     801453 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013bb:	83 ec 08             	sub    $0x8,%esp
  8013be:	ff 75 d0             	pushl  -0x30(%ebp)
  8013c1:	57                   	push   %edi
  8013c2:	e8 33 03 00 00       	call   8016fa <strnlen>
  8013c7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013ca:	29 c1                	sub    %eax,%ecx
  8013cc:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8013cf:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013d2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013d9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013dc:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013de:	eb 0f                	jmp    8013ef <vprintfmt+0x1db>
					putch(padc, putdat);
  8013e0:	83 ec 08             	sub    $0x8,%esp
  8013e3:	53                   	push   %ebx
  8013e4:	ff 75 e0             	pushl  -0x20(%ebp)
  8013e7:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e9:	83 ef 01             	sub    $0x1,%edi
  8013ec:	83 c4 10             	add    $0x10,%esp
  8013ef:	85 ff                	test   %edi,%edi
  8013f1:	7f ed                	jg     8013e0 <vprintfmt+0x1cc>
  8013f3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8013f6:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8013f9:	85 c9                	test   %ecx,%ecx
  8013fb:	b8 00 00 00 00       	mov    $0x0,%eax
  801400:	0f 49 c1             	cmovns %ecx,%eax
  801403:	29 c1                	sub    %eax,%ecx
  801405:	89 75 08             	mov    %esi,0x8(%ebp)
  801408:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80140b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80140e:	89 cb                	mov    %ecx,%ebx
  801410:	eb 4d                	jmp    80145f <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801412:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801416:	74 1b                	je     801433 <vprintfmt+0x21f>
  801418:	0f be c0             	movsbl %al,%eax
  80141b:	83 e8 20             	sub    $0x20,%eax
  80141e:	83 f8 5e             	cmp    $0x5e,%eax
  801421:	76 10                	jbe    801433 <vprintfmt+0x21f>
					putch('?', putdat);
  801423:	83 ec 08             	sub    $0x8,%esp
  801426:	ff 75 0c             	pushl  0xc(%ebp)
  801429:	6a 3f                	push   $0x3f
  80142b:	ff 55 08             	call   *0x8(%ebp)
  80142e:	83 c4 10             	add    $0x10,%esp
  801431:	eb 0d                	jmp    801440 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  801433:	83 ec 08             	sub    $0x8,%esp
  801436:	ff 75 0c             	pushl  0xc(%ebp)
  801439:	52                   	push   %edx
  80143a:	ff 55 08             	call   *0x8(%ebp)
  80143d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801440:	83 eb 01             	sub    $0x1,%ebx
  801443:	eb 1a                	jmp    80145f <vprintfmt+0x24b>
  801445:	89 75 08             	mov    %esi,0x8(%ebp)
  801448:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80144b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80144e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801451:	eb 0c                	jmp    80145f <vprintfmt+0x24b>
  801453:	89 75 08             	mov    %esi,0x8(%ebp)
  801456:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801459:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80145c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80145f:	83 c7 01             	add    $0x1,%edi
  801462:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801466:	0f be d0             	movsbl %al,%edx
  801469:	85 d2                	test   %edx,%edx
  80146b:	74 23                	je     801490 <vprintfmt+0x27c>
  80146d:	85 f6                	test   %esi,%esi
  80146f:	78 a1                	js     801412 <vprintfmt+0x1fe>
  801471:	83 ee 01             	sub    $0x1,%esi
  801474:	79 9c                	jns    801412 <vprintfmt+0x1fe>
  801476:	89 df                	mov    %ebx,%edi
  801478:	8b 75 08             	mov    0x8(%ebp),%esi
  80147b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80147e:	eb 18                	jmp    801498 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801480:	83 ec 08             	sub    $0x8,%esp
  801483:	53                   	push   %ebx
  801484:	6a 20                	push   $0x20
  801486:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801488:	83 ef 01             	sub    $0x1,%edi
  80148b:	83 c4 10             	add    $0x10,%esp
  80148e:	eb 08                	jmp    801498 <vprintfmt+0x284>
  801490:	89 df                	mov    %ebx,%edi
  801492:	8b 75 08             	mov    0x8(%ebp),%esi
  801495:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801498:	85 ff                	test   %edi,%edi
  80149a:	7f e4                	jg     801480 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80149c:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80149f:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014a5:	e9 90 fd ff ff       	jmp    80123a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014aa:	83 f9 01             	cmp    $0x1,%ecx
  8014ad:	7e 19                	jle    8014c8 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8014af:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b2:	8b 50 04             	mov    0x4(%eax),%edx
  8014b5:	8b 00                	mov    (%eax),%eax
  8014b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ba:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c0:	8d 40 08             	lea    0x8(%eax),%eax
  8014c3:	89 45 14             	mov    %eax,0x14(%ebp)
  8014c6:	eb 38                	jmp    801500 <vprintfmt+0x2ec>
	else if (lflag)
  8014c8:	85 c9                	test   %ecx,%ecx
  8014ca:	74 1b                	je     8014e7 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8014cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8014cf:	8b 00                	mov    (%eax),%eax
  8014d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014d4:	89 c1                	mov    %eax,%ecx
  8014d6:	c1 f9 1f             	sar    $0x1f,%ecx
  8014d9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8014df:	8d 40 04             	lea    0x4(%eax),%eax
  8014e2:	89 45 14             	mov    %eax,0x14(%ebp)
  8014e5:	eb 19                	jmp    801500 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8014e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ea:	8b 00                	mov    (%eax),%eax
  8014ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ef:	89 c1                	mov    %eax,%ecx
  8014f1:	c1 f9 1f             	sar    $0x1f,%ecx
  8014f4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8014f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014fa:	8d 40 04             	lea    0x4(%eax),%eax
  8014fd:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801500:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801503:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801506:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80150b:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80150f:	0f 89 0e 01 00 00    	jns    801623 <vprintfmt+0x40f>
				putch('-', putdat);
  801515:	83 ec 08             	sub    $0x8,%esp
  801518:	53                   	push   %ebx
  801519:	6a 2d                	push   $0x2d
  80151b:	ff d6                	call   *%esi
				num = -(long long) num;
  80151d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801520:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801523:	f7 da                	neg    %edx
  801525:	83 d1 00             	adc    $0x0,%ecx
  801528:	f7 d9                	neg    %ecx
  80152a:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80152d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801532:	e9 ec 00 00 00       	jmp    801623 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801537:	83 f9 01             	cmp    $0x1,%ecx
  80153a:	7e 18                	jle    801554 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  80153c:	8b 45 14             	mov    0x14(%ebp),%eax
  80153f:	8b 10                	mov    (%eax),%edx
  801541:	8b 48 04             	mov    0x4(%eax),%ecx
  801544:	8d 40 08             	lea    0x8(%eax),%eax
  801547:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80154a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80154f:	e9 cf 00 00 00       	jmp    801623 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801554:	85 c9                	test   %ecx,%ecx
  801556:	74 1a                	je     801572 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  801558:	8b 45 14             	mov    0x14(%ebp),%eax
  80155b:	8b 10                	mov    (%eax),%edx
  80155d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801562:	8d 40 04             	lea    0x4(%eax),%eax
  801565:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801568:	b8 0a 00 00 00       	mov    $0xa,%eax
  80156d:	e9 b1 00 00 00       	jmp    801623 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801572:	8b 45 14             	mov    0x14(%ebp),%eax
  801575:	8b 10                	mov    (%eax),%edx
  801577:	b9 00 00 00 00       	mov    $0x0,%ecx
  80157c:	8d 40 04             	lea    0x4(%eax),%eax
  80157f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801582:	b8 0a 00 00 00       	mov    $0xa,%eax
  801587:	e9 97 00 00 00       	jmp    801623 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80158c:	83 ec 08             	sub    $0x8,%esp
  80158f:	53                   	push   %ebx
  801590:	6a 58                	push   $0x58
  801592:	ff d6                	call   *%esi
			putch('X', putdat);
  801594:	83 c4 08             	add    $0x8,%esp
  801597:	53                   	push   %ebx
  801598:	6a 58                	push   $0x58
  80159a:	ff d6                	call   *%esi
			putch('X', putdat);
  80159c:	83 c4 08             	add    $0x8,%esp
  80159f:	53                   	push   %ebx
  8015a0:	6a 58                	push   $0x58
  8015a2:	ff d6                	call   *%esi
			break;
  8015a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8015aa:	e9 8b fc ff ff       	jmp    80123a <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8015af:	83 ec 08             	sub    $0x8,%esp
  8015b2:	53                   	push   %ebx
  8015b3:	6a 30                	push   $0x30
  8015b5:	ff d6                	call   *%esi
			putch('x', putdat);
  8015b7:	83 c4 08             	add    $0x8,%esp
  8015ba:	53                   	push   %ebx
  8015bb:	6a 78                	push   $0x78
  8015bd:	ff d6                	call   *%esi
			num = (unsigned long long)
  8015bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c2:	8b 10                	mov    (%eax),%edx
  8015c4:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015c9:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015cc:	8d 40 04             	lea    0x4(%eax),%eax
  8015cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015d2:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015d7:	eb 4a                	jmp    801623 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8015d9:	83 f9 01             	cmp    $0x1,%ecx
  8015dc:	7e 15                	jle    8015f3 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8015de:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e1:	8b 10                	mov    (%eax),%edx
  8015e3:	8b 48 04             	mov    0x4(%eax),%ecx
  8015e6:	8d 40 08             	lea    0x8(%eax),%eax
  8015e9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8015ec:	b8 10 00 00 00       	mov    $0x10,%eax
  8015f1:	eb 30                	jmp    801623 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8015f3:	85 c9                	test   %ecx,%ecx
  8015f5:	74 17                	je     80160e <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8015f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8015fa:	8b 10                	mov    (%eax),%edx
  8015fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  801601:	8d 40 04             	lea    0x4(%eax),%eax
  801604:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801607:	b8 10 00 00 00       	mov    $0x10,%eax
  80160c:	eb 15                	jmp    801623 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80160e:	8b 45 14             	mov    0x14(%ebp),%eax
  801611:	8b 10                	mov    (%eax),%edx
  801613:	b9 00 00 00 00       	mov    $0x0,%ecx
  801618:	8d 40 04             	lea    0x4(%eax),%eax
  80161b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80161e:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801623:	83 ec 0c             	sub    $0xc,%esp
  801626:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80162a:	57                   	push   %edi
  80162b:	ff 75 e0             	pushl  -0x20(%ebp)
  80162e:	50                   	push   %eax
  80162f:	51                   	push   %ecx
  801630:	52                   	push   %edx
  801631:	89 da                	mov    %ebx,%edx
  801633:	89 f0                	mov    %esi,%eax
  801635:	e8 f1 fa ff ff       	call   80112b <printnum>
			break;
  80163a:	83 c4 20             	add    $0x20,%esp
  80163d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801640:	e9 f5 fb ff ff       	jmp    80123a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801645:	83 ec 08             	sub    $0x8,%esp
  801648:	53                   	push   %ebx
  801649:	52                   	push   %edx
  80164a:	ff d6                	call   *%esi
			break;
  80164c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80164f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801652:	e9 e3 fb ff ff       	jmp    80123a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801657:	83 ec 08             	sub    $0x8,%esp
  80165a:	53                   	push   %ebx
  80165b:	6a 25                	push   $0x25
  80165d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80165f:	83 c4 10             	add    $0x10,%esp
  801662:	eb 03                	jmp    801667 <vprintfmt+0x453>
  801664:	83 ef 01             	sub    $0x1,%edi
  801667:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80166b:	75 f7                	jne    801664 <vprintfmt+0x450>
  80166d:	e9 c8 fb ff ff       	jmp    80123a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801672:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801675:	5b                   	pop    %ebx
  801676:	5e                   	pop    %esi
  801677:	5f                   	pop    %edi
  801678:	5d                   	pop    %ebp
  801679:	c3                   	ret    

0080167a <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80167a:	55                   	push   %ebp
  80167b:	89 e5                	mov    %esp,%ebp
  80167d:	83 ec 18             	sub    $0x18,%esp
  801680:	8b 45 08             	mov    0x8(%ebp),%eax
  801683:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801686:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801689:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80168d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801690:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801697:	85 c0                	test   %eax,%eax
  801699:	74 26                	je     8016c1 <vsnprintf+0x47>
  80169b:	85 d2                	test   %edx,%edx
  80169d:	7e 22                	jle    8016c1 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80169f:	ff 75 14             	pushl  0x14(%ebp)
  8016a2:	ff 75 10             	pushl  0x10(%ebp)
  8016a5:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8016a8:	50                   	push   %eax
  8016a9:	68 da 11 80 00       	push   $0x8011da
  8016ae:	e8 61 fb ff ff       	call   801214 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8016b3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8016b6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8016b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016bc:	83 c4 10             	add    $0x10,%esp
  8016bf:	eb 05                	jmp    8016c6 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016c6:	c9                   	leave  
  8016c7:	c3                   	ret    

008016c8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016ce:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016d1:	50                   	push   %eax
  8016d2:	ff 75 10             	pushl  0x10(%ebp)
  8016d5:	ff 75 0c             	pushl  0xc(%ebp)
  8016d8:	ff 75 08             	pushl  0x8(%ebp)
  8016db:	e8 9a ff ff ff       	call   80167a <vsnprintf>
	va_end(ap);

	return rc;
}
  8016e0:	c9                   	leave  
  8016e1:	c3                   	ret    

008016e2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016e2:	55                   	push   %ebp
  8016e3:	89 e5                	mov    %esp,%ebp
  8016e5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ed:	eb 03                	jmp    8016f2 <strlen+0x10>
		n++;
  8016ef:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016f2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016f6:	75 f7                	jne    8016ef <strlen+0xd>
		n++;
	return n;
}
  8016f8:	5d                   	pop    %ebp
  8016f9:	c3                   	ret    

008016fa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801700:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801703:	ba 00 00 00 00       	mov    $0x0,%edx
  801708:	eb 03                	jmp    80170d <strnlen+0x13>
		n++;
  80170a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80170d:	39 c2                	cmp    %eax,%edx
  80170f:	74 08                	je     801719 <strnlen+0x1f>
  801711:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801715:	75 f3                	jne    80170a <strnlen+0x10>
  801717:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801719:	5d                   	pop    %ebp
  80171a:	c3                   	ret    

0080171b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80171b:	55                   	push   %ebp
  80171c:	89 e5                	mov    %esp,%ebp
  80171e:	53                   	push   %ebx
  80171f:	8b 45 08             	mov    0x8(%ebp),%eax
  801722:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801725:	89 c2                	mov    %eax,%edx
  801727:	83 c2 01             	add    $0x1,%edx
  80172a:	83 c1 01             	add    $0x1,%ecx
  80172d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801731:	88 5a ff             	mov    %bl,-0x1(%edx)
  801734:	84 db                	test   %bl,%bl
  801736:	75 ef                	jne    801727 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801738:	5b                   	pop    %ebx
  801739:	5d                   	pop    %ebp
  80173a:	c3                   	ret    

0080173b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80173b:	55                   	push   %ebp
  80173c:	89 e5                	mov    %esp,%ebp
  80173e:	53                   	push   %ebx
  80173f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801742:	53                   	push   %ebx
  801743:	e8 9a ff ff ff       	call   8016e2 <strlen>
  801748:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80174b:	ff 75 0c             	pushl  0xc(%ebp)
  80174e:	01 d8                	add    %ebx,%eax
  801750:	50                   	push   %eax
  801751:	e8 c5 ff ff ff       	call   80171b <strcpy>
	return dst;
}
  801756:	89 d8                	mov    %ebx,%eax
  801758:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175b:	c9                   	leave  
  80175c:	c3                   	ret    

0080175d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80175d:	55                   	push   %ebp
  80175e:	89 e5                	mov    %esp,%ebp
  801760:	56                   	push   %esi
  801761:	53                   	push   %ebx
  801762:	8b 75 08             	mov    0x8(%ebp),%esi
  801765:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801768:	89 f3                	mov    %esi,%ebx
  80176a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80176d:	89 f2                	mov    %esi,%edx
  80176f:	eb 0f                	jmp    801780 <strncpy+0x23>
		*dst++ = *src;
  801771:	83 c2 01             	add    $0x1,%edx
  801774:	0f b6 01             	movzbl (%ecx),%eax
  801777:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80177a:	80 39 01             	cmpb   $0x1,(%ecx)
  80177d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801780:	39 da                	cmp    %ebx,%edx
  801782:	75 ed                	jne    801771 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801784:	89 f0                	mov    %esi,%eax
  801786:	5b                   	pop    %ebx
  801787:	5e                   	pop    %esi
  801788:	5d                   	pop    %ebp
  801789:	c3                   	ret    

0080178a <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	56                   	push   %esi
  80178e:	53                   	push   %ebx
  80178f:	8b 75 08             	mov    0x8(%ebp),%esi
  801792:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801795:	8b 55 10             	mov    0x10(%ebp),%edx
  801798:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80179a:	85 d2                	test   %edx,%edx
  80179c:	74 21                	je     8017bf <strlcpy+0x35>
  80179e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8017a2:	89 f2                	mov    %esi,%edx
  8017a4:	eb 09                	jmp    8017af <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8017a6:	83 c2 01             	add    $0x1,%edx
  8017a9:	83 c1 01             	add    $0x1,%ecx
  8017ac:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8017af:	39 c2                	cmp    %eax,%edx
  8017b1:	74 09                	je     8017bc <strlcpy+0x32>
  8017b3:	0f b6 19             	movzbl (%ecx),%ebx
  8017b6:	84 db                	test   %bl,%bl
  8017b8:	75 ec                	jne    8017a6 <strlcpy+0x1c>
  8017ba:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8017bc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017bf:	29 f0                	sub    %esi,%eax
}
  8017c1:	5b                   	pop    %ebx
  8017c2:	5e                   	pop    %esi
  8017c3:	5d                   	pop    %ebp
  8017c4:	c3                   	ret    

008017c5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017c5:	55                   	push   %ebp
  8017c6:	89 e5                	mov    %esp,%ebp
  8017c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017cb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017ce:	eb 06                	jmp    8017d6 <strcmp+0x11>
		p++, q++;
  8017d0:	83 c1 01             	add    $0x1,%ecx
  8017d3:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017d6:	0f b6 01             	movzbl (%ecx),%eax
  8017d9:	84 c0                	test   %al,%al
  8017db:	74 04                	je     8017e1 <strcmp+0x1c>
  8017dd:	3a 02                	cmp    (%edx),%al
  8017df:	74 ef                	je     8017d0 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017e1:	0f b6 c0             	movzbl %al,%eax
  8017e4:	0f b6 12             	movzbl (%edx),%edx
  8017e7:	29 d0                	sub    %edx,%eax
}
  8017e9:	5d                   	pop    %ebp
  8017ea:	c3                   	ret    

008017eb <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017eb:	55                   	push   %ebp
  8017ec:	89 e5                	mov    %esp,%ebp
  8017ee:	53                   	push   %ebx
  8017ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017f5:	89 c3                	mov    %eax,%ebx
  8017f7:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017fa:	eb 06                	jmp    801802 <strncmp+0x17>
		n--, p++, q++;
  8017fc:	83 c0 01             	add    $0x1,%eax
  8017ff:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801802:	39 d8                	cmp    %ebx,%eax
  801804:	74 15                	je     80181b <strncmp+0x30>
  801806:	0f b6 08             	movzbl (%eax),%ecx
  801809:	84 c9                	test   %cl,%cl
  80180b:	74 04                	je     801811 <strncmp+0x26>
  80180d:	3a 0a                	cmp    (%edx),%cl
  80180f:	74 eb                	je     8017fc <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801811:	0f b6 00             	movzbl (%eax),%eax
  801814:	0f b6 12             	movzbl (%edx),%edx
  801817:	29 d0                	sub    %edx,%eax
  801819:	eb 05                	jmp    801820 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80181b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801820:	5b                   	pop    %ebx
  801821:	5d                   	pop    %ebp
  801822:	c3                   	ret    

00801823 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	8b 45 08             	mov    0x8(%ebp),%eax
  801829:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80182d:	eb 07                	jmp    801836 <strchr+0x13>
		if (*s == c)
  80182f:	38 ca                	cmp    %cl,%dl
  801831:	74 0f                	je     801842 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801833:	83 c0 01             	add    $0x1,%eax
  801836:	0f b6 10             	movzbl (%eax),%edx
  801839:	84 d2                	test   %dl,%dl
  80183b:	75 f2                	jne    80182f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80183d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801842:	5d                   	pop    %ebp
  801843:	c3                   	ret    

00801844 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801844:	55                   	push   %ebp
  801845:	89 e5                	mov    %esp,%ebp
  801847:	8b 45 08             	mov    0x8(%ebp),%eax
  80184a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80184e:	eb 03                	jmp    801853 <strfind+0xf>
  801850:	83 c0 01             	add    $0x1,%eax
  801853:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801856:	38 ca                	cmp    %cl,%dl
  801858:	74 04                	je     80185e <strfind+0x1a>
  80185a:	84 d2                	test   %dl,%dl
  80185c:	75 f2                	jne    801850 <strfind+0xc>
			break;
	return (char *) s;
}
  80185e:	5d                   	pop    %ebp
  80185f:	c3                   	ret    

00801860 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	57                   	push   %edi
  801864:	56                   	push   %esi
  801865:	53                   	push   %ebx
  801866:	8b 7d 08             	mov    0x8(%ebp),%edi
  801869:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80186c:	85 c9                	test   %ecx,%ecx
  80186e:	74 36                	je     8018a6 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801870:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801876:	75 28                	jne    8018a0 <memset+0x40>
  801878:	f6 c1 03             	test   $0x3,%cl
  80187b:	75 23                	jne    8018a0 <memset+0x40>
		c &= 0xFF;
  80187d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801881:	89 d3                	mov    %edx,%ebx
  801883:	c1 e3 08             	shl    $0x8,%ebx
  801886:	89 d6                	mov    %edx,%esi
  801888:	c1 e6 18             	shl    $0x18,%esi
  80188b:	89 d0                	mov    %edx,%eax
  80188d:	c1 e0 10             	shl    $0x10,%eax
  801890:	09 f0                	or     %esi,%eax
  801892:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801894:	89 d8                	mov    %ebx,%eax
  801896:	09 d0                	or     %edx,%eax
  801898:	c1 e9 02             	shr    $0x2,%ecx
  80189b:	fc                   	cld    
  80189c:	f3 ab                	rep stos %eax,%es:(%edi)
  80189e:	eb 06                	jmp    8018a6 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8018a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a3:	fc                   	cld    
  8018a4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8018a6:	89 f8                	mov    %edi,%eax
  8018a8:	5b                   	pop    %ebx
  8018a9:	5e                   	pop    %esi
  8018aa:	5f                   	pop    %edi
  8018ab:	5d                   	pop    %ebp
  8018ac:	c3                   	ret    

008018ad <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8018ad:	55                   	push   %ebp
  8018ae:	89 e5                	mov    %esp,%ebp
  8018b0:	57                   	push   %edi
  8018b1:	56                   	push   %esi
  8018b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018b8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8018bb:	39 c6                	cmp    %eax,%esi
  8018bd:	73 35                	jae    8018f4 <memmove+0x47>
  8018bf:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018c2:	39 d0                	cmp    %edx,%eax
  8018c4:	73 2e                	jae    8018f4 <memmove+0x47>
		s += n;
		d += n;
  8018c6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018c9:	89 d6                	mov    %edx,%esi
  8018cb:	09 fe                	or     %edi,%esi
  8018cd:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018d3:	75 13                	jne    8018e8 <memmove+0x3b>
  8018d5:	f6 c1 03             	test   $0x3,%cl
  8018d8:	75 0e                	jne    8018e8 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018da:	83 ef 04             	sub    $0x4,%edi
  8018dd:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018e0:	c1 e9 02             	shr    $0x2,%ecx
  8018e3:	fd                   	std    
  8018e4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018e6:	eb 09                	jmp    8018f1 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018e8:	83 ef 01             	sub    $0x1,%edi
  8018eb:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018ee:	fd                   	std    
  8018ef:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018f1:	fc                   	cld    
  8018f2:	eb 1d                	jmp    801911 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018f4:	89 f2                	mov    %esi,%edx
  8018f6:	09 c2                	or     %eax,%edx
  8018f8:	f6 c2 03             	test   $0x3,%dl
  8018fb:	75 0f                	jne    80190c <memmove+0x5f>
  8018fd:	f6 c1 03             	test   $0x3,%cl
  801900:	75 0a                	jne    80190c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801902:	c1 e9 02             	shr    $0x2,%ecx
  801905:	89 c7                	mov    %eax,%edi
  801907:	fc                   	cld    
  801908:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80190a:	eb 05                	jmp    801911 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80190c:	89 c7                	mov    %eax,%edi
  80190e:	fc                   	cld    
  80190f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801911:	5e                   	pop    %esi
  801912:	5f                   	pop    %edi
  801913:	5d                   	pop    %ebp
  801914:	c3                   	ret    

00801915 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801918:	ff 75 10             	pushl  0x10(%ebp)
  80191b:	ff 75 0c             	pushl  0xc(%ebp)
  80191e:	ff 75 08             	pushl  0x8(%ebp)
  801921:	e8 87 ff ff ff       	call   8018ad <memmove>
}
  801926:	c9                   	leave  
  801927:	c3                   	ret    

00801928 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801928:	55                   	push   %ebp
  801929:	89 e5                	mov    %esp,%ebp
  80192b:	56                   	push   %esi
  80192c:	53                   	push   %ebx
  80192d:	8b 45 08             	mov    0x8(%ebp),%eax
  801930:	8b 55 0c             	mov    0xc(%ebp),%edx
  801933:	89 c6                	mov    %eax,%esi
  801935:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801938:	eb 1a                	jmp    801954 <memcmp+0x2c>
		if (*s1 != *s2)
  80193a:	0f b6 08             	movzbl (%eax),%ecx
  80193d:	0f b6 1a             	movzbl (%edx),%ebx
  801940:	38 d9                	cmp    %bl,%cl
  801942:	74 0a                	je     80194e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801944:	0f b6 c1             	movzbl %cl,%eax
  801947:	0f b6 db             	movzbl %bl,%ebx
  80194a:	29 d8                	sub    %ebx,%eax
  80194c:	eb 0f                	jmp    80195d <memcmp+0x35>
		s1++, s2++;
  80194e:	83 c0 01             	add    $0x1,%eax
  801951:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801954:	39 f0                	cmp    %esi,%eax
  801956:	75 e2                	jne    80193a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801958:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80195d:	5b                   	pop    %ebx
  80195e:	5e                   	pop    %esi
  80195f:	5d                   	pop    %ebp
  801960:	c3                   	ret    

00801961 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801961:	55                   	push   %ebp
  801962:	89 e5                	mov    %esp,%ebp
  801964:	53                   	push   %ebx
  801965:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801968:	89 c1                	mov    %eax,%ecx
  80196a:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80196d:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801971:	eb 0a                	jmp    80197d <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801973:	0f b6 10             	movzbl (%eax),%edx
  801976:	39 da                	cmp    %ebx,%edx
  801978:	74 07                	je     801981 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80197a:	83 c0 01             	add    $0x1,%eax
  80197d:	39 c8                	cmp    %ecx,%eax
  80197f:	72 f2                	jb     801973 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801981:	5b                   	pop    %ebx
  801982:	5d                   	pop    %ebp
  801983:	c3                   	ret    

00801984 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801984:	55                   	push   %ebp
  801985:	89 e5                	mov    %esp,%ebp
  801987:	57                   	push   %edi
  801988:	56                   	push   %esi
  801989:	53                   	push   %ebx
  80198a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80198d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801990:	eb 03                	jmp    801995 <strtol+0x11>
		s++;
  801992:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801995:	0f b6 01             	movzbl (%ecx),%eax
  801998:	3c 20                	cmp    $0x20,%al
  80199a:	74 f6                	je     801992 <strtol+0xe>
  80199c:	3c 09                	cmp    $0x9,%al
  80199e:	74 f2                	je     801992 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8019a0:	3c 2b                	cmp    $0x2b,%al
  8019a2:	75 0a                	jne    8019ae <strtol+0x2a>
		s++;
  8019a4:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8019a7:	bf 00 00 00 00       	mov    $0x0,%edi
  8019ac:	eb 11                	jmp    8019bf <strtol+0x3b>
  8019ae:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8019b3:	3c 2d                	cmp    $0x2d,%al
  8019b5:	75 08                	jne    8019bf <strtol+0x3b>
		s++, neg = 1;
  8019b7:	83 c1 01             	add    $0x1,%ecx
  8019ba:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019bf:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019c5:	75 15                	jne    8019dc <strtol+0x58>
  8019c7:	80 39 30             	cmpb   $0x30,(%ecx)
  8019ca:	75 10                	jne    8019dc <strtol+0x58>
  8019cc:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019d0:	75 7c                	jne    801a4e <strtol+0xca>
		s += 2, base = 16;
  8019d2:	83 c1 02             	add    $0x2,%ecx
  8019d5:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019da:	eb 16                	jmp    8019f2 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019dc:	85 db                	test   %ebx,%ebx
  8019de:	75 12                	jne    8019f2 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019e0:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019e5:	80 39 30             	cmpb   $0x30,(%ecx)
  8019e8:	75 08                	jne    8019f2 <strtol+0x6e>
		s++, base = 8;
  8019ea:	83 c1 01             	add    $0x1,%ecx
  8019ed:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019f7:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019fa:	0f b6 11             	movzbl (%ecx),%edx
  8019fd:	8d 72 d0             	lea    -0x30(%edx),%esi
  801a00:	89 f3                	mov    %esi,%ebx
  801a02:	80 fb 09             	cmp    $0x9,%bl
  801a05:	77 08                	ja     801a0f <strtol+0x8b>
			dig = *s - '0';
  801a07:	0f be d2             	movsbl %dl,%edx
  801a0a:	83 ea 30             	sub    $0x30,%edx
  801a0d:	eb 22                	jmp    801a31 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801a0f:	8d 72 9f             	lea    -0x61(%edx),%esi
  801a12:	89 f3                	mov    %esi,%ebx
  801a14:	80 fb 19             	cmp    $0x19,%bl
  801a17:	77 08                	ja     801a21 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801a19:	0f be d2             	movsbl %dl,%edx
  801a1c:	83 ea 57             	sub    $0x57,%edx
  801a1f:	eb 10                	jmp    801a31 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a21:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a24:	89 f3                	mov    %esi,%ebx
  801a26:	80 fb 19             	cmp    $0x19,%bl
  801a29:	77 16                	ja     801a41 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a2b:	0f be d2             	movsbl %dl,%edx
  801a2e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a31:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a34:	7d 0b                	jge    801a41 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a36:	83 c1 01             	add    $0x1,%ecx
  801a39:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a3d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a3f:	eb b9                	jmp    8019fa <strtol+0x76>

	if (endptr)
  801a41:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a45:	74 0d                	je     801a54 <strtol+0xd0>
		*endptr = (char *) s;
  801a47:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a4a:	89 0e                	mov    %ecx,(%esi)
  801a4c:	eb 06                	jmp    801a54 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a4e:	85 db                	test   %ebx,%ebx
  801a50:	74 98                	je     8019ea <strtol+0x66>
  801a52:	eb 9e                	jmp    8019f2 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a54:	89 c2                	mov    %eax,%edx
  801a56:	f7 da                	neg    %edx
  801a58:	85 ff                	test   %edi,%edi
  801a5a:	0f 45 c2             	cmovne %edx,%eax
}
  801a5d:	5b                   	pop    %ebx
  801a5e:	5e                   	pop    %esi
  801a5f:	5f                   	pop    %edi
  801a60:	5d                   	pop    %ebp
  801a61:	c3                   	ret    

00801a62 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a62:	55                   	push   %ebp
  801a63:	89 e5                	mov    %esp,%ebp
  801a65:	56                   	push   %esi
  801a66:	53                   	push   %ebx
  801a67:	8b 75 08             	mov    0x8(%ebp),%esi
  801a6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801a70:	85 c0                	test   %eax,%eax
  801a72:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a77:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801a7a:	83 ec 0c             	sub    $0xc,%esp
  801a7d:	50                   	push   %eax
  801a7e:	e8 90 e8 ff ff       	call   800313 <sys_ipc_recv>
  801a83:	83 c4 10             	add    $0x10,%esp
  801a86:	85 c0                	test   %eax,%eax
  801a88:	79 16                	jns    801aa0 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801a8a:	85 f6                	test   %esi,%esi
  801a8c:	74 06                	je     801a94 <ipc_recv+0x32>
            *from_env_store = 0;
  801a8e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801a94:	85 db                	test   %ebx,%ebx
  801a96:	74 2c                	je     801ac4 <ipc_recv+0x62>
            *perm_store = 0;
  801a98:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a9e:	eb 24                	jmp    801ac4 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801aa0:	85 f6                	test   %esi,%esi
  801aa2:	74 0a                	je     801aae <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801aa4:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa9:	8b 40 74             	mov    0x74(%eax),%eax
  801aac:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801aae:	85 db                	test   %ebx,%ebx
  801ab0:	74 0a                	je     801abc <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801ab2:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab7:	8b 40 78             	mov    0x78(%eax),%eax
  801aba:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801abc:	a1 04 40 80 00       	mov    0x804004,%eax
  801ac1:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801ac4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac7:	5b                   	pop    %ebx
  801ac8:	5e                   	pop    %esi
  801ac9:	5d                   	pop    %ebp
  801aca:	c3                   	ret    

00801acb <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801acb:	55                   	push   %ebp
  801acc:	89 e5                	mov    %esp,%ebp
  801ace:	57                   	push   %edi
  801acf:	56                   	push   %esi
  801ad0:	53                   	push   %ebx
  801ad1:	83 ec 0c             	sub    $0xc,%esp
  801ad4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ad7:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ada:	8b 45 10             	mov    0x10(%ebp),%eax
  801add:	85 c0                	test   %eax,%eax
  801adf:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ae4:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801ae7:	eb 1c                	jmp    801b05 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801ae9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aec:	74 12                	je     801b00 <ipc_send+0x35>
  801aee:	50                   	push   %eax
  801aef:	68 80 22 80 00       	push   $0x802280
  801af4:	6a 3a                	push   $0x3a
  801af6:	68 96 22 80 00       	push   $0x802296
  801afb:	e8 3e f5 ff ff       	call   80103e <_panic>
		sys_yield();
  801b00:	e8 3f e6 ff ff       	call   800144 <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801b05:	ff 75 14             	pushl  0x14(%ebp)
  801b08:	53                   	push   %ebx
  801b09:	56                   	push   %esi
  801b0a:	57                   	push   %edi
  801b0b:	e8 e0 e7 ff ff       	call   8002f0 <sys_ipc_try_send>
  801b10:	83 c4 10             	add    $0x10,%esp
  801b13:	85 c0                	test   %eax,%eax
  801b15:	78 d2                	js     801ae9 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801b17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1a:	5b                   	pop    %ebx
  801b1b:	5e                   	pop    %esi
  801b1c:	5f                   	pop    %edi
  801b1d:	5d                   	pop    %ebp
  801b1e:	c3                   	ret    

00801b1f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b25:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b2a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b2d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b33:	8b 52 50             	mov    0x50(%edx),%edx
  801b36:	39 ca                	cmp    %ecx,%edx
  801b38:	75 0d                	jne    801b47 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b3a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b3d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b42:	8b 40 48             	mov    0x48(%eax),%eax
  801b45:	eb 0f                	jmp    801b56 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b47:	83 c0 01             	add    $0x1,%eax
  801b4a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b4f:	75 d9                	jne    801b2a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b51:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b56:	5d                   	pop    %ebp
  801b57:	c3                   	ret    

00801b58 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b5e:	89 d0                	mov    %edx,%eax
  801b60:	c1 e8 16             	shr    $0x16,%eax
  801b63:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b6a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b6f:	f6 c1 01             	test   $0x1,%cl
  801b72:	74 1d                	je     801b91 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b74:	c1 ea 0c             	shr    $0xc,%edx
  801b77:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b7e:	f6 c2 01             	test   $0x1,%dl
  801b81:	74 0e                	je     801b91 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b83:	c1 ea 0c             	shr    $0xc,%edx
  801b86:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b8d:	ef 
  801b8e:	0f b7 c0             	movzwl %ax,%eax
}
  801b91:	5d                   	pop    %ebp
  801b92:	c3                   	ret    
  801b93:	66 90                	xchg   %ax,%ax
  801b95:	66 90                	xchg   %ax,%ax
  801b97:	66 90                	xchg   %ax,%ax
  801b99:	66 90                	xchg   %ax,%ax
  801b9b:	66 90                	xchg   %ax,%ax
  801b9d:	66 90                	xchg   %ax,%ax
  801b9f:	90                   	nop

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
