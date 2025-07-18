<script lang="ts">
    import {onMount} from "svelte";
    import {useI18nAdmin} from "$state/i18n_admin.svelte";
    import ButtonAddModal from "$lib5/button/ButtonAddModal.svelte";
    import ContentAdmin from "$lib5/ContentAdmin.svelte";
    import NavButtonTile from "$lib5/nav/NavButtonTile.svelte";
    import NavSub from "$lib5/nav/NavSub.svelte";
    import OrderSearchBar from "$lib5/search_bar/OrderSearchBar.svelte";
    import {fetchGet} from "$api/fetch";
    import {useParam} from "$state/param.svelte";
    import type {GroupResponse} from "$api/types/groups.ts";
    import GroupAddNew from "$lib5/admin/groups/GroupAddNew.svelte";
    import GroupDetails from "$lib5/admin/groups/GroupDetails.svelte";
    import {useTrigger} from "$state/callback.svelte";

    let ta = useI18nAdmin();

    let refAddNew: undefined | HTMLButtonElement = $state();
    let tr = useTrigger();
    tr.set('navMain', () => refAddNew?.focus());

    let closeModal: undefined | (() => void) = $state();

    let err = $state('');
    let groups: GroupResponse[] = $state([]);
    let groupsFiltered: GroupResponse[] = $state([]);
    let group: undefined | GroupResponse = $state();
    let gid = useParam('gid');

    const searchOptions = [ta.common.name, 'ID'];
    let searchOption = $state(searchOptions[0]);
    let searchValue = $state('');
    const orderOptions = [ta.common.name, 'ID'];

    onMount(() => {
        fetchGroups();
    });

    $effect(() => {
        group = groups.find(g => g.id === gid.get());
    });

    $effect(() => {
        let search = searchValue.toLowerCase();
        if (!search) {
            groupsFiltered = groups;
        } else if (searchOption === searchOptions[0]) {
            groupsFiltered = groups.filter(g => g.name?.toLowerCase().includes(search));
        } else if (searchOption === searchOptions[1]) {
            groupsFiltered = groups.filter(g => g.id.toLowerCase().includes(search));
        }
    });

    async function fetchGroups() {
        let res = await fetchGet<GroupResponse[]>('/auth/v1/groups');
        if (res.body) {
            groups = res.body;
        } else {
            err = res.error?.message || 'Error';
        }
    }

    function onChangeOrder(option: string, direction: 'up' | 'down') {
        let up = direction === 'up';
        if (option === orderOptions[0]) {
            groups.sort((a, b) => up ? a.name.localeCompare(b.name) : b.name.localeCompare(a.name));
        } else if (option === orderOptions[1]) {
            groups.sort((a, b) => up ? a.id.localeCompare(b.id) : b.id.localeCompare(a.id));
        }
    }

    function onSave() {
        fetchGroups();
    }

    async function onAddNew(id: string) {
        closeModal?.();
        await fetchGroups();
        gid.set(id);
    }

</script>

<NavSub
        paddingTop="2.1rem"
        buttonTilesAriaControls="groups"
        width="min(20rem, 100dvw)"
        thresholdNavSub={700}
>
    <ButtonAddModal bind:ref={refAddNew} level={groups.length === 0 ? 1 : 2} bind:closeModal alignRight>
        <GroupAddNew onSave={onAddNew} {groups}/>
    </ButtonAddModal>
    <OrderSearchBar
            {searchOptions}
            bind:searchOption
            bind:value={searchValue}
            {orderOptions}
            {onChangeOrder}
            searchWidth="min(19.5rem, 100dvw - .5rem)"
    />

    {#snippet buttonTiles()}
        <div class="groupsList">
            {#each groupsFiltered as group (group.id)}
                <NavButtonTile onclick={() => gid.set(group.id)} selected={gid.get() === group.id}>
                    {group.name}
                </NavButtonTile>
            {/each}
        </div>
    {/snippet}
</NavSub>

<ContentAdmin>
    {#if err}
        <div class="err">
            {err}
        </div>
    {/if}

    <div id="groups">
        {#if group}
            <GroupDetails {group} {groups} {onSave}/>
        {/if}
    </div>
</ContentAdmin>

<style>
    .groupsList {
        max-height: calc(100dvh - 9.5rem);
        margin-top: .5rem;
        overflow-y: auto;
    }
</style>