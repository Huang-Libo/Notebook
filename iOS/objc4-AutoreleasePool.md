
# AutoreleasePoolPage 源码分析

> 说明：本文摘出的源码均来自 **objc4-818.2** 这个版本。`AutoreleasePoolPage` 的源码位于 `objc4` 的 [NSObject.mm](https://opensource.apple.com/source/objc4/objc4-818.2/runtime/NSObject.mm.auto.html) 中。

<h2>目录</h2>

- [AutoreleasePoolPage 源码分析](#autoreleasepoolpage-源码分析)
  - [简介](#简介)
  - [基础结构](#基础结构)
    - [`AutoreleasePoolPageData`](#autoreleasepoolpagedata)
    - [`AutoreleasePoolPage`](#autoreleasepoolpage)
  - [友元](#友元)
    - [`thread_data_t`](#thread_data_t)
  - [public 成员变量](#public-成员变量)
    - [`SIZE`](#size)
  - [private 成员变量](#private-成员变量)
    - [`key`](#key)
    - [`SCRIBBLE`](#scribble)
    - [`COUNT`](#count)
  - [宏（内部定义的）](#宏内部定义的)
    - [`EMPTY_POOL_PLACEHOLDER`](#empty_pool_placeholder)
    - [`POOL_BOUNDARY`](#pool_boundary)
  - [宏（外部定义的）](#宏外部定义的)
    - [`SUPPORT_AUTORELEASEPOOL_DEDUP_PTRS`](#support_autoreleasepool_dedup_ptrs)
    - [`PROTECT_AUTORELEASEPOOL`](#protect_autoreleasepool)
  - [构造方法 & 析构方法](#构造方法--析构方法)
  - [private 方法](#private-方法)
    - [`begin()`](#begin)
    - [`end()`](#end)
    - [`empty()`](#empty)
    - [`full()`](#full)
    - [`lessThanHalfFull()`](#lessthanhalffull)
    - [`add(id obj)`](#addid-obj)
    - [`releaseAll()`](#releaseall)
    - [`releaseUntil(id *stop)`](#releaseuntilid-stop)
    - [`kill()`](#kill)
    - [`tls_dealloc(void *p)`](#tls_deallocvoid-p)
    - [`pageForPointer(const void *p)` & `pageForPointer(uintptr_t p)`](#pageforpointerconst-void-p--pageforpointeruintptr_t-p)
    - [`haveEmptyPoolPlaceholder()` & `setEmptyPoolPlaceholder()`](#haveemptypoolplaceholder--setemptypoolplaceholder)
    - [`hotPage()` & `setHotPage(AutoreleasePoolPage *page)`](#hotpage--sethotpageautoreleasepoolpage-page)
    - [`coldPage()`](#coldpage)
    - [`autoreleaseFast(id obj)`](#autoreleasefastid-obj)
    - [`autoreleaseFullPage(id obj, AutoreleasePoolPage *page)`](#autoreleasefullpageid-obj-autoreleasepoolpage-page)
    - [`autoreleaseNoPage(id obj)`](#autoreleasenopageid-obj)
    - [`autoreleaseNewPage(id obj)` (Debug only)](#autoreleasenewpageid-obj-debug-only)
  - [public 方法](#public-方法)
    - [`autorelease(id obj)`](#autoreleaseid-obj)
    - [`push()`](#push)
    - [`pop(void *token)`](#popvoid-token)
    - [`popPage(void *token, AutoreleasePoolPage *page, id *stop)`](#poppagevoid-token-autoreleasepoolpage-page-id-stop)
    - [`init()`](#init)
  - [便捷的函数](#便捷的函数)
    - [`objc_autoreleasePoolPush(void)`](#objc_autoreleasepoolpushvoid)
    - [`objc_autoreleasePoolPop(void *ctxt)`](#objc_autoreleasepoolpopvoid-ctxt)
    - [`objc_autorelease(id obj)`](#objc_autoreleaseid-obj)
  - [参考](#参考)

## 简介

在声明 `AutoreleasePoolPage` 类的前面有一段关于它的注释：

> *Autorelease pool implementation*
>  
> - A **thread**'s autorelease pool is **a stack of pointers**.
> - Each pointer is either an object to release, or `POOL_BOUNDARY` which is an autorelease pool boundary.
> - A **pool token** is a pointer to the `POOL_BOUNDARY` for that pool. When the pool is popped, every object hotter than the **sentinel** is released.
> - The stack is divided into **a doubly-linked list of pages**. Pages are added and deleted as necessary.
> - **Thread-local storage** points to the **hot page**, where newly autoreleased objects are stored.

**翻译（内容稍作了充实）：**

- 自动释放池是以 `AutoreleasePoolPage` 为节点的**双链表**结构，其中 `AutoreleasePoolPage` 是*存储指针的栈 (a stack of pointers)* ，其存储的指针有两种类型：
  - 一种是代表自动释放池的边界的指针，这些指针指向 `POOL_BOUNDARY`（值为 `nil` ），也就是我们常说的*哨兵*，它是在 `push()` 方法中调用 `autoreleaseFast(POOL_BOUNDARY)` 的时候加入到 `page` 中的。当自动释放池执行 `pop()` 方法时，那些在*哨兵 (sentinel)* 之后添加的（对象指针指向的）对象都会被释放。
  - 另一种指针是**需要自动释放的对象的指针**，这些对象的指针是在调用 `-autorelease` 方法时加入到 `page` 中的。
- **线程**与自动释放池是一一对应的。
- **pool token** 是指向自动释放池的 `POOL_BOUNDARY` 的指针（也就是哨兵）。
- **hot page** 的指针存储在*线程局部存储 (Thread-local storage)* 中，它是当前存储自动释放对象的指针的 `page` 。

## 基础结构

### `AutoreleasePoolPageData`

`AutoreleasePoolPageData` 位于 [NSObject-internal.h](https://opensource.apple.com/source/objc4/objc4-818.2/runtime/NSObject-internal.h.auto.html) 中，它封装了重要的成员变量：

```cpp
class AutoreleasePoolPage;

struct AutoreleasePoolPageData
{
#if SUPPORT_AUTORELEASEPOOL_DEDUP_PTRS
    struct AutoreleasePoolEntry {
        uintptr_t ptr: 48;
        uintptr_t count: 16;

        static const uintptr_t maxCount = 65535; // 2^16 - 1
    };
    static_assert((AutoreleasePoolEntry){ .ptr = MACH_VM_MAX_ADDRESS }.ptr == MACH_VM_MAX_ADDRESS, "MACH_VM_MAX_ADDRESS doesn't fit into AutoreleasePoolEntry::ptr!");
#endif

	magic_t const magic;
	__unsafe_unretained id *next;
	pthread_t const thread;
	AutoreleasePoolPage * const parent;
	AutoreleasePoolPage *child;
	uint32_t const depth;
	uint32_t hiwat;

	AutoreleasePoolPageData(__unsafe_unretained id* _next, pthread_t _thread, AutoreleasePoolPage* _parent, uint32_t _depth, uint32_t _hiwat)
		: magic(), next(_next), thread(_thread),
		  parent(_parent), child(nil),
		  depth(_depth), hiwat(_hiwat)
	{
	}
};
```

**字段解读：**

- `magic` ：用于对当前 `AutoreleasePoolPage` **完整性**的校验；
- `thread` ：当前的自动释放池对应的线程；
- `next` ：指向最新添加的 autorelease 对象的下一个位置，初始化时指向 `begin()` ；
- `parent` ：指向上一个 `page` ，第一个结点的 `parent` 值为 `nil` ；
- `child` ：指向下一个 `page` ，最后一个结点的 `child` 值为 `nil` ；
- `depth` ：代表当前 `page` 在双链表中的深度，从 `0` 开始，往后递增 `1` ；
- `hiwat` ：代表 *high water mark* 。❓

### `AutoreleasePoolPage`

`AutoreleasePoolPage` **私有**继承自 `AutoreleasePoolPageData` ，因此包含前面介绍的那些成员变量。除此之外还定义了一些独有的成员变量：

```cpp
class AutoreleasePoolPage : private AutoreleasePoolPageData
{
	friend struct thread_data_t;

public:
	static size_t const SIZE =
#if PROTECT_AUTORELEASEPOOL
		PAGE_MAX_SIZE;  // must be multiple of vm page size
#else
		PAGE_MIN_SIZE;  // size and alignment, power of 2
#endif

private:
   static pthread_key_t const key = AUTORELEASE_POOL_KEY;
   static uint8_t const SCRIBBLE = 0xA3;  // 0xA3A3A3A3 after releasing
   static size_t const COUNT = SIZE / sizeof(id);
   static size_t const MAX_FAULTS = 2;

    // EMPTY_POOL_PLACEHOLDER is stored in TLS when exactly one pool is 
    // pushed and it has never contained any objects. This saves memory 
    // when the top level (i.e. libdispatch) pushes and pops pools but 
    // never uses them.
#   define EMPTY_POOL_PLACEHOLDER ((id*)1)

#   define POOL_BOUNDARY nil

// ...(省略了类的方法，后面将逐个分析)
}
```

## 友元

### `thread_data_t`

> ❓ 这个友元的作用待研究。。。

在 `AutoreleasePoolPage` 中的声明：

```cpp
friend struct thread_data_t;
```

`struct thread_data_t` 的定义是：

```cpp
struct thread_data_t
{
#ifdef __LP64__
	pthread_t const thread;
	uint32_t const hiwat;
	uint32_t const depth;
#else
	pthread_t const thread;
	uint32_t const hiwat;
	uint32_t const depth;
	uint32_t padding;
#endif
};
```

## public 成员变量

### `SIZE`

`SIZE` 表示 `AutoreleasePoolPage` 的大小。在定义 `SIZE` 的地方用了 `PROTECT_AUTORELEASEPOOL` 宏做了控制：

```cpp
public:
	static size_t const SIZE =
#if PROTECT_AUTORELEASEPOOL
		PAGE_MAX_SIZE;  // must be multiple of vm page size
#else
		PAGE_MIN_SIZE;  // size and alignment, power of 2
#endif
```

在源码里搜索这个宏定义，可以看到其值是 `0` ：

```cpp
// Set this to 1 to mprotect() autorelease pool contents
#define PROTECT_AUTORELEASEPOOL 0
```

因此，`SIZE` 的值是 `PAGE_MIN_SIZE` ，再来看 `PAGE_MIN_SIZE` 的定义：

```cpp
#define PAGE_MIN_SHIFT          12
#define PAGE_MIN_SIZE           (1 << PAGE_MIN_SHIFT)
```

对 `1` 左移了 `12` 位，其值是 `2^12` ，也就是 `4 * 1024 Byte` = `4096 Byte` （`4 KB`）。因此可以得出结论一般情况下 **`AutoreleasePoolPage` 的大小是 `4 KB`** 。

如果将 `PROTECT_AUTORELEASEPOOL` 的值改为 `1` ，那么 `SIZE` 的值是 `PAGE_MAX_SIZE` ，其定义是：

```cpp
#define PAGE_MAX_SHIFT          14
#define PAGE_MAX_SIZE           (1 << PAGE_MAX_SHIFT)
```

同理，值是 `2^14` ，也就是 `16 * 1024 Byte` = `16384 Byte`（`16 KB`）。

## private 成员变量

### `key`

```cpp
static pthread_key_t const key = AUTORELEASE_POOL_KEY;
```

成员变量 `key` 的作用：**通过此 `key` 从当前线程的局部存储中（TLS）取出 hot page 。**

**1、`key` 的类型：`pthread_key_t`**

`pthread_key_t` 实际是一个 `unsigned long` 类型，它在系统头文件中的定义是：

```cpp
typedef __darwin_pthread_key_t pthread_key_t;
typedef unsigned long __darwin_pthread_key_t;
```

**2、`key` 的值：`AUTORELEASE_POOL_KEY`**

```cpp
#   define AUTORELEASE_POOL_KEY  ((tls_key_t)__PTK_FRAMEWORK_OBJC_KEY3)
```

`__PTK_FRAMEWORK_OBJC_KEY3` 定义在 `tsd_private.h` 文件中:

```cpp
/* Keys 40-49 for Objective-C runtime usage */
// ...
#define __PTK_FRAMEWORK_OBJC_KEY3	43
// ...
```

说明：

- 可以在 Xcode 中使用 `cmd` + `shift` + `o` 搜索 `__PTK_FRAMEWORK_OBJC_KEY3` 这个宏；
- `tsd` : *线程的私有数据 (thread specific data)* 。

### `SCRIBBLE`

```cpp
static uint8_t const SCRIBBLE = 0xA3;  // 0xA3A3A3A3 after releasing
```

在 `releaseUntil` 函数中，将 `release` 后空出的位置使用 `SCRIBBLE` 填充：

```cpp
memset((void*)page->next, SCRIBBLE, sizeof(*page->next));
```

### `COUNT`

```cpp
static size_t const COUNT = SIZE / sizeof(id);
```

可保存的对象指针的数量是 `4096` / `8` = `512`（指针的大小是 `8` 字节），实际可用容量要减去 `page` 自身的成员变量占用的 `56` 字节，也就是 `7` 个对象指针的大小 ，因此实际可存储 `505` 个对象指针。

## 宏（内部定义的）

### `EMPTY_POOL_PLACEHOLDER`

```cpp
#   define EMPTY_POOL_PLACEHOLDER ((id*)1)
```

注释：

> `EMPTY_POOL_PLACEHOLDER` is stored in **TLS** when exactly one pool is pushed and it has never contained any objects. This saves memory when the top level (i.e. `libdispatch`) pushes and pops pools but never uses them.

翻译：

当一个自动释放池被 `push()` 且它从未包含任何对象指针时，就将 `EMPTY_POOL_PLACEHOLDER` 存储在 `TLS` 中。当上层（如 `libdispatch` ）`push()` 和 `pop()` 自动释放池但从不使用它们时，这将节省内存。

### `POOL_BOUNDARY`

```cpp
#   define POOL_BOUNDARY nil
```

可以看到 `POOL_BOUNDARY` 就是 `nil` ，也就是说哨兵指针都是指向 `nil` 的。

## 宏（外部定义的）

### `SUPPORT_AUTORELEASEPOOL_DEDUP_PTRS`

```cpp
#if !__LP64__
#   define SUPPORT_AUTORELEASEPOOL_DEDUP_PTRS 0
#else
#   define SUPPORT_AUTORELEASEPOOL_DEDUP_PTRS 1
#endif
```

> 注释：Define SUPPORT_AUTORELEASEPOOL_DEDDUP_PTRS to combine consecutive pointers to the same object in autorelease pools

**翻译**：定义 `SUPPORT_AUTORELEASEPOOL_DEDDUP_PTRS` 来组合自动释放池中指向同一对象的连续指针。

这个宏在 64 位设备上的值是 `1` ，在其他设备上的值是 `0` 。

### `PROTECT_AUTORELEASEPOOL`

```cpp
// Set this to 1 to mprotect() autorelease pool contents
#define PROTECT_AUTORELEASEPOOL 0
```

这个宏的值是 `0` 。将其设为 `1` 可以对自动释放池的内容执行 `mprotect()` 。

由于宏的默认值为 `0` ，因此 `protect()` 和 `unprotect()` 这两个函数实际上什么也没做：

```cpp
inline void protect() {
#if PROTECT_AUTORELEASEPOOL
    mprotect(this, SIZE, PROT_READ);
    check();
#endif
}

inline void unprotect() {
#if PROTECT_AUTORELEASEPOOL
    check();
    mprotect(this, SIZE, PROT_READ | PROT_WRITE);
#endif
}
```

## 构造方法 & 析构方法

```cpp
AutoreleasePoolPage(AutoreleasePoolPage *newParent) :
    AutoreleasePoolPageData(begin(),
                            objc_thread_self(),
                            newParent,
                            newParent ? 1+newParent->depth : 0,
                            newParent ? newParent->hiwat : 0)
{
    if (objc::PageCountWarning != -1) {
        checkTooMuchAutorelease();
    }

    if (parent) {
        parent->check();
        ASSERT(!parent->child);
        parent->unprotect();
        parent->child = this;
        parent->protect();
    }
    protect();
}
```

```cpp
~AutoreleasePoolPage() 
{
    check();
    unprotect();
    ASSERT(empty());

    // Not recursive: we don't want to blow out the stack 
    // if a thread accumulates a stupendous amount of garbage
    ASSERT(!child);
}
```

## private 方法

### `begin()`

```cpp
id * begin() {
    return (id *) ((uint8_t *)this+sizeof(*this));
}
```

### `end()`

```cpp
id * end() {
    return (id *) ((uint8_t *)this+SIZE);
}
```

### `empty()`

```cpp
bool empty() {
    return next == begin();
}
```

### `full()`

```cpp
bool full() { 
    return next == end();
}
```

### `lessThanHalfFull()`

```cpp
bool lessThanHalfFull() {
    return (next - begin() < (end() - begin()) / 2);
}
```

### `add(id obj)`

将一个对象指针添加到自动释放池。

**简化版：**

```cpp
id *add(id obj)
{
    ASSERT(!full());
    id *ret;
    ret = next;  // faster than `return next-1` because of aliasing
    *next++ = obj;
    return ret;
}
```

**完整版：**

宏 `SUPPORT_AUTORELEASEPOOL_DEDUP_PTRS` 在 64 位设备上是 `1` ，里面的逻辑较多，可以暂时不看宏所包裹的内容。

```cpp
id *add(id obj)
{
    ASSERT(!full());
    unprotect();
    id *ret;

#if SUPPORT_AUTORELEASEPOOL_DEDUP_PTRS
    if (!DisableAutoreleaseCoalescing || !DisableAutoreleaseCoalescingLRU) {
        if (!DisableAutoreleaseCoalescingLRU) {
            if (!empty() && (obj != POOL_BOUNDARY)) {
                AutoreleasePoolEntry *topEntry = (AutoreleasePoolEntry *)next - 1;
                for (uintptr_t offset = 0; offset < 4; offset++) {
                    AutoreleasePoolEntry *offsetEntry = topEntry - offset;
                    if (offsetEntry <= (AutoreleasePoolEntry*)begin() || *(id *)offsetEntry == POOL_BOUNDARY) {
                        break;
                    }
                    if (offsetEntry->ptr == (uintptr_t)obj && offsetEntry->count < AutoreleasePoolEntry::maxCount) {
                        if (offset > 0) {
                            AutoreleasePoolEntry found = *offsetEntry;
                            memmove(offsetEntry, offsetEntry + 1, offset * sizeof(*offsetEntry));
                            *topEntry = found;
                        }
                        topEntry->count++;
                        ret = (id *)topEntry;  // need to reset ret
                        goto done;
                    }
                }
            }
        } else {
            if (!empty() && (obj != POOL_BOUNDARY)) {
                AutoreleasePoolEntry *prevEntry = (AutoreleasePoolEntry *)next - 1;
                if (prevEntry->ptr == (uintptr_t)obj && prevEntry->count < AutoreleasePoolEntry::maxCount) {
                    prevEntry->count++;
                    ret = (id *)prevEntry;  // need to reset ret
                    goto done;
                }
            }
        }
    }
#endif
    ret = next;  // faster than `return next-1` because of aliasing
    *next++ = obj;
#if SUPPORT_AUTORELEASEPOOL_DEDUP_PTRS
    // Make sure obj fits in the bits available for it
    ASSERT(((AutoreleasePoolEntry *)ret)->ptr == (uintptr_t)obj);
#endif
    done:
    protect();
    return ret;
}
```

### `releaseAll()`

```cpp
void releaseAll()
{
    releaseUntil(begin());
}
```

### `releaseUntil(id *stop)`

```cpp
void releaseUntil(id *stop)
{
    // Not recursive: we don't want to blow out the stack 
    // if a thread accumulates a stupendous amount of garbage
    
    while (this->next != stop) {
        // Restart from hotPage() every time, in case -release 
        // autoreleased more objects
        AutoreleasePoolPage *page = hotPage();

        // fixme I think this `while` can be `if`, but I can't prove it
        while (page->empty()) {
            page = page->parent;
            setHotPage(page);
        }

        page->unprotect();
#if SUPPORT_AUTORELEASEPOOL_DEDUP_PTRS
        AutoreleasePoolEntry* entry = (AutoreleasePoolEntry*) --page->next;

        // create an obj with the zeroed out top byte and release that
        id obj = (id)entry->ptr;
        int count = (int)entry->count;  // grab these before memset
#else
        id obj = *--page->next;
#endif
        memset((void*)page->next, SCRIBBLE, sizeof(*page->next));
        page->protect();

        if (obj != POOL_BOUNDARY) {
#if SUPPORT_AUTORELEASEPOOL_DEDUP_PTRS
            // release count+1 times since it is count of the additional
            // autoreleases beyond the first one
            for (int i = 0; i < count + 1; i++) {
                objc_release(obj);
            }
#else
            objc_release(obj);
#endif
        }
    }

    setHotPage(this);

#if DEBUG
    // we expect any children to be completely empty
    for (AutoreleasePoolPage *page = child; page; page = page->child) {
        ASSERT(page->empty());
    }
#endif
}
```

### `kill()`

将当前页面以及子页面全部删除。

从当前的 `page` 开始，一直根据 `child` 链向前走直到 `child` 为空，把经过的 `page` 全部执行 `delete` 操作（包括当前 `page` ）。

`kill()` 被调用到的地方：

**1）** `tls_dealloc(void *p)` 方法中：

```cpp
page->kill()
```

**2）** `popPage()` 方法中：

```cpp
...
else if (page->child) {
    // hysteresis: keep one empty child if page is more than half full
    if (page->lessThanHalfFull()) {
        page->child->kill();
    }
    else if (page->child->child) {
        page->child->child->kill();
    }
}
...
```

**`kill()` 方法说明**：

- 删除 `page` 使用的是 `delete` 关键字；
- 循环使用的是 `do...while` ，所以会至少进行一次 `delete` ；
- `kill()` 方法中的`this` 是调用它的 `page` 。比如调用 `page->child->kill()` ，此时 `kill()` 方法中的 `this` 就是指代 `page->child` 。

```cpp
void kill()
{
    // Not recursive: we don't want to blow out the stack 
    // if a thread accumulates a stupendous amount of garbage
    AutoreleasePoolPage *page = this;
    while (page->child) page = page->child;

    AutoreleasePoolPage *deathptr;
    do {
        deathptr = page;
        page = page->parent;
        if (page) {
            page->unprotect();
            page->child = nil;
            page->protect();
        }
        delete deathptr;
    } while (deathptr != this);
}
```

### `tls_dealloc(void *p)`

`tls_dealloc(void *p)` 是*线程局部存储 (Thread Local Stroge, TLS)* 的析构函数，它是在 `AutoreleasePoolPage` 的 `init()` 方法中作为**函数指针**传入给 `pthread_key_init_np()` 函数的第二个参数的：

```cpp
pthread_key_init_np(AutoreleasePoolPage::key, AutoreleasePoolPage::tls_dealloc);
```

在 `tls_dealloc(void *p)` 中，要对自动释放池内的所有自动释放对象执行 `release()` 操作，然后调用 `kill()` 来释放所有的 `page` 。

```cpp
static void tls_dealloc(void *p) 
{
    if (p == (void*)EMPTY_POOL_PLACEHOLDER) {
        // No objects or pool pages to clean up here.
        return;
    }

    // reinstate TLS value while we work
    setHotPage((AutoreleasePoolPage *)p);

    if (AutoreleasePoolPage *page = coldPage()) {
        if (!page->empty()) objc_autoreleasePoolPop(page->begin());  // pop all of the pools
        if (slowpath(DebugMissingPools || DebugPoolAllocation)) {
            // pop() killed the pages already
        } else {
            page->kill();  // free all of the pages
        }
    }
    
    // clear TLS value so TLS destruction doesn't loop
    setHotPage(nil);
}
```

### `pageForPointer(const void *p)` & `pageForPointer(uintptr_t p)`

通过内存地址的计算，获取 `p` 指针所在的 `page` 的首地址。将指针与 `page` 的大小，也就是 `4096` 取模，得到当前指针的 `offset` ，再通过 `(p - offset)` 就能获取到 `p` 所在的 `page` 的起始地址：

```cpp
static AutoreleasePoolPage *pageForPointer(const void *p) 
{
    return pageForPointer((uintptr_t)p);
}

static AutoreleasePoolPage *pageForPointer(uintptr_t p) 
{
    AutoreleasePoolPage *result;
    uintptr_t offset = p % SIZE;

    ASSERT(offset >= sizeof(AutoreleasePoolPage));

    result = (AutoreleasePoolPage *)(p - offset);
    result->fastcheck();

    return result;
}
```

而最后调用的方法 `fastCheck()` 用来检查当前的 `result` 是不是一个 `AutoreleasePoolPage` 。

通过检查 magic_t 结构体中的某个成员是否为 0xA1A1A1A1。

其中，`uintptr_t` 实际上就是 `unsigned long` ：

```cpp
typedef unsigned long           uintptr_t;
```

### `haveEmptyPoolPlaceholder()` & `setEmptyPoolPlaceholder()`

判断 `tls` 中的 `key`（`AUTORELEASE_POOL_KEY`）对应的值是否是 `EMPTY_POOL_PLACEHOLDER` ：

```cpp
static inline bool haveEmptyPoolPlaceholder()
{
    id *tls = (id *)tls_get_direct(key);
    return (tls == EMPTY_POOL_PLACEHOLDER);
}
```

在 `tls` 中将 `key`（`AUTORELEASE_POOL_KEY`）的值设置为 `EMPTY_POOL_PLACEHOLDER` ：

```cpp
static inline id* setEmptyPoolPlaceholder()
{
    ASSERT(tls_get_direct(key) == nil);
    tls_set_direct(key, (void *)EMPTY_POOL_PLACEHOLDER);
    return EMPTY_POOL_PLACEHOLDER;
}
```

### `hotPage()` & `setHotPage(AutoreleasePoolPage *page)`

从 `tls` 中获取 `hotPage` ：

```cpp
static inline AutoreleasePoolPage *hotPage()
{
    AutoreleasePoolPage *result = (AutoreleasePoolPage *)
        tls_get_direct(key);
    if ((id *)result == EMPTY_POOL_PLACEHOLDER) return nil;
    if (result) result->fastcheck();
    return result;
}
```

将 `hotPage` 存入 `tls` ：

```cpp
static inline void setHotPage(AutoreleasePoolPage *page) 
{
    if (page) page->fastcheck();
    tls_set_direct(key, (void *)page);
}
```

### `coldPage()`

`coldPage` 是双链表中的第一个 `page` ：

```cpp
static inline AutoreleasePoolPage *coldPage() 
{
    AutoreleasePoolPage *result = hotPage();
    if (result) {
        while (result->parent) {
            result = result->parent;
            result->fastcheck();
        }
    }
    return result;
}
```

### `autoreleaseFast(id obj)`

`AutoreleasePoolPage` 的 `push()` 和 `autorelease(id obj)` 方法最终都是调用的 `autoreleaseFast(id obj)` ：

```cpp
static inline id *autoreleaseFast(id obj)
{
    AutoreleasePoolPage *page = hotPage();
    if (page && !page->full()) {
        return page->add(obj);
    } else if (page) {
        return autoreleaseFullPage(obj, page);
    } else {
        return autoreleaseNoPage(obj);
    }
}
```

在此方法中，先取出 `hotPage` 然后分三种情况处理：

- `page` 存在且未满，则直接调用 `page->add(obj)` 将 `obj` 存入到自动释放池中；
- `page` 存在但已满，调用 `autoreleaseFullPage(obj, page)` ；
- `page` 不存在，调用 `autoreleaseNoPage(obj)` 。

### `autoreleaseFullPage(id obj, AutoreleasePoolPage *page)`

注释：

> The hot page is full. Step to the next non-full page, adding a new page if necessary. Then add the object to that page.

解读：

*hot page* 已满，跳转到下一个未满的 `page` ，若不存在则添加新 `page` 。最后将 `obj` 添加到该 `page` 中。

```cpp
static __attribute__((noinline))
id *autoreleaseFullPage(id obj, AutoreleasePoolPage *page)
{
    ASSERT(page == hotPage());
    ASSERT(page->full()  ||  DebugPoolAllocation);

    do {
        if (page->child) page = page->child;
        else page = new AutoreleasePoolPage(page);
    } while (page->full());

    setHotPage(page);
    return page->add(obj);
}
```

如果存在未满的 `page->child` ，则将其设置为 *hot page* ；否则需要创建一个新的 `page` 。

最后执行 `page->add(obj)` 将 `obj` 添加到自动释放池中。

### `autoreleaseNoPage(id obj)`

注释：

> "No page" could mean no pool has been pushed or an empty placeholder pool has been pushed and has no contents yet

翻译：

"*No page*" 指未曾执行 `push()` 因而还不存在 pool ，或者是执行 `push()` 后创建的是 *empty placeholder pool* 、因此里面还没有内容。

代码解读：

此方法创建了一个新的 `page` ，最后调用 `page->add(obj)` 将 `obj` 添加到 `page` 中。

```cpp
static __attribute__((noinline))
id *autoreleaseNoPage(id obj)
{
    ASSERT(!hotPage());

    bool pushExtraBoundary = false;
    if (haveEmptyPoolPlaceholder()) {
        // We are pushing a second pool over the empty placeholder pool
        // or pushing the first object into the empty placeholder pool.
        // Before doing that, push a pool boundary on behalf of the pool 
        // that is currently represented by the empty placeholder.
        pushExtraBoundary = true;
    }
    else if (obj != POOL_BOUNDARY  &&  DebugMissingPools) {
        // We are pushing an object with no pool in place, 
        // and no-pool debugging was requested by environment.
        _objc_inform("MISSING POOLS: (%p) Object %p of class %s "
                     "autoreleased with no pool in place - "
                     "just leaking - break on "
                     "objc_autoreleaseNoPool() to debug", 
                     objc_thread_self(), (void*)obj, object_getClassName(obj));
        objc_autoreleaseNoPool(obj);
        return nil;
    }
    else if (obj == POOL_BOUNDARY  &&  !DebugPoolAllocation) {
        // We are pushing a pool with no pool in place,
        // and alloc-per-pool debugging was not requested.
        // Install and return the empty pool placeholder.
        return setEmptyPoolPlaceholder();
    }

    // We are pushing an object or a non-placeholder'd pool.

    // Install the first page.
    AutoreleasePoolPage *page = new AutoreleasePoolPage(nil);
    setHotPage(page);
    
    // Push a boundary on behalf of the previously-placeholder'd pool.
    if (pushExtraBoundary) {
        page->add(POOL_BOUNDARY);
    }
    
    // Push the requested object or pool.
    return page->add(obj);
}
```

### `autoreleaseNewPage(id obj)` (Debug only)

此方法应该只用于 debug 环境。

```cpp
static __attribute__((noinline))
id *autoreleaseNewPage(id obj)
{
    AutoreleasePoolPage *page = hotPage();
    if (page) return autoreleaseFullPage(obj, page);
    else return autoreleaseNoPage(obj);
}
```

仅在 `push()` 中用到了此方法，通过 `DebugPoolAllocation` 进行的判断：

> 调用时的注释：Each autorelease pool starts on a new pool page

```cpp
static inline void *push() 
{
    id *dest;
    if (slowpath(DebugPoolAllocation)) {
        // Each autorelease pool starts on a new pool page.
        dest = autoreleaseNewPage(POOL_BOUNDARY);
    } else {
        dest = autoreleaseFast(POOL_BOUNDARY);
    }
    ASSERT(dest == EMPTY_POOL_PLACEHOLDER || *dest == POOL_BOUNDARY);
    return dest;
}
```

## public 方法

### `autorelease(id obj)`

```cpp
static inline id autorelease(id obj)
{
    ASSERT(!obj->isTaggedPointerOrNil());
    id *dest __unused = autoreleaseFast(obj);
#if SUPPORT_AUTORELEASEPOOL_DEDUP_PTRS
    ASSERT(!dest  ||  dest == EMPTY_POOL_PLACEHOLDER  ||  (id)((AutoreleasePoolEntry *)dest)->ptr == obj);
#else
    ASSERT(!dest  ||  dest == EMPTY_POOL_PLACEHOLDER  ||  *dest == obj);
#endif
    return obj;
}
```

- 使用 `obj->isTaggedPointerOrNil()` 对 `Tagged Pointer` 做了断言；
- 调用了 `autoreleaseFast(obj)` 将 `obj` 加入到自动释放池中；
- `dest` 这个值只用于 `ASSERT` 中，因此使用 `__unused` 来修饰了。

### `push()`

```cpp
static inline void *push() 
{
    id *dest;
    if (slowpath(DebugPoolAllocation)) {
        // Each autorelease pool starts on a new pool page.
        dest = autoreleaseNewPage(POOL_BOUNDARY);
    } else {
        dest = autoreleaseFast(POOL_BOUNDARY);
    }
    ASSERT(dest == EMPTY_POOL_PLACEHOLDER || *dest == POOL_BOUNDARY);
    return dest;
}
```

实际上调用了 `autoreleaseFast(POOL_BOUNDARY)` ，另一个`autoreleaseNewPage(POOL_BOUNDARY)` 仅用于 Debug 环境。

可以看到返回值 `dest` 有两种类型：要么是 `EMPTY_POOL_PLACEHOLDER` ，要么是指向 `POOL_BOUNDARY` 的指针。

返回值 `dest` 就是哨兵指针，它也是后面执行 `pop(void *token)` 时需要的参数 `token` 。

### `pop(void *token)`

先调用 `pageForPointer(token)` 找到 `token`（也就是哨兵指针）所在的 `page` ，再调用了 `popPage<false>(token, page, stop)` 。

```cpp
static inline void
pop(void *token)
{
    AutoreleasePoolPage *page;
    id *stop;
    if (token == (void*)EMPTY_POOL_PLACEHOLDER) {
        // Popping the top-level placeholder pool.
        page = hotPage();
        if (!page) {
            // Pool was never used. Clear the placeholder.
            return setHotPage(nil);
        }
        // Pool was used. Pop its contents normally.
        // Pool pages remain allocated for re-use as usual.
        page = coldPage();
        token = page->begin();
    } else {
        page = pageForPointer(token);
    }

    stop = (id *)token;
    if (*stop != POOL_BOUNDARY) {
        if (stop == page->begin()  &&  !page->parent) {
            // Start of coldest page may correctly not be POOL_BOUNDARY:
            // 1. top-level pool is popped, leaving the cold page in place
            // 2. an object is autoreleased with no pool
        } else {
            // Error. For bincompat purposes this is not 
            // fatal in executables built with old SDKs.
            return badPop(token);
        }
    }

    if (slowpath(PrintPoolHiwat || DebugPoolAllocation || DebugMissingPools)) {
        return popPageDebug(token, page, stop);
    }

    return popPage<false>(token, page, stop);
}
```

### `popPage(void *token, AutoreleasePoolPage *page, id *stop)`

`pop(void *token)` 会调用此方法，然后此方法会调用 `page->releaseUntil(stop)` ，最后会调用 `kill()` 方法来删除 `page` 。

`popPage()` 方法中对 `kill()` 方法调用的说明：

- 如果 `page->child` 存在，则调用 `page->lessThanHalfFull()` 方法检测“当前 `page` 存储的内容是否超过一半”：
  - 不超过一半，则删除 `page->child` 及之后的节点；
  - 超过一半，则保留 `page->child` ，删除 `page->child->child` 及之后的节点。

```cpp
template<bool allowDebug>
static void
popPage(void *token, AutoreleasePoolPage *page, id *stop)
{
    if (allowDebug && PrintPoolHiwat) printHiwat();

    page->releaseUntil(stop);

    // memory: delete empty children
    if (allowDebug && DebugPoolAllocation  &&  page->empty()) {
        // special case: delete everything during page-per-pool debugging
        AutoreleasePoolPage *parent = page->parent;
        page->kill();
        setHotPage(parent);
    } else if (allowDebug && DebugMissingPools  &&  page->empty()  &&  !page->parent) {
        // special case: delete everything for pop(top)
        // when debugging missing autorelease pools
        page->kill();
        setHotPage(nil);
    } else if (page->child) {
        // hysteresis: keep one empty child if page is more than half full
        if (page->lessThanHalfFull()) {
            page->child->kill();
        }
        else if (page->child->child) {
            page->child->child->kill();
        }
    }
}
```

### `init()`

```cpp
static void init()
{
    int r __unused = pthread_key_init_np(AutoreleasePoolPage::key, 
                                         AutoreleasePoolPage::tls_dealloc);
    ASSERT(r == 0);
}
```

> 说明：`np` 是 *not portable* 的缩写，代表不可移植。

这里调用 `pthread_key_init_np(int, void (*)(void *))` 执行了 `pthread` 的初始化，其中：

- 第一个参数：`AutoreleasePoolPage::key` ，值为 `AUTORELEASE_POOL_KEY` ；
- 第二个参数：`AutoreleasePoolPage::tls_dealloc` ，是析构函数。

`pthread_key_init_np()` 的函数原型是：

```c
/* setup destructor function for static key as it is not created with pthread_key_create() */
extern int pthread_key_init_np(int, void (*)(void *));
```

注释的翻译：为静态键设置**析构函数**，因为它不是用 `pthread_key_create()` 创建的。

## 便捷的函数

### `objc_autoreleasePoolPush(void)`

实际上调用了 `AutoreleasePoolPage::push()` 方法：

```cpp
void *
objc_autoreleasePoolPush(void)
{
    return AutoreleasePoolPage::push();
}
```

而 `_objc_autoreleasePoolPush()` 其实只是简单调用了 `objc_autoreleasePoolPush()` ：

```cpp
void *
_objc_autoreleasePoolPush(void)
{
    return objc_autoreleasePoolPush();
}
```

**`push` 的调用路径**：

```cpp
_objc_autoreleasePoolPush()
    objc_autoreleasePoolPush()
        AutoreleasePoolPage::push()
            autoreleaseFast(POOL_BOUNDARY)
                || add(obj)
                || autoreleaseFullPage(obj, page)
                || autoreleaseNoPage(obj)
```

注意：

- 在 `push()` 内调用 `autoreleaseFast(id obj)` 传入的参数是 `POOL_BOUNDARY` ；
- `autoreleaseFullPage(obj, page)` 和 `autoreleaseNoPage(obj)` 最终调会调用 `add(obj)` 方法。

### `objc_autoreleasePoolPop(void *ctxt)`

实际上调用了 `AutoreleasePoolPage::pop(void *token)` 方法，这里传入的 `ctxt` 就是 `token` ，也就是哨兵指针：

```cpp
NEVER_INLINE
void
objc_autoreleasePoolPop(void *ctxt)
{
    AutoreleasePoolPage::pop(ctxt);
}
```

同样，`_objc_autoreleasePoolPop(void *ctxt)` 也只是简单调用了 `objc_autoreleasePoolPop(void *ctxt)` ：

```cpp
void
_objc_autoreleasePoolPop(void *ctxt)
{
    objc_autoreleasePoolPop(ctxt);
}
```

**`pop()` 的调用路径**：

```cpp
_objc_autoreleasePoolPop(void *ctxt)
    objc_autoreleasePoolPop(void *ctxt)
        AutoreleasePoolPage::pop(ctxt)
            popPage<false>(token, page, stop)
                && releaseUntil(stop)
                && kill()
```

### `objc_autorelease(id obj)`

**1）**`objc_autorelease(id obj)`

```cpp
/***********************************************************************
* Optimized retain/release/autorelease entrypoints
**********************************************************************/

__attribute__((aligned(16), flatten, noinline))
id
objc_autorelease(id obj)
{
    if (obj->isTaggedPointerOrNil()) return obj;
    return obj->autorelease();
}
```

**2）**`objc_object::autorelease()`

如果 `ISA()->hasCustomRR()` 为 `false` ，则直接调转到第 `5` 步，否则执行第 `3` 步：

```cpp
// Equivalent to [this autorelease], with shortcuts if there is no override
inline id 
objc_object::autorelease()
{
    ASSERT(!isTaggedPointer());
    if (fastpath(!ISA()->hasCustomRR())) {
        return rootAutorelease();
    }

    return ((id(*)(objc_object *, SEL))objc_msgSend)(this, @selector(autorelease));
}
```

**3）**`-[NSObject autorelease]`

```cpp
// Replaced by ObjectAlloc
- (id)autorelease {
    return _objc_rootAutorelease(self);
}
```

**4）**`_objc_rootAutorelease(id obj)`

```cpp
NEVER_INLINE id
_objc_rootAutorelease(id obj)
{
    ASSERT(obj);
    return obj->rootAutorelease();
}
```

**5）**`objc_object::rootAutorelease()`

```cpp
// Base autorelease implementation, ignoring overrides.
inline id 
objc_object::rootAutorelease()
{
    if (isTaggedPointer()) return (id)this;
    if (prepareOptimizedReturn(ReturnAtPlus1)) return (id)this;

    return rootAutorelease2();
}
```

**6）**`objc_object::rootAutorelease2()`

```cpp
__attribute__((noinline,used))
id 
objc_object::rootAutorelease2()
{
    ASSERT(!isTaggedPointer());
    return AutoreleasePoolPage::autorelease((id)this);
}
```

**7）**`AutoreleasePoolPage::autorelease(id obj)`

```cpp
static inline id autorelease(id obj)
{
    ASSERT(!obj->isTaggedPointerOrNil());
    id *dest __unused = autoreleaseFast(obj);
#if SUPPORT_AUTORELEASEPOOL_DEDUP_PTRS
    ASSERT(!dest  ||  dest == EMPTY_POOL_PLACEHOLDER  ||  (id)((AutoreleasePoolEntry *)dest)->ptr == obj);
#else
    ASSERT(!dest  ||  dest == EMPTY_POOL_PLACEHOLDER  ||  *dest == obj);
#endif
    return obj;
}
```

**8）**`autoreleaseFast(id obj)`

```cpp
static inline id *autoreleaseFast(id obj)
{
    AutoreleasePoolPage *page = hotPage();
    if (page && !page->full()) {
        return page->add(obj);
    } else if (page) {
        return autoreleaseFullPage(obj, page);
    } else {
        return autoreleaseNoPage(obj);
    }
}
```

`autorelease` 方法的调用栈：

> 参考：[draveness《自动释放池的前世今生》](https://github.com/draveness/analyze/blob/master/contents/objc/自动释放池的前世今生.md#autorelease-方法)

❓ 这种分支图是用什么工具画的？

```objectivec
- [NSObject autorelease]
└── id objc_object::rootAutorelease()
    └── id objc_object::rootAutorelease2()
        └── static id AutoreleasePoolPage::autorelease(id obj)
            └── static id AutoreleasePoolPage::autoreleaseFast(id obj)
                ├── id *add(id obj)
                ├── static id *autoreleaseFullPage(id obj, AutoreleasePoolPage *page)
                │   ├── AutoreleasePoolPage(AutoreleasePoolPage *newParent)
                │   └── id *add(id obj)
                └── static id *autoreleaseNoPage(id obj)
                    ├── AutoreleasePoolPage(AutoreleasePoolPage *newParent)
                    └── id *add(id obj)

```

**引申问题**：

因此可以得知，即使一个 `NSTread` 子线程没有使用 `@autoreleasepool` 包裹，对象在调用 `autorelease` 之后，最终会调用 `autoreleaseNoPage(obj)` 来创建一个自动释放池。

线程销毁时，会在 `tls_dealloc(void *p)` 方法中：

- 先调用 `coldPage()` 方法找到双链表中的第一个 `page` ；
- 再调用 `objc_autoreleasePoolPop(page->begin())` 来释放所有 `autorelease` 对象；
- 最后调用 `page->kill()` 来释放所有的 page 。

`tls_dealloc(void *p)` 方法中的核心代码：

```cpp
// ...
if (AutoreleasePoolPage *page = coldPage()) {
    if (!page->empty()) objc_autoreleasePoolPop(page->begin());  // pop all of the pools
    if (slowpath(DebugMissingPools || DebugPoolAllocation)) {
        // pop() killed the pages already
    } else {
        page->kill();  // free all of the pages
    }
}
// ...
```

**结论**：

- 如果某个 `NSTread` 子线程只需要执行一次任务就销毁，则`autorelease` 对象会在线程销毁时释放，不会引起内存泄漏；
- ~~如果某个 `NSTread` 子线程是常驻子线程，却没有使用 `@autoreleasepool` 包裹，那么 `autorelease` 对象会因为没有释放而占用大量的内存，造成内存泄漏。~~（需要再研究一下 AFN2 的常驻线程）

因此常驻子线程的~~回调方法~~一定要使用 `@autoreleasepool` 包裹，以保障每次执行完回调后，产生的 `autorelease` 对象能得到及时释放。

## 参考

- [iOS 从源码解析 Runtime (六) ：AutoreleasePool 实现原理解读](https://juejin.cn/post/6877085831647985677)
