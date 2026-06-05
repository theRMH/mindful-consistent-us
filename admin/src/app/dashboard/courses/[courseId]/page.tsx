'use client';

import { useEffect, useState, use } from 'react';
import Link from 'next/link';

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
  description: string;
  totalDays: number;
  priceInr: number;
  courseDays: CourseDay[];
}

export default function CourseBuilder({ params }: { params: Promise<{ courseId: string }> }) {
  const { courseId } = use(params);
  const [course, setCourse] = useState<Course | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  // Day Form States
  const [showDayForm, setShowDayForm] = useState(false);
  const [dayNumber, setDayNumber] = useState('');
  const [dayTitle, setDayTitle] = useState('');
  const [dayDesc, setDayDesc] = useState('');

  // Video Form States
  const [activeDayId, setActiveDayId] = useState<string | null>(null);
  const [videoTitle, setVideoTitle] = useState('');
  const [videoCategory, setVideoCategory] = useState('yoga');
  const [videoDuration, setVideoDuration] = useState('1200');
  const [bunnyVideoId, setBunnyVideoId] = useState('');
  const [bunnyLibraryId, setBunnyLibraryId] = useState('mock_lib_123');
  const [isFree, setIsFree] = useState(false);

  const fetchCourseData = async () => {
    try {
      const res = await fetch(`/api/courses/${courseId}`);
      if (!res.ok) throw new Error('Failed to fetch course details');
      const data = await res.json();
      setCourse(data);
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
    setError('');

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
    }
  };

  const handleAddVideo = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

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
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 19l-7-7m0 0l-7-7m7 7h18" />
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
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm"
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
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm"
                    placeholder="e.g. Spine Extension pose"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-gray-500">Description / Focus</label>
                  <textarea
                    value={dayDesc}
                    onChange={(e) => setDayDesc(e.target.value)}
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm"
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
                    className="px-3 py-1.5 text-xs font-bold rounded-lg text-white bg-emerald-600"
                  >
                    Save Day
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
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm"
                    placeholder="e.g. Breath Flow alignment"
                  />
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-bold text-gray-500">Category</label>
                    <select
                      value={videoCategory}
                      onChange={(e) => setVideoCategory(e.target.value)}
                      className="mt-1 block w-full px-2 py-1.5 border border-gray-300 rounded-md text-sm"
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
                      className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm"
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
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold text-gray-500">Bunny Library ID</label>
                  <input
                    type="text"
                    required
                    value={bunnyLibraryId}
                    onChange={(e) => setBunnyLibraryId(e.target.value)}
                    className="mt-1 block w-full px-3 py-1.5 border border-gray-300 rounded-md text-sm"
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
                    className="px-3 py-1.5 text-xs font-bold rounded-lg text-white bg-emerald-600"
                  >
                    Save Video
                  </button>
                </div>
              </form>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
