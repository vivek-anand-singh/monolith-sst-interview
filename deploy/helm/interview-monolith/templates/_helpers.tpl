{{- define "interview-monolith.name" -}}
{{- .Chart.Name -}}
{{- end -}}

{{- define "interview-monolith.labels" -}}
app.kubernetes.io/name: {{ include "interview-monolith.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ required "image.tag (the commit SHA) must be set" .Values.image.tag | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end -}}

{{- define "interview-monolith.selectorLabels" -}}
app.kubernetes.io/name: {{ include "interview-monolith.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
