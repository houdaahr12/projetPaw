<template>
  <div class="page-container">
    <main class="main-content">
      <section
        :class="[ 'calendar-container', { 'move-left': modalVisible } ]"
      >
        <div class="calendar-header">
          <button @click="prevMonth" class="nav-button">&lt;</button>
          <span class="month-label">{{ monthNames[currentMonth] }} {{ currentYear }}</span>
          <button @click="nextMonth" class="nav-button">&gt;</button>
        </div>

        <div class="calendar-grid">
          <!-- Display day names -->
          <div class="day-name" v-for="day in dayNames" :key="day">{{ day }}</div>

          <!-- Render days -->
          <div
            class="day"
            v-for="day in daysInMonth"
            :key="day.date"
            :class="{
              'is-today': day.isToday,
              'is-empty': !day.date,
              'has-task': hasTasks(day.date),
            }"
            @click="day.date && openModal(day.date)"
          >
            <div v-if="hasTasks(day.date)" class="task-indicator"></div>
            {{ day.day }}
          </div>
        </div>
      </section>

      <section v-if="modalVisible" class="task-details">
        <h2>
          Tâches pour {{ formatSelectedDate(selectedDate) }}
          <button @click="closeModal" class="close-button">X</button>
        </h2>
        <div v-if="modalTasks.length > 0">
          <ul >
          <li v-for="task in modalTasks" :key="task.id" class="task-container">
            <TaskDisplayCalen :task="task" />
          </li>
        </ul>

        </div>

        <!-- Display "No tasks in this category" message -->
        <div v-else class="d-flex justify-content-center align-items-center gap-4 no-tasks">
          <p class="text-muted">Aucune tâche pour cette date!</p>
          <img 
            :src="require('@/assets/NoTasksss.png')" 
            alt="No Tasks" 
            class="img-fluid animated-image" 
          />
        </div>

        <!-- Button to add a task -->
        <button @click="goToAddView" class="add-task-button">Ajouter une Tâche</button>
      </section>
    </main>
  </div>
</template>



<script>
import axios from "axios";
import TaskDisplayCalen from "@/components/TaskDisplayCalen.vue";

export default {
  components: { TaskDisplayCalen },
  data() {
  return {
    currentYear: new Date().getFullYear(),
    currentMonth: new Date().getMonth(),
    selectedDate: null,
    tasks: [],
    modalTasks: [], // Separate property for tasks in the modal
    modalVisible: false,
    dayNames: ["Dim", "Lun", "Mar", "Mer", "Jeu", "Ven", "Sam"],
  };
},
  computed: {
    monthNames() {
      return [
        "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
        "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre",
      ];
    },
    daysInMonth() {
      const days = [];
      const firstDay = new Date(this.currentYear, this.currentMonth, 1).getDay();
      const lastDate = new Date(this.currentYear, this.currentMonth + 1, 0).getDate();

      // Fill empty days before the first day of the month
      for (let i = 0; i < firstDay; i++) {
        days.push({ day: "", date: null });
      }

      // Fill days in the month
      for (let i = 1; i <= lastDate; i++) {
        const date = new Date(this.currentYear, this.currentMonth, i);
        days.push({
          day: i,
          date: this.formatDate(date),
          isToday: this.isToday(date),
        });
      }

      return days;
    },
  },
  methods: {
    isToday(date) {
      const today = new Date();
      return (
        date.getFullYear() === today.getFullYear() &&
        date.getMonth() === today.getMonth() &&
        date.getDate() === today.getDate()
      );
    },
    formatSelectedDate(date) {
  const [year, month, day] = date.split("-");
  return `${day}/${month}/${year}`;
},

    formatDate(date) {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`; // Ensure date is in YYYY-MM-DD format
},

    async loadTasksForMonth() {
  try {
    const response = await axios.get(
      `http://localhost:3000/api/tasks-for-calendar/${this.currentYear}/${this.currentMonth + 1}`
    );
    console.log('Response from API:', response.data);  // Log the full response
    this.tasks = response.data || [];  // Ensure tasks is assigned correctly
    console.log("Tasks for the month:", this.tasks);  // Log the tasks data
  } catch (error) {
    console.error("Erreur lors de la récupération des tâches pour le mois:", error);
    this.tasks = [];
  }
},


    hasTasks(date) {
  if (!date) return false; // Skip empty days
  return this.tasks.some(task => task.due_date === date);
},


    tasksForDate(date) {
  console.log(`Tasks for ${date}:`, this.tasks.filter(task => task.due_date === date));
  return this.tasks.filter(task => task.due_date === date);
},

    openModal(date) {
    this.selectedDate = date;
    this.modalVisible = true;

    // Filter tasks for the selected date
    this.modalTasks = this.tasks.filter(task => task.due_date === date);
    console.log(`Opening modal for ${date}. Tasks:`, this.modalTasks);
  },

  closeModal() {
    this.modalVisible = false;
    this.modalTasks = []; // Reset tasks when closing the modal
  },
    prevMonth() {
      if (this.currentMonth === 0) {
        this.currentMonth = 11;
        this.currentYear--;
      } else {
        this.currentMonth--;
      }
      this.loadTasksForMonth();
    },
    nextMonth() {
      if (this.currentMonth === 11) {
        this.currentMonth = 0;
        this.currentYear++;
      } else {
        this.currentMonth++;
      }
      this.loadTasksForMonth();
    },
    goToAddView() {
      this.$router.push({ name: "AddView", query: { date: this.selectedDate } });
    },
  },
  mounted() {
  console.log('Calendar component mounted');
  console.log('Tasks fetched as long as mounted');
  this.loadTasksForMonth(); // Correctly call the method
},

};
</script>



<style scoped>
.page-container {
  color: white;
  font-family: 'Poppins', sans-serif;
  display: flex;
  justify-content: center;
  align-items: center;
  position: relative;
  overflow: hidden;
  background: rgba(235, 234, 234, 0.708); 
}

.main-content {
  display: flex;
  width: 100vw;
  margin-left: 210px;
}

.calendar-container {
  color: #333;
  border-radius: 25px;
  padding: 25px;
  box-shadow: 0 10px 25px #10002b;
  width: 45vw;
  transition: transform 0.5s ease, opacity 0.5s ease;
  margin: 0 auto 0;
  background: white; 
  margin: 25px auto;
}

.calendar-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
  color: #10002b;
}

.month-label {
  font-size: 2rem;
  font-weight: bold;
}

.nav-button {
  background: none;
  border: 3px solid #3c096c;
  color: #3c096c;
  border-radius: 50%;
  padding: 15px 25px;
  font-size: 1.8rem;
  font-weight: bold;
  transition: all 0.3s ease, box-shadow 0.2s ease;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
}

.nav-button:hover {
  background: #5a189a;
  color: #fff;
  border-color: transparent;
  transform: translateY(-3px);
  box-shadow: 0 8px 15px #6a11cb66;
}

.nav-button:active {
  transform: translateY(0);
  box-shadow: 0 4px 8px rgba(106, 17, 203, 0.2);
}

.calendar-container.move-left {
  transform: translateX(-20vw);
  opacity: 0.8;
}

.calendar-grid {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 15px;
}

.day {
  padding: 25px;
  text-align: center;
  border-radius: 15px;
  color: #10002b;
  background: rgba(106, 17, 203, 0.15);
  cursor: pointer;
  transition: transform 0.2s, background 0.3s;
  font-size: 1.8rem;
  position: relative;
}
.day:hover {
  transform: scale(1.1);
  background: rgba(106, 17, 203, 0.35);
}
.is-today {
  border: 3px solid #6a11cb66; 
  font-weight: bold;
  background-color: #6a11cb66; 
}

.task-indicator {
  position: absolute;
  bottom: 5px; 
  right: 5px; 
  width: 10px;
  height: 10px;
  background-color: red;
  border-radius: 50%;
  box-shadow: 0 0 4px rgba(128, 0, 128, 0.6);
  animation: zoom 2s ease-in-out infinite;
}

@keyframes zoom {
  0% {
    transform: scale(0.8);
  }
  50% {
    transform: scale(1);
  }
  100% {
    transform: scale(0.8);
  }
}


.overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(0, 0, 0, 0.5); 
  z-index: 999; 
  transition: opacity 0.3s ease;
}

.task-details {
  position: fixed;
  top: 90px;
  right: 0;
  background: rgba(235, 234, 234);
  border-radius: 15px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
  width: 600px; 
  height: 100vh; 
  padding: 25px 40px;
  color: #333;
  margin-right: 10px;
  z-index: 1000; 
  overflow-y: auto; 

}



.task-details h2 {
  margin-bottom: 20px;
  color: #3c096c;
  position: relative;
  padding-right: 30px; 
  font-weight: bold;
}

ul {
  list-style-type: none;
  padding: 0;
  margin: 0;
}

.task-content h3 {
  margin: 0;
  font-size: 1.5rem;
}

.task-content p {
  margin: 5px 0;
  font-size: 1.1rem;
}

.add-task-button {
  background: #3c096c;
  color: white;
  padding: 15px 30px;
  border: none;
  border-radius: 25px;
  cursor: pointer;
  margin-top: 15px;
  font-size: 1.2rem;
  margin-right: 20px;
  transition: transform 0.2s ease;
}

.add-task-button:hover {
  background: #7b2cbf;
  transform: translateY(-3px) scale(1.05);
}

.close-button {
  position: absolute;
  top: 0;
  right: 0;
  background: none;
  border: none;
  color: #3c096c;
  font-size: 2rem;
  cursor: pointer;
  transition: color 0.3s ease;
  font-weight: bold;
  transition: transform 0.2s ease;
  
}

.close-button:hover {
  color: #5a189a; 
  transform: translateY(-3px) scale(1.05);
}

@media (max-width: 768px) {
  .calendar-container {
    width: 70vw;
    margin-right: 140px;
    padding: 15px;
  }

  .calendar-header {
    display: flex; /* Make it a flex container */
    justify-content: space-between; /* Ensure space between buttons and month label */
    align-items: center; /* Vertically center the items */
    flex-direction: row; /* Keep items in the same row */
    width: 100%; /* Ensure full width to align the elements */
  }

  .month-label {
    font-size: 1.5rem;
    text-align: center; /* Center align the month label */
  }

  
  .nav-button {
  background: none;
  border: 3px solid #3c096c;
  color: #3c096c;
  border-radius: 50%;
  padding: 15px 25px;
  font-size: 1.8rem;
  font-weight: bold;
  transition: all 0.3s ease, box-shadow 0.2s ease;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1rem;
}

  .calendar-grid {
    grid-template-columns: repeat(7, 1fr);
    gap: 10px;
  }

  .day {
    padding: 10px;
    font-size: 1.5rem;
  }

  .task-details {
    width: 70vw;
    height: 100vh;
    padding: 30px;
    margin-right: 0;
  }

  .add-task-button {
    font-size: 1rem;
    padding: 12px 25px;

  }
}


.dark-mode .calendar-header{
  color: #ac72df;

}

.dark-mode .task-details{
  background: rgb(55, 54, 56);
}

.dark-mode .task-details h2{
  color: #ac72df;
}

.dark-mode .task-details .add-task-button{
  background: hsl(272, 63%, 56%);
}

.dark-mode .task-details .close-button{
  color: hsl(272, 63%, 56%);
}

.dark-mode .day-name{
  color: hsl(270, 5%, 68%)
}
.dark-mode .page-container{
  background-color:#212121 ;
}

.dark-mode .calendar-container{
  background: hsl(270, 2%, 32%);
}
.dark-mode .day{
  background: hsl(270, 5%, 48%);
  color: rgba(235, 234, 234, 0.708);
}
.dark-mode .nav-button{
  color: #ac72df;
  border: 1px solid #ac72df;
}
.dark-mode .is-today{
  background: #ac72df;
}
.no-tasks {
  display: flex;
  flex-direction: column; /* Aligns text and image vertically */
  justify-content: center;
  align-items: center;
  text-align: center;
  gap: 15px;
}

.no-tasks p {
  font-size: 1.2rem;
  color: #6a11cb;
  margin-bottom: 10px; /* Space between text and image */
}

.no-tasks img {
  max-width: 200px; /* Adjust image size as necessary */
  animation: zoom 3s ease-in-out infinite;
}

@keyframes zoom {
  0% {
    transform: scale(0.8);
  }
  50% {
    transform: scale(1);
  }
  100% {
    transform: scale(0.8);
  }
}


</style>