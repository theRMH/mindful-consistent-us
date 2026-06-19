"use client";

import { useEffect, useState, use } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";

interface Video {
  id: string;
  title: string;
  description: string | null;
  category: string;
  durationSeconds: number;
  videoSource: string;
  bunnyVideoId: string | null;
  bunnyLibraryId: string | null;
  youtubeVideoId: string | null;
  isFree: boolean;
}

interface CourseDay {
  id: string;
  dayNumber: number;
  title: string;
  description: string;
  videos: Video[];
}

interface Course {
  id: string;
  title: string;
  slug: string;
  description: string | null;
  category: string | null;
  totalDays: number;
  priceInr: number;
  priceUsd: number | null;
  whatsappLink: string | null;
  scheduledStartDate: string | null;
  thumbnailUrl: string | null;
  isPublished: boolean;
  instructorName: string | null;
  instructorTitle: string | null;
  instructorBio: string | null;
  instructorPhotoUrl: string | null;
  courseDays: CourseDay[];
}

function formatCategory(category: string | null | undefined) {
  if (category === "general_exercise") return "General Workout";
  if (category === "yoga") return "Yoga";
  return category || "Uncategorized";
}

export default function CourseBuilder({
  params,
}: {
  params: Promise<{ courseId: string }>;
}) {
  const { courseId } = use(params);
  const router = useRouter();
  const [course, setCourse] = useState<Course | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  // Course Edit States
  const [editTitle, setEditTitle] = useState("");
  const [editSlug, setEditSlug] = useState("");
  const [editDesc, setEditDesc] = useState("");
  const [editPrice, setEditPrice] = useState("");
  const [editTotalDays, setEditTotalDays] = useState("");
  const [editThumbnail, setEditThumbnail] = useState("");
  const [editCategory, setEditCategory] = useState("yoga");
  const [editPublished, setEditPublished] = useState(false);
  const [editPriceUsd, setEditPriceUsd] = useState("");
  const [editWhatsapp, setEditWhatsapp] = useState("");
  const [editScheduledStart, setEditScheduledStart] = useState("");
  const [editInstructorName, setEditInstructorName] = useState("");
  const [editInstructorTitle, setEditInstructorTitle] = useState("");
  const [editInstructorBio, setEditInstructorBio] = useState("");
  const [editInstructorPhoto, setEditInstructorPhoto] = useState("");
  const [courseSubmitting, setCourseSubmitting] = useState(false);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);

  // Day Form States
  const [showDayForm, setShowDayForm] = useState(false);
  const [dayNumber, setDayNumber] = useState("");
  const [dayTitle, setDayTitle] = useState("");
  const [dayDesc, setDayDesc] = useState("");
  const [daySubmitting, setDaySubmitting] = useState(false);

  // Edit Day States
  const [editingDay, setEditingDay] = useState<CourseDay | null>(null);
  const [editDayTitle, setEditDayTitle] = useState("");
  const [editDayDesc, setEditDayDesc] = useState("");
  const [editDaySubmitting, setEditDaySubmitting] = useState(false);

  // Add Video Form States
  const [activeDayId, setActiveDayId] = useState<string | null>(null);
  const [videoTitle, setVideoTitle] = useState("");
  const [videoDescription, setVideoDescription] = useState("");
  const [videoCategory, setVideoCategory] = useState("yoga");
  const [videoDuration, setVideoDuration] = useState("20");
  const [videoSource, setVideoSource] = useState<"bunny" | "youtube" | "supabase">("bunny");
  const [bunnyVideoId, setBunnyVideoId] = useState("");
  const [bunnyLibraryId, setBunnyLibraryId] = useState("");
  const [youtubeVideoId, setYoutubeVideoId] = useState("");
  const [supabaseVideoUrl, setSupabaseVideoUrl] = useState("");
  const [supabaseUploading, setSupabaseUploading] = useState(false);
  const [isFree, setIsFree] = useState(false);
  const [videoThumbnail, setVideoThumbnail] = useState("");
  const [videoSubmitting, setVideoSubmitting] = useState(false);

  // Edit Video Form States
  const [editingVideo, setEditingVideo] = useState<Video | null>(null);
  const [editVideoTitle, setEditVideoTitle] = useState("");
  const [editVideoDescription, setEditVideoDescription] = useState("");
  const [editVideoCategory, setEditVideoCategory] = useState("yoga");
  const [editVideoDuration, setEditVideoDuration] = useState("20");
  const [editVideoSource, setEditVideoSource] = useState<"bunny" | "youtube" | "supabase">(
    "bunny",
  );
  const [editBunnyVideoId, setEditBunnyVideoId] = useState("");
  const [editBunnyLibraryId, setEditBunnyLibraryId] = useState("");
  const [editYoutubeVideoId, setEditYoutubeVideoId] = useState("");
  const [editSupabaseVideoUrl, setEditSupabaseVideoUrl] = useState("");
  const [editSupabaseUploading, setEditSupabaseUploading] = useState(false);
  const [editVideoIsFree, setEditVideoIsFree] = useState(false);
  const [editVideoSubmitting, setEditVideoSubmitting] = useState(false);

  const handleVideoFileUpload = async (file: File, isEdit: boolean) => {
    const setUploading = isEdit ? setEditSupabaseUploading : setSupabaseUploading;
    const setUrl = isEdit ? setEditSupabaseVideoUrl : setSupabaseVideoUrl;
    setUploading(true);
    try {
      const fd = new FormData();
      fd.append("file", file);
      const res = await fetch("/api/upload/video", { method: "POST", body: fd });
      if (!res.ok) throw new Error((await res.json()).error ?? "Upload failed");
      const { url } = await res.json();
      setUrl(url as string);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Upload failed");
    } finally {
      setUploading(false);
    }
  };

  const fetchCourseData = async () => {
    try {
      const res = await fetch(`/api/courses/${courseId}`);
      if (!res.ok) throw new Error("Failed to fetch course details");
      const data = await res.json();
      setCourse(data);
      // Initialize edit states
      setEditTitle(data.title);
      setEditSlug(data.slug);
      setEditDesc(data.description || "");
      setEditPrice(Number(data.priceInr).toString());
      setEditTotalDays(data.totalDays.toString());
      setEditThumbnail(data.thumbnailUrl || "");
      setEditCategory(data.category || "yoga");
      setEditPublished(data.isPublished);
      setEditPriceUsd(data.priceUsd != null ? Number(data.priceUsd).toString() : "");
      setEditWhatsapp(data.whatsappLink || "");
      setEditScheduledStart(data.scheduledStartDate ? data.scheduledStartDate.slice(0, 10) : "");
      setEditInstructorName(data.instructorName || "");
      setEditInstructorTitle(data.instructorTitle || "");
      setEditInstructorBio(data.instructorBio || "");
      setEditInstructorPhoto(data.instructorPhotoUrl || "");
      setLoading(false);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Something went wrong');
      setLoading(false);
    }
  };

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    fetchCourseData();
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [courseId]);

  const handleAddDay = async (e: React.FormEvent) => {
    e.preventDefault();
    if (daySubmitting) return;
    setError("");
    setDaySubmitting(true);

    try {
      const res = await fetch(`/api/courses/${courseId}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          action: "add_day",
          dayNumber,
          title: dayTitle,
          description: dayDesc,
        }),
      });

      if (!res.ok) throw new Error("Failed to add course day");

      // Reset & Reload
      setShowDayForm(false);
      setDayNumber("");
      setDayTitle("");
      setDayDesc("");
      fetchCourseData();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Request failed');
    } finally {
      setDaySubmitting(false);
    }
  };

  const handleAddVideo = async (e: React.FormEvent) => {
    e.preventDefault();
    if (videoSubmitting) return;
    setError("");
    setVideoSubmitting(true);

    try {
      const res = await fetch(`/api/courses/${courseId}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          action: "add_video",
          courseDayId: activeDayId,
          title: videoTitle,
          description: videoDescription || undefined,
          category: videoCategory,
          durationSeconds: Number(videoDuration) * 60,
          videoSource,
          bunnyVideoId: videoSource === "bunny" ? bunnyVideoId : videoSource === "supabase" ? supabaseVideoUrl : undefined,
          bunnyLibraryId: videoSource === "bunny" ? bunnyLibraryId : undefined,
          youtubeVideoId: videoSource === "youtube" ? youtubeVideoId : undefined,
          isFree,
          thumbnailUrl: videoThumbnail || undefined,
        }),
      });

      if (!res.ok) throw new Error("Failed to link video");

      // Reset & Reload
      setActiveDayId(null);
      setVideoTitle("");
      setVideoDescription("");
      setVideoSource("bunny");
      setBunnyVideoId("");
      setYoutubeVideoId("");
      setSupabaseVideoUrl("");
      setVideoThumbnail("");
      fetchCourseData();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Request failed');
    } finally {
      setVideoSubmitting(false);
    }
  };

  const openEditVideo = (vid: Video) => {
    setEditingVideo(vid);
    setEditVideoTitle(vid.title);
    setEditVideoDescription(vid.description ?? "");
    setEditVideoCategory(vid.category);
    setEditVideoDuration(Math.round(vid.durationSeconds / 60).toString());
    setEditVideoSource(vid.videoSource as "bunny" | "youtube" | "supabase");
    setEditBunnyVideoId(vid.videoSource === "bunny" ? (vid.bunnyVideoId ?? "") : "");
    setEditBunnyLibraryId(vid.bunnyLibraryId ?? "");
    setEditYoutubeVideoId(vid.youtubeVideoId ?? "");
    setEditSupabaseVideoUrl(vid.videoSource === "supabase" ? (vid.bunnyVideoId ?? "") : "");
    setEditVideoIsFree(vid.isFree);
    setActiveDayId(null);
    setShowDayForm(false);
  };

  const handleUpdateVideo = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingVideo || editVideoSubmitting) return;
    setError("");
    setEditVideoSubmitting(true);
    try {
      const res = await fetch(`/api/videos/${editingVideo.id}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          title: editVideoTitle,
          description: editVideoDescription || undefined,
          category: editVideoCategory,
          durationSeconds: Number(editVideoDuration) * 60,
          videoSource: editVideoSource,
          bunnyVideoId: editVideoSource === "bunny" ? editBunnyVideoId : editVideoSource === "supabase" ? editSupabaseVideoUrl : undefined,
          bunnyLibraryId: editVideoSource === "bunny" ? editBunnyLibraryId : undefined,
          youtubeVideoId: editVideoSource === "youtube" ? editYoutubeVideoId : undefined,
          isFree: editVideoIsFree,
        }),
      });
      if (!res.ok) throw new Error("Failed to update video");
      setEditingVideo(null);
      fetchCourseData();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Request failed');
    } finally {
      setEditVideoSubmitting(false);
    }
  };

  const handleDeleteVideo = async (videoId: string) => {
    if (!confirm("Delete this video? This cannot be undone.")) return;
    setError("");
    try {
      const res = await fetch(`/api/videos/${videoId}`, { method: "DELETE" });
      if (!res.ok) throw new Error("Failed to delete video");
      fetchCourseData();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Request failed');
    }
  };

  const handleUpdateCourse = async (e: React.FormEvent) => {
    e.preventDefault();
    if (courseSubmitting) return;
    setError("");
    setCourseSubmitting(true);

    try {
      const res = await fetch(`/api/courses/${courseId}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          title: editTitle,
          slug: editSlug,
          description: editDesc,
          category: editCategory,
          priceInr: editPrice,
          totalDays: editTotalDays,
          isPublished: editPublished,
          thumbnailUrl: editThumbnail,
          priceUsd: editPriceUsd !== "" ? editPriceUsd : null,
          whatsappLink: editWhatsapp || null,
          scheduledStartDate: editScheduledStart || null,
          instructorName: editInstructorName,
          instructorTitle: editInstructorTitle,
          instructorBio: editInstructorBio,
          instructorPhotoUrl: editInstructorPhoto,
        }),
      });

      if (!res.ok) {
        const errData = await res.json();
        throw new Error(errData.error || "Failed to update course details");
      }
      fetchCourseData();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Request failed');
    } finally {
      setCourseSubmitting(false);
    }
  };

  const openEditDay = (day: CourseDay) => {
    setEditingDay(day);
    setEditDayTitle(day.title);
    setEditDayDesc(day.description);
    setShowDayForm(false);
    setActiveDayId(null);
  };

  const handleUpdateDay = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingDay || editDaySubmitting) return;
    setError("");
    setEditDaySubmitting(true);
    try {
      const res = await fetch(`/api/days/${editingDay.id}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ title: editDayTitle, description: editDayDesc }),
      });
      if (!res.ok) throw new Error("Failed to update day");
      setEditingDay(null);
      fetchCourseData();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Request failed');
    } finally {
      setEditDaySubmitting(false);
    }
  };

  const handleDeleteDay = async (dayId: string) => {
    if (!confirm("Delete this day and all its videos? This cannot be undone."))
      return;
    setError("");
    try {
      const res = await fetch(`/api/days/${dayId}`, { method: "DELETE" });
      if (!res.ok) throw new Error("Failed to delete day");
      fetchCourseData();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Request failed');
    }
  };

  const handleDeleteCourse = async () => {
    try {
      const res = await fetch(`/api/courses/${courseId}`, {
        method: "DELETE",
      });
      if (!res.ok) throw new Error("Failed to delete course");
      router.push("/dashboard/courses");
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Request failed');
      setShowDeleteConfirm(false);
    }
  };

  if (loading) {
    return (
      <div className="h-64 flex items-center justify-center">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-emerald-600"></div>
      </div>
    );
  }

  if (error || !course) {
    return (
      <div className="bg-red-50 text-red-600 p-4 rounded-lg border border-red-100 font-medium text-sm">
        {error || "Course not found"}
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="flex items-center space-x-3">
        <Link
          href="/dashboard/courses"
          className="text-gray-500 hover:text-gray-700"
        >
          <svg
            className="w-6 h-6"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M10.5 19.5L3 12m0 0l7.5-7.5M3 12h18"
            />
          </svg>
        </Link>
        <div>
          <h2 className="text-2xl font-extrabold text-gray-900">
            {course.title}
          </h2>
          <p className="text-sm text-gray-500 mt-1">
            Manage day schedules, focus summaries, and linked videos.
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3 items-start">
        {/* Days & Videos Manager List */}
        <div className="lg:col-span-2 space-y-6">
          <div className="flex justify-between items-center bg-gray-50 p-4 rounded-lg border border-gray-100">
            <h3 className="font-bold text-gray-800 text-lg">
              Program Days list
            </h3>
            <button
              onClick={() => setShowDayForm(true)}
              className="inline-flex items-center px-3 py-1.5 text-xs font-bold rounded-lg text-white bg-emerald-600 hover:bg-emerald-700 transition-colors"
            >
              Add Day
            </button>
          </div>

          {course.courseDays.length === 0 ? (
            <div className="p-12 border-2 border-dashed border-gray-200 rounded-lg text-center text-sm text-gray-400">
              No Days configured yet. Click &quot;Add Day&quot; to structure your program
              curriculum.
            </div>
          ) : (
            <div className="space-y-6">
              {course.courseDays.map((day) => (
                <div
                  key={day.id}
                  className="bg-white shadow rounded-lg border border-gray-100 overflow-hidden"
                >
                  <div className="bg-gray-50/70 p-4 border-b border-gray-100 flex justify-between items-center">
                    <div>
                      <h4 className="font-extrabold text-gray-800">
                        Day {day.dayNumber}: {day.title || "Untitled Day"}
                      </h4>
                      <p className="text-xs text-gray-500 mt-1">
                        {day.description || "No focus description set."}
                      </p>
                    </div>
                    <div className="flex items-center space-x-3">
                      <button
                        onClick={() => openEditDay(day)}
                        className="text-xs font-bold text-blue-600 hover:underline"
                      >
                        Edit
                      </button>
                      <button
                        onClick={() => handleDeleteDay(day.id)}
                        className="text-xs font-bold text-red-500 hover:underline"
                      >
                        Delete
                      </button>
                      <button
                        onClick={() => setActiveDayId(day.id)}
                        className="text-xs font-bold text-emerald-600 hover:text-emerald-700 hover:underline"
                      >
                        Link Video
                      </button>
                    </div>
                  </div>

                  {/* Day Videos */}
                  <div className="p-4 space-y-3">
                    {day.videos.length === 0 ? (
                      <div className="text-center py-6 text-xs text-gray-400 font-medium">
                        No videos linked for this day. Click &quot;Link Video&quot; to add
                        sessions.
                      </div>
                    ) : (
                      day.videos.map((vid) => (
                        <div
                          key={vid.id}
                          className="flex items-center justify-between p-3 bg-gray-50 rounded-lg text-sm border border-gray-100"
                        >
                          <div className="min-w-0 flex-1">
                            <div className="font-bold text-gray-800">
                              {vid.title}
                            </div>
                            <div className="text-xs text-gray-400 mt-0.5">
                              {formatCategory(vid.category)} •{" "}
                              {Math.round(vid.durationSeconds / 60)} mins •{" "}
                              <span className="font-medium">
                                {vid.videoSource === "youtube"
                                  ? `YouTube: ${vid.youtubeVideoId}`
                                  : `Bunny: ${vid.bunnyVideoId}`}
                              </span>
                            </div>
                          </div>
                          <div className="flex items-center space-x-2 ml-3 flex-shrink-0">
                            <button
                              onClick={() => openEditVideo(vid)}
                              className="px-2 py-1 text-xs font-bold text-emerald-700 bg-emerald-50 border border-emerald-200 rounded hover:bg-emerald-100 transition-colors"
                            >
                              Edit
                            </button>
                            <button
                              onClick={() => handleDeleteVideo(vid.id)}
                              className="px-2 py-1 text-xs font-bold text-red-600 bg-red-50 border border-red-200 rounded hover:bg-red-100 transition-colors"
                            >
                              Delete
                            </button>
                          </div>
                        </div>
                      ))
                    )}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Side Panels (Modals/Inline Forms) */}
        <div className="space-y-6">
          {/* Edit Day Box */}
          {editingDay && (
            <div className="bg-white shadow rounded-lg border border-gray-100 p-6 space-y-4">
              <h3 className="font-bold text-gray-900 border-b border-gray-50 pb-2">
                Edit Day {editingDay.dayNumber}
              </h3>
              <form onSubmit={handleUpdateDay} className="space-y-4">
                <div>
                  <label className="block text-xs font-bold text-gray-500">
                    Day Title
                  </label>
                  <input
                    type="text"
                    required
                    value={editDayTitle}
                    onChange={(e) => setEditDayTitle(e.target.value)}
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-gray-500">
                    Description / Focus
                  </label>
                  <textarea
                    value={editDayDesc}
                    onChange={(e) => setEditDayDesc(e.target.value)}
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                    rows={3}
                  />
                </div>
                <div className="flex justify-end space-x-2 pt-2">
                  <button
                    type="button"
                    onClick={() => setEditingDay(null)}
                    className="px-3 py-1.5 text-xs font-bold border rounded-lg text-gray-600"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    disabled={editDaySubmitting}
                    className="px-3 py-1.5 text-xs font-bold rounded-lg text-white bg-emerald-600 disabled:opacity-50"
                  >
                    {editDaySubmitting ? "Saving..." : "Save Changes"}
                  </button>
                </div>
              </form>
            </div>
          )}

          {/* Add Day Box */}
          {showDayForm && (
            <div className="bg-white shadow rounded-lg border border-gray-100 p-6 space-y-4">
              <h3 className="font-bold text-gray-900 border-b border-gray-50 pb-2">
                Add Program Day
              </h3>
              <form onSubmit={handleAddDay} className="space-y-4">
                <div>
                  <label className="block text-xs font-bold text-gray-500">
                    Day Number
                  </label>
                  <input
                    type="number"
                    required
                    value={dayNumber}
                    onChange={(e) => setDayNumber(e.target.value)}
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                    placeholder="e.g. 5"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-gray-500">
                    Day Title
                  </label>
                  <input
                    type="text"
                    required
                    value={dayTitle}
                    onChange={(e) => setDayTitle(e.target.value)}
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                    placeholder="e.g. Spine Extension pose"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-gray-500">
                    Description / Focus
                  </label>
                  <textarea
                    value={dayDesc}
                    onChange={(e) => setDayDesc(e.target.value)}
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                    rows={3}
                  />
                </div>
                <div className="flex justify-end space-x-2 pt-2">
                  <button
                    type="button"
                    onClick={() => setShowDayForm(false)}
                    className="px-3 py-1.5 text-xs font-bold border rounded-lg text-gray-600"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    disabled={daySubmitting}
                    className="px-3 py-1.5 text-xs font-bold rounded-lg text-white bg-emerald-600 disabled:opacity-50"
                  >
                    {daySubmitting ? "Saving..." : "Save Day"}
                  </button>
                </div>
              </form>
            </div>
          )}

          {/* Add Video Box */}
          {activeDayId && (
            <div className="bg-white shadow rounded-lg border border-gray-100 p-6 space-y-4">
              <h3 className="font-bold text-gray-900 border-b border-gray-50 pb-2">
                Link Session Video
              </h3>
              <form onSubmit={handleAddVideo} className="space-y-4">
                <div>
                  <label className="block text-xs font-bold text-gray-500">
                    Video Title
                  </label>
                  <input
                    type="text"
                    required
                    value={videoTitle}
                    onChange={(e) => setVideoTitle(e.target.value)}
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                    placeholder="e.g. Breath Flow alignment"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-gray-500">
                    Subtitle{" "}
                    <span className="font-normal text-gray-400">(shown under title in app)</span>
                  </label>
                  <input
                    type="text"
                    value={videoDescription}
                    onChange={(e) => setVideoDescription(e.target.value)}
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                    placeholder="e.g. Build Strength & Flexibility"
                  />
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-bold text-gray-500">
                      Category
                    </label>
                    <select
                      value={videoCategory}
                      onChange={(e) => setVideoCategory(e.target.value)}
                      className="mt-1 block w-full px-2 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                    >
                      <option value="yoga">Yoga</option>
                      <option value="general_exercise">Workout</option>
                    </select>
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-gray-500">
                      Duration (Mins)
                    </label>
                    <input
                      type="number"
                      required
                      min="1"
                      value={videoDuration}
                      onChange={(e) => setVideoDuration(e.target.value)}
                      className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                    />
                  </div>
                </div>
                <div>
                  <label className="block text-xs font-bold text-gray-500">
                    Video Source
                  </label>
                  <div className="mt-1 flex rounded-md border border-gray-300 overflow-hidden text-xs font-bold">
                    <button
                      type="button"
                      onClick={() => setVideoSource("bunny")}
                      className={`flex-1 py-1.5 transition-colors ${videoSource === "bunny" ? "bg-emerald-600 text-white" : "bg-white text-gray-600 hover:bg-gray-50"}`}
                    >
                      BunnyNet
                    </button>
                    <button
                      type="button"
                      onClick={() => setVideoSource("youtube")}
                      className={`flex-1 py-1.5 transition-colors ${videoSource === "youtube" ? "bg-red-500 text-white" : "bg-white text-gray-600 hover:bg-gray-50"}`}
                    >
                      YouTube
                    </button>
                    <button
                      type="button"
                      onClick={() => setVideoSource("supabase")}
                      className={`flex-1 py-1.5 transition-colors ${videoSource === "supabase" ? "bg-violet-600 text-white" : "bg-white text-gray-600 hover:bg-gray-50"}`}
                    >
                      Upload
                    </button>
                  </div>
                </div>
                {videoSource === "bunny" ? (
                  <>
                    <div>
                      <label className="block text-xs font-bold text-gray-500">
                        Bunny Video ID
                      </label>
                      <input
                        type="text"
                        required
                        value={bunnyVideoId}
                        onChange={(e) => setBunnyVideoId(e.target.value)}
                        className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                      />
                    </div>
                    <div>
                      <label className="block text-xs font-bold text-gray-500">
                        Bunny Library ID
                      </label>
                      <input
                        type="text"
                        required
                        value={bunnyLibraryId}
                        onChange={(e) => setBunnyLibraryId(e.target.value)}
                        className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                      />
                    </div>
                  </>
                ) : videoSource === "youtube" ? (
                  <div>
                    <label className="block text-xs font-bold text-gray-500">
                      YouTube Video ID
                    </label>
                    <input
                      type="text"
                      required
                      value={youtubeVideoId}
                      onChange={(e) => setYoutubeVideoId(e.target.value)}
                      className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                      placeholder="e.g. dQw4w9WgXcQ"
                    />
                  </div>
                ) : (
                  <div>
                    <label className="block text-xs font-bold text-gray-500">
                      Video File
                    </label>
                    <div className="mt-1">
                      <label className={`flex items-center justify-center w-full px-4 py-6 border-2 border-dashed rounded-md cursor-pointer transition-colors ${supabaseUploading ? "border-gray-200 bg-gray-50 cursor-not-allowed" : "border-violet-300 hover:border-violet-400 hover:bg-violet-50"}`}>
                        <div className="text-center">
                          {supabaseUploading ? (
                            <p className="text-xs text-gray-500 font-medium">Uploading…</p>
                          ) : supabaseVideoUrl ? (
                            <>
                              <p className="text-xs text-emerald-600 font-bold">✓ Uploaded</p>
                              <p className="text-[10px] text-gray-400 mt-0.5 break-all max-w-[180px]">{supabaseVideoUrl.split("/").pop()}</p>
                              <p className="text-[10px] text-violet-500 mt-1">Click to replace</p>
                            </>
                          ) : (
                            <>
                              <p className="text-xs text-gray-600 font-medium">Click to select video</p>
                              <p className="text-[10px] text-gray-400 mt-0.5">MP4, MOV, WebM — uploaded to Supabase</p>
                            </>
                          )}
                        </div>
                        <input
                          type="file"
                          accept="video/*"
                          className="hidden"
                          disabled={supabaseUploading}
                          onChange={(e) => {
                            const f = e.target.files?.[0];
                            if (f) handleVideoFileUpload(f, false);
                          }}
                        />
                      </label>
                    </div>
                    {!supabaseVideoUrl && !supabaseUploading && (
                      <p className="mt-1 text-[10px] text-red-500">Upload a file before saving.</p>
                    )}
                  </div>
                )}
                <div>
                  <label className="block text-xs font-bold text-gray-500">
                    Icon / Thumbnail URL{" "}
                    <span className="font-normal text-gray-400">
                      (optional)
                    </span>
                  </label>
                  <input
                    type="text"
                    value={videoThumbnail}
                    onChange={(e) => setVideoThumbnail(e.target.value)}
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                    placeholder="https://… or assets/icon_asana.png"
                  />
                </div>
                <div className="flex items-center">
                  <input
                    id="isFreeVideo"
                    type="checkbox"
                    checked={isFree}
                    onChange={(e) => setIsFree(e.target.checked)}
                    className="h-4 w-4 text-emerald-600 border-gray-300 rounded"
                  />
                  <label
                    htmlFor="isFreeVideo"
                    className="ml-2 block text-xs font-bold text-gray-900"
                  >
                    Free video preview (visible to guests)
                  </label>
                </div>
                <div className="flex justify-end space-x-2 pt-2">
                  <button
                    type="button"
                    onClick={() => setActiveDayId(null)}
                    className="px-3 py-1.5 text-xs font-bold border rounded-lg text-gray-600"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    disabled={videoSubmitting}
                    className="px-3 py-1.5 text-xs font-bold rounded-lg text-white bg-emerald-600 disabled:opacity-50"
                  >
                    {videoSubmitting ? "Saving..." : "Save Video"}
                  </button>
                </div>
              </form>
            </div>
          )}

          {/* Edit Video Box */}
          {editingVideo && !activeDayId && !showDayForm && (
            <div className="bg-white shadow rounded-lg border border-emerald-100 p-6 space-y-4">
              <div className="flex justify-between items-center border-b border-gray-50 pb-2">
                <h3 className="font-bold text-gray-900">Edit Video</h3>
                <button
                  onClick={() => setEditingVideo(null)}
                  className="text-gray-400 hover:text-gray-600 text-xs font-bold"
                >
                  ✕ Cancel
                </button>
              </div>
              <form onSubmit={handleUpdateVideo} className="space-y-4">
                <div>
                  <label className="block text-xs font-bold text-gray-500">
                    Video Title
                  </label>
                  <input
                    type="text"
                    required
                    value={editVideoTitle}
                    onChange={(e) => setEditVideoTitle(e.target.value)}
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-gray-500">
                    Subtitle{" "}
                    <span className="font-normal text-gray-400">(shown under title in app)</span>
                  </label>
                  <input
                    type="text"
                    value={editVideoDescription}
                    onChange={(e) => setEditVideoDescription(e.target.value)}
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                    placeholder="e.g. Build Strength & Flexibility"
                  />
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-bold text-gray-500">
                      Category
                    </label>
                    <select
                      value={editVideoCategory}
                      onChange={(e) => setEditVideoCategory(e.target.value)}
                      className="mt-1 block w-full px-2 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                    >
                      <option value="yoga">Yoga</option>
                      <option value="general_exercise">Workout</option>
                    </select>
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-gray-500">
                      Duration (Mins)
                    </label>
                    <input
                      type="number"
                      required
                      min="1"
                      value={editVideoDuration}
                      onChange={(e) => setEditVideoDuration(e.target.value)}
                      className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                    />
                  </div>
                </div>
                <div>
                  <label className="block text-xs font-bold text-gray-500">
                    Video Source
                  </label>
                  <div className="mt-1 flex rounded-md border border-gray-300 overflow-hidden text-xs font-bold">
                    <button
                      type="button"
                      onClick={() => setEditVideoSource("bunny")}
                      className={`flex-1 py-1.5 transition-colors ${editVideoSource === "bunny" ? "bg-emerald-600 text-white" : "bg-white text-gray-600 hover:bg-gray-50"}`}
                    >
                      BunnyNet
                    </button>
                    <button
                      type="button"
                      onClick={() => setEditVideoSource("youtube")}
                      className={`flex-1 py-1.5 transition-colors ${editVideoSource === "youtube" ? "bg-red-500 text-white" : "bg-white text-gray-600 hover:bg-gray-50"}`}
                    >
                      YouTube
                    </button>
                    <button
                      type="button"
                      onClick={() => setEditVideoSource("supabase")}
                      className={`flex-1 py-1.5 transition-colors ${editVideoSource === "supabase" ? "bg-violet-600 text-white" : "bg-white text-gray-600 hover:bg-gray-50"}`}
                    >
                      Upload
                    </button>
                  </div>
                </div>
                {editVideoSource === "bunny" ? (
                  <>
                    <div>
                      <label className="block text-xs font-bold text-gray-500">
                        Bunny Video ID
                      </label>
                      <input
                        type="text"
                        required
                        value={editBunnyVideoId}
                        onChange={(e) => setEditBunnyVideoId(e.target.value)}
                        className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                      />
                    </div>
                    <div>
                      <label className="block text-xs font-bold text-gray-500">
                        Bunny Library ID
                      </label>
                      <input
                        type="text"
                        required
                        value={editBunnyLibraryId}
                        onChange={(e) => setEditBunnyLibraryId(e.target.value)}
                        className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                      />
                    </div>
                  </>
                ) : editVideoSource === "youtube" ? (
                  <div>
                    <label className="block text-xs font-bold text-gray-500">
                      YouTube Video ID
                    </label>
                    <input
                      type="text"
                      required
                      value={editYoutubeVideoId}
                      onChange={(e) => setEditYoutubeVideoId(e.target.value)}
                      className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                      placeholder="e.g. dQw4w9WgXcQ"
                    />
                  </div>
                ) : (
                  <div>
                    <label className="block text-xs font-bold text-gray-500">
                      Video File
                    </label>
                    <div className="mt-1">
                      <label className={`flex items-center justify-center w-full px-4 py-6 border-2 border-dashed rounded-md cursor-pointer transition-colors ${editSupabaseUploading ? "border-gray-200 bg-gray-50 cursor-not-allowed" : "border-violet-300 hover:border-violet-400 hover:bg-violet-50"}`}>
                        <div className="text-center">
                          {editSupabaseUploading ? (
                            <p className="text-xs text-gray-500 font-medium">Uploading…</p>
                          ) : editSupabaseVideoUrl ? (
                            <>
                              <p className="text-xs text-emerald-600 font-bold">✓ Uploaded</p>
                              <p className="text-[10px] text-gray-400 mt-0.5 break-all max-w-[180px]">{editSupabaseVideoUrl.split("/").pop()}</p>
                              <p className="text-[10px] text-violet-500 mt-1">Click to replace</p>
                            </>
                          ) : (
                            <>
                              <p className="text-xs text-gray-600 font-medium">Click to select video</p>
                              <p className="text-[10px] text-gray-400 mt-0.5">MP4, MOV, WebM — uploaded to Supabase</p>
                            </>
                          )}
                        </div>
                        <input
                          type="file"
                          accept="video/*"
                          className="hidden"
                          disabled={editSupabaseUploading}
                          onChange={(e) => {
                            const f = e.target.files?.[0];
                            if (f) handleVideoFileUpload(f, true);
                          }}
                        />
                      </label>
                    </div>
                  </div>
                )}
                <div className="flex items-center">
                  <input
                    id="editVideoIsFree"
                    type="checkbox"
                    checked={editVideoIsFree}
                    onChange={(e) => setEditVideoIsFree(e.target.checked)}
                    className="h-4 w-4 text-emerald-600 border-gray-300 rounded"
                  />
                  <label
                    htmlFor="editVideoIsFree"
                    className="ml-2 block text-xs font-bold text-gray-900"
                  >
                    Free video preview (visible to guests)
                  </label>
                </div>
                <div className="flex justify-end pt-2">
                  <button
                    type="submit"
                    disabled={editVideoSubmitting}
                    className="px-4 py-2 text-xs font-bold rounded-lg text-white bg-emerald-600 disabled:opacity-50"
                  >
                    {editVideoSubmitting ? "Saving..." : "Save Changes"}
                  </button>
                </div>
              </form>
            </div>
          )}

          {/* Program settings (default sidebar panel) */}
          {!showDayForm && !activeDayId && !editingVideo && (
            <div className="bg-white shadow rounded-lg border border-gray-100 p-6 space-y-4">
              <h3 className="font-bold text-gray-900 border-b border-gray-50 pb-2">
                Program Settings
              </h3>
              <form onSubmit={handleUpdateCourse} className="space-y-4">
                <div>
                  <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider">
                    Title
                  </label>
                  <input
                    type="text"
                    required
                    value={editTitle}
                    onChange={(e) => {
                      setEditTitle(e.target.value);
                      setEditSlug(
                        e.target.value
                          .toLowerCase()
                          .replace(/[^a-z0-9]+/g, "-")
                          .replace(/(^-|-$)/g, ""),
                      );
                    }}
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider">
                    Slug URL
                  </label>
                  <input
                    type="text"
                    required
                    value={editSlug}
                    onChange={(e) => setEditSlug(e.target.value)}
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider">
                    Category
                  </label>
                  <select
                    value={editCategory}
                    onChange={(e) => setEditCategory(e.target.value)}
                    className="mt-1 block w-full px-2 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                  >
                    <option value="yoga">Yoga</option>
                    <option value="general_exercise">General Workout</option>
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider">
                    Description
                  </label>
                  <textarea
                    value={editDesc}
                    onChange={(e) => setEditDesc(e.target.value)}
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                    rows={4}
                  />
                </div>
                <div className="grid grid-cols-3 gap-3">
                  <div>
                    <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider">
                      Price (₹ INR)
                    </label>
                    <input
                      type="number"
                      required
                      value={editPrice}
                      onChange={(e) => setEditPrice(e.target.value)}
                      className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider">
                      Price ($ USD)
                    </label>
                    <input
                      type="number"
                      value={editPriceUsd}
                      onChange={(e) => setEditPriceUsd(e.target.value)}
                      placeholder="Optional"
                      className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider">
                      Total Days
                    </label>
                    <input
                      type="number"
                      required
                      value={editTotalDays}
                      onChange={(e) => setEditTotalDays(e.target.value)}
                      className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                    />
                  </div>
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider">
                      WhatsApp Link
                    </label>
                    <input
                      type="text"
                      value={editWhatsapp}
                      onChange={(e) => setEditWhatsapp(e.target.value)}
                      placeholder="https://chat.whatsapp.com/..."
                      className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider">
                      Scheduled Start Date
                    </label>
                    <input
                      type="date"
                      value={editScheduledStart}
                      onChange={(e) => setEditScheduledStart(e.target.value)}
                      className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                    />
                    <p className="text-[10px] text-gray-400 mt-0.5">Leave blank for immediate access</p>
                  </div>
                </div>
                <div>
                  <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider">
                    Thumbnail Image URL
                  </label>
                  <input
                    type="text"
                    value={editThumbnail}
                    onChange={(e) => setEditThumbnail(e.target.value)}
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                    placeholder="https://..."
                  />
                </div>
                <div className="pt-2 border-t border-gray-100">
                  <p className="text-xs font-bold text-gray-500 uppercase tracking-wider mb-3">Instructor</p>
                  <div className="space-y-3">
                    <div className="grid grid-cols-2 gap-3">
                      <div>
                        <label className="block text-xs font-bold text-gray-500">Name</label>
                        <input
                          type="text"
                          value={editInstructorName}
                          onChange={(e) => setEditInstructorName(e.target.value)}
                          className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                          placeholder="e.g. Deepa"
                        />
                      </div>
                      <div>
                        <label className="block text-xs font-bold text-gray-500">Title</label>
                        <input
                          type="text"
                          value={editInstructorTitle}
                          onChange={(e) => setEditInstructorTitle(e.target.value)}
                          className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                          placeholder="e.g. Certified Yoga Instructor"
                        />
                      </div>
                    </div>
                    <div>
                      <label className="block text-xs font-bold text-gray-500">Bio</label>
                      <textarea
                        value={editInstructorBio}
                        onChange={(e) => setEditInstructorBio(e.target.value)}
                        className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                        rows={3}
                        placeholder="Short bio shown in the app when the instructor card is tapped…"
                      />
                    </div>
                    <div>
                      <label className="block text-xs font-bold text-gray-500">Photo URL</label>
                      <input
                        type="text"
                        value={editInstructorPhoto}
                        onChange={(e) => setEditInstructorPhoto(e.target.value)}
                        className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                        placeholder="https://..."
                      />
                    </div>
                  </div>
                </div>
                <div className="flex items-center">
                  <input
                    id="editPublished"
                    type="checkbox"
                    checked={editPublished}
                    onChange={(e) => setEditPublished(e.target.checked)}
                    className="h-4 w-4 text-emerald-600 border-gray-300 rounded focus:ring-emerald-500"
                  />
                  <label
                    htmlFor="editPublished"
                    className="ml-2 block text-xs font-bold text-gray-900"
                  >
                    Publish program immediately
                  </label>
                </div>
                <div className="flex justify-end space-x-2 pt-2 border-t border-gray-50">
                  <button
                    type="submit"
                    disabled={courseSubmitting}
                    className="px-4 py-2 text-xs font-bold rounded-lg text-white bg-emerald-600 disabled:opacity-50"
                  >
                    {courseSubmitting ? "Saving..." : "Save Settings"}
                  </button>
                </div>
              </form>
              <div className="pt-4 border-t border-gray-100 flex justify-between items-center">
                <div>
                  <h4 className="text-xs font-bold text-red-500 uppercase tracking-wider">
                    Danger Zone
                  </h4>
                  <p className="text-[10px] text-gray-400 mt-0.5">
                    Completely delete this course catalog.
                  </p>
                </div>
                <button
                  onClick={() => setShowDeleteConfirm(true)}
                  className="px-3 py-1.5 text-xs font-bold text-white bg-red-600 hover:bg-red-700 rounded-lg transition-colors"
                >
                  Delete Program
                </button>
              </div>
            </div>
          )}
        </div>
      </div>

      {/* Delete Confirmation Modal */}
      {showDeleteConfirm && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50">
          <div className="bg-white rounded-xl shadow-2xl max-w-md w-full overflow-hidden border border-gray-100">
            <div className="p-6 text-center space-y-4">
              <div className="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-red-100 text-red-600">
                <svg
                  className="h-6 w-6"
                  fill="none"
                  stroke="currentColor"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
                  />
                </svg>
              </div>
              <div>
                <h3 className="text-lg font-bold text-gray-900">
                  Delete Program
                </h3>
                <p className="text-sm text-gray-500 mt-2">
                  Are you sure you want to delete{" "}
                  <span className="font-semibold text-gray-800">
                    &quot;{course.title}&quot;
                  </span>
                  ? This will permanently delete the course, all associated
                  days, and all linked videos. This action cannot be undone.
                </p>
              </div>
              <div className="flex justify-center space-x-3 pt-2">
                <button
                  onClick={() => setShowDeleteConfirm(false)}
                  className="px-4 py-2 border border-gray-300 rounded-lg text-sm font-bold text-gray-700 hover:bg-gray-50 transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={handleDeleteCourse}
                  className="px-4 py-2 border border-transparent text-sm font-bold rounded-lg text-white bg-red-600 hover:bg-red-700 transition-colors shadow-sm"
                >
                  Delete Program
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
