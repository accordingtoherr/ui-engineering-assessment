<template>
  <div
    v-if="events"
    class="event-wrapper"
  >
    <ElButton type="primary" @click="toggleUITable">
      Table View
    </ElButton>
    <ElButton type="primary" @click="toggleUICard">
      Card View
    </ElButton>
    <h3>Upcoming Events</h3>
    <div v-if="card">
      <ElCard
        v-for="event in events"
        :key="event.id"
      >
        <template #header>
          <div class="card-header">
            <h3>
              <RouterLink :to="`/events/${event.id}`">
                {{ event.name }}
              </RouterLink>
            </h3>
            <div class="when-where">
              <div>
                <ElIcon><Calendar /></ElIcon>
                {{ dateFormatter(event.startDate) }}
              </div>
              <b>
                {{ event.location }}
              </b>
            </div>
          </div>
        </template>
        {{ event.description || 'No description' }}
        <template #footer>
          <div class="card-footer">
            <div class="footer-buttons">
              <span v-if="authenticated">
                <ElButton
                  v-if="event.userId === user.id"
                  data-test="edit-event-button"
                  type="primary"
                  @click="editEvent(event)"
                >
                  Edit
                </ElButton>
                <ElButton
                  v-if="attending(event)"
                  data-test="delete-event-button"
                  type="danger"
                  @click="declineEvent(event)"
                >
                  Decline
                </ElButton>
                <ElButton
                  v-else
                  data-test="attend-event-button"
                  type="success"
                  @click="attendEvent(event)"
                >
                  Attend
                </ElButton>
              </span>
              <ElButton
                v-else
                type="primary"
                data-test="sign-in-button"
                @click="() => $router.push({ name: 'SignIn' })"
              >
                Sign In to RSVP
              </ElButton>
            </div>
            <div class="attendees-badge">
              <ElTag>{{ event.attendeesCount }} Going</ElTag>
            </div>
          </div>
        </template>
      </ElCard>
    </div>
    <div v-if="!card">
      <ElTable
        :data="events"
        @sort-change="doSort"
      >
        <ElTableColumn prop="name" label="Event Name">
          <!-- the event names are clickable in table just like in cards. when clicked we use Router to avoid a not needed page reload and load up the event page we clicked on -->
          <template #default="scope">
            <RouterLink :to="`/events/${scope.row.id}`">
              {{ scope.row.name }}
            </RouterLink>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="attendeesCount" label="AttendeeCount" sortable="custom" />
        <!-- description is not filled in for most events but if it exists it prints in this col -->
        <ElTableColumn prop="description" label="Description" sortable="custom" />
        <ElTableColumn prop="location" label="Location" sortable="custom" />
        <ElTableColumn prop="startDate" label="Date" :formatter="dateFormatter">
          <!-- use dateFormatter helper func to format the startDate timestamp into proper format -->
          <template #default="scope">
            {{ dateFormatter(scope.row.startDate) }}
          </template>
        </ElTableColumn>
        <ElTableColumn label="RSVP">
          <span v-if="authenticated">
            <ElButton
              size="small"
              data-test="delete-event-button"
              type="danger"
              @click="declineEvent(event)"
            >
              Decline
            </ElButton>
            <ElButton
              size="small"
              data-test="accept-event-button"
              type="success"
              @click="acceptEvent(event)"
            >
              Attend
            </ElButton>
          </span>
          <span v-else-if="!authenticated">
            <ElButton
              type="primary"
              data-test="sign-in-button"
              @click="() => $router.push({ name: 'SignIn' })"
            >
              Sign In to RSVP
            </ElButton>
          </span>
        </ElTableColumn>
        <ElTableColumn
          v-if="eventsType === 'myEvents'"
        >
          <template #default="scope">
            <ElButton
              v-if="scope.row.userId === user.id"
              size="small"
              type="primary"
              @click="editEvent(scope.row)"
            >
              Edit
            </ElButton>
          </template>
        </ElTableColumn>
      </ElTable>
    </div>
  </div>
</template>

<script>
  import { mapActions, mapState } from 'pinia';
  import { useAuthStore } from '@/stores/auth.js';
  import { useEventsStore } from '@/stores/events.js';
  import { declineEvent, joinEvent } from '@/services/events.js';
  import { getUser } from '@/services/users.js';
  import { formatDate } from '@/utils/common.js';

  export default {
    name: 'UpcomingEvents',
    inject: ['loadEvents'],
    data() {
      return {
        card: true,

      };
    },
    computed: {
      ...mapState(useAuthStore, ['authenticated', 'user']),
      ...mapState(useEventsStore, ['events']),
    },
    async created() {
      /**
       * Load event data into store
       */
      await this.loadEvents();
    },
    methods: {
      ...mapActions(useAuthStore, ['setUser']),
      ...mapActions(useEventsStore, ['editEvent']),

      // these need to be separate since each handle a different value probably could be enhanced by using computer prop or ref //
      toggleUICard() {
        this.card = true;
        this.table = false;
      },
      toggleUITable() {
        this.table = true;
        this.card = false
      },
      /**
       * Format date helper
       *
       * @param {string} dateString
       * @returns {Date}
       */
      dateFormatter(dateString) {
        return formatDate(dateString);
      },
      /**
       * Determine if the user is attending an event
       *
       * @param {object} root
       * @param {number} root.id
       * @returns {boolean}
       */
      attending({ id: eventId }) {
        return this.user.attendingEvents?.find(({ id: attendingEventId }) => attendingEventId === eventId);
      },
      /**
       * Call API to mark user as attending an event then reload events
       *
       * @param {object} event
       */
      async attendEvent(event) {
        await joinEvent(event.id, this.user.id);
        const user = await getUser(this.user.id);

        this.setUser(user);
        this.loadEvents();
      },
      /**
       * Unmark user as attending an event and reload events
       *
       * @param {object} root
       * @param {number} root.id
       */
      async declineEvent({ id }) {
        await declineEvent(id, this.user.id);
        const user = await getUser(this.user.id);

        this.setUser(user);
        this.loadEvents();
      },
    },
  };
</script>

<style lang="scss" scoped>
.event-wrapper {
  display: inline-block;
  width: 1000px;
  padding: 1em;

  :deep(.el-card) {
    margin: 1em 0;
  }
}

.card-header {
  display: flex;
  justify-content: space-between;

  .when-where {
    text-align: right;
  }
}

.card-footer {
  display: flex;
  justify-content: space-between;
}

h3 {
  margin: 0;
  padding-top: 1rem;
}
</style>
