org 0x7e00
jmp 0x0000:start

codigo: db 'struct group_info init_groups = { .usage = ATOMIC_INIT(2) };',10,13,'',10,13,'struct group_info *groups_alloc(int gidsetsize){',10,13,'',10,13,'    struct group_info *group_info;',10,13,'',10,13,'    int nblocks;',10,13,'',10,13,'    int i;',10,13,'',10,13,'',10,13,'',10,13,'    nblocks = (gidsetsize + NGROUPS_PER_BLOCK - 1) / NGROUPS_PER_BLOCK;',10,13,'',10,13,'    /* Make sure we always allocate at least one indirect block pointer */',10,13,'',10,13,'    nblocks = nblocks ? : 1;',10,13,'',10,13,'    group_info = kmalloc(sizeof(*group_info) + nblocks*sizeof(gid_t *), GFP_USER);',10,13,'',10,13,'    if (!group_info)',10,13,'',10,13,'        return NULL;',10,13,'',10,13,'    group_info->ngroups = gidsetsize;',10,13,'',10,13,'    group_info->nblocks = nblocks;',10,13,'',10,13,'    atomic_set(&group_info->usage, 1);',10,13,'',10,13,'',10,13,'',10,13,'    if (gidsetsize <= NGROUPS_SMALL)',10,13,'',10,13,'        group_info->blocks[0] = group_info->small_block;',10,13,'',10,13,'    else {',10,13,'',10,13,'        for (i = 0; i < nblocks; i++) {',10,13,'',10,13,'            gid_t *b;',10,13,'',10,13,'            b = (void *)__get_free_page(GFP_USER);',10,13,'',10,13,'            if (!b)',10,13,'',10,13,'                goto out_undo_partial_alloc;',10,13,'',10,13,'            group_info->blocks[i] = b;',10,13,'',10,13,'        }',10,13,'',10,13,'    }',10,13,'',10,13,'    return group_info;',10,13,'',10,13,'',10,13,'',10,13,'out_undo_partial_alloc:',10,13,'',10,13,'    while (--i >= 0) {',10,13,'',10,13,'        free_page((unsigned long)group_info->blocks[i]);',10,13,'',10,13,'    }',10,13,'',10,13,'    kfree(group_info);',10,13,'',10,13,'    return NULL;',10,13,'',10,13,'}',10,13,'',10,13,'',10,13,'',10,13,'EXPORT_SYMBOL(groups_alloc);',10,13,'',10,13,'',10,13,'',10,13,'void groups_free(struct group_info *group_info)',10,13,'',10,13,'{',10,13,'',10,13,'    if (group_info->blocks[0] != group_info->small_block) {',10,13,'',10,13,'        int i;',10,13,'',10,13,'        for (i = 0; i < group_info->nblocks; i++)',10,13,'',10,13,'            free_page((unsigned long)group_info->blocks[i]);',10,13,'',10,13,'    }',10,13,'',10,13,'    kfree(group_info);',10,13,'',10,13,'}',10,13,'',10,13,'',10,13,'',10,13,'EXPORT_SYMBOL(groups_free);',10,13,'',10,13,'',10,13,'',10,13,'/* export the group_info to a user-space array */',10,13,'',10,13,'static int groups_to_user(gid_t __user *grouplist,',10,13,'',10,13,'              const struct group_info *group_info)',10,13,'',10,13,'{',10,13,'',10,13,'    int i;',10,13,'',10,13,'    unsigned int count = group_info->ngroups;',10,13,'',10,13,'',10,13,'',10,13,'    for (i = 0; i < group_info->nblocks; i++) {',10,13,'',10,13,'        unsigned int cp_count = min(NGROUPS_PER_BLOCK, count);',10,13,'',10,13,'        unsigned int len = cp_count * sizeof(*grouplist);',10,13,'',10,13,'',10,13,'',10,13,'        if (copy_to_user(grouplist, group_info->blocks[i], len))',10,13,'',10,13,'            return -EFAULT;',10,13,'',10,13,'',10,13,'',10,13,'        grouplist += NGROUPS_PER_BLOCK;',10,13,'',10,13,'        count -= cp_count;',10,13,'',10,13,'    }',10,13,'',10,13,'    return 0;',10,13,'',10,13,'}',10,13,'',10,13,'',10,13,'',10,13,'/* fill a group_info from a user-space array - it must be allocated already */',10,13,'',10,13,'static int groups_from_user(struct group_info *group_info,',10,13,'',10,13,'    gid_t __user *grouplist)',10,13,'',10,13,'{',10,13,'',10,13,'    int i;',10,13,'',10,13,'    unsigned int count = group_info->ngroups;',10,13,'',10,13,'',10,13,'',10,13,'    for (i = 0; i < group_info->nblocks; i++) {',10,13,'',10,13,'        unsigned int cp_count = min(NGROUPS_PER_BLOCK, count);',10,13,'',10,13,'        unsigned int len = cp_count * sizeof(*grouplist);',10,13,'',10,13,'',10,13,'',10,13,'        if (copy_from_user(group_info->blocks[i], grouplist, len))',10,13,'',10,13,'            return -EFAULT;',10,13,'',10,13,'',10,13,'',10,13,'        grouplist += NGROUPS_PER_BLOCK;',10,13,'',10,13,'        count -= cp_count;',10,13,'',10,13,'    }',10,13,'',10,13,'    return 0;',10,13,'',10,13,'}',10,13,'',10,13,'',10,13,'',10,13,'/* a simple Shell sort */',10,13,'',10,13,'static void groups_sort(struct group_info *group_info)',10,13,'',10,13,'{',10,13,'',10,13,'    int base, max, stride;',10,13,'',10,13,'    int gidsetsize = group_info->ngroups;',10,13,'',10,13,'',10,13,'',10,13,'    for (stride = 1; stride < gidsetsize; stride = 3 * stride + 1)',10,13,'',10,13,'        ; /* nothing */',10,13,'',10,13,'    stride /= 3;',10,13,'',10,13,'',10,13,'',10,13,'    while (stride) {',10,13,'',10,13,'        max = gidsetsize - stride;',10,13,'',10,13,'        for (base = 0; base < max; base++) {',10,13,'',10,13,'            int left = base;',10,13,'',10,13,'            int right = left + stride;',10,13,'',10,13,'            gid_t tmp = GROUP_AT(group_info, right);',10,13,'',10,13,'',10,13,'',10,13,'            while (left >= 0 && GROUP_AT(group_info, left) > tmp) {',10,13,'',10,13,'                GROUP_AT(group_info, right) =',10,13,'',10,13,'                    GROUP_AT(group_info, left);',10,13,'',10,13,'                right = left;',10,13,'',10,13,'                left -= stride;',10,13,'',10,13,'            }',10,13,'',10,13,'            GROUP_AT(group_info, right) = tmp;',10,13,'',10,13,'        }',10,13,'',10,13,'        stride /= 3;',10,13,'',10,13,'    }',10,13,'',10,13,'}',10,13,'',10,13,'',10,13,'',10,13,'/* a simple bsearch */',10,13,'',10,13,'int groups_search(const struct group_info *group_info, gid_t grp)',10,13,'',10,13,'{',10,13,'',10,13,'    unsigned int left, right;',10,13,'',10,13,'',10,13,'',10,13,'    if (!group_info)',10,13,'',10,13,'        return 0;',10,13,'',10,13,'',10,13,'',10,13,'    left = 0;',10,13,'',10,13,'    right = group_info->ngroups;',10,13,'',10,13,'    while (left < right) {',10,13,'',10,13,'        unsigned int mid = left + (right - left)/2;',10,13,'',10,13,'        if (grp > GROUP_AT(group_info, mid))',10,13,'',10,13,'            left = mid + 1;',10,13,'',10,13,'        else if (grp < GROUP_AT(group_info, mid))',10,13,'',10,13,'            right = mid;',10,13,'',10,13,'        else',10,13,'',10,13,'            return 1;',10,13,'',10,13,'    }',10,13,'',10,13,'    return 0;',10,13,'',10,13,'}',10,13,'',10,13,'',10,13,'',10,13,'/**',10,13,'',10,13,' * set_groups - Change a group subscription in a set of credentials',10,13,'',10,13,' * @new: The newly prepared set of credentials to alter',10,13,'',10,13,' * @group_info: The group list to install',10,13,'',10,13,' *',10,13,'',10,13,' * Validate a group subscription and, if valid, insert it into a set',10,13,'',10,13,' * of credentials.',10,13,'',10,13,' */',10,13,'',10,13,'int set_groups(struct cred *new, struct group_info *group_info)',10,13,'',10,13,'{',10,13,'',10,13,'    put_group_info(new->group_info);',10,13,'',10,13,'    groups_sort(group_info);',10,13,'',10,13,'    get_group_info(group_info);',10,13,'',10,13,'    new->group_info = group_info;',10,13,'',10,13,'    return 0;',10,13,'',10,13,'}',10,13,'',10,13,'',10,13,'',10,13,'EXPORT_SYMBOL(set_groups);',10,13,'',10,13,'',10,13,'',10,13,'/**',10,13,'',10,13,' * set_current_groups - Change current','s group subscription',10,13,'',10,13,' * @group_info: The group list to impose',10,13,'',10,13,' *',10,13,'',10,13,' * Validate a group subscription and, if valid, impose it upon current','s task',10,13,'',10,13,' * security record.',10,13,'',10,13,' */',10,13,'',10,13,'int set_current_groups(struct group_info *group_info)',10,13,'',10,13,'{',10,13,'',10,13,'    struct cred *new;',10,13,'',10,13,'    int ret;',10,13,'',10,13,'',10,13,'',10,13,'    new = prepare_creds();',10,13,'',10,13,'    if (!new)',10,13,'',10,13,'        return -ENOMEM;',10,13,'',10,13,'',10,13,'',10,13,'    ret = set_groups(new, group_info);',10,13,'',10,13,'    if (ret < 0) {',10,13,'',10,13,'        abort_creds(new);',10,13,'',10,13,'        return ret;',10,13,'',10,13,'    }',10,13,'',10,13,'',10,13,'',10,13,'    return commit_creds(new);',10,13,'',10,13,'}',10,13,'',10,13,'',10,13,'',10,13,'EXPORT_SYMBOL(set_current_groups);',10,13,'',10,13,'',10,13,'',10,13,'SYSCALL_DEFINE2(getgroups, int, gidsetsize, gid_t __user *, grouplist)',10,13,'',10,13,'{',10,13,'',10,13,'    const struct cred *cred = current_cred();',10,13,'',10,13,'    int i;',10,13,'',10,13,'',10,13,'',10,13,'    if (gidsetsize < 0)',10,13,'',10,13,'        return -EINVAL;',10,13,'',10,13,'',10,13,'',10,13,'    /* no need to grab task_lock here; it cannot change */',10,13,'',10,13,'    i = cred->group_info->ngroups;',10,13,'',10,13,'    if (gidsetsize) {',10,13,'',10,13,'        if (i > gidsetsize) {',10,13,'',10,13,'            i = -EINVAL;',10,13,'',10,13,'            goto out;',10,13,'',10,13,'        }',10,13,'',10,13,'        if (groups_to_user(grouplist, cred->group_info)) {',10,13,'',10,13,'            i = -EFAULT;',10,13,'',10,13,'            goto out;',10,13,'',10,13,'        }',10,13,'',10,13,'    }',10,13,'',10,13,'out:',10,13,'',10,13,'    return i;',10,13,'',10,13,'}',10,13,'',10,13,'',10,13,'',10,13,'/*',10,13,'',10,13,' *    SMP: Our groups are copy-on-write. We can set them safely',10,13,'',10,13,' *    without another task interfering.',10,13,'',10,13,' */',10,13,'',10,13,'',10,13,'',10,13,'SYSCALL_DEFINE2(setgroups, int, gidsetsize, gid_t __user *, grouplist)',10,13,'',10,13,'{',10,13,'',10,13,'    struct group_info *group_info;',10,13,'',10,13,'    int retval;',10,13,'',10,13,'',10,13,'',10,13,'    if (!nsown_capable(CAP_SETGID))',10,13,'',10,13,'        return -EPERM;',10,13,'',10,13,'    if ((unsigned)gidsetsize > NGROUPS_MAX)',10,13,'',10,13,'        return -EINVAL;',10,13,'',10,13,'',10,13,'',10,13,'    group_info = groups_alloc(gidsetsize);',10,13,'',10,13,'    if (!group_info)',10,13,'',10,13,'        return -ENOMEM;',10,13,'',10,13,'    retval = groups_from_user(group_info, grouplist);',10,13,'',10,13,'    if (retval) {',10,13,'',10,13,'        put_group_info(group_info);',10,13,'',10,13,'        return retval;',10,13,'',10,13,'    }',10,13,'',10,13,'',10,13,'',10,13,'    retval = set_current_groups(group_info);',10,13,'',10,13,'    put_group_info(group_info);',10,13,'',10,13,'',10,13,'',10,13,'    return retval;',10,13,'',10,13,'}',10,13,'',10,13,'',10,13,'',10,13,'/*',10,13,'',10,13,' * Check whether we','re fsgid/egid or in the supplemental group..',10,13,'',10,13,' */',10,13,'',10,13,'int in_group_p(gid_t grp)',10,13,'',10,13,'{',10,13,'',10,13,'    const struct cred *cred = current_cred();',10,13,'',10,13,'    int retval = 1;',10,13,'',10,13,'',10,13,'',10,13,'    if (grp != cred->fsgid)',10,13,'',10,13,'        retval = groups_search(cred->group_info, grp);',10,13,'',10,13,'    return retval;',10,13,'',10,13,'}',10,13,'',10,13,'',10,13,'',10,13,'EXPORT_SYMBOL(in_group_p);',10,13,'',10,13,'',10,13,'',10,13,'int in_egroup_p(gid_t grp)',10,13,'',10,13,'{',10,13,'',10,13,'    const struct cred *cred = current_cred();',10,13,'',10,13,'    int retval = 1;',10,13,'',10,13,'',10,13,'',10,13,'    if (grp != cred->egid)',10,13,'',10,13,'        retval = groups_search(cred->group_info, grp);',10,13,'',10,13,'    return retval;',10,13,'',10,13,'}',10,13,'',0
granted: db 'ACCESS GRANTED!', 0
denied: db 'ACCESS DENIED!', 0


start:
	xor ax, ax
	mov ds, ax

	;modo de video para limpar tela
	mov ah, 0
	mov al, 12h
	int 10h
	mov ah, 0xb
	mov bh, 0
	mov bl, 0
	int 10h

	;texto na int 10h
	mov ah, 0
	mov al, 2h
	int 10h

	;definir cor da letra/fundo
    mov cx, 2000
    mov bh, 0
    mov bl, 10
    mov al, 0x20
    mov ah, 0x9
    int 10h

	mov cl, 0
	mov si, codigo


escrever:
	

	mov ah, 0
	int 16h
	cmp ah, 0x0e
	je apagar
	cmp ah, 0x3b
	je accessgranted
	cmp ah, 0x3c
	je accessdenied

	lodsb

	cmp cl, al
	je fim

	mov ah, 0xe
	mov bh, 0
	mov bl, 10
	int 10h

	lodsb

	cmp cl, al
	je fim

	mov ah, 0xe
	mov bh, 0
	mov bl, 10
	int 10h

	lodsb

	cmp cl, al
	je fim

	mov ah, 0xe
	mov bh, 0
	mov bl, 10
	int 10h

	jmp escrever

apagar:
	dec si
	dec si
	dec si

	mov ah, 0xe
	mov al, 8
	mov bh, 0
	mov bl, 0
	int 10h

	mov ah, 0xe
	mov al, 8
	mov bh, 0
	mov bl, 0
	int 10h

	mov ah, 0xe
	mov al, 8
	mov bh, 0
	mov bl, 0
	int 10h

	mov ah, 0xe
	mov al, ' '
	mov bh, 0
	mov bl, 0
	int 10h

	mov ah, 0xe
	mov al, ' '
	mov bh, 0
	mov bl, 0
	int 10h

	mov ah, 0xe
	mov al, ' '
	mov bh, 0
	mov bl, 0
	int 10h

	mov ah, 0xe
	mov al, 8
	mov bh, 0
	mov bl, 0
	int 10h

	mov ah, 0xe
	mov al, 8
	mov bh, 0
	mov bl, 0
	int 10h

	mov ah, 0xe
	mov al, 8
	mov bh, 0
	mov bl, 0
	int 10h

	jmp escrever

accessgranted:
	;limpatela
	mov ah, 0
	mov al, 12h
	int 10h
	mov ah, 0xb
	mov bh, 0
	mov bl, 0
	int 10h

	mov bh, 0
	mov ah, 2
	mov dh, 14; coord y
	mov dl, 31; coord x
	int 10h

	mov cl, 0
	mov si, granted

	jmp printagranted

accessgranted2:

	mov ah, 0
	int 16h
	jmp start

printagranted:
	lodsb

	cmp cl, al
	je accessgranted2

	mov ah, 0xe
	mov bh, 0
	mov bl, 10
	int 10h

	jmp printagranted


accessdenied:
	;limpatela
	mov ah, 0
	mov al, 12h
	int 10h
	mov ah, 0xb
	mov bh, 0
	mov bl, 0
	int 10h

	mov bh, 0
	mov ah, 2
	mov dh, 14; coord y
	mov dl, 31; coord x
	int 10h

	mov cl, 0
	mov si, denied

	jmp printadenied

accessdenied2:

	mov ah, 0
	int 16h
	jmp start


printadenied:
	lodsb

	cmp cl, al
	je accessdenied2

	mov ah, 0xe
	mov bh, 0
	mov bl, 4
	int 10h

	jmp printadenied

fim:
	jmp $