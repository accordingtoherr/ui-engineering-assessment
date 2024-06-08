<template>
  <div class="main">
    <MainHeader />
    <router-view />
    <RegisterModal />
    <EditModal />
  </div>
</template>

<script>
  import { mapWritableState } from 'pinia';
  import { useAuthStore } from '@/stores/auth.js';
  import MainHeader from '@/components/MainHeader.vue';
  import RegisterModal from '@/components/modals/RegisterModal.vue';
  import EditModal from '@/components/modals/EditModal.vue';

  export default {
    name: 'App',
    components: {
      MainHeader,
      RegisterModal,
      EditModal,
    },
    computed: {
      ...mapWritableState(useAuthStore, ['isRegisterModalVisible']),
      ...mapWritableState(useAuthStore, ['isEditModalVisible']),

    },
  };
</script>

<style lang="scss">
  body, html {
    height: 100%;
    -ms-overflow-style: -ms-autohiding-scrollbar;
  }

  #app {
    display: flex;
    flex-direction: column;
  }
  .main {
    display: flex;
    flex-direction: column;
    height: 100%;
  }
</style>
