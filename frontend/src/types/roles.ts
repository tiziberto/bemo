import {
  Users, Stethoscope, Building2, CalendarDays, FileText, Settings,
  ClipboardList, Send, UserCheck, DollarSign, Copy, Archive,
  Receipt, BarChart3, FileSpreadsheet, BookOpen, Ban, Activity,
  Calendar, Download, Phone, Heart, Clock, Briefcase,
  type Component,
} from "lucide-vue-next";

export type UserRole = "ROLE_ADMIN" | "ROLE_PACIENTE" | "ROLE_DOCTOR" | "ROLE_RECEPCION" | "ROLE_FACTURACION";

export interface MockUser {
  id: string;
  name: string;
  email: string;
  role: UserRole;
  dni: string;
}

export interface SidebarSection {
  title: string;
  items: SidebarItem[];
}

export interface SidebarItem {
  label: string;
  icon: Component;
  path: string;
}

export const roleLabels: Record<UserRole, string> = {
  ROLE_ADMIN: "Administrador",
  ROLE_PACIENTE: "Paciente",
  ROLE_DOCTOR: "Médico",
  ROLE_RECEPCION: "Recepción",
  ROLE_FACTURACION: "Facturación",
};

export const mockUsers: MockUser[] = [
  { id: "1", name: "Admin ECOMED", email: "admin@ecomed.com", role: "admin", dni: "11111111" },
  { id: "2", name: "Juan Pérez", email: "juan@email.com", role: "paciente", dni: "22222222" },
  { id: "3", name: "Dra. María López", email: "maria@ecomed.com", role: "medico", dni: "33333333" },
  { id: "4", name: "Ana García", email: "ana@ecomed.com", role: "administrativo", dni: "44444444" },
  { id: "5", name: "Carlos Ruiz", email: "carlos@ecomed.com", role: "contaduria", dni: "55555555" },
];

export const sidebarConfig: Record<UserRole, SidebarSection[]> = {
  ROLE_ADMIN: [
    {
      title: "Tablas",
      items: [
        { label: "Pacientes", icon: Users, path: "/dashboard/pacientes" },
        { label: "Profesionales", icon: Stethoscope, path: "/dashboard/profesionales" },
        { label: "Obras Sociales", icon: Building2, path: "/dashboard/obras-sociales" },
        { label: "Nomenclador", icon: BookOpen, path: "/dashboard/nomenclador" },
        { label: "Usuarios", icon: Users, path: "/dashboard/usuarios" },
        { label: "Solicitantes", icon: UserCheck, path: "/dashboard/solicitantes" },
        { label: "Pre-informes", icon: FileText, path: "/dashboard/pre-informes" },
        { label: "Períodos", icon: Clock, path: "/dashboard/periodos" },
      ],
    },
    {
      title: "Procesos",
      items: [
        { label: "Turnos", icon: CalendarDays, path: "/dashboard/turnos" },
        { label: "Informar Estudio", icon: ClipboardList, path: "/dashboard/informar-estudio" },
        { label: "Enviar Confirmación", icon: Send, path: "/dashboard/enviar-confirmacion" },
        { label: "Atención de Pacientes", icon: UserCheck, path: "/dashboard/atencion" },
        { label: "Valorizar Prestaciones", icon: DollarSign, path: "/dashboard/valorizar" },
        { label: "Copiar Valores", icon: Copy, path: "/dashboard/copiar-valores" },
        { label: "Valores en Depósito", icon: Archive, path: "/dashboard/deposito" },
        { label: "Generar Resumen Fact.", icon: Receipt, path: "/dashboard/resumen-facturacion" },
        { label: "Enviar Informes", icon: Send, path: "/dashboard/enviar-informes" },
      ],
    },
    {
      title: "Informes",
      items: [
        { label: "Rendiciones", icon: FileSpreadsheet, path: "/dashboard/rendiciones" },
        { label: "Facturación", icon: DollarSign, path: "/dashboard/facturacion" },
        { label: "Liquidaciones", icon: BarChart3, path: "/dashboard/liquidaciones" },
        { label: "Facturación por Origen", icon: Receipt, path: "/dashboard/fact-origen" },
        { label: "Resumen de Facturación", icon: FileText, path: "/dashboard/resumen-fact" },
      ],
    },
    {
      title: "Utilidades",
      items: [
        { label: "Datos para Recordar", icon: BookOpen, path: "/dashboard/datos-recordar" },
        { label: "Anular Día de Turnos", icon: Ban, path: "/dashboard/anular-dia" },
      ],
    },
  ],
  ROLE_PACIENTE: [
    {
      title: "Mi Portal",
      items: [
        { label: "Mis Turnos", icon: Calendar, path: "/dashboard/mis-turnos" },
        { label: "Solicitar Turno", icon: CalendarDays, path: "/dashboard/solicitar-turno" },
        { label: "Historial de Estudios", icon: FileText, path: "/dashboard/historial" },
        { label: "Descargar Informes", icon: Download, path: "/dashboard/informes" },
        { label: "Historia Clínica", icon: Heart, path: "/dashboard/historia-clinica" },
        { label: "Mis Datos", icon: Users, path: "/dashboard/mis-datos" },
        { label: "Contacto", icon: Phone, path: "/dashboard/contacto-clinica" },
      ],
    },
  ],
  ROLE_DOCTOR: [
    {
      title: "Mi Práctica",
      items: [
        { label: "Mi Agenda", icon: Calendar, path: "/dashboard/mi-agenda" },
        { label: "Estudios Asignados", icon: ClipboardList, path: "/dashboard/estudios-asignados" },
        { label: "Informar Estudios", icon: FileText, path: "/dashboard/informar" },
        { label: "Historial Realizados", icon: Activity, path: "/dashboard/historial-realizados" },
        { label: "Informes Previos", icon: FileSpreadsheet, path: "/dashboard/informes-previos" },
        { label: "Pacientes Atendidos", icon: Users, path: "/dashboard/pacientes-atendidos" },
      ],
    },
    {
      title: "Facturación",
      items: [
        { label: "Mi Facturación", icon: DollarSign, path: "/dashboard/mi-facturacion" },
        { label: "Liquidaciones", icon: BarChart3, path: "/dashboard/mis-liquidaciones" },
      ],
    },
  ],
  ROLE_RECEPCION: [
    {
      title: "Operaciones",
      items: [
        { label: "Gestión de Turnos", icon: CalendarDays, path: "/dashboard/gestion-turnos" },
        { label: "Atención de Pacientes", icon: UserCheck, path: "/dashboard/atencion-pacientes" },
        { label: "Alta de Pacientes", icon: Users, path: "/dashboard/alta-pacientes" },
        { label: "Asignar Estudios", icon: ClipboardList, path: "/dashboard/asignar-estudios" },
        { label: "Enviar Confirmaciones", icon: Send, path: "/dashboard/confirmaciones" },
        { label: "Gestión de Agendas", icon: Calendar, path: "/dashboard/agendas" },
      ],
    },
  ],
  ROLE_FACTURACION: [
    {
      title: "Finanzas",
      items: [
        { label: "Facturación", icon: DollarSign, path: "/dashboard/facturacion-cont" },
        { label: "Rendiciones", icon: FileSpreadsheet, path: "/dashboard/rendiciones-cont" },
        { label: "Liquidaciones", icon: BarChart3, path: "/dashboard/liquidaciones-cont" },
        { label: "Fact. por Obra Social", icon: Receipt, path: "/dashboard/fact-obra-social" },
        { label: "Resúmenes Mensuales", icon: FileText, path: "/dashboard/resumenes" },
        { label: "Exportar Reportes", icon: Download, path: "/dashboard/exportar" },
      ],
    },
  ],
};
