<template>
  <v-chart 
    :option="chartOptions" 
    style="width: 100%; height: 400px;" 
    ref="chartRef"
    class="dashboard-pie-chart" 
  />
</template>

<script>
import { defineComponent, watch, ref, onMounted, onUnmounted } from 'vue';
import { use } from 'echarts/core';
import { PieChart } from 'echarts/charts';
import { TitleComponent, TooltipComponent, LegendComponent } from 'echarts/components';
import { CanvasRenderer } from 'echarts/renderers';
import VChart from 'vue-echarts';

use([PieChart, TitleComponent, TooltipComponent, LegendComponent, CanvasRenderer]);

export default defineComponent({
  name: 'PieChart',
  components: { VChart },
  props: {
    statistics: {
      type: Array,
      required: true,
    },
  },
  setup(props) {
    const chartRef = ref(null);
    const isDarkMode = ref(document.body.classList.contains('dark-mode'));

    const chartOptions = ref({
      tooltip: {
        trigger: 'item',
        formatter: '{b}: {c} ({d}%)',
      },
      legend: {
        top: '5%',
        left: 'center',
        orient: 'horizontal',
        textStyle: {
          color: isDarkMode.value ? '#FFF' : '#333',
          fontSize: 13,
        },
      },
      color: isDarkMode.value
        ? ['#5a189a', '#e0aaff', '#9d4edd', '#10002b', '#73C0DE']
        : ['#5a189a', '#e0aaff', '#9d4edd', '#10002b', '#73C0DE'],
      series: [
        {
          name: 'Task Statistics',
          type: 'pie',
          radius: '50%',
          data: [],
          label: {
            color: isDarkMode.value ? '#FFF' : '#333',
            fontSize: 12,
          },
          emphasis: {
            itemStyle: {
              shadowBlur: 10,
              shadowOffsetX: 0,
              shadowColor: 'rgba(0, 0, 0, 0.5)',
            },
          },
        },
      ],
    });

    // Watch for changes in dark mode class
    let observer; // Declare the observer outside to use it in both onMounted and onUnmounted
    const updateDarkMode = () => {
      isDarkMode.value = document.body.classList.contains('dark-mode');
      chartOptions.value.legend.textStyle.color = isDarkMode.value ? '#FFF' : '#333';
      chartOptions.value.color = isDarkMode.value
        ? ['#5a189a', '#e0aaff', '#9d4edd', '#10002b', '#73C0DE']
        : ['#5a189a', '#e0aaff', '#9d4edd', '#10002b', '#73C0DE'];
      chartOptions.value.series[0].label.color = isDarkMode.value ? '#FFF' : '#333';
    };

    onMounted(() => {
      observer = new MutationObserver(updateDarkMode);
      observer.observe(document.body, { attributes: true, attributeFilter: ['class'] });
    });

    onUnmounted(() => {
      if (observer) {
        observer.disconnect();
      }
    });

    // Watch for statistics updates
    watch(
      () => props.statistics,
      (newStatistics) => {
        chartOptions.value.series[0].data = newStatistics.map((stat) => {
          let modifiedStatus = stat.status;
          if (modifiedStatus === 'termine') modifiedStatus = 'Terminé';
          else if (modifiedStatus === 'pas commence') modifiedStatus = 'Pas commencé';
          else if (modifiedStatus === 'annule') modifiedStatus = 'Annulé';
          else if (modifiedStatus === 'en cours') modifiedStatus = 'En cours';

          return {
            value: stat.count,
            name: modifiedStatus,
          };
        });
      },
      { immediate: true }
    );

    return { chartOptions, chartRef };
  },
});
</script>

<style scoped>
.dashboard-pie-chart {
  border-radius: 12px;
  background: #fff;
  box-shadow: 0 8px 15px rgba(0, 0, 0, 0.1);
  max-width: 400px;
  transition: background-color 0.3s;
  

}
.dark-mode .dashboard-pie-chart{
  background-color: rgb(55, 54, 56);
  margin-left: 1px;
}

@media screen and (max-width: 768px) {
  .dashboard-pie-chart{
    margin-left: 1px;
    
  }
}  

</style>
