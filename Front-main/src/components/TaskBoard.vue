<template>
  <div>
    <div class="task-board-wrapper">

    <div class="task-board" >
      <!-- Loop through task statuses -->
      <div
        v-for="(tasks, status) in sortedTaskStatuses"
        :key="status"
        class="task-column"
        @dragover.prevent
        @drop="onDrop($event, status)"
      >
        <div class="header d-flex justify-content-between fw-bold">
          <h2 class="heading">
            {{ statusLabels[status] }}
            <span class="task-count">({{ tasks.length }})</span>
          </h2>
          <button class="add" @click="goToAddTask(status)"  title="ajouter tache">+</button>
        </div>

        <!-- Show message if column is empty -->
        <div v-if="tasks.length === 0" class="d-flex justify-content-center align-items-center gap-4 empty-column-message">
          <p class="text-muted">Oups...rien à voir ici</p>
          <img 
          :src="require('@/assets/NoTasksss.png')" 
          alt="No Tasks" 
          class="img-fluid animated-image" 
        />
        </div>

        <!-- Render tasks if there are any -->
        <div v-else class="task-list">
          <div
            v-for="task in tasks"
            :key="task.id"
            class="task-item"
            draggable="true"
            @dragstart="onDragStart($event, task)"
          >
            <TaskDisplay
              :task="task"
              :show-checkbox="false"
              @trigger-edit="openEditPopup"
              @delete-task="handleDeleteTask"
              @update-task="updateTaskStatus" 
              @remove-task="removeTask"
              @show-toast="showToast" 
            />
          </div>
        </div>
      </div>
    </div>
    </div>

    <EditTask
      v-if="showEditPopup"
      :task="taskToEdit"
      @update-task="updateTask"
      @close="closeEditPopup"
    />

   
  
    <!-- Toast notification -->
    <div v-if="toastMessage" class="toast-container">
      <div class="toast-message">{{ toastMessage }}</div>
    </div>
  </div>
</template>


<script>
import axios from "axios";
import TaskDisplay from "./TaskDisplay.vue";
import EditTask from "./EditTask.vue"; // Ensure EditTask is imported
axios.defaults.withCredentials = true;
export default {
 // Assure que les cookies de session sont envoyés

  name: "TaskBoard",
  components: { TaskDisplay, EditTask },

  data() {
    return {
      showEditPopup: false,
      taskToEdit: null,
      draggedTask: null,
      taskCount: 0,
      taskStatuses: {
        "pas commence": [],
        "en cours": [],
        "termine": [],
      },
      statusLabels: {
        "pas commence": "Pas Commencé",
        "en cours": "En Cours",
        "termine": "Terminé",
      },
      toastMessage: "",
    };
  },

  created() {
    axios
      .get("http://localhost:3000/api/tasks/today")
      .then((response) => {
        this.taskCount = response.data.taskCount;
      })
      .catch((error) => {
        console.error("Error fetching task count:", error);
      });
  },

  computed: {
    sortedTaskStatuses() {
      const priorityOrder = {
        urgent: 1,
        important: 2,
        "moins important": 3,
      };

      const sortTasks = (tasks) => {
        return tasks.sort((a, b) => {
          const priorityA = priorityOrder[a.priority?.toLowerCase()] || 4; 
          const priorityB = priorityOrder[b.priority?.toLowerCase()] || 4;

          if (priorityA !== priorityB) {
            return priorityA - priorityB;
          }

          const dateA = a.due_date ? new Date(a.due_date) : null;
          const dateB = b.due_date ? new Date(b.due_date) : null;

          if (dateA && !dateB) return -1; 
          if (!dateA && dateB) return 1;
          if (!dateA && !dateB) return 0;

          return dateA - dateB; 
        });
      };

      return Object.keys(this.taskStatuses).reduce((sortedStatuses, status) => {
        sortedStatuses[status] = sortTasks([...this.taskStatuses[status]]);
        return sortedStatuses;
      }, {});
    },

    isAllEmpty() {
      return Object.values(this.taskStatuses).every(
        (tasks) => tasks.length === 0
      );
    },
  },

  methods: {
    async fetchTasksByStatus() {
      try {
        const response = await axios.get(
          "http://localhost:3000/api/tasks-by-status"
        );
        this.taskStatuses = response.data;

        // Calculate total task count
        this.taskCount = Object.values(this.taskStatuses).reduce(
          (total, tasks) => total + tasks.length,
          0
        );

        this.sortTasksByDate();
      } catch (error) {
        console.error("Erreur lors de la récupération des tâches :", error);
      }
    },
    openEditPopup(task) {
      this.taskToEdit = task;
      this.showEditPopup = true;
    },
    closeEditPopup() {
      this.showEditPopup = false;
      this.taskToEdit = null;
    },

    sortTasksByDate() {
      for (const status in this.taskStatuses) {
        this.taskStatuses[status].sort((a, b) => {

          const dateA = a.due_date ? new Date(a.due_date) : null;
          const dateB = b.due_date ? new Date(b.due_date) : null;

          if (dateA && !dateB) return -1; 
          if (!dateA && dateB) return 1; 
          return dateA - dateB; 
        });
      }
    },

    onDragStart(event, task) {
      this.draggedTask = task;
      event.dataTransfer.effectAllowed = "move";
      task.dropped = false; 
    },

    onDragEnd() {
      if (this.draggedTask) {
        this.draggedTask.dropped = true; 
      }
      this.draggedTask = null;
    },

    onDrop(event, newStatus) {
      if (!this.draggedTask) return;

      const oldStatus = this.draggedTask.status;

      if (newStatus !== oldStatus) {
        this.taskStatuses[oldStatus] = this.taskStatuses[oldStatus].filter(
          (task) => task.id !== this.draggedTask.id
        );
        this.draggedTask.status = newStatus;
        this.taskStatuses[newStatus].push(this.draggedTask);

        this.draggedTask.dropped = true; // Apply drop animation
        axios
          .put(`http://localhost:3000/api/tasks/${this.draggedTask.id}`, {
            status: newStatus,
          })
          .then(() => console.log("Task status updated successfully."))
          .catch((error) => console.error("Error updating task status:", error));
      }

      this.draggedTask = null;
    },

    handleEditTask(task) {
      console.log("Editing task:", task);
    },

    async removeTask(taskId) {
  console.log("Deleting task with ID:", taskId);
  
  let taskStatus = null;
  let taskIndex = null;
  

  for (const status in this.taskStatuses) {
    taskIndex = this.taskStatuses[status].findIndex(task => task.id === taskId);
    if (taskIndex !== -1) {
      taskStatus = status;
      break;
    }
  }
  
  if (taskStatus !== null && taskIndex !== -1) {

    this.taskStatuses[taskStatus].splice(taskIndex, 1);
    this.showToast("Tâche supprimée localement!");

    try {
      await axios.put(`http://localhost:3000/api/tasks/cancel/${taskId}`);
      this.showToast("Tâche supprimée et déplacée vers la corbeille !");
    } catch (error) {
      console.error("Error updating task status:", error);
      this.showToast("Erreur lors de la mise à jour de l'état de la tâche sur le serveur.");
    }
  } else {
    console.error("Task not found locally.");
    this.showToast("Tâche introuvable.");
  }
},


   showToast(message) {
      this.toastMessage = message;
      setTimeout(() => {
        this.toastMessage = ""; 
      }, 7000);
},
updateTaskStatus(updatedTask) {
    const taskIndex = this.tasks.findIndex(task => task.id === updatedTask.id);
    if (taskIndex !== -1) {
      this.tasks[taskIndex] = updatedTask;
    }
  },

    goToAddTask(status) {
    this.$router.push({ name: 'AddView', query: { status } });
  },
  },

  mounted() {
    this.fetchTasksByStatus();
  },
};
</script>



<style scoped>


.task-board {
  display: flex;
  justify-content: space-between;
  margin: 0 0 50px 120px;
  gap: 1.5rem;
  padding: 1rem;
  position: relative;
  width: 100%;
  border-radius: 20px;
  }

.heading {
  color: #240046;
  font-weight: bold;
  padding-bottom: 10px;
  border-bottom: 1px solid #240046;
  margin-bottom: 1rem;
  
}
.dark-mode .heading{
  color: #fff;
  border-bottom: 1px solid #9d4edd;
}
.task-count {
  color: #240046;
  font-size: 14px;
  margin-left: 5px;
  font-weight: normal;
}
.dark-mode .task-count{
  color: #9d4edd;
}
.task-column {
  flex: 1;
  background-color: #ffffff;
  border-radius: 12px;
  padding: 1rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
}
.dark-mode .task-column{
  background-color: rgb(55, 54, 56);
}
.task-list {
  margin-top: 1rem;
  max-height: 400px;
  overflow-y: auto;
  padding-right: 0.5rem;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: bold;
}

.add {
  background-color: #9d4edd;
  color: white;
  font-size: 25px;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: transform 0.2s ease, background-color 0.3s ease;
}

.add:hover {
  background:#e0aaff;
  transform: scale(1.1);
  box-shadow: 0 6px 8px rgba(0, 0, 0, 0.15);
}

/* Style for the scrollbar */
.task-list::-webkit-scrollbar {
  width: 8px;
}

.task-list::-webkit-scrollbar-thumb {
  background: #ccc;
  border-radius: 4px;
}

.task-list::-webkit-scrollbar-thumb:hover {
  background: #bbb;
}

.task-list::-webkit-scrollbar-track {
  background: #f9f9f9;
}

.task-item {
  cursor: grab; 
  transition: transform 0.2s, box-shadow 0.2s;
}


.no-tasks-message {
  display: flex;
  justify-content: center;
  padding: 20px;
  background-color: rgba(217, 201, 233, 0.589);
  box-shadow: 5px 18px 22px rgba(0, 0, 0, 0.324);
  margin-left: 260px;
  margin-bottom: 30px;
}

.no-tasks-content {
  display: flex;
  align-items: center; 
  justify-content: space-between; 
  width: 100%;
  max-width: 600px; 
}

.no-tasks-message p {
  font-size: 1.5rem;
   color: #491784;
  font-weight: bold;
  margin-right: 20px; 
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
  flex: 1;
}

.no-tasks-message p:hover {
  color: #370f66;
  transition: color 0.3s ease;
}

.animated-image {
  width: 100px;
  height: 100px;
}

@keyframes imageZoom {
  0% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.2);
  }
  100% {
    transform: scale(1);
  }
}

/* Toast notification container */
.toast-container {
  position: fixed;
  bottom: 20px;
  right: 20px; 
  z-index: 9999;
  width: auto; 
  max-width: 350px; 
  padding: 10px;
}

/* Toast message styles */
.toast-message {
  background-color: #e4c1f9; 
  color: #491784;
  padding: 12px 20px; 
  border-radius: 8px;
  font-size: 16px;
  box-shadow: 0px 4px 6px rgba(0, 0, 0, 0.2);
  animation: fadeInRight 0.5s ease-out; 
}

/* Animation for toast */
@keyframes fadeInRight {
  0% {
    opacity: 0;
    transform: translateX(100%);
  }
  100% {
    opacity: 1;
    transform: translateX(0);
  }
}


/* Responsive Styles */
@media (max-width: 768px) {
  .task-board-wrapper {
  max-width: 200%;
  overflow-x: auto;
}
.task-board{
  margin-left: 60px;
  width: 250%;
}

}
</style>

