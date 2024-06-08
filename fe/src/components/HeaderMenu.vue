<template>
  <ElMenu
    mode="horizontal"
    :ellipsis="false"
  >
    <ElSubMenu index="1">
      <template #title>
        <ElIcon><Setting /></ElIcon>
      </template>
      <template
        v-if="authenticated"
      >
        <ElMenuItem
          @click="() => editEvent()"
        >
          <template #title>
            <ElIcon><Calendar /></ElIcon>
            Create new event
          </template>
        </ElMenuItem>
        <ElMenuItem
          @click="signOut"
        >
          <template #title>
            <ElIcon><Unlock /></ElIcon>
            Sign Out
          </template>
        </ElMenuItem>
      </template>
      <template v-else>
        <ElMenuItem
          @click="() => $router.push({ name: 'SignIn' })"
        >
          <template #title>
            <ElIcon><Lock /></ElIcon>
            Sign In
          </template>
        </ElMenuItem>
        <ElMenuItem
          @click="isRegisterModalVisible = true"
        >
          <template #title>
            <ElIcon><User /></ElIcon>
            Register
          </template>
        </ElMenuItem>
        <ElMenuItem
          @click="isEditModalVisible = true"
        >
          <template #title>
            <ElIcon><User /></ElIcon>
            Register
          </template>
        </ElMenuItem>
      </template>
    </ElSubMenu>
  </ElMenu>
</template>

<script>
  import { mapActions, mapState, mapWritableState } from 'pinia';
  import { useAuthStore } from '@/stores/auth.js';
  import { useEventsStore } from '@/stores/events.js';
  import { signOut } from '@/services/auth.js';

  export default {
    name: 'MainHeader',
    computed: {
      ...mapState(useAuthStore, ['authenticated']),
      ...mapWritableState(useAuthStore, ['isRegisterModalVisible']),
      ...mapWritableState(useAuthStore, ['isEditModalVisible']),
    },
    methods: {
      ...mapActions(useEventsStore, ['editEvent']),

      /**
       * Call API sign out service and redirect to Home
       */
      async signOut() {
        signOut();
        await this.$router.push({ name: 'Home' });
      },
    },
  };
</script>
