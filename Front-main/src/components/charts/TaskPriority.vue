<template>
  <div class="priorite">
    <!-- Graphique des priorités -->
    <div id="taskPriority" style="width: 100%; height: 290px;"></div>
    <p v-if="!taskData || taskData.length === 0">
      Aucune donnée à afficher pour cette semaine.
    </p>
    <div class="navigation-buttons">
      <button @click="goToPreviousWeek" class="arrow-button">
        <i class="fas fa-arrow-left"></i>
      </button>
      <button @click="goToNextWeek" class="arrow-button">
        <i class="fas fa-arrow-right"></i>
      </button>
    </div>
  </div>
</template>

<script>
import * as echarts from "echarts";
import axios from "axios";
import { nextTick } from "vue";

function getCurrentWeekNumber() {
  const currentDate = new Date();
  const startOfYear = new Date(currentDate.getFullYear(), 0, 1);
  const pastDaysOfYear = (currentDate - startOfYear + 86400000) / 86400000;
  return Math.ceil(pastDaysOfYear / 7);
}

export default {
  name: "TaskPriority",
  data() {
    return {
      taskData: [],
      selectedWeek: null,
      currentYear: null,
      maxWeeks: 52,
      isDarkMode: document.body.classList.contains("dark-mode"),
      myChart: null, // Stockage de l'instance de graphique
    };
  },
  mounted() {
    this.currentYear = new Date().getFullYear();
    this.selectedWeek = getCurrentWeekNumber();
    this.fetchTaskPriorityData();

    // Observer le mode sombre
    this.observeDarkModeChange();
  },
  watch: {
    taskData() {
      this.renderChart();
    },
  },
  methods: {
    goToPreviousWeek() {
      if (this.selectedWeek > 1) {
        this.selectedWeek -= 1;
      } else {
        this.selectedWeek = this.maxWeeks;
        this.currentYear -= 1;
      }
      this.fetchTaskPriorityData();
    },
    goToNextWeek() {
      if (this.selectedWeek < this.maxWeeks) {
        this.selectedWeek += 1;
      } else {
        this.selectedWeek = 1;
        this.currentYear += 1;
      }
      this.fetchTaskPriorityData();
    },
    fetchTaskPriorityData() {
      axios
        .get("http://localhost:3000/api/statistiques/tasks-by-priority", {
          params: { year: this.currentYear, week: this.selectedWeek },
        })
        .then((response) => {
          this.taskData = response.data;
        })
        .catch((error) => {
          console.error("Erreur lors de la récupération des données :", error);
        });
    },
    observeDarkModeChange() {
      const observer = new MutationObserver(() => {
        this.isDarkMode = document.body.classList.contains("dark-mode");
        this.renderChart();
      });
      observer.observe(document.body, { attributes: true, attributeFilter: ["class"] });
    },
    renderChart() {
      // Attendre que le DOM soit prêt
      nextTick(() => {
        const chartDom = document.getElementById("taskPriority");

        if (!chartDom) {
          console.error("Élément DOM introuvable pour le graphique.");
          return;
        }

        // Supprimer l'ancien graphique si existant
        if (this.myChart) {
          this.myChart.dispose();
        }

   

    // Initialiser le graphique avec des dimensions fixes
    this.myChart = echarts.init(chartDom, null, { 
      width: 370,  // Largeur explicite
      height: 290, // Hauteur explicite
    });

        const daysTranslation = {
          Monday: "Lundi",
          Tuesday: "Mardi",
          Wednesday: "Mercredi",
          Thursday: "Jeudi",
          Friday: "Vendredi",
          Saturday: "Samedi",
          Sunday: "Dimanche",
        };
        const daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
        const priorities = ["urgent", "important", "moins important"];

        const seriesData = priorities.map((priority) => ({
          name: priority.charAt(0).toUpperCase() + priority.slice(1),
          type: "bar",
          data: daysOfWeek.map((day) => {
            const task = this.taskData.find(
              (t) => t.day_of_week === day && t.priority === priority
            );
            return task ? task.task_count : 0;
          }),
          barWidth: "10%",
          itemStyle: {
            color: priority === "urgent" ? "#3c096c" : priority === "important" ? "#7b2cbf" : "#e0aaff",
          },
        }));

        const option = {
          grid: {
            bottom: "0%",
            left: "5%",
            right: "5%",
            top: "35%",
            containLabel: true,
          },
          tooltip: {
            trigger: "axis",
            axisPointer: { type: "shadow" },
          },
          legend: {
            data: priorities.map((p) => p.charAt(0).toUpperCase() + p.slice(1)),
            top: "10%",
            textStyle: {
              color: this.isDarkMode ? "#FFF" : "#333",
            },
          },
          xAxis: {
            type: "category",
            data: daysOfWeek.map((day) => daysTranslation[day]),
            axisLabel: {
              rotate: 45,
              interval: 0,
              color: this.isDarkMode ? "#FFF" : "#333",
            },
          },
          yAxis: {
            type: "value",
            interval: 1,
            axisLabel: {
              color: this.isDarkMode ? "#FFF" : "#333",
            },
          },
          series: seriesData,
        };

        this.myChart.setOption(option);
      });
    },
  },
};
</script>

<style scoped>
.priorite {
  border-radius: 12px;
  box-shadow: 0 3px 12px rgba(0, 0, 0, 0.1);
  background-color: #fff;
  height: 400px;
  max-width: 600px;
  padding: 20px;
}
.dark-mode .priorite {
  background-color: rgb(55, 54, 56);
}
.navigation-buttons {
  display: flex;
  justify-content: space-between;
  margin-top: 10px;
}
.arrow-button {
  background-color: transparent;
  border: none;
  font-size: 1.5rem;
  cursor: pointer;
  padding: 10px;
}
.arrow-button i {
  color: rgb(82, 26, 122);
}
.arrow-button:hover {
  background-color: #f0f0f0;
  border-radius: 50%;
}
.dark-mode .arrow-button i {
  color: #e0aaff;
}
#taskPriority {
  width: 100%;
  height: 290px;
}

/* Responsive : Petits écrans */
@media screen and (max-width: 768px) {
  .priorite{
    margin-left: 70px;
  }
}
</style>
