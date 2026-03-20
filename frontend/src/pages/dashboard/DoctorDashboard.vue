<script setup lang="ts">
import Card from "@/components/ui/Card.vue";
import CardContent from "@/components/ui/CardContent.vue";
import CardHeader from "@/components/ui/CardHeader.vue";
import CardTitle from "@/components/ui/CardTitle.vue";
import Badge from "@/components/ui/Badge.vue";
import Button from "@/components/ui/Button.vue";
import Table from "@/components/ui/Table.vue";
import TableHeader from "@/components/ui/TableHeader.vue";
import TableBody from "@/components/ui/TableBody.vue";
import TableRow from "@/components/ui/TableRow.vue";
import TableHead from "@/components/ui/TableHead.vue";
import TableCell from "@/components/ui/TableCell.vue";
import { Calendar, ClipboardList, FileText, Stethoscope } from "lucide-vue-next";
import { useAuthStore } from "@/stores/auth";

const auth = useAuthStore();

const todayAgenda = [
  { hora: "08:00", paciente: "Juan Pérez", estudio: "Ecografía Abdominal", estado: "En espera" },
  { hora: "09:00", paciente: "María García", estudio: "Ecografía Tiroides", estado: "En curso" },
  { hora: "10:30", paciente: "Carlos López", estudio: "Ecografía Renal", estado: "Pendiente" },
  { hora: "11:30", paciente: "Ana Martínez", estudio: "Ecografía Mamaria", estado: "Pendiente" },
];

const pendingReports = [
  { id: 1, fecha: "14/02/2026", paciente: "Luis Torres", estudio: "TC Cerebral" },
  { id: 2, fecha: "13/02/2026", paciente: "Paula Sánchez", estudio: "RMN Columna" },
  { id: 3, fecha: "12/02/2026", paciente: "Ricardo Díaz", estudio: "Ecografía Doppler" },
];

const doctorStats = [
  { label: "Turnos Hoy", value: "8", icon: Calendar, color: "text-primary" },
  { label: "Informes Pendientes", value: "3", icon: FileText, color: "text-orange-500" },
  { label: "Estudios Mes", value: "42", icon: Stethoscope, color: "text-secondary" },
];
</script>

<template>
  <div class="space-y-6">
    <div>
      <h1 class="text-2xl font-bold">Bienvenida, {{ auth.user?.name }}</h1>
      <p class="text-muted-foreground">Resumen de tu jornada y estudios pendientes</p>
    </div>

    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
      <Card v-for="s in doctorStats" :key="s.label">
        <CardContent class="flex items-center gap-3 p-4">
          <component :is="s.icon" :class="['h-8 w-8', s.color]" />
          <div>
            <p class="text-xl font-bold">{{ s.value }}</p>
            <p class="text-xs text-muted-foreground">{{ s.label }}</p>
          </div>
        </CardContent>
      </Card>
    </div>

    <Card>
      <CardHeader>
        <CardTitle class="flex items-center gap-2 text-base">
          <Calendar class="h-4 w-4 text-primary" /> Agenda de Hoy
        </CardTitle>
      </CardHeader>
      <CardContent>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Hora</TableHead>
              <TableHead>Paciente</TableHead>
              <TableHead>Estudio</TableHead>
              <TableHead>Estado</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-for="(a, i) in todayAgenda" :key="i">
              <TableCell class="font-medium">{{ a.hora }}</TableCell>
              <TableCell>{{ a.paciente }}</TableCell>
              <TableCell>{{ a.estudio }}</TableCell>
              <TableCell>
                <Badge :variant="a.estado === 'En curso' ? 'default' : a.estado === 'En espera' ? 'secondary' : 'outline'">
                  {{ a.estado }}
                </Badge>
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </CardContent>
    </Card>

    <Card>
      <CardHeader>
        <CardTitle class="flex items-center gap-2 text-base">
          <ClipboardList class="h-4 w-4 text-orange-500" /> Informes Pendientes
        </CardTitle>
      </CardHeader>
      <CardContent>
        <div class="space-y-3">
          <div v-for="r in pendingReports" :key="r.id" class="flex items-center justify-between p-3 bg-muted/30 rounded-lg">
            <div>
              <p class="text-sm font-medium">{{ r.paciente }} — {{ r.estudio }}</p>
              <p class="text-xs text-muted-foreground">{{ r.fecha }}</p>
            </div>
            <Button size="sm" variant="outline">Informar</Button>
          </div>
        </div>
      </CardContent>
    </Card>
  </div>
</template>
