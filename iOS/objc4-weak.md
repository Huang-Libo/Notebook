# weak 源码分析

> 说明：本文摘出的源码均来自 **objc4-818.2** 这个版本。

<h2>目录</h2>

- [weak 源码分析](#weak-源码分析)
  - [头文件声明](#头文件声明)
    - [注释](#注释)
    - [`weak_table_t`](#weak_table_t)
    - [`weak_entry_t`](#weak_entry_t)
    - [`weak_referrer_t`](#weak_referrer_t)
  - [参考](#参考)

## 头文件声明

### 注释

`objc-weak.h` 的开头处有一段注释：

> The weak table is a hash table governed by a single ~~spin lock~~.  
>  
> An allocated blob of memory, most often an object, but under `GC` any such allocation, may have its address stored in a `__weak` marked storage location through use of compiler generated write-barriers or hand coded uses of the register weak primitive. Associated with the registration can be a callback block for the case when one of the allocated chunks of memory is reclaimed.  
>  
> The table is hashed on the address of the allocated memory.  When `__weak` marked memory changes its reference, we count on the fact that we can still see its previous reference.  
>  
> So, in the hash table, indexed by the weakly referenced item, is a list of all locations where this address is currently being stored.  
>  
> For ARC, we also keep track of whether an arbitrary object is being deallocated by briefly placing it in the table just prior to invoking dealloc, and removing it via `objc_clear_deallocating` just prior to memory reclamation.

**翻译**：

弱引用表由一个~~自旋锁~~（已改用互斥锁 `os_unfair_lock` ）管理的哈希表。

。。。后面的没看太懂。。。❓

### `weak_table_t`

全局弱引用表：

```cpp
struct weak_table_t {
    weak_entry_t *weak_entries;
    size_t    num_entries;
    uintptr_t mask;
    uintptr_t max_hash_displacement;
};
```

注释：

> The global weak references table.  
> Stores object ids as keys, and `weak_entry_t` structs as their values.

哈希表的键值：

- key ：对象的地址（object `id`s）；
- value ：`weak_entry_t` 结构体，里面存有弱引用指针的地址（二级指针）的数组。

### `weak_entry_t`

`weak_entry_t` 是全局弱引用表中 `value` 的类型。弱引用指针的地址存储在 `weak_entry_t` 内的 `weak_referrer_t` 类型中。

弱引用指针的地址（二级指针）最初存储在 `inline_referrers` 中（定长数组），当弱引用指针的数量超过 `WEAK_INLINE_COUNT`（值为 `4` ）时，才申请内存创建一个 `referrers` 数组。

```cpp
struct weak_entry_t {
    DisguisedPtr<objc_object> referent;
    union {
        struct {
            weak_referrer_t *referrers;
            uintptr_t        out_of_line_ness : 2;
            uintptr_t        num_refs : PTR_MINUS_2;
            uintptr_t        mask;
            uintptr_t        max_hash_displacement;
        };
        struct {
            // out_of_line_ness field is low bits of inline_referrers[1]
            weak_referrer_t  inline_referrers[WEAK_INLINE_COUNT];
        };
    };

    bool out_of_line() {
        return (out_of_line_ness == REFERRERS_OUT_OF_LINE);
    }

    weak_entry_t& operator=(const weak_entry_t& other) {
        memcpy(this, &other, sizeof(other));
        return *this;
    }

    weak_entry_t(objc_object *newReferent, objc_object **newReferrer)
        : referent(newReferent)
    {
        inline_referrers[0] = newReferrer;
        for (int i = 1; i < WEAK_INLINE_COUNT; i++) {
            inline_referrers[i] = nil;
        }
    }
};
```

### `weak_referrer_t`

```cpp
typedef DisguisedPtr<objc_object *> weak_referrer_t;
```

注释：

> The address of a `__weak` variable.  
> These pointers are stored disguised so memory analysis tools don't see lots of interior pointers from the weak table into objects.

翻译：

`weak_referrer_t` 是 `__weak` 弱引用指针的地址。

## 参考

- [iOS weak 底层实现原理(一)](https://juejin.cn/post/6865468675940417550)
