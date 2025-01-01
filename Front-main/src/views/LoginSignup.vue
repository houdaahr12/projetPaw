<template>
  <v-container>
    <v-row align="center" justify="center">
      <v-col cols="12" sm="10">
        <v-card style="margin-bottom: 200px; " class="elevation-6 ">
          <v-window v-model="step">
            <!-- Login Page -->
            <v-window-item :value="1">
              <v-row>
                <v-col cols="12" md="6">
                  <v-card-text class="mt-15">
                    <img :src="logoo" alt="Logo" width="70px" class="mt-n9" />
                    <h2 class="text-center mb-5 mt-2" style="color:hsl(268, 70%, 30%)">Bienvenue de nouveau !</h2>
                    <h6 class="text-center text-grey mb-n10">
                      Connectez-vous à votre compte pour continuer à gérer<br />
                      vos tâches efficacement.
                    </h6>
                    <v-row align="center" justify="center">
                      <v-col cols="12" sm="8">
                        <v-text-field
                        label="Email"
                        outlined
                        dense
                         class="mt-16"
                        color="hsl(268, 70%, 30%)"
                        type="email"
                        v-model="email"
                         :rules="[emailRules.required, emailRules.email]"
                        />
                        <v-text-field
                          label="Mot de passe"
                          outlined
                          dense
                          color="hsl(268, 70%, 30%)"
                          type="password"
                          v-model="password"
                        />
                        
                          
                        <v-btn  class="buttons" block tile :disabled="!isLoginValid"  @click="login">Se connecter</v-btn>
                      
            
                      </v-col>
                    </v-row>
                  </v-card-text>
                </v-col>
                <v-col cols="12" md="6" class="purple_bg" style="border-bottom-left-radius: 200px !important">
                  <div style="text-align: center; padding: 180px 0;">
                    <v-card-text class="text-white">
                      <h5 class="text-center mb-5">Pas encore inscrit(e) ?</h5>
                      <h6 class="text-center mb-3 ">
                        Créez un compte pour commencer à organiser vos tâches et atteindre vos objectifs.
                      </h6>
                    </v-card-text>
                    <div class="text-center">
                   <v-btn tile outlined dark class="custom-v-btn" @click="step++" > S'inscrire</v-btn>
                    </div>
                  </div>
                </v-col>
              </v-row>
            </v-window-item>
            <!-- Signup Page -->
            <v-window-item :value="2">
              <v-row>
                <v-col cols="12" md="6" class="purple_bg " style="border-bottom-right-radius: 200px !important">
                  <div style="text-align: center; padding: 180px 0;">
                    <v-card-text class="text-white mt-10">
                      <h4 class="text-center mb-5 ">Déjà inscrit(e) ?</h4>
                      <h6 class="text-center ">
                        Connectez-vous à votre compte pour continuer à gérer vos tâches.
                      </h6>
                    </v-card-text>
                    <div class="text-center">
                   <v-btn
                          tile
                         outlined
                           dark
                          class="custom-v-btn"
                               @click="step--"
                         > Se connecter</v-btn>
                    </div>
                  </div>
                </v-col>
                <v-col cols="12" md="6">
                  <v-card-text class="mt-12">
                    <img :src="logoo" alt="Logo" width="70px" class="mt-n9" />
                    <h2 class="text-center mb-4" style="color:hsl(268, 70%, 30%)">Créer un compte</h2>
                    <h6 class="text-center text-grey">
                      Inscrivez-vous pour organiser votre emploi du temps et vos objectifs.
                    </h6>
                    <v-row align="center" justify="center">
                      <v-col cols="12" sm="8">
                        <v-row>
                          <v-col cols="12" sm="6">
                            <v-text-field
                              label="Prénom"
                              outlined
                              dense
                              color="hsl(268, 70%, 30%)"
                              class="mt-4"
                              v-model="name"
                            />
                          </v-col>
                          <v-col cols="12" sm="6">
                            <v-text-field
                              label="Nom"
                              outlined
                              dense
                              color="hsl(268, 70%, 30%)"
                              class="mt-4"
                              v-model="surname"
                            />
                          </v-col>
                        </v-row>
                        <v-text-field
                          label="Email"
                          outlined
                          dense
                          color="hsl(268, 70%, 30%)"
                          type="email"
                          v-model="email"
                           :rules="[emailRules.required, emailRules.email]"
                        />
                        <v-text-field
                        label="Mot de passe"
                           outlined
                            dense
                           color="hsl(268, 70%, 30%)"
                            type="password"
                            v-model="password"
                          :rules="[passwordRules.required, passwordRules.min]"
                        />
                        <v-text-field
                        label="Confirmer le mot de passe"
                           outlined
                           dense
                           color="hsl(268, 70%, 30%)"
                            type="password"
                            v-model="confirmPassword"
                           :rules="[passwordRules.required, passwordConfirmRule]"
                         />
                        <v-row>
                          <v-col cols="12" sm="12">
                            <v-checkbox v-model="acceptTerms" color= "hsl(268, 70%, 30%)" :rules="[rules.required]">
                                <template #label>J'accepte les<span style="margin-left:2px;"></span> <router-link to="/UserTerms" class="terms-link"> termes et conditions</router-link></template>
                            </v-checkbox>
                          </v-col>
                        </v-row>
                        <v-btn class="buttons" block tile :disabled="!isFormValid" @click="signup">S'inscrire</v-btn>
                     
                      </v-col>
                    </v-row>
                  </v-card-text>
                </v-col>
              </v-row>
            </v-window-item>
          </v-window>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script setup>
import { ref, computed } from "vue";
import { VContainer, VRow, VCol, VCard, VTextField, VCheckbox, VBtn} from 'vuetify/components';
import  'vuetify/styles';
import axios from "axios";
import logoo from '@/assets/logo1.png';
import {  onMounted, watch  } from 'vue';
import { useRoute } from 'vue-router';

const route = useRoute(); 
const step = ref(2);
const name = ref("");
const surname = ref("");
const email = ref("");
const password = ref("");
const acceptTerms = ref(false);
const confirmPassword = ref("");

axios.defaults.withCredentials = true;
const updateStep = () => {
  if (route.query.mode === 'signup') {
    step.value = 2; // Show the signup form
  } else {
    step.value = 1; 
  }
};
const passwordConfirmRule = (value) => {
  if (value !== password.value) {
    return "Les mots de passe ne correspondent pas.";
  }
  return true;
};
const passwordRules = {
  required: value => !!value || 'Le mot de passe est requis.',
  min: value => (value && value.length >= 8) || 'Le mot de passe doit contenir au moins 8 caractères.',
};


const isFormValid = computed(() => {
  return (
    emailRules.required(email.value) === true &&
    emailRules.email(email.value) === true &&
    passwordRules.required(password.value) === true &&
    passwordRules.min(password.value) === true &&
    passwordConfirmRule(confirmPassword.value) === true &&
    acceptTerms.value
  );
});
const isLoginValid = computed(() => {
  return (
    emailRules.required(email.value) === true &&
    emailRules.email(email.value) === true &&
    passwordRules.required(password.value) === true
  );
});


onMounted(() => {
  updateStep(); 
});


watch(route, updateStep, { immediate: true });

const rules = {
  required: (value) => !!value || "Vous devez accepter les termes et conditions.",
};
const emailRules = {
  required: value => !!value || 'L’email est requis.',
  email: value => {
    const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return regex.test(value) || 'Veuillez entrer une adresse email valide.';
  },
};

//login route
const login = async () => {
  try {
    const response = await axios.post("http://localhost:3000/login", {
      email: email.value,
      password: password.value,
    });
    alert(response.data.message);

    if (response.status === 200) {
      window.location.href = "/dashboard"; 
    }
  } catch (error) {
    alert(error.response?.data?.message || "Une erreur est survenue");
  }
};

const signup = async () => {
  try {
    const response = await axios.post("http://localhost:3000/signup", {
      name: name.value,
      surname: surname.value,
      email: email.value,
      password: password.value,
    });
    alert(response.data.message);
    step.value = 1;
  } catch (error) {
    alert(error.response?.data?.message || "Une erreur est survenue");
  }
};
</script>

<style >

.purple_bg {
  background-color: hsl(268, 70%, 30%);
}
.buttons{
  margin-bottom: 50px;
  background-color:hsl(268, 70%, 30%) ;
  color:#f4f3f3;
}

.custom-v-btn {
  padding: 1.3em 3em;
  font-size: 12px;
  text-transform: uppercase;
  letter-spacing: 2.5px;
  font-weight: 500;
  color: #000;
  background-color: #d6aefef1;
  border-radius: 100px;
  box-shadow: 0px 8px 15px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease 0s;
  cursor: pointer;
}

.custom-v-btn:hover {
  background-color: #861ed0;
  box-shadow: 0px 15px 20px rgba(49, 32, 62, 0.918);
  color: #fff;
  transform: translateY(-4px);
}

.custom-v-btn:active {
  transform: translateY(-1px);
}
.terms-link {
  color: hsl(268, 70%, 30%);
  text-decoration: underline;
}

.terms-link:hover {
  color: hsl(268, 60%, 40%);
}
v-checkbox input {
  display: block !important;
  width: auto !important;
  height: auto !important;
  background-color: white !important;
}


.dark-mode {
  background-color:#212121 ;
  color: #ffffff;
}

.dark-mode .v-card {
  background-color: #484747;
  color: #ffffff;
}

.dark-mode .v-text-field input {
  background-color: #333;
  color: #ffffff;
}

.dark-mode .v-btn {
  background-color: #444;
  color: #ffffff;
}

.dark-mode .terms-link {
  color: #bbb;
}
.dark-mode .purple_bg {
  background-color: hsl(267, 34%, 55%);
}
</style>