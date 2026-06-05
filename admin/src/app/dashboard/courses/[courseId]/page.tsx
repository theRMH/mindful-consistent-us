'use client';

import { useEffect, useState, use } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';

interface Video {
  id: string;
  title: string;
  category: string;
  durationSeconds: number;
  bunnyVideoId: string;
  bunnyLibraryId: string;
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
  totalDays: number;
  priceInr: number;
  thumbnailUrl: string | null;
  isPublished: boolean;
  courseDays: CourseDay[];
}

export default function CourseBuilder({ params }: { params: Promise<{ courseId: string }> }) {
  const { courseId } = use(params);
  const router = useRouter();
  const [course, setCourse] = useState<Course | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  // Course Edit States
  const [editTitle, setEditTitle] = useState('');
  const [editSlug, setEditSlug] = useState('');
  const [editDesc, setEditDesc] = useState('');
  const [editPrice, setEditPrice] = useState('');
  const [editTotalDays, setEditTotalDays] = useState('');
  const [editThumbnail, setEditThumbnail] = useState('');
  const [editPublished, setEditPublished] = useState(false);
  const [courseSubmitting, setCourseSubmitting] = useState(false);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);

  // Day Form States
  const [showDayForm, setShowDayForm] = useState(false);
  const [dayNumber, setDayNumber] = useState('');
  const [dayTitle, setDayTitle] = useState('');
  const [dayDesc, setDayDesc] = useState('');
  const [daySubmitting, setDaySubmitting] = useState(false);

  // Video Form States
  const [activeDayId, setActiveDayId] = useState<string | null>(null);
  const [videoTitle, setVideoTitle] = useState('');
  const [videoCategory, setVideoCategory] = useState('yoga');
  const [videoDuration, setVideoDuration] = useState('1200');
  const [bunnyVideoId, setBunnyVideoId] = useState('');
  const [bunnyLibraryId, setBunnyLibraryId] = useState('mock_lib_123');
  const [isFree, setIsFree] = useState(false);
  const [videoSubmitting, setVideoSubmitting] = useState(false);

  const fetchCourseData = async () => {
    try {
      const res = await fetch(`/api/courses/${courseId}`);
      if (!res.ok) throw new Error('Failed to fetch course details');
      const data = await res.json();
      setCourse(data);
      // Initialize edit states
      setEditTitle(data.title);
      setEditSlug(data.slug);
      setEditDesc(data.description || '');
      setEditPrice(Number(data.priceInr).toString());
      setEditTotalDays(data.totalDays.toString());
      setEditThumbnail(data.thumbnailUrl || '');
      setEditPublished(data.isPublished);
      setLoading(false);
    } catch (err: any) {
      setError(err.message || 'Something went wrong');
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCourseData();
  }, [courseId]);

  const handleAddDay = async (e: React.FormEvent) => {
    e.preventDefault();
    if (daySubmitting) return;
    setError('');
    setDaySubmitting(true);
 
    try {
      const res = await fetch(`/api/courses/${courseId}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'add_day',
          dayNumber,
          title: dayTitle,
          description: dayDesc,
        }),
      });
 
      if (!res.ok) throw new Error('Failed to add course day');
       
      // Reset & Reload
      setShowDayForm(false);
      setDayNumber('');
      setDayTitle('');
      setDayDesc('');
      fetchCourseData();
    } catch (err: any) {
      setError(err.message);
    } finally {
      setDaySubmitting(false);
    }
  };
 
  const handleAddVideo = async (e: React.FormEvent) => {
    e.preventDefault();
    if (videoSubmitting) return;
    setError('');
    setVideoSubmitting(true);
 
    try {
      const res = await fetch(`/api/courses/${courseId}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'add_video',
          courseDayId: activeDayId,
          title: videoTitle,
          category: videoCategory,
          durationSeconds: videoDuration,
          bunnyVideoId,
          bunnyLibraryId,
          isFree,
        }),
      });
 
      if (!res.ok) throw new Error('Failed to link video');
 
      // Reset & Reload
      setActiveDayId(null);
      setVideoTitle('');
      setBunnyVideoId('');
      fetchCourseData();
    } catch (err: any) {
      setError(err.message);
    } finally {
      setVideoSubmitting(false);
    }
  };

  const handleUpdateCourse = async (e: React.FormEvent) => {
    e.preventDefault();
    if (courseSubmitting) return;
    setError('');
    setCourseSubmitting(true);

    try {
      const res = await fetch(`/api/courses/${courseId}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: editTitle,
          slug: editSlug,
          description: editDesc,
          priceInr: editPrice,
          totalDays: editTotalDays,
          isPublished: editPublished,
          thumbnailUrl: editThumbnail,
        }),
      });

      if (!res.ok) {
        const errData = await res.json();
        throw new Error(errData.error || 'Failed to update course details');
      }
      fetchCourseData();
    } catch (err: any) {
      setError(err.message);
    } finally {
      setCourseSubmitting(false);
    }
  };

  const handleDeleteCourse = async () => {
    try {
      const res = await fetch(`/api/courses/${courseId}`, {
        method: 'DELETE',
      });
      if (!res.ok) throw new Error('Failed to delete course');
      router.push('/dashboard/courses');
    } catch (err: any) {
      setError(err.message);
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
        {error || 'Course not found'}
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="flex items-center space-x-3">
        <Link href="/dashboard/courses" className="text-gray-500 hover:text-gray-700">
          <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10.5 19.5L3 12m0 0l7.5-7.5M3 12h18" />
          </svg>
        </Link>
        <div>
          <h2 className="text-2xl font-extrabold text-gray-900">{course.title}</h2>
          <p className="text-sm text-gray-500 mt-1">Manage day schedules, focus summaries, and linked videos.</p>
        </div>
      </div>

      <div className="grid grid-cols-1 gap-6 lg:grid-cols-3 items-start">
        {/* Days & Videos Manager List */}
        <div className="lg:col-span-2 space-y-6">
          <div className="flex justify-between items-center bg-gray-50 p-4 rounded-lg border border-gray-100">
            <h3 className="font-bold text-gray-800 text-lg">Program Days list</h3>
            <button
              onClick={() => setShowDayForm(true)}
              className="inline-flex items-center px-3 py-1.5 text-xs font-bold rounded-lg text-white bg-emerald-600 hover:bg-emerald-700 transition-colors"
            >
              Add Day
            </button>
          </div>

          {course.courseDays.length === 0 ? (
            <div className="p-12 border-2 border-dashed border-gray-200 rounded-lg text-center text-sm text-gray-400">
              No Days configured yet. Click "Add Day" to structure your program curriculum.
            </div>
          ) : (
            <div className="space-y-6">
              {course.courseDays.map((day) => (
                <div key={day.id} className="bg-white shadow rounded-lg border border-gray-100 overflow-hidden">
                  <div className="bg-gray-50/70 p-4 border-b border-gray-100 flex justify-between items-center">
                    <div>
                      <h4 className="font-extrabold text-gray-800">Day {day.dayNumber}: {day.title || 'Untitled Day'}</h4>
                      <p className="text-xs text-gray-500 mt-1">{day.description || 'No focus description set.'}</p>
                    </div>
                    <button
                      onClick={() => setActiveDayId(day.id)}
                      className="text-xs font-bold text-emerald-600 hover:text-emerald-700 hover:underline"
                    >
                      Link Video
                    </button>
                  </div>

                  {/* Day Videos */}
                  <div className="p-4 space-y-3">
                    {day.videos.length === 0 ? (
                      <div className="text-center py-6 text-xs text-gray-400 font-medium">
                        No videos linked for this day. Click "Link Video" to add sessions.
                      </div>
                    ) : (
                      day.videos.map((vid) => (
                        <div key={vid.id} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg text-sm border border-gray-100">
                          <div>
                            <div className="font-bold text-gray-800">{vid.title}</div>
                            <div className="text-xs text-gray-400 mt-0.5">
                              {vid.category} • {Math.round(vid.durationSeconds / 60)}Mins
                            </div>
                          </div>
                          <div className="flex items-center space-x-3">
                            <span className="text-xs text-gray-400 font-bold bg-white border border-gray-200 px-2 py-0.5 rounded">
                              Bunny: {vid.bunnyVideoId}
                            </span>
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
          {/* Add Day Box */}
          {showDayForm && (
            <div className="bg-white shadow rounded-lg border border-gray-100 p-6 space-y-4">
              <h3 className="font-bold text-gray-900 border-b border-gray-50 pb-2">Add Program Day</h3>
              <form onSubmit={handleAddDay} className="space-y-4">
                <div>
                  <label className="block text-xs font-bold text-gray-500">Day Number</label>
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
                  <label className="block text-xs font-bold text-gray-500">Day Title</label>
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
                  <label className="block text-xs font-bold text-gray-500">Description / Focus</label>
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
                    {daySubmitting ? 'Saving...' : 'Save Day'}
                  </button>
                </div>
              </form>
            </div>
          )}

          {/* Add Video Box */}
          {activeDayId && (
            <div className="bg-white shadow rounded-lg border border-gray-100 p-6 space-y-4">
              <h3 className="font-bold text-gray-900 border-b border-gray-50 pb-2">Link Session Video</h3>
              <form onSubmit={handleAddVideo} className="space-y-4">
                <div>
                  <label className="block text-xs font-bold text-gray-500">Video Title</label>
                  <input
                    type="text"
                    required
                    value={videoTitle}
                    onChange={(e) => setVideoTitle(e.target.value)}
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                    placeholder="e.g. Breath Flow alignment"
                  />
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-bold text-gray-500">Category</label>
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
                    <label className="block text-xs font-bold text-gray-500">Duration (Secs)</label>
                    <input
                      type="number"
                      required
                      value={videoDuration}
                      onChange={(e) => setVideoDuration(e.target.value)}
                      className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                    />
                  </div>
                </div>
                <div>
                  <label className="block text-xs font-bold text-gray-500">Bunny Video ID</label>
                  <input
                    type="text"
                    required
                    value={bunnyVideoId}
                    onChange={(e) => setBunnyVideoId(e.target.value)}
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-gray-500">Bunny Library ID</label>
                  <input
                    type="text"
                    required
                    value={bunnyLibraryId}
                    onChange={(e) => setBunnyLibraryId(e.target.value)}
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
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
                  <label htmlFor="isFreeVideo" className="ml-2 block text-xs font-bold text-gray-900">
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
                    {videoSubmitting ? 'Saving...' : 'Save Video'}
                  </button>
                </div>
              </form>
            </div>
          )}

          {/* Program settings (default sidebar panel) */}
          {!showDayForm && !activeDayId && (
            <div className="bg-white shadow rounded-lg border border-gray-100 p-6 space-y-4">
              <h3 className="font-bold text-gray-900 border-b border-gray-50 pb-2">Program Settings</h3>
              <form onSubmit={handleUpdateCourse} className="space-y-4">
                <div>
                  <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider">Title</label>
                  <input
                    type="text"
                    required
                    value={editTitle}
                    onChange={(e) => {
                      setEditTitle(e.target.value);
                      setEditSlug(e.target.value.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, ''));
                    }}
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider">Slug URL</label>
                  <input
                    type="text"
                    required
                    value={editSlug}
                    onChange={(e) => setEditSlug(e.target.value)}
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider">Description</label>
                  <textarea
                    value={editDesc}
                    onChange={(e) => setEditDesc(e.target.value)}
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                    rows={4}
                  />
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider">INR Price (₹)</label>
                    <input
                      type="number"
                      required
                      value={editPrice}
                      onChange={(e) => setEditPrice(e.target.value)}
                      className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider">Total Days</label>
                    <input
                      type="number"
                      required
                      value={editTotalDays}
                      onChange={(e) => setEditTotalDays(e.target.value)}
                      className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                    />
                  </div>
                </div>
                <div>
                  <label className="block text-xs font-bold text-gray-500 uppercase tracking-wider">Thumbnail Image URL</label>
                  <input
                    type="text"
                    value={editThumbnail}
                    onChange={(e) => setEditThumbnail(e.target.value)}
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm text-gray-900 bg-white"
                    placeholder="https://..."
                  />
                </div>
                <div className="flex items-center">
                  <input
                    id="editPublished"
                    type="checkbox"
                    checked={editPublished}
                    onChange={(e) => setEditPublished(e.target.checked)}
                    className="h-4 w-4 text-emerald-600 border-gray-300 rounded focus:ring-emerald-500"
                  />
                  <label htmlFor="editPublished" className="ml-2 block text-xs font-bold text-gray-900">
                    Publish program immediately
                  </label>
                </div>
                <div className="flex justify-end space-x-2 pt-2 border-t border-gray-50">
                  <button
                    type="submit"
                    disabled={courseSubmitting}
                    className="px-4 py-2 text-xs font-bold rounded-lg text-white bg-emerald-600 disabled:opacity-50"
                  >
                    {courseSubmitting ? 'Saving...' : 'Save Settings'}
                  </button>
                </div>
              </form>
              <div className="pt-4 border-t border-gray-100 flex justify-between items-center">
                <div>
                  <h4 className="text-xs font-bold text-red-500 uppercase tracking-wider">Danger Zone</h4>
                  <p className="text-[10px] text-gray-400 mt-0.5">Completely delete this course catalog.</p>
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
                <svg className="h-6 w-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                </svg>
              </div>
              <div>
                <h3 className="text-lg font-bold text-gray-900">Delete Program</h3>
                <p className="text-sm text-gray-500 mt-2">
                  Are you sure you want to delete <span className="font-semibold text-gray-800">"{course.title}"</span>? This will permanently delete the course, all associated days, and all linked videos. This action cannot be undone.
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
