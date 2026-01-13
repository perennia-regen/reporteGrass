'use client';

import {
  Document,
  Page,
  Text,
  View,
  StyleSheet,
  pdf,
  Image,
} from '@react-pdf/renderer';
import { mockDashboardData } from './mock-data';
import { ISE_THRESHOLD, grassTheme } from '@/styles/grass-theme';

// Estilos para el PDF
const styles = StyleSheet.create({
  page: {
    padding: 40,
    fontSize: 11,
    fontFamily: 'Helvetica',
    backgroundColor: '#FFFFFF',
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 20,
    paddingBottom: 10,
    borderBottomWidth: 2,
    borderBottomColor: grassTheme.colors.primary.green,
  },
  headerTitle: {
    fontSize: 20,
    fontFamily: 'Helvetica-Bold',
    color: grassTheme.colors.primary.greenDark,
  },
  headerSubtitle: {
    fontSize: 10,
    color: '#666666',
    marginTop: 4,
  },
  section: {
    marginBottom: 20,
  },
  sectionTitle: {
    fontSize: 14,
    fontFamily: 'Helvetica-Bold',
    color: grassTheme.colors.primary.greenDark,
    marginBottom: 10,
    paddingBottom: 5,
    borderBottomWidth: 1,
    borderBottomColor: '#E0E0E0',
  },
  card: {
    backgroundColor: '#F9FAFB',
    padding: 12,
    borderRadius: 4,
    marginBottom: 10,
  },
  row: {
    flexDirection: 'row',
    marginBottom: 6,
  },
  label: {
    fontSize: 9,
    color: '#666666',
    width: 100,
  },
  value: {
    fontSize: 10,
    fontFamily: 'Helvetica-Bold',
  },
  kpiContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    gap: 10,
  },
  kpiCard: {
    flex: 1,
    backgroundColor: '#F9FAFB',
    padding: 15,
    borderRadius: 4,
    alignItems: 'center',
  },
  kpiValue: {
    fontSize: 24,
    fontFamily: 'Helvetica-Bold',
    color: grassTheme.colors.primary.greenDark,
  },
  kpiLabel: {
    fontSize: 9,
    color: '#666666',
    marginTop: 4,
  },
  table: {
    marginTop: 10,
  },
  tableHeader: {
    flexDirection: 'row',
    backgroundColor: grassTheme.colors.primary.greenDark,
    padding: 8,
  },
  tableHeaderCell: {
    color: '#FFFFFF',
    fontSize: 10,
    fontFamily: 'Helvetica-Bold',
  },
  tableRow: {
    flexDirection: 'row',
    borderBottomWidth: 1,
    borderBottomColor: '#E0E0E0',
    padding: 8,
  },
  tableCell: {
    fontSize: 10,
  },
  iseBar: {
    height: 20,
    backgroundColor: '#E0E0E0',
    borderRadius: 4,
    marginVertical: 4,
    position: 'relative',
  },
  iseBarFill: {
    height: '100%',
    borderRadius: 4,
  },
  iseBarLabel: {
    position: 'absolute',
    right: 8,
    top: 3,
    fontSize: 10,
    fontFamily: 'Helvetica-Bold',
    color: '#FFFFFF',
  },
  footer: {
    position: 'absolute',
    bottom: 30,
    left: 40,
    right: 40,
    flexDirection: 'row',
    justifyContent: 'space-between',
    borderTopWidth: 1,
    borderTopColor: '#E0E0E0',
    paddingTop: 10,
  },
  footerText: {
    fontSize: 8,
    color: '#666666',
  },
  paragraph: {
    fontSize: 10,
    lineHeight: 1.5,
    color: '#374151',
  },
});

// Secciones disponibles para el PDF
export type PDFSection =
  | 'identificacion'
  | 'kpis'
  | 'iseEstrato'
  | 'observacionGeneral'
  | 'planResumen'
  | 'planEstratos'
  | 'procesos'
  | 'estratificacion'
  | 'recomendaciones'
  | 'comentarioFinal'
  | 'sobreGrassIntro'
  | 'sobreGrassISE'
  | 'comunidadEstadisticas';

export const PDF_SECTIONS: { id: PDFSection; label: string; tab: string }[] = [
  { id: 'identificacion', label: 'Identificación del Predio', tab: 'Inicio' },
  { id: 'kpis', label: 'Datos Destacados', tab: 'Inicio' },
  { id: 'iseEstrato', label: 'ISE por Estrato', tab: 'Inicio' },
  { id: 'observacionGeneral', label: 'Observación General', tab: 'Inicio' },
  { id: 'planResumen', label: 'Resumen del Plan', tab: 'Plan de Monitoreo' },
  { id: 'planEstratos', label: 'Tabla de Estratos', tab: 'Plan de Monitoreo' },
  { id: 'procesos', label: 'Procesos del Ecosistema', tab: 'Resultados' },
  { id: 'estratificacion', label: 'Estratificación', tab: 'Resultados' },
  { id: 'recomendaciones', label: 'Recomendaciones', tab: 'Resultados' },
  { id: 'comentarioFinal', label: 'Comentario Final', tab: 'Resultados' },
  { id: 'sobreGrassIntro', label: 'Introducción GRASS', tab: 'Sobre GRASS' },
  { id: 'sobreGrassISE', label: 'Explicación ISE', tab: 'Sobre GRASS' },
  { id: 'comunidadEstadisticas', label: 'Estadísticas Comunidad', tab: 'Comunidad' },
];

// Componente del documento PDF
interface ReportePDFProps {
  observacionGeneral: string;
  comentarioFinal: string;
  selectedSections?: PDFSection[];
}

export function ReportePDF({ observacionGeneral, comentarioFinal, selectedSections }: ReportePDFProps) {
  // Si no se especifican secciones, mostrar todas
  const sections = selectedSections || PDF_SECTIONS.map(s => s.id);
  const { establecimiento, ise, estratos, procesos, recomendaciones } = mockDashboardData;

  // Determinar qué páginas mostrar según las secciones seleccionadas
  const showPage1 = sections.some(s => ['identificacion', 'kpis', 'iseEstrato', 'observacionGeneral'].includes(s));
  const showPage2 = sections.some(s => ['procesos', 'estratificacion', 'recomendaciones', 'comentarioFinal'].includes(s));
  const totalPages = (showPage1 ? 1 : 0) + (showPage2 ? 1 : 0);
  let currentPage = 0;

  return (
    <Document>
      {/* Página 1: Resumen Ejecutivo */}
      {showPage1 && (
        <Page size="A4" style={styles.page}>
          {/* Header */}
          <View style={styles.header}>
            <View>
              <Text style={styles.headerTitle}>
                GRASS - Monitoreo Ambiental
              </Text>
              <Text style={styles.headerSubtitle}>
                Informe de Salud Ecosistémica
              </Text>
            </View>
            <View style={{ alignItems: 'flex-end' }}>
              <Text style={{ fontSize: 14, fontFamily: 'Helvetica-Bold' }}>
                {establecimiento.nombre}
              </Text>
              <Text style={{ fontSize: 9, color: '#666666' }}>
                {establecimiento.fecha}
              </Text>
            </View>
          </View>

          {/* Identificación del Predio */}
          {sections.includes('identificacion') && (
            <View style={styles.section}>
              <Text style={styles.sectionTitle}>Identificación del Predio</Text>
              <View style={styles.card}>
                <View style={styles.row}>
                  <Text style={styles.label}>Establecimiento:</Text>
                  <Text style={styles.value}>{establecimiento.nombre}</Text>
                </View>
                <View style={styles.row}>
                  <Text style={styles.label}>Código:</Text>
                  <Text style={styles.value}>{establecimiento.codigo}</Text>
                </View>
                <View style={styles.row}>
                  <Text style={styles.label}>Nodo:</Text>
                  <Text style={styles.value}>{establecimiento.nodo}</Text>
                </View>
                <View style={styles.row}>
                  <Text style={styles.label}>Técnico:</Text>
                  <Text style={styles.value}>{establecimiento.tecnico}</Text>
                </View>
                <View style={styles.row}>
                  <Text style={styles.label}>Ubicación:</Text>
                  <Text style={styles.value}>
                    {establecimiento.ubicacion.provincia}, {establecimiento.ubicacion.departamento}
                  </Text>
                </View>
              </View>
            </View>
          )}

          {/* KPIs */}
          {sections.includes('kpis') && (
            <View style={styles.section}>
              <Text style={styles.sectionTitle}>Datos Destacados</Text>
              <View style={styles.kpiContainer}>
                <View style={styles.kpiCard}>
                  <Text style={styles.kpiValue}>{ise.promedio.toFixed(1)}</Text>
                  <Text style={styles.kpiLabel}>ISE Promedio</Text>
                </View>
                <View style={styles.kpiCard}>
                  <Text style={[styles.kpiValue, { color: grassTheme.colors.estratos.loma }]}>
                    {establecimiento.areaTotal}
                  </Text>
                  <Text style={styles.kpiLabel}>Hectáreas</Text>
                </View>
                <View style={styles.kpiCard}>
                  <Text style={[styles.kpiValue, { color: grassTheme.colors.procesos.cicloAgua }]}>
                    {estratos.reduce((sum, e) => sum + e.estaciones, 0)}
                  </Text>
                  <Text style={styles.kpiLabel}>Sitios MCP</Text>
                </View>
                <View style={styles.kpiCard}>
                  <Text style={[styles.kpiValue, { color: grassTheme.colors.estratos.bajo }]}>
                    {estratos.length}
                  </Text>
                  <Text style={styles.kpiLabel}>Estratos</Text>
                </View>
              </View>
            </View>
          )}

          {/* ISE por Estrato */}
          {sections.includes('iseEstrato') && (
            <View style={styles.section}>
              <Text style={styles.sectionTitle}>ISE por Estrato</Text>
              {Object.entries(ise.porEstrato).map(([estrato, valor]) => (
                <View key={estrato} style={{ marginBottom: 8 }}>
                  <View style={{ flexDirection: 'row', justifyContent: 'space-between', marginBottom: 2 }}>
                    <Text style={{ fontSize: 10 }}>{estrato}</Text>
                    <Text style={{ fontSize: 10, fontFamily: 'Helvetica-Bold' }}>{valor.toFixed(1)}</Text>
                  </View>
                  <View style={styles.iseBar}>
                    <View
                      style={[
                        styles.iseBarFill,
                        {
                          width: `${Math.max(valor, 0)}%`,
                          backgroundColor: valor >= ISE_THRESHOLD
                            ? grassTheme.colors.primary.green
                            : grassTheme.colors.estratos.bajo,
                        },
                      ]}
                    />
                  </View>
                </View>
              ))}
              <Text style={{ fontSize: 8, color: '#666666', marginTop: 4 }}>
                Umbral deseable: {ISE_THRESHOLD} puntos
              </Text>
            </View>
          )}

          {/* Observación General */}
          {sections.includes('observacionGeneral') && (
            <View style={styles.section}>
              <Text style={styles.sectionTitle}>Observación General</Text>
              <Text style={styles.paragraph}>{observacionGeneral}</Text>
            </View>
          )}

          {/* Footer */}
          <View style={styles.footer}>
            <Text style={styles.footerText}>
              Protocolo GRASS - Monitoreo de Pastizales Regenerativos
            </Text>
            <Text style={styles.footerText}>Página {++currentPage} de {totalPages}</Text>
          </View>
        </Page>
      )}

      {/* Página 2: Resultados y Recomendaciones */}
      {showPage2 && (
        <Page size="A4" style={styles.page}>
          {/* Header */}
          <View style={styles.header}>
            <View>
              <Text style={styles.headerTitle}>Resultados y Recomendaciones</Text>
              <Text style={styles.headerSubtitle}>{establecimiento.nombre} - {establecimiento.fecha}</Text>
            </View>
          </View>

          {/* Procesos Ecosistémicos */}
          {sections.includes('procesos') && (
            <View style={styles.section}>
              <Text style={styles.sectionTitle}>Procesos del Ecosistema</Text>
              <View style={styles.card}>
                <View style={styles.row}>
                  <Text style={{ ...styles.label, width: 150 }}>Ciclo del Agua:</Text>
                  <Text style={styles.value}>{procesos.cicloAgua}%</Text>
                </View>
                <View style={styles.row}>
                  <Text style={{ ...styles.label, width: 150 }}>Ciclo de los Minerales:</Text>
                  <Text style={styles.value}>{procesos.cicloMineral}%</Text>
                </View>
                <View style={styles.row}>
                  <Text style={{ ...styles.label, width: 150 }}>Flujo de Energía:</Text>
                  <Text style={styles.value}>{procesos.flujoEnergia}%</Text>
                </View>
                <View style={styles.row}>
                  <Text style={{ ...styles.label, width: 150 }}>Dinámica de Comunidades:</Text>
                  <Text style={styles.value}>{procesos.dinamicaComunidades}%</Text>
                </View>
              </View>
            </View>
          )}

          {/* Tabla de Estratificación */}
          {sections.includes('estratificacion') && (
            <View style={styles.section}>
              <Text style={styles.sectionTitle}>Estratificación</Text>
              <View style={styles.table}>
                <View style={styles.tableHeader}>
                  <Text style={[styles.tableHeaderCell, { width: '25%' }]}>Estrato</Text>
                  <Text style={[styles.tableHeaderCell, { width: '20%' }]}>Superficie</Text>
                  <Text style={[styles.tableHeaderCell, { width: '15%' }]}>%</Text>
                  <Text style={[styles.tableHeaderCell, { width: '20%' }]}>Estaciones</Text>
                  <Text style={[styles.tableHeaderCell, { width: '20%' }]}>Ha/Est.</Text>
                </View>
                {estratos.map((estrato) => (
                  <View key={estrato.id} style={styles.tableRow}>
                    <Text style={[styles.tableCell, { width: '25%' }]}>{estrato.nombre}</Text>
                    <Text style={[styles.tableCell, { width: '20%' }]}>{estrato.superficie} has</Text>
                    <Text style={[styles.tableCell, { width: '15%' }]}>{estrato.porcentaje}%</Text>
                    <Text style={[styles.tableCell, { width: '20%' }]}>{estrato.estaciones}</Text>
                    <Text style={[styles.tableCell, { width: '20%' }]}>{estrato.areaPorEstacion}</Text>
                  </View>
                ))}
              </View>
            </View>
          )}

          {/* Recomendaciones */}
          {sections.includes('recomendaciones') && (
            <View style={styles.section}>
              <Text style={styles.sectionTitle}>Recomendaciones por Estrato</Text>
              {recomendaciones.map((rec) => (
                <View key={rec.estrato} style={{ marginBottom: 10 }}>
                  <Text style={{ fontSize: 11, fontFamily: 'Helvetica-Bold', marginBottom: 4 }}>
                    {rec.estrato}
                  </Text>
                  <Text style={{ fontSize: 9, lineHeight: 1.4, color: '#374151' }}>
                    {rec.sugerencia}
                  </Text>
                </View>
              ))}
            </View>
          )}

          {/* Comentario Final */}
          {sections.includes('comentarioFinal') && (
            <View style={styles.section}>
              <Text style={styles.sectionTitle}>Comentario Final</Text>
              <Text style={styles.paragraph}>{comentarioFinal}</Text>
            </View>
          )}

          {/* Footer */}
          <View style={styles.footer}>
            <Text style={styles.footerText}>
              Generado con GRASS Dashboard Builder - Ovis21
            </Text>
            <Text style={styles.footerText}>Página {showPage1 ? 2 : 1} de {totalPages}</Text>
          </View>
        </Page>
      )}
    </Document>
  );
}

// Función para generar y descargar el PDF
export async function generatePDF(
  observacionGeneral: string,
  comentarioFinal: string,
  selectedSections?: PDFSection[]
): Promise<void> {
  const blob = await pdf(
    <ReportePDF
      observacionGeneral={observacionGeneral}
      comentarioFinal={comentarioFinal}
      selectedSections={selectedSections}
    />
  ).toBlob();

  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = `GRASS_Reporte_${mockDashboardData.establecimiento.nombre.replace(/\s+/g, '_')}_${new Date().toISOString().split('T')[0]}.pdf`;
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  URL.revokeObjectURL(url);
}
