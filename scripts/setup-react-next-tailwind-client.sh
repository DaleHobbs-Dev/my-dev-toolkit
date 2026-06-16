#!/bin/bash
set -e
set -u

PROJECT_NAME="sentinel-matrix-client"

if [ -d "$PROJECT_NAME" ]; then
  echo "Error: $PROJECT_NAME already exists."
  exit 1
fi

npx create-next-app@latest "$PROJECT_NAME" \
  --js \
  --eslint \
  --tailwind \
  --src-dir \
  --app \
  --import-alias "@/*"

cd "$PROJECT_NAME"

mkdir -p src/components
mkdir -p src/lib
mkdir -p src/app/login
mkdir -p src/app/register
mkdir -p src/app/dashboard
mkdir -p src/app/courses/[courseId]
mkdir -p src/app/students/[studentId]
mkdir -p src/app/analytics

cat > src/app/globals.css <<'EOF'
@import "tailwindcss";

:root {
  --background: #f1f4fa;
  --foreground: #111827;
  --primary: #005C72;
  --primary-dark: #00485a;
  --primary-light: #e1f3f7;
  --accent: #14b8a6;
  --danger: #dc2626;
  --warning: #f59e0b;
  --success: #16a34a;
}

body {
  background: var(--background);
  color: var(--foreground);
  font-family: Arial, Helvetica, sans-serif;
}

a {
  text-decoration: none;
}
EOF

cat > src/app/layout.js <<'EOF'
import "./globals.css"

export const metadata = {
  title: "Sentinel Matrix",
  description: "Student risk dashboard for instructors",
}

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
EOF

cat > src/components/Button.jsx <<'EOF'
import Link from "next/link"

export default function Button({
  children,
  variant = "primary",
  className = "",
  href,
  type = "button",
  ...props
}) {
  const base =
    "inline-flex items-center justify-center px-4 py-2 rounded-lg font-medium transition cursor-pointer focus:outline-none disabled:opacity-60 disabled:cursor-not-allowed"

  const variants = {
    primary: "bg-[#005C72] text-white hover:bg-[#00485a]",
    accent: "bg-teal-500 text-white hover:bg-teal-600",
    secondary: "bg-gray-200 text-gray-900 hover:bg-gray-300",
    outline: "border border-[#005C72] text-[#005C72] hover:bg-[#e1f3f7]",
    danger: "bg-red-600 text-white hover:bg-red-700",
    ghost: "bg-transparent text-[#005C72] hover:bg-[#e1f3f7]",
    nav: "bg-transparent text-white hover:bg-white/10",
  }

  const classes = `${base} ${variants[variant]} ${className}`

  if (href) {
    return (
      <Link href={href} className={classes} {...props}>
        {children}
      </Link>
    )
  }

  return (
    <button type={type} className={classes} {...props}>
      {children}
    </button>
  )
}
EOF

cat > src/components/Card.jsx <<'EOF'
export default function Card({ children, className = "" }) {
  return (
    <section className={`rounded-lg border border-gray-200 bg-white p-5 ${className}`}>
      {children}
    </section>
  )
}
EOF

cat > src/components/Container.jsx <<'EOF'
export default function Container({ children, className = "" }) {
  return <main className={`mx-auto w-full max-w-7xl px-6 py-6 ${className}`}>{children}</main>
}
EOF

cat > src/components/Navbar.jsx <<'EOF'
import Link from "next/link"
import Button from "./Button"

export default function Navbar() {
  return (
    <header className="bg-[#005C72] text-white">
      <nav className="mx-auto flex max-w-7xl items-center justify-between px-6 py-4">
        <Link href="/dashboard" className="text-xl font-bold">
          Sentinel Matrix
        </Link>

        <div className="flex items-center gap-3">
          <Button href="/dashboard" variant="nav">Dashboard</Button>
          <Button href="/courses" variant="nav">Courses</Button>
          <Button href="/students" variant="nav">Students</Button>
          <Button href="/analytics" variant="nav">Analytics</Button>
        </div>
      </nav>
    </header>
  )
}
EOF

cat > src/components/Sidebar.jsx <<'EOF'
import Link from "next/link"

const links = [
  { href: "/dashboard", label: "Dashboard" },
  { href: "/courses", label: "Courses" },
  { href: "/students", label: "Students" },
  { href: "/analytics", label: "Analytics" },
]

export default function Sidebar() {
  return (
    <aside className="min-h-screen w-64 border-r border-gray-200 bg-white p-4">
      <h2 className="mb-6 text-lg font-bold text-[#005C72]">Sentinel Matrix</h2>
      <nav className="space-y-2">
        {links.map((link) => (
          <Link
            key={link.href}
            href={link.href}
            className="block rounded-lg px-3 py-2 text-gray-700 hover:bg-[#e1f3f7] hover:text-[#005C72]"
          >
            {link.label}
          </Link>
        ))}
      </nav>
    </aside>
  )
}
EOF

cat > src/components/Footer.jsx <<'EOF'
export default function Footer() {
  return (
    <footer className="border-t border-gray-200 bg-white px-6 py-4 text-center text-sm text-gray-500">
      Sentinel Matrix &copy; {new Date().getFullYear()}
    </footer>
  )
}
EOF

cat > src/components/Layout.jsx <<'EOF'
import Navbar from "./Navbar"
import Footer from "./Footer"
import Container from "./Container"

export default function Layout({ children }) {
  return (
    <div className="min-h-screen bg-[#f1f4fa]">
      <Navbar />
      <Container>{children}</Container>
      <Footer />
    </div>
  )
}
EOF

cat > src/components/Modal.jsx <<'EOF'
import Button from "./Button"

export default function Modal({ title, children, isOpen, onClose }) {
  if (!isOpen) return null

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 px-4">
      <div className="w-full max-w-lg rounded-lg bg-white p-6">
        <div className="mb-4 flex items-center justify-between">
          <h2 className="text-xl font-bold text-gray-900">{title}</h2>
          <Button variant="ghost" onClick={onClose}>Close</Button>
        </div>
        {children}
      </div>
    </div>
  )
}
EOF

cat > src/components/Typography.jsx <<'EOF'
export function PageTitle({ children, className = "" }) {
  return <h1 className={`text-3xl font-bold text-gray-950 ${className}`}>{children}</h1>
}

export function SectionTitle({ children, className = "" }) {
  return <h2 className={`text-xl font-semibold text-gray-900 ${className}`}>{children}</h2>
}

export function MutedText({ children, className = "" }) {
  return <p className={`text-sm text-gray-500 ${className}`}>{children}</p>
}
EOF

cat > src/components/Input.jsx <<'EOF'
export default function Input({ label, className = "", ...props }) {
  return (
    <label className="block">
      {label && <span className="mb-1 block text-sm font-medium text-gray-700">{label}</span>}
      <input
        className={`w-full rounded-lg border border-gray-300 px-3 py-2 focus:border-[#005C72] focus:outline-none ${className}`}
        {...props}
      />
    </label>
  )
}
EOF

cat > src/components/Select.jsx <<'EOF'
export default function Select({ label, children, className = "", ...props }) {
  return (
    <label className="block">
      {label && <span className="mb-1 block text-sm font-medium text-gray-700">{label}</span>}
      <select
        className={`w-full rounded-lg border border-gray-300 px-3 py-2 focus:border-[#005C72] focus:outline-none ${className}`}
        {...props}
      >
        {children}
      </select>
    </label>
  )
}
EOF

cat > src/components/FormField.jsx <<'EOF'
export default function FormField({ label, children, helperText }) {
  return (
    <div className="space-y-1">
      {label && <label className="text-sm font-medium text-gray-700">{label}</label>}
      {children}
      {helperText && <p className="text-xs text-gray-500">{helperText}</p>}
    </div>
  )
}
EOF

cat > src/components/Badge.jsx <<'EOF'
export default function Badge({ children, variant = "default", className = "" }) {
  const variants = {
    default: "bg-gray-100 text-gray-700",
    success: "bg-green-100 text-green-700",
    warning: "bg-yellow-100 text-yellow-800",
    danger: "bg-red-100 text-red-700",
    info: "bg-[#e1f3f7] text-[#005C72]",
  }

  return (
    <span className={`inline-flex rounded-full px-2.5 py-1 text-xs font-medium ${variants[variant]} ${className}`}>
      {children}
    </span>
  )
}
EOF

cat > src/components/RiskBadge.jsx <<'EOF'
import Badge from "./Badge"

export default function RiskBadge({ band }) {
  const normalized = band?.toLowerCase()

  if (normalized === "high") return <Badge variant="danger">High Risk</Badge>
  if (normalized === "moderate") return <Badge variant="warning">Moderate Risk</Badge>
  if (normalized === "low") return <Badge variant="success">Low Risk</Badge>

  return <Badge>Unknown</Badge>
}
EOF

cat > src/components/Table.jsx <<'EOF'
export default function Table({ columns = [], data = [], renderRow }) {
  return (
    <div className="overflow-hidden rounded-lg border border-gray-200 bg-white">
      <table className="w-full border-collapse text-left text-sm">
        <thead className="bg-gray-50 text-gray-600">
          <tr>
            {columns.map((column) => (
              <th key={column} className="px-4 py-3 font-semibold">
                {column}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="divide-y divide-gray-200">
          {data.map((item, index) => renderRow(item, index))}
        </tbody>
      </table>
    </div>
  )
}
EOF

cat > src/components/StatCard.jsx <<'EOF'
import Card from "./Card"

export default function StatCard({ label, value, helperText }) {
  return (
    <Card>
      <p className="text-sm font-medium text-gray-500">{label}</p>
      <p className="mt-2 text-3xl font-bold text-[#005C72]">{value}</p>
      {helperText && <p className="mt-1 text-sm text-gray-500">{helperText}</p>}
    </Card>
  )
}
EOF

cat > src/components/EmptyState.jsx <<'EOF'
import Button from "./Button"

export default function EmptyState({ title, message, actionLabel, actionHref }) {
  return (
    <div className="rounded-lg border border-dashed border-gray-300 bg-white p-8 text-center">
      <h3 className="text-lg font-semibold text-gray-900">{title}</h3>
      <p className="mt-2 text-sm text-gray-500">{message}</p>
      {actionLabel && actionHref && (
        <div className="mt-4">
          <Button href={actionHref}>{actionLabel}</Button>
        </div>
      )}
    </div>
  )
}
EOF

cat > src/components/LoadingSpinner.jsx <<'EOF'
export default function LoadingSpinner({ label = "Loading..." }) {
  return (
    <div className="flex items-center gap-3 text-gray-600">
      <div className="h-5 w-5 animate-spin rounded-full border-2 border-gray-300 border-t-[#005C72]" />
      <span>{label}</span>
    </div>
  )
}
EOF

cat > src/components/PageHeader.jsx <<'EOF'
import Button from "./Button"

export default function PageHeader({ title, description, actionLabel, actionHref }) {
  return (
    <div className="mb-6 flex items-start justify-between gap-4">
      <div>
        <h1 className="text-3xl font-bold text-gray-950">{title}</h1>
        {description && <p className="mt-1 text-gray-600">{description}</p>}
      </div>

      {actionLabel && actionHref && (
        <Button href={actionHref}>{actionLabel}</Button>
      )}
    </div>
  )
}
EOF

cat > src/components/DashboardSection.jsx <<'EOF'
export default function DashboardSection({ title, children }) {
  return (
    <section className="space-y-4">
      <h2 className="text-xl font-semibold text-gray-900">{title}</h2>
      {children}
    </section>
  )
}
EOF

cat > src/components/index.js <<'EOF'
export { default as Badge } from "./Badge"
export { default as Button } from "./Button"
export { default as Card } from "./Card"
export { default as Container } from "./Container"
export { default as DashboardSection } from "./DashboardSection"
export { default as EmptyState } from "./EmptyState"
export { default as Footer } from "./Footer"
export { default as FormField } from "./FormField"
export { default as Input } from "./Input"
export { default as Layout } from "./Layout"
export { default as LoadingSpinner } from "./LoadingSpinner"
export { default as Modal } from "./Modal"
export { default as Navbar } from "./Navbar"
export { default as PageHeader } from "./PageHeader"
export { default as RiskBadge } from "./RiskBadge"
export { default as Select } from "./Select"
export { default as Sidebar } from "./Sidebar"
export { default as StatCard } from "./StatCard"
export { default as Table } from "./Table"
export * from "./Typography"
EOF

cat > src/lib/constants.js <<'EOF'
export const APP_NAME = "Sentinel Matrix"

export const RISK_BANDS = {
  LOW: "low",
  MODERATE: "moderate",
  HIGH: "high",
}

export const PRIOR_ACADEMIC_STANDING = {
  HIGH: "high",
  MEDIUM: "medium",
  LOW: "low",
}

export const API_BASE_URL =
  process.env.NEXT_PUBLIC_API_BASE_URL || "http://localhost:8000"
EOF

cat > src/lib/api.js <<'EOF'
import { API_BASE_URL } from "./constants"

export async function apiRequest(path, options = {}) {
  const response = await fetch(`${API_BASE_URL}${path}`, {
    headers: {
      "Content-Type": "application/json",
      ...options.headers,
    },
    ...options,
  })

  if (!response.ok) {
    throw new Error(`API request failed: ${response.status}`)
  }

  return response.json()
}
EOF

cat > src/lib/index.js <<'EOF'
export * from "./api"
export * from "./constants"
EOF

cat > src/app/page.js <<'EOF'
import { Button, Card, Container } from "@/components"

export default function HomePage() {
  return (
    <Container className="flex min-h-screen items-center justify-center">
      <Card className="max-w-2xl text-center">
        <p className="text-sm font-semibold uppercase tracking-wide text-[#005C72]">
          Student Risk Dashboard
        </p>
        <h1 className="mt-3 text-4xl font-bold text-gray-950">
          Sentinel Matrix
        </h1>
        <p className="mt-4 text-gray-600">
          An instructor-focused analytics platform for identifying at-risk students
          using grades, attendance, missing assignments, and prior academic standing.
        </p>
        <div className="mt-6 flex justify-center gap-3">
          <Button href="/login">Login</Button>
          <Button href="/register" variant="outline">Register</Button>
        </div>
      </Card>
    </Container>
  )
}
EOF

cat > src/app/login/page.js <<'EOF'
import { Button, Card, Container, Input } from "@/components"

export default function LoginPage() {
  return (
    <Container className="flex min-h-screen items-center justify-center">
      <Card className="w-full max-w-md">
        <h1 className="text-2xl font-bold text-gray-950">Login</h1>
        <form className="mt-6 space-y-4">
          <Input label="Email" type="email" placeholder="instructor@example.com" />
          <Input label="Password" type="password" placeholder="Password" />
          <Button type="submit" className="w-full">Login</Button>
        </form>
      </Card>
    </Container>
  )
}
EOF

cat > src/app/register/page.js <<'EOF'
import { Button, Card, Container, Input } from "@/components"

export default function RegisterPage() {
  return (
    <Container className="flex min-h-screen items-center justify-center">
      <Card className="w-full max-w-md">
        <h1 className="text-2xl font-bold text-gray-950">Create Account</h1>
        <form className="mt-6 space-y-4">
          <Input label="First Name" />
          <Input label="Last Name" />
          <Input label="Email" type="email" />
          <Input label="Password" type="password" />
          <Button type="submit" className="w-full">Register</Button>
        </form>
      </Card>
    </Container>
  )
}
EOF

cat > src/app/dashboard/page.js <<'EOF'
import { Layout, PageHeader, StatCard, DashboardSection, Card } from "@/components"

export default function DashboardPage() {
  return (
    <Layout>
      <PageHeader
        title="Dashboard"
        description="Monitor course-level student risk indicators."
      />

      <div className="grid gap-4 md:grid-cols-4">
        <StatCard label="Total Courses" value="0" />
        <StatCard label="Total Students" value="0" />
        <StatCard label="High Risk" value="0" />
        <StatCard label="Moderate Risk" value="0" />
      </div>

      <div className="mt-8">
        <DashboardSection title="At-Risk Students">
          <Card>
            <p className="text-gray-500">Student risk data will appear here after connecting the Django API.</p>
          </Card>
        </DashboardSection>
      </div>
    </Layout>
  )
}
EOF

cat > src/app/courses/page.js <<'EOF'
import { Layout, PageHeader, EmptyState } from "@/components"

export default function CoursesPage() {
  return (
    <Layout>
      <PageHeader
        title="Courses"
        description="Create and manage instructor-owned courses."
        actionLabel="Create Course"
        actionHref="/courses/new"
      />

      <EmptyState
        title="No courses yet"
        message="Create your first course to start enrolling students."
        actionLabel="Create Course"
        actionHref="/courses/new"
      />
    </Layout>
  )
}
EOF

cat > src/app/courses/[courseId]/page.js <<'EOF'
import { Layout, PageHeader, Card } from "@/components"

export default function CourseDetailPage() {
  return (
    <Layout>
      <PageHeader
        title="Course Detail"
        description="View enrolled students and course risk indicators."
      />

      <Card>
        <p className="text-gray-500">Course roster will appear here.</p>
      </Card>
    </Layout>
  )
}
EOF

cat > src/app/students/page.js <<'EOF'
import { Layout, PageHeader, EmptyState } from "@/components"

export default function StudentsPage() {
  return (
    <Layout>
      <PageHeader
        title="Students"
        description="Manage student records and enrollments."
        actionLabel="Add Student"
        actionHref="/students/new"
      />

      <EmptyState
        title="No students yet"
        message="Add students before enrolling them in courses."
        actionLabel="Add Student"
        actionHref="/students/new"
      />
    </Layout>
  )
}
EOF

cat > src/app/students/[studentId]/page.js <<'EOF'
import { Layout, PageHeader, Card } from "@/components"

export default function StudentDetailPage() {
  return (
    <Layout>
      <PageHeader
        title="Student Detail"
        description="View academic standing, enrollments, and risk indicators."
      />

      <Card>
        <p className="text-gray-500">Student profile details will appear here.</p>
      </Card>
    </Layout>
  )
}
EOF

cat > src/app/analytics/page.js <<'EOF'
import { Layout, PageHeader, Card } from "@/components"

export default function AnalyticsPage() {
  return (
    <Layout>
      <PageHeader
        title="Analytics"
        description="Review aggregate course and student risk trends."
      />

      <Card>
        <p className="text-gray-500">Analytics widgets will appear here.</p>
      </Card>
    </Layout>
  )
}
EOF

cat > .env.local <<'EOF'
NEXT_PUBLIC_API_BASE_URL=http://localhost:8000
EOF

echo ""
echo "Sentinel Matrix client setup complete."
echo "Next steps:"
echo "cd $PROJECT_NAME"
echo "npm run dev"