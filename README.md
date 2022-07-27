# Swift_protocol_reproducer

本项目是用来复现Swift编译器对protocol进行-O优化时生成同名跳板符号导致的bug

How to produce：
```swift
// FrameworkA（static）：
public func foo(){
    var change: [NSKeyValueChangeKey: Any]? = [:]
    change![.newKey] = "hello world"
    if let offset = change![.newKey] as? CGPoint{
        print(offset)
    }
}

public func bar(){
    var change: [RunLoop.Mode: Any]? = [:]
    var mode = RunLoop.Mode.init(rawValue: "hello world")
    change![mode] = "hello world"
    if let offset = change![mode] as? CGPoint{
        print(offset)
    }
}
```
Xcode中设置Optimization level设置为-O
```
FrameworkA(FooBar.o):   file format mach-o 64-bit x86-64

Disassembly of section __TEXT,__text:

0000000000000500 <_$sSo13NSRunLoopModeaSHSCSH13_rawHashValue4seedS2i_tFTW>:
     500: 55                            pushq   %rbp
     501: 48 89 e5                      movq    %rsp, %rbp
     504: 41 57                         pushq   %r15
     506: 41 56                         pushq   %r14
     508: 41 55                         pushq   %r13
     50a: 53                            pushq   %rbx
     50b: 48 83 ec 50                   subq    $80, %rsp
     50f: 49 89 fe                      movq    %rdi, %r14
     512: 49 8b 7d 00                   movq    (%r13), %rdi
     516: e8 00 00 00 00                callq   0x51b <_$sSo13NSRunLoopModeaSHSCSH13_rawHashValue4seedS2i_tFTW+0x1b>
     51b: 49 89 c7                      movq    %rax, %r15
     51e: 48 89 d3                      movq    %rdx, %rbx
     521: 4c 8d 6d 98                   leaq    -104(%rbp), %r13
     525: 4c 89 e8                      movq    %r13, %rax
     528: 4c 89 f7                      movq    %r14, %rdi
     52b: e8 00 00 00 00                callq   0x530 <_$sSo13NSRunLoopModeaSHSCSH13_rawHashValue4seedS2i_tFTW+0x30>
     530: 4c 89 ef                      movq    %r13, %rdi
     533: 4c 89 fe                      movq    %r15, %rsi
     536: 48 89 da                      movq    %rbx, %rdx
     539: e8 00 00 00 00                callq   0x53e <_$sSo13NSRunLoopModeaSHSCSH13_rawHashValue4seedS2i_tFTW+0x3e>
     53e: e8 00 00 00 00                callq   0x543 <_$sSo13NSRunLoopModeaSHSCSH13_rawHashValue4seedS2i_tFTW+0x43>
     543: 49 89 c6                      movq    %rax, %r14
     546: 48 89 df                      movq    %rbx, %rdi
     549: e8 00 00 00 00                callq   0x54e <_$sSo13NSRunLoopModeaSHSCSH13_rawHashValue4seedS2i_tFTW+0x4e>
     54e: 4c 89 f0                      movq    %r14, %rax
     551: 48 83 c4 50                   addq    $80, %rsp
     555: 5b                            popq    %rbx
     556: 41 5d                         popq    %r13
     558: 41 5e                         popq    %r14
     55a: 41 5f                         popq    %r15
     55c: 5d                            popq    %rbp
     55d: c3                            retq
     55e: 66 90                         nop
     
0000000000001e30 <_$sSo19NSKeyValueChangeKeyaSHSCSH08_rawHashB04seedS2i_tFTW>:
    1e30: 55                                   pushq        %rbp
    1e31: 48 89 e5                             movq        %rsp, %rbp
    1e34: 5d                                   popq        %rbp
    1e35: e9 00 00 00 00                       jmp        0x1e3a <_$sSo19NSKeyValueChangeKeyaSHSCSH08_rawHashB04seedS2i_tFTW+0xa>
    1e3a: 66 0f 1f 44 00 00                    nopw        (%rax,%rax)
```

``` Swift
// FrameworkB（static）:
public func bar(){
    var change: [RunLoop.Mode: Any]? = [:]
    var mode = RunLoop.Mode.init(rawValue: "hello world")
    change![mode] = "hello world"
    if let offset = change![mode] as? CGPoint{
        print(offset)
    }
}
```

Xcode中Optimization level设置为-Onone
```
FrameworkB(Bar.o):        file format mach-o 64-bit x86-64

Disassembly of section __TEXT,__text:

0000000000000c40 <_$sSo13NSRunLoopModeaSHSCSH13_rawHashValue4seedS2i_tFTW>:
     c40: 55                                   pushq        %rbp
     c41: 48 89 e5                             movq        %rsp, %rbp
     c44: 48 83 ec 20                          subq        $32, %rsp
     c48: 48 89 55 f8                          movq        %rdx, -8(%rbp)
     c4c: 48 89 75 f0                          movq        %rsi, -16(%rbp)
     c50: 48 89 7d e8                          movq        %rdi, -24(%rbp)
     c54: e8 00 00 00 00                       callq        0xc59 <_$sSo13NSRunLoopModeaSHSCSH13_rawHashValue4seedS2i_tFTW+0x19>
     c59: 48 8b 7d e8                          movq        -24(%rbp), %rdi
     c5d: 48 8b 75 f0                          movq        -16(%rbp), %rsi
     c61: 48 8b 55 f8                          movq        -8(%rbp), %rdx
     c65: 48 89 c1                             movq        %rax, %rcx
     c68: 4c 8b 05 00 00 00 00                 movq        (%rip), %r8             ## 0xc6f <_$sSo13NSRunLoopModeaSHSCSH13_rawHashValue4seedS2i_tFTW+0x2f>
     c6f: e8 00 00 00 00                       callq        0xc74 <_$sSo13NSRunLoopModeaSHSCSH13_rawHashValue4seedS2i_tFTW+0x34>
     c74: 48 83 c4 20                          addq        $32, %rsp
     c78: 5d                                   popq        %rbp
     c79: c3                                   retq
     c7a: 66 0f 1f 44 00 00                    nopw        (%rax,%rax)
```

使用项目中提供的linking.sh进行链接，这个脚本中这个链接顺序很关键，会导致链接器链接到错误的符号：
```
-all_load \
-framework \
FrameworkB \
-framework \
FrameworkA \
-filelist \
/Users/bytedance/Library/Developer/Xcode/DerivedData/hash-aemzjpwsctkicsbrxrmwmxwtkcqs/Build/Intermediates.noindex/hash.build/Debug/hash.build/Objects-normal/x86_64/hash.LinkFileList \
```
- -all_load确保FrameworkA和FrmaeworkB中的符号会被直接加载，而不是懒加载
- FrameworkB放在前，FrmaeworkA放在后，保证链接器一定先见到FrameworkB的sSo13NSRunLoopModeaSHSCSH13_rawHashValue4seedS2i_tFTW符号，
然后见到FrameworkA的sSo19NSKeyValueChangeKeyaSHSCSH08_rawHashB04seedS2i_tFTW符号
- sSo19NSKeyValueChangeKeyaSHSCSH08_rawHashB04seedS2i_tFTW符号定义中的重定位会jmp到sSo13NSRunLoopModeaSHSCSH13_rawHashValue4seedS2i_tFTW符号；
按理讲这里jmp到的应该是FrameworkA中同一个.o里的这个符号，但是由于链接器先加载FrameworkB，因此最后使用的会是FrameworkB的这个符号

由于FrameworkA的优化等级为O，swift编译器会对protocol witness符号进行一个优化（相同layout的类型可以共用一部分汇编代码），所以实际上：

FrameworkA：foo (optimized) -> bar (optimized)

而FrameworkB没有开启优化，并且在FrameworkB的scope中没有其它类型可以合并protocol witness，因此：

FrameworkB: bar (normal)

链接之后会变为：

main.o: foo (optimized) -> bar (normal)

最终触发程序崩溃

