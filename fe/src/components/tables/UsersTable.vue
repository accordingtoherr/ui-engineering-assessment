<template>
  <div class="users-table">
    <ElTable
      v-if="localUsers"
      :data="localUsers"
      @sort-change="doSort"
    >
      <ElTableColumn prop="id" label="ID" />
      <ElTableColumn prop="firstName" label="First name" />
      <ElTableColumn prop="lastName" label="Last name" />
      <ElTableColumn prop="emailAddress" label="Email address" sortable="custom" />
      <ElTableColumn>
        <template #default="scope">
          <ElButton
            v-if="user?.admin"
            size="small"
            type="danger"
            @click="deleteUser(scope.row)"
          >
            Delete
          </ElButton>
          <ElButton
            size="small"
            type="primary"
            @click="isEditModalVisible = true"
          >
            Edit
          </ElButton>
        </template>
      </ElTableColumn>
    </ElTable>
  </div>
</template>

<script>
  import { mapActions, mapState, mapWritableState } from 'pinia';
  import { getUsers, deleteUser } from '@/services/users.js';
  import { useAuthStore } from '@/stores/auth.js';
  import { useUsersStore } from '@/stores/users.js';
  import { useAlertsStore } from '@/stores/alerts.js';

  export default {
    name: 'UsersTable',
    data() {
      return {
        /**
         * Local users table data
         */
        localUsers: null,
      };
    },
    computed: {
      ...mapState(useUsersStore, ['users']),
      ...mapState(useAuthStore, ['user']),
      ...mapWritableState(useAuthStore, ['isEditModalVisible']),
    },
    watch: {
      users: {
        /**
         * Update localUsers when store data changes
         */
        handler() {
          this.localUsers = this.users.map((user) => user);
        },
        immediate: true,
        deep: true,
      },
    },
    async created() {
      /**
       * Load users from API on load
       */
      await this.loadUsers();
    },
    methods: {
      ...mapActions(useAlertsStore, ['addAlert']),
      ...mapActions(useUsersStore, ['setUsers']),

      /**
       * Load users from the API and save them in the store
       */
      async loadUsers() {
        try {
          const data = await getUsers();

          this.setUsers(data);
        } catch (error) {
          /**
           * Show error alert
           */
          this.addAlert({
            title: 'Error retrieving users.',
            type: 'error',
          });
        }
      },
      /**
       * Delete user and reload users list
       *
       * @param {object} user
       */
      async deleteUser(user) {
        await deleteUser(user);
        this.loadUsers();
      },
      /**
       * Custom table sort method
       *
       * @param {object} root
       * @param {string} root.prop
       * @param {string} root.order
       */
      doSort({ prop, order }) {
        if (order) {
          this.localUsers.sort((a, b) => {
            if (order === 'ascending') {
              return a[prop] > b[prop] ? 1 : -1;
            }

            return a[prop] < b[prop] ? 1 : -1;
          });
        } else {
          this.localUsers = this.users;
        }
      },
    },
  };
</script>

<style lang="scss" scoped>
.users-table {
  height: 100%;
  width: 100%;
  overflow: auto;
  padding: 0 1em;
}
</style>
