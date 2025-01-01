<template>
  <div>
    <!-- Form Container -->
    <transition name="fade" @before-enter="beforeEnter" @enter="enter" @leave="leave">
      <div 
        v-if="formVisible" 
        class="modal-container" 
        @click="handleBackgroundClick"
      >
        <!-- Modal Window -->
        <div class="modal-content" @click.stop>
          <!-- Form Header -->
          <h2 class="form-title">Créer une Nouvelle Tâche</h2>

          <!-- Form -->
          <form @submit.prevent="addTask">
            <!-- Task Name -->
            <div class="input-group">
              <label for="taskName">Nom de la tâche *</label>
              <input
                type="text"
                id="taskName"
                v-model="task.name"
                placeholder="Entrez le nom de la tâche"
              />
              <span v-if="!task.name && isSubmitted" class="error">Ce champ est obligatoire.</span>
            </div>

            <!-- Category Selection -->
            <div class="input-group">
              <label>Catégorie *</label>
              <div class="categories">
                <div
                  v-for="category in categories"
                  :key="category.name"
                  
                  :class="['category-item', { selected: task.category === category.name }, { 'disabled-category': categoryDisabled }]"
                  @click="!categoryDisabled && (task.category = category.name)"
                  :style="categoryDisabled ? { pointerEvents: 'none', opacity: 0.5 } : {}"
                  :disabled="categoryDisabled"
                >
                  <i :class="category.icon"></i> {{ category.name }}
                </div>

              </div>
              <span v-if="!task.category && isSubmitted" class="error">Veuillez choisir une catégorie.</span>
            </div>

            <!-- Date -->
            <div class="input-group">
              <label for="date">Date *</label>
              <input type="date" id="date" v-model="task.due_date" :disabled="dateDisabled"/>
              <span v-if="!task.due_date && isSubmitted" class="error">Veuillez sélectionner une date.</span>
            </div>

            <!-- Time -->
            <div class="input-group">
              <label for="time">Heure (Optionnel)</label>
              <input type="time" id="time" v-model="task.due_time" />
            </div>

            <!-- Importance Level -->
            <div class="input-group">
              <label>Niveau d'importance</label>
              <div class="importance-levels">
                <div
                  v-for="level in importanceLevels"
                  :key="level.value"
                  :class="['importance-level', { selected: task.importance === level.value }]"
                  @click="selectImportance(level.value)"
                >
                  {{ level.label }}
                </div>
              </div>

              <!-- Progress Bar -->
              <div class="progress-bar">
                <div
                  class="progress"
                  :style="{ 
                    width: task.importance === 'low' ? '33%' : 
                          task.importance === 'medium' ? '70%' : '100%', 
                    backgroundColor: getImportanceColor(task.importance) 
                  }"
                >
                  <span class="progress-label">{{ importanceLabel }}</span>
                </div>
              </div>
            </div>

            <!-- Action Buttons -->
            <div class="button-group">
              <button type="button" class="btn btn-cancel" @click="resetForm">Annuler</button>
              <button type="submit" class="btn btn-add">Ajouter</button>
            </div>
          </form>
        </div>

       <!-- Popup Modal -->
        <div v-if="showPopup" class="popup-overlay">
          <div class="popup-content">
            <h3>Bravo ! 🎉</h3>
            <p>Tâche ajoutée avec succès</p>
            <p>Vous êtes en train de conquérir votre journée !</p>
            <div class="popup-actions">
              <router-link to="/dashboard" class="btn btn-secondary">Revenir au Dashboard</router-link>
              <router-link to="/cat" class="btn see">Voir ma tâche</router-link>
            </div>
          </div>
        </div>

      </div>
    </transition>
  </div>
</template>


<script>
import axios from "axios"; 

export default {
  data() {
    return {
      task: {
        name: "",
        category: this.$route.query.categoryName || "",
        importance: "low",
        due_date: "",
        due_time: "",
        status: this.$route.query.status || 'pas commence', 
      },
      categories: [
        { name: "Travail", icon: "fas fa-briefcase" },
        { name: "Etude", icon: "fas fa-book" },
        { name: "Maison", icon: "fas fa-home" },
        { name: "Personnel", icon: "fas fa-user" },
        { name: "Loisirs", icon: "fas fa-gamepad" },
        { name: "Autre", icon: "fas fa-exclamation-circle" },
      ],
      categoryDisabled: false, 
      dateDisabled: false, // Add dateDisabled to disable the date input
 

      importanceLevels: [
        { value: "low", label: "Moins important" },
        { value: "medium", label: "Important" },
        { value: "high", label: "Urgent" },
      ],
      progressBarWidth: 33,
      progressBarColor: "#9b59b6",
      importanceLabel: "Moins Important",
      
      formVisible: false,
      isSubmitted: false,
      showPopup: false,
    };
  },

  

  mounted() {
    this.formVisible=true;
    console.log("Query String: ", window.location.search);

    const urlParams = new URLSearchParams(window.location.search);
    const dueDate = urlParams.get('date');
    const categoryName = urlParams.get('categoryName');

    if (dueDate) {
      this.task.due_date = dueDate;
      this.dateDisabled = true; // Disable the date input
    }
    if (categoryName) {
      this.category = categoryName;
      this.categoryDisabled = true; // Disable the category selection
    }
  },

  methods: {

    addTask() {
      this.isSubmitted = true;

      // Validate required fields
      if (!this.task.name || !this.task.category || (!this.dateDisabled && !this.task.due_date)) {
        alert("Veuillez remplir tous les champs obligatoires.");
        return;
      }

      const currentDate = new Date();
      const selectedDate = new Date(this.task.due_date);

      // Validation: Task date cannot be in the past
      if (selectedDate < currentDate.setHours(0, 0, 0, 0)) { // Compare to today's start
        alert("La date ne peut pas être dans le passé.");
        return;
      }

      // If the task is for today, validate the time
      if (selectedDate.toDateString() === new Date().toDateString() && this.task.due_time) {
        const currentTime = new Date();
        const [hours, minutes] = this.task.due_time.split(":");
        const selectedTime = new Date();
        selectedTime.setHours(parseInt(hours), parseInt(minutes), 0);

        if (selectedTime < currentTime) {
          alert("L'heure sélectionnée ne peut pas être dans le passé.");
          return;
        }
      }

      // Map importance levels to backend values
      const importanceMap = {
        low: "moins important",
        medium: "important",
        high: "urgent",
      };

      const formattedTask = {
        task_name: this.task.name,
        category: this.task.category,
        due_date: this.task.due_date,
        due_time: this.task.due_time || null,
        priority: importanceMap[this.task.importance],
        status: this.task.status,
      };
      // Send data to the backend
      axios
        .post("http://localhost:3000/api/tasks-add", formattedTask)
        .then(() => {
          this.showPopup = true; // Show success popup
        })
        .catch((err) => {
          console.error("Erreur lors de l'ajout de la tâche:", err);
          alert("Une erreur s'est produite lors de l'ajout de la tâche.");
        });
    },

    selectImportance(level) {
      this.task.importance = level;
      const settings = {
        low: { width: 33, color: "#f1c40f", label: "Moins Important" },
        medium: { width: 70, color: "#2ecc71", label: "Important" },
        high: { width: 100, color: "#e74c3c", label: "Urgent" },
      };
      this.progressBarWidth = settings[level].width;
      this.progressBarColor = settings[level].color;
      this.importanceLabel = settings[level].label;
    },

    getImportanceColor(importance) {
      switch (importance) {
        case "low":
          return "#2ecc71";  
        case "medium":
          return "#FFA500";
        case "high":
          return "#e74c3c";
        default:
          return "#9b59b6";
      }
    },

    resetForm() {
      this.task = {
        name: "",
        category: "",
        due_date: "",
        due_time: "",
        importance: "low",
      };
      this.isSubmitted = false;
      this.$router.push('/dashboard');
    },
  },
};
</script>


<style scoped>
body {
  font-family: Arial, sans-serif;
  background-color: #a878b8;
  color: #f5f5f5;
}

.modal-container {
  position: fixed;
  top: 0;
  left: 0;
  width: 100vw;
  height: 100vh;
  background: rgba(146, 144, 148, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background-color: #ffffff;
  padding: 40px;
  border-radius: 10px;
  width: 90%;
  max-width: 900px;
  position: relative;
  box-shadow: 0 4px 10px rgba(169, 86, 177, 0.717);
  color: #240046; 
  overflow-y: auto;
}

.sidebar-btn {
  position: fixed;
  top: 20px;
  right: 20px;
  background-color: #9b59b6;
}



h2.form-title {
  margin-bottom: 20px;
  text-align: center;
  font-size: 24px;
}

.input-group {
  margin-bottom: 15px;
}

.input-group label {
  display: block;
  font-size: 16px;
  margin-bottom: 5px;
}

.input-group input {
  width: 100%;
  padding: 10px;
  font-size: 16px;
  border-radius: 5px;
  border: 1px solid #ddd;
}

.input-group .error {
  color: #e74c3c;
  font-size: 14px;
}

 
.categories {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  gap: 10px; 
}

.category-item {
  padding: 10px;
  cursor: pointer;
  border-radius: 5px;
  transition: background-color 0.3s;
  flex: 1 1 calc(33.33% - 10px); 
  display: flex;
  justify-content: center; 
  align-items: center; 
  box-sizing: border-box;
}

.category-item i { 
  font-size: 24px; 
  margin-right: 5px; 
}

.category-item:hover {
  background-color: #C77DFF;
}

.category-item.selected {
  background-color: #9b59b6;
}

/* Responsive styles */
@media (max-width: 768px) {
  .category-item {
    flex: 1 1 calc(50% - 10px);
  }
}

@media (max-width: 480px) {
  .category-item {
    flex: 1 1 100%; 
  }
}

.importance-levels {
  display: flex;
  justify-content: space-around;
}

.importance-level {
  padding: 10px;
  cursor: pointer;
  border-radius: 5px;
  transition: background-color 0.3s;
}

.importance-level.selected {
  background-color: #9b59b6;
}

.progress-bar {
  background-color: #ddd;
  height: 10px;
  width: 100%;
  border-radius: 5px;
}

.progress {
  height: 100%;
  border-radius: 5px;
  text-align: center;
  line-height: 30px;
  color: white;
  font-weight: bold;
}



.progress-bar {
  background-color: #ddd;
  height: 10px;
  width: 100%;
  border-radius: 5px;
  margin: 10px 0;
}

.progress {
  height: 100%;
  border-radius: 5px;
  text-align: center;
  line-height: 30px;
  color: white;
  font-weight: bold;
}

.button-group {
  display: flex;
  justify-content: space-between;
}

.btn {
  padding: 10px 20px;
  border-radius: 5px;
  cursor: pointer;
}

.btn-cancel {
  background-color: #e74c3c;
  color: white;
  transition: transform 0.2s ease;
}
.btn-cancel:hover{
  background-color: #ee7f72;
  transform: translateY(-3px) scale(1.05);
}
.btn-cancel:active{
  background-color: hsl(6, 78%, 9%);
  transform: translateY(-3px) scale(1.05);
}

.btn-add {
  background-color: #240046;
  color: white;
  transition: transform 0.2s ease;
}

.btn-add:hover{
  background-color: #b786ca;
  transform: translateY(-3px) scale(1.05);
}
.btn-add:active{
  background-color: hsl(283, 39%, 76%);
}



.popup-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);  
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
  color: #e0aaff;

}
.popup-content h3{
  color: #7b2cbf;
}

.popup-content {
  background: #10002B;
  padding: 15px;  
  border-radius: 8px;
  text-align: center;
  width: 70%;  
  max-width: 600px;  
  box-sizing: border-box;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);  
}
.popup-actions {
  display: flex;
  justify-content: space-between;
  gap: 10px;
  flex-wrap: wrap;
}

.popup-actions .btn {
  display: inline-block;
  padding: 10px 25px;  
  border-radius: 15px;
  font-size: 16px;
  white-space: nowrap;
  width: 48%;
  box-sizing: border-box;
}

.see {
  background: #E0AAFF;
  transition: transform 0.2s ease;
}

.see:hover {
  background: hsl(287, 26%, 69%);
  transform: translateY(-3px) scale(1.05);
}

.btn-secondary{
  transition: transform 0.2s ease;
}
.btn-secondary:hover{
  transform: translateY(-3px) scale(1.05);
}

.popup-fade-enter-active,
.popup-fade-leave-active {
  transition: opacity 0.5s, transform 0.3s;
}

.popup-fade-enter,
.popup-fade-leave-to {
  opacity: 0;
  transform: scale(0.7);
}

/* Media Queries for Responsiveness */
@media (max-width: 768px) {
  .modal-content {
    padding: 20px;
    max-width: 400px;
    margin-left: 50px;
  }

  h2.form-title {
    font-size: 20px;
  }

  .input-group label {
    font-size: 14px;
  }

  .input-group input {
    font-size: 14px;
    padding: 8px;
  }

  .categories .category-item {
    flex: 1 1 calc(50% - 10px); /* Adjust to fit two items per row */
  }

  .btn {
    font-size: 14px;
    padding: 8px 10px;
  }

  .popup-content {
    margin-left: 90px;
}
.btn-secondary{
  text-align: center;
}
}

</style>